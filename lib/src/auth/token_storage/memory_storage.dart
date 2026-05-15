import '../token.dart';

/// In-memory [TokenStorage] implementation.
///
/// Suitable for short-lived processes (CLI, serverless).
/// For Flutter apps, use a persistent implementation like flutter_secure_storage.
class MemoryTokenStorage implements TokenStorage {
  Token? _token;

  @override
  Future<Token?> read() async => _token;

  @override
  Future<void> write(Token token) async => _token = token;

  @override
  Future<void> delete() async => _token = null;
}
