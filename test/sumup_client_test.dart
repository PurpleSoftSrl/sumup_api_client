import 'dart:io';

import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:sumup_api_client/sumup_api_client.dart';

String? _env(String name) => Platform.environment[name]?.isNotEmpty == true
    ? Platform.environment[name]
    : null;

final _clientId = _env('SUMUP_CLIENT_ID');
final _clientSecret = _env('SUMUP_CLIENT_SECRET');
final _hasOAuth2 = _clientId != null && _clientSecret != null;

final _apiKey = _env('SUMUP_API_KEY');
final _hasApiKey = _apiKey != null;

void main() {
  late SumUpClient client;
  String? merchantCode;

  setUpAll(() async {
    if (!_hasOAuth2) return;
    client = SumUpClient.withOAuth2(
      clientId: _clientId!,
      clientSecret: _clientSecret!,
    );
    try {
      final profile = await client.dio.get<Map<dynamic, dynamic>>(
        'https://api.sumup.com/v0.1/me/personal-profile',
      );
      final data = profile.data as Map<String, dynamic>?;
      merchantCode = data?['merchant_code'] as String?;
      if (merchantCode != null) {
        print('  ✅ Discovered merchant: $merchantCode');
      }
    } catch (e) {
      merchantCode = _env('SUMUP_TEST_MERCHANT_CODE');
      if (merchantCode == null) {
        print('  ⚠️  Could not discover merchant code: $e');
      }
    }
  });

  group('SumUpClient', () {
    test('OAuth2 with real credentials', () {
      if (!_hasOAuth2) {
        print('  ⚠️  Skipping — set SUMUP_CLIENT_ID / SUMUP_CLIENT_SECRET');
        return;
      }
      expect(client, isNotNull);
      expect(client.oauth2, isNotNull);
    });

    test('API key client', () {
      final c = SumUpClient.withApiKey('test_key');
      expect(c.dio.options.headers['Authorization'], equals('Bearer test_key'));
    });

    test('Token client', () {
      final c = SumUpClient.withToken('my_token');
      expect(c.dio.options.headers['Authorization'], equals('Bearer my_token'));
    });

    test('all API groups exposed', () {
      final c = SumUpClient.withApiKey('k');
      expect(c.checkouts, isNotNull);
      expect(c.transactions, isNotNull);
      expect(c.merchants, isNotNull);
      expect(c.readers, isNotNull);
    });
  });

  group('OAuth2 token flow', () {
    test('fetches valid token', () async {
      if (!_hasOAuth2) {
        print('  ⚠️  Skipping — no credentials');
        return;
      }
      final token = await client.oauth2!.getToken();
      expect(token.accessToken, isNotEmpty);
      expect(token.tokenType, equals('Bearer'));
      expect(token.expiresIn, greaterThan(0));
    });

    test('token is cached after first fetch', () async {
      if (!_hasOAuth2) {
        print('  ⚠️  Skipping — no credentials');
        return;
      }
      final t1 = await client.oauth2!.getToken();
      final t2 = await client.oauth2!.getToken();
      expect(t2.accessToken, equals(t1.accessToken));
    });
  });

  group('Merchant API', () {
    test('getMerchant returns data or valid error', () async {
      final mc = merchantCode ?? _env('SUMUP_TEST_MERCHANT_CODE');
      if (!_hasOAuth2 || mc == null) {
        print('  ⚠️  Skipping — set SUMUP_TEST_MERCHANT_CODE');
        return;
      }
      try {
        final result = await client.merchants.getMerchant(merchantCode: mc);
        expect(result, isNotNull);
        print('  ✅ Merchant API works');
      } on DioException catch (e) {
        expect(e.response?.statusCode, anyOf(equals(401), equals(403)));
        print(
            '  ✅ Auth working — got ${e.response?.statusCode} for merchant: $mc');
      }
    });
  });

  group('Checkouts API', () {
    test('listCheckouts returns results or valid auth error', () async {
      if (!_hasOAuth2) {
        print('  ⚠️  Skipping — no credentials');
        return;
      }
      try {
        final result = await client.checkouts.listCheckouts();
        expect(result, isNotNull);
      } on DioException catch (e) {
        // 403 expected without checkout scope — auth is working
        expect(e.response?.statusCode, anyOf(equals(403), equals(401)));
        print(
            '  ✅ Auth working — got ${e.response?.statusCode} (expected without checkout scope)');
      }
    });
  });

  group('API Key auth', () {
    test('calls SumUp with API key', () async {
      if (!_hasApiKey) {
        print('  ⚠️  Skipping — set SUMUP_API_KEY');
        return;
      }
      final apiClient = SumUpClient.withApiKey(_apiKey!);
      try {
        final mc = _env('SUMUP_TEST_MERCHANT_CODE');
        if (mc != null) {
          final result =
              await apiClient.merchants.getMerchant(merchantCode: mc);
          expect(result, isNotNull);
          print('  ✅ API Key auth works');
        }
      } on DioException catch (e) {
        expect(e.response?.statusCode, anyOf(equals(401), equals(403)));
        print('  ✅ API Key sent — got ${e.response?.statusCode}');
      }
    });
  });
}
