import 'package:dio/dio.dart';

import 'auth/oauth2_manager.dart';
import 'auth/token.dart';
import 'auth/token_storage/memory_storage.dart';
import 'core/rate_limiter.dart';
import 'core/retry.dart';
import 'generated/api/api_client.dart';
import 'generated/api/checkouts_api.dart';
import 'generated/api/customers_api.dart';
import 'generated/api/members_api.dart';
import 'generated/api/memberships_api.dart';
import 'generated/api/merchants_api.dart';
import 'generated/api/payouts_api.dart';
import 'generated/api/readers_api.dart';
import 'generated/api/receipts_api.dart';
import 'generated/api/roles_api.dart';
import 'generated/api/transactions_api.dart';

/// Enterprise-ready SumUp REST API client.
///
/// Creates and configures a [Dio] HTTP client with OAuth2 authentication,
/// automatic token management, rate limiting, retry, and response caching.
///
/// ```dart
/// // OAuth2 (recommended)
/// final client = await SumUpClient.withOAuth2(
///   clientId: 'xxx',
///   clientSecret: 'xxx',
/// );
///
/// // API Key (legacy)
/// final client = SumUpClient.withApiKey('sup_sk_xxx');
///
/// // Personal Token
/// final client = SumUpClient.withToken('tkn_xxx');
/// ```
class SumUpClient {
  final ApiClient _api;
  final OAuth2Manager? _oauth2;

  SumUpClient._(this._api, this._oauth2);

  // ── Factory constructors ──────────────────────────────────

  /// Creates a client with OAuth2 client_credentials auth.
  ///
  /// Token is fetched on first request and automatically refreshed.
  factory SumUpClient.withOAuth2({
    required String clientId,
    required String clientSecret,
    String tokenUrl = 'https://api.sumup.com/token',
    String baseUrl = 'https://api.sumup.com',
    TokenStorage? tokenStorage,
    bool enableRateLimiting = true,
    bool enableRetry = true,
    int maxRetries = 3,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    List<Interceptor>? extraInterceptors,
  }) {
    final dio = _createDio(
      baseUrl: baseUrl,
      enableRateLimiting: enableRateLimiting,
      enableRetry: enableRetry,
      maxRetries: maxRetries,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      extraInterceptors: extraInterceptors,
    );

    final storage = tokenStorage ?? MemoryTokenStorage();
    final oauth2 = OAuth2Manager(
      clientId: clientId,
      clientSecret: clientSecret,
      tokenUrl: tokenUrl,
      storage: storage,
      dio: Dio(),  // separate Dio for token requests
    );

    dio.interceptors.add(oauth2.createInterceptor());

    final api = ApiClient(dio: dio, baseUrl: baseUrl);
    return SumUpClient._(api, oauth2);
  }

  /// Creates a client with API Key authentication (legacy).
  factory SumUpClient.withApiKey(
    String apiKey, {
    String baseUrl = 'https://api.sumup.com',
    bool enableRateLimiting = true,
    bool enableRetry = true,
    int maxRetries = 3,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    List<Interceptor>? extraInterceptors,
  }) {
    final dio = _createDio(
      baseUrl: baseUrl,
      enableRateLimiting: enableRateLimiting,
      enableRetry: enableRetry,
      maxRetries: maxRetries,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      extraInterceptors: extraInterceptors,
    );

    dio.options.headers['Authorization'] = 'Bearer $apiKey';

    final api = ApiClient(dio: dio, baseUrl: baseUrl);
    return SumUpClient._(api, null);
  }

  /// Creates a client with a static Personal Access Token.
  factory SumUpClient.withToken(
    String token, {
    String baseUrl = 'https://api.sumup.com',
    bool enableRateLimiting = true,
    bool enableRetry = true,
    int maxRetries = 3,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    List<Interceptor>? extraInterceptors,
  }) {
    final dio = _createDio(
      baseUrl: baseUrl,
      enableRateLimiting: enableRateLimiting,
      enableRetry: enableRetry,
      maxRetries: maxRetries,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      extraInterceptors: extraInterceptors,
    );

    dio.options.headers['Authorization'] = 'Bearer $token';

    final api = ApiClient(dio: dio, baseUrl: baseUrl);
    return SumUpClient._(api, null);
  }

  // ── API groups ────────────────────────────────────────────

  CheckoutsApi get checkouts => _api.checkouts;
  CustomersApi get customers => _api.customers;
  TransactionsApi get transactions => _api.transactions;
  PayoutsApi get payouts => _api.payouts;
  ReceiptsApi get receipts => _api.receipts;
  MembershipsApi get memberships => _api.memberships;
  MembersApi get members => _api.members;
  RolesApi get roles => _api.roles;
  MerchantsApi get merchants => _api.merchants;
  ReadersApi get readers => _api.readers;

  /// Returns the underlying [Dio] instance for custom configuration.
  Dio get dio => _api.dio;

  /// Returns the underlying [ApiClient] for advanced usage.
  ApiClient get api => _api;

  /// Returns the [OAuth2Manager] if using OAuth2, null otherwise.
  OAuth2Manager? get oauth2 => _oauth2;

  // ── Private helpers ────────────────────────────────────────

  static Dio _createDio({
    required String baseUrl,
    required bool enableRateLimiting,
    required bool enableRetry,
    required int maxRetries,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    List<Interceptor>? extraInterceptors,
  }) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout ?? const Duration(seconds: 30),
      receiveTimeout: receiveTimeout ?? const Duration(seconds: 60),
      contentType: Headers.jsonContentType,
    ));

    if (enableRateLimiting) {
      dio.interceptors.add(RateLimitInterceptor());
    }
    if (enableRetry) {
      dio.interceptors.add(RetryInterceptor(maxRetries: maxRetries));
    }
    if (extraInterceptors != null) {
      dio.interceptors.addAll(extraInterceptors);
    }

    return dio;
  }
}
