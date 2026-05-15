import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:mcache_dart/mcache_dart.dart';

import 'token.dart';
import 'token_storage/memory_storage.dart';

class OAuth2Manager {
  final String clientId;
  final String clientSecret;
  final String tokenUrl;
  final TokenStorage _storage;
  final MemoryCache _tokenCache;
  final Dio _dio;

  static const _tokenCacheKey = 'sumup_oauth2_token';

  OAuth2Manager({
    required this.clientId,
    required this.clientSecret,
    this.tokenUrl = 'https://api.sumup.com/token',
    TokenStorage? storage,
    MemoryCache? cache,
    Dio? dio,
  })  : _storage = storage ?? MemoryTokenStorage(),
        _tokenCache = cache ?? MemoryCache(),
        _dio = dio ?? Dio();

  /// Fetches a new token from SumUp OAuth2 endpoint.
  Future<Token> fetchToken() async {
    final response = await _dio.post<Map<String, dynamic>>(
      tokenUrl,
      data: {
        'grant_type': 'client_credentials',
        'client_id': clientId,
        'client_secret': clientSecret,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    if (response.statusCode != 200) {
      throw TokenException(
        'Failed to fetch token',
        statusCode: response.statusCode,
        response: response.data,
      );
    }

    final data = response.data is String
        ? jsonDecode(response.data as String)
        : response.data as Map<String, dynamic>;

    final token = Token(
      accessToken: data['access_token'] as String,
      tokenType: (data['token_type'] as String?) ?? 'Bearer',
      expiresIn: (data['expires_in'] as num).toInt(),
      scope: (data['scope'] as String?)?.split(' '),
      refreshToken: data['refresh_token'] as String?,
    );

    // Cache in both mcache_dart (fast in-memory) and persistent storage
    _tokenCache.set(
      _tokenCacheKey,
      token,
      MemoryCacheEntryOptions()
        ..absoluteExpirationRelativeToNow = Duration(seconds: token.expiresIn),
    );
    await _storage.write(token);

    return token;
  }

  /// Returns a valid token, reusing cached or fetching a new one.
  Future<Token> getToken() async {
    // Fast path: mcache_dart in-memory cache
    if (_tokenCache.tryGet(_tokenCacheKey, (v) => v as Token)) {
      final cached = _tokenCache.get(_tokenCacheKey);
      if (cached is Token && !cached.isExpired) return cached;
      _tokenCache.remove(_tokenCacheKey);
    }

    // Fallback: persistent storage
    final stored = await _storage.read();
    if (stored != null && !stored.isExpired) {
      _tokenCache.set(
        _tokenCacheKey,
        stored,
        MemoryCacheEntryOptions()
          ..absoluteExpirationRelativeToNow =
              Duration(seconds: stored.expiresIn),
      );
      return stored;
    }

    return fetchToken();
  }

  /// Forces a new token to be fetched, invalidating any cached token.
  Future<Token> refreshToken() async {
    _tokenCache.remove(_tokenCacheKey);
    await _storage.delete();
    return fetchToken();
  }

  /// Creates a Dio interceptor that automatically adds the Bearer token.
  Interceptor createInterceptor() => _OAuth2Interceptor(this);
}

class _OAuth2Interceptor extends Interceptor {
  final OAuth2Manager _manager;

  _OAuth2Interceptor(this._manager);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _manager.getToken();
    options.headers['Authorization'] = token.authorizationHeader;
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        final token = await _manager.refreshToken();
        final opts = err.requestOptions;
        opts.headers['Authorization'] = token.authorizationHeader;
        final response = await Dio().fetch<dynamic>(opts);
        handler.resolve(response);
        return;
      } catch (_) {}
    }
    handler.next(err);
  }
}
