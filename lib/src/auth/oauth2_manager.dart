import 'dart:convert';

import 'package:dio/dio.dart';

import 'token.dart';
import 'token_storage/memory_storage.dart';

class OAuth2Manager {
  final String clientId;
  final String clientSecret;
  final String tokenUrl;
  final TokenStorage _storage;
  final Dio _dio;

  OAuth2Manager({
    required this.clientId,
    required this.clientSecret,
    this.tokenUrl = 'https://api.sumup.com/token',
    TokenStorage? storage,
    Dio? dio,
  })  : _storage = storage ?? MemoryTokenStorage(),
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

    await _storage.write(token);
    return token;
  }

  /// Returns a valid token, reusing cached or fetching a new one.
  Future<Token> getToken() async {
    final cached = await _storage.read();
    if (cached != null && !cached.isExpired) return cached;

    try {
      return await fetchToken();
    } catch (_) {
      await _storage.delete();
      rethrow;
    }
  }

  /// Forces a new token to be fetched, invalidating any cached token.
  Future<Token> refreshToken() async {
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
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
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
