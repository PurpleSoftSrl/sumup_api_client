import 'package:test/test.dart';
import 'package:sumup_api_client/src/auth/token.dart';
import 'package:sumup_api_client/src/auth/token_storage/memory_storage.dart';

void main() {
  group('Token', () {
    test('parses from OAuth2 response', () {
      final token = Token(
        accessToken: 'tok_abc123',
        tokenType: 'Bearer',
        expiresIn: 3600,
        scope: ['read', 'write'],
      );

      expect(token.accessToken, equals('tok_abc123'));
      expect(token.tokenType, equals('Bearer'));
      expect(token.expiresIn, equals(3600));
      expect(token.scope, equals(['read', 'write']));
      expect(token.isExpired, isFalse);
      expect(token.authorizationHeader, equals('Bearer tok_abc123'));
    });

    test('isExpired returns false for fresh token', () {
      final token = Token(
        accessToken: 'tok',
        expiresIn: 3600,
      );
      expect(token.isExpired, isFalse);
    });

    test('default tokenType is Bearer', () {
      final token = Token(
        accessToken: 'tok',
        expiresIn: 3600,
      );
      expect(token.tokenType, equals('Bearer'));
    });
  });

  group('MemoryTokenStorage', () {
    test('read returns null when empty', () async {
      final storage = MemoryTokenStorage();
      expect(await storage.read(), isNull);
    });

    test('write and read round-trips', () async {
      final storage = MemoryTokenStorage();
      final token = Token(accessToken: 'tok', expiresIn: 3600);

      await storage.write(token);
      final read = await storage.read();

      expect(read?.accessToken, equals('tok'));
    });

    test('delete clears stored token', () async {
      final storage = MemoryTokenStorage();
      await storage.write(Token(accessToken: 'tok', expiresIn: 3600));
      await storage.delete();
      expect(await storage.read(), isNull);
    });

    test('write overwrites previous token', () async {
      final storage = MemoryTokenStorage();
      await storage.write(Token(accessToken: 'old', expiresIn: 3600));
      await storage.write(Token(accessToken: 'new', expiresIn: 7200));

      final read = await storage.read();
      expect(read?.accessToken, equals('new'));
    });
  });
}
