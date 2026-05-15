import 'dart:io';

import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:sumup_api_client/src/core/rate_limiter.dart';
import 'package:sumup_api_client/src/core/retry.dart';

void main() {
  group('RetryInterceptor', () {
    test('retries on 500', () async {
      int requestCount = 0;
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) {
        requestCount++;
        request.response.statusCode = 500;
        request.response.write('{}');
        request.response.close();
      });

      final dio = Dio(BaseOptions(
        baseUrl: 'http://localhost:${server.port}',
        connectTimeout: const Duration(milliseconds: 500),
        receiveTimeout: const Duration(milliseconds: 500),
      ));
      dio.interceptors.add(RetryInterceptor(maxRetries: 2, baseDelay: const Duration(milliseconds: 10)));

      try { await dio.get<dynamic>('/test'); } catch (_) {}
      await server.close();

      // original + retries on 500 (retry uses new Dio().fetch, counted separately)
      expect(requestCount, greaterThanOrEqualTo(2));
    });

    test('stops retrying on 200', () async {
      int attempts = 0;
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) {
        attempts++;
        if (attempts < 2) {
          request.response.statusCode = 500;
        } else {
          request.response.statusCode = 200;
        }
        request.response.write('{}');
        request.response.close();
      });

      final dio = Dio(BaseOptions(
        baseUrl: 'http://localhost:${server.port}',
        connectTimeout: const Duration(milliseconds: 500),
        receiveTimeout: const Duration(milliseconds: 500),
      ));
      dio.interceptors.add(RetryInterceptor(maxRetries: 3, baseDelay: const Duration(milliseconds: 10)));

      final response = await dio.get<dynamic>('/test');
      await server.close();

      expect(response.statusCode, equals(200));
      expect(attempts, equals(2));
    });

    test('does not retry on 400', () async {
      int requestCount = 0;
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) {
        requestCount++;
        request.response.statusCode = 400;
        request.response.write('{}');
        request.response.close();
      });

      final dio = Dio(BaseOptions(
        baseUrl: 'http://localhost:${server.port}',
        connectTimeout: const Duration(milliseconds: 500),
        receiveTimeout: const Duration(milliseconds: 500),
      ));
      dio.interceptors.add(RetryInterceptor(maxRetries: 3, baseDelay: const Duration(milliseconds: 10)));

      try { await dio.get<dynamic>('/test'); } catch (_) {}
      await server.close();
      expect(requestCount, equals(1));
    });
  });

  group('RateLimitInterceptor', () {
    test('retries on 429 with success', () async {
      int attempts = 0;
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) {
        attempts++;
        if (attempts < 2) {
          request.response.headers.set('Retry-After', '0');
          request.response.statusCode = 429;
        } else {
          request.response.statusCode = 200;
        }
        request.response.write('{}');
        request.response.close();
      });

      final dio = Dio(BaseOptions(
        baseUrl: 'http://localhost:${server.port}',
        connectTimeout: const Duration(milliseconds: 500),
        receiveTimeout: const Duration(milliseconds: 500),
      ));
      dio.interceptors.add(RateLimitInterceptor(maxRetries: 3, baseDelay: const Duration(milliseconds: 10)));

      final response = await dio.get<dynamic>('/test');
      await server.close();

      expect(response.statusCode, equals(200));
      expect(attempts, equals(2));
    });
  });
}
