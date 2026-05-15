import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';

/// A Dio interceptor that queues requests and applies exponential backoff
/// when a 429 (Too Many Requests) response is received.
class RateLimitInterceptor extends Interceptor {
  final int _maxRetries;
  final Duration _baseDelay;
  final Random _random = Random();

  RateLimitInterceptor(
      {int maxRetries = 5, Duration baseDelay = const Duration(seconds: 1)})
      : _maxRetries = maxRetries,
        _baseDelay = baseDelay;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 429 || _maxRetries <= 0) {
      handler.next(err);
      return;
    }

    var retries = 0;
    while (retries < _maxRetries) {
      final retryAfter =
          _parseRetryAfter(err.response?.headers.value('Retry-After'));
      final delay = retryAfter ??
          _baseDelay * pow(2, retries) +
              Duration(milliseconds: _random.nextInt(500));

      await Future<void>.delayed(delay);
      retries++;

      try {
        final opts = err.requestOptions;
        final response = await Dio().fetch<dynamic>(opts);
        handler.resolve(response);
        return;
      } catch (e) {
        if (e is DioException && e.response?.statusCode != 429) {
          handler.next(e);
          return;
        }
      }
    }
    handler.next(err);
  }

  Duration? _parseRetryAfter(String? header) {
    if (header == null) return null;
    final seconds = int.tryParse(header);
    if (seconds != null) return Duration(seconds: seconds);
    return null;
  }
}
