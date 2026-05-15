import 'package:clock/clock.dart';

class Token {
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final List<String>? scope;
  final String? refreshToken;
  final DateTime obtainedAt;

  Token({
    required this.accessToken,
    this.tokenType = 'Bearer',
    required this.expiresIn,
    this.scope,
    this.refreshToken,
    DateTime? obtainedAt,
  }) : obtainedAt = obtainedAt ?? clock.now();

  bool get isExpired {
    final expiresAt = obtainedAt.add(Duration(seconds: expiresIn));
    return clock.now().isAfter(expiresAt.subtract(const Duration(seconds: 30)));
  }

  String get authorizationHeader => '$tokenType $accessToken';
}

abstract class TokenStorage {
  Future<Token?> read();
  Future<void> write(Token token);
  Future<void> delete();
}

class TokenException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic response;

  const TokenException(this.message, {this.statusCode, this.response});

  @override
  String toString() => 'TokenException: $message';
}
