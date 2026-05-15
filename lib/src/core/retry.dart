import 'dart:math';
import 'package:dio/dio.dart';

/// Retries failed requests with exponential backoff.
class RetryInterceptor extends Interceptor {
  final int _maxRetries;
  final Duration _baseDelay;
  final bool _retryOn5xx;
  final Random _random = Random();

  RetryInterceptor({
    int maxRetries = 3,
    Duration baseDelay = const Duration(seconds: 1),
    bool retryOn5xx = true,
  })  : _maxRetries = maxRetries,
        _baseDelay = baseDelay,
        _retryOn5xx = retryOn5xx;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final shouldRetry = err.response?.statusCode == 429 ||
        (_retryOn5xx &&
            err.response?.statusCode != null &&
            err.response!.statusCode! >= 500 &&
            err.response!.statusCode! < 600) ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout;

    if (!shouldRetry || _maxRetries <= 0) {
      handler.next(err);
      return;
    }

    var retries = 0;
    while (retries < _maxRetries) {
      final delay = _baseDelay * pow(2, retries) +
          Duration(milliseconds: _random.nextInt(500));
      await Future<void>.delayed(delay);
      retries++;

      try {
        final opts = err.requestOptions;
        final response = await Dio().fetch<dynamic>(opts);
        handler.resolve(response);
        return;
      } catch (e) {
        if (e is DioException &&
            e.type != DioExceptionType.connectionTimeout &&
            e.type != DioExceptionType.receiveTimeout) {
          handler.next(e);
          return;
        }
      }
    }
    handler.next(err);
  }
}
