import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:sumup_api_client/src/auth/oauth2_manager.dart';
import 'package:sumup_api_client/src/auth/token.dart';

class FakeTokenStorage implements TokenStorage {
  Token? _token;
  int readCount = 0;
  int writeCount = 0;
  int deleteCount = 0;

  @override
  Future<Token?> read() async {
    readCount++;
    return _token;
  }

  @override
  Future<void> write(Token token) async {
    writeCount++;
    _token = token;
  }

  @override
  Future<void> delete() async {
    deleteCount++;
    _token = null;
  }
}

class MockInterceptorHandler extends Interceptor {
  final List<Map<String, dynamic>> requests = [];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    requests.add({
      'headers': Map.of(options.headers),
      'path': options.path,
    });
    handler.next(options);
  }
}

void main() {
  late FakeTokenStorage storage;

  setUp(() {
    storage = FakeTokenStorage();
  });

  group('OAuth2Manager', () {
    test('creates with custom tokenUrl', () {
      final manager = OAuth2Manager(
        clientId: 'test-id',
        clientSecret: 'test-secret',
        tokenUrl: 'https://custom.sumup.com/token',
        storage: storage,
      );
      expect(manager.clientId, equals('test-id'));
      expect(manager.tokenUrl, equals('https://custom.sumup.com/token'));
    });

    test('defaults to https://api.sumup.com/token', () {
      final manager = OAuth2Manager(
        clientId: 'test-id',
        clientSecret: 'test-secret',
        storage: storage,
      );
      expect(manager.tokenUrl, equals('https://api.sumup.com/token'));
    });

    test('getToken uses cached token when not expired', () async {
      final token = Token(accessToken: 'cached', expiresIn: 3600);
      await storage.write(token);

      final manager = OAuth2Manager(
        clientId: 'id',
        clientSecret: 'secret',
        storage: storage,
      );

      final result = await manager.getToken();
      expect(result.accessToken, equals('cached'));
      expect(storage.readCount, greaterThanOrEqualTo(1));
    });

    test('refreshToken deletes cache', () async {
      await storage.write(Token(accessToken: 'old', expiresIn: 3600));
      print('  ⚠️  Skipping refreshToken test — requires real SumUp endpoint');
    }, skip: true);

    test('createInterceptor generates interceptor', () {
      OAuth2Manager(
        clientId: 'id',
        clientSecret: 'secret',
        storage: storage,
      ).createInterceptor();
    });
  });

  group('TokenException', () {
    test('formats message', () {
      final ex = TokenException('auth failed', statusCode: 401);
      expect(ex.message, equals('auth failed'));
      expect(ex.statusCode, equals(401));
      expect(ex.toString(), contains('auth failed'));
    });
  });
}
