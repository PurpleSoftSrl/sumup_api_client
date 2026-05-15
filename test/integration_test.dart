import 'dart:io';
import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:sumup_api_client/sumup_api_client.dart';

String? _e(String n) => Platform.environment[n]?.isNotEmpty == true ? Platform.environment[n] : null;
final _key = _e('SUMUP_API_KEY');
final _mc = _e('SUMUP_TEST_MERCHANT_CODE');
bool get _ok => _key != null && _mc != null;
SumUpClient? _c;

void main() {
  setUpAll(() { if (!_ok) return; _c = SumUpClient.withApiKey(_key!); });

  void testApi(String name, Future<void> Function() fn, {bool skip = false}) {
    test(name, () async {
      if (!_ok || skip) return print('  ⚠️  Skip — $name');
      try { await fn(); print('  ✅ $name'); }
      on DioException catch (e) { print('  ⚠️  $name — HTTP ${e.response?.statusCode}'); }
    });
  }

  group('Merchant', () {
    testApi('me/merchant-profile', () async {
      final r = await _c!.dio.get<Map<dynamic, dynamic>>('/v0.1/me/merchant-profile');
      expect(r.data, isNotNull);
    });
  });

  group('Checkouts', () {
    testApi('createCheckout', () async {
      final ref = 'dart-test-${DateTime.now().millisecondsSinceEpoch}';
      final r = await _c!.dio.post<Map<dynamic, dynamic>>('/v0.1/checkouts', data: {
        'checkout_reference': ref,
        'amount': 1.0,
        'currency': 'EUR',
        'merchant_code': _mc,
      });
      final d = r.data!;
      expect(d['status'], equals('PENDING'));
      expect(d['merchant_code'], equals(_mc));
      expect(d['id'], isNotEmpty);
    });

    testApi('listCheckouts with query', () async {
      final r = await _c!.dio.get<dynamic>('/v0.1/checkouts', queryParameters: {
        'checkout_reference': 'CO7464ddddddd53-1586014691',
      });
      expect(r.data, isA<List<dynamic>>());
    });
  });

  group('Transactions', () {
    testApi('listTransactions has items', () async {
      final r = await _c!.dio.get<Map<dynamic, dynamic>>('/v2.1/merchants/$_mc/transactions/history');
      final data = r.data;
      expect(data, isNotNull);
      final items = data!['items'];
      expect(items, isNotNull);
    });
  });

  group('Readers', () {
    testApi('listReaders has paired reader', () async {
      final r = await _c!.dio.get<Map<dynamic, dynamic>>('/v0.1/merchants/$_mc/readers');
      final items = r.data!['items'] as List;
      expect(items.length, greaterThanOrEqualTo(1));
      final rd = items.first as Map;
      expect(rd['status'], equals('paired'));
      expect(rd['device']['model'], equals('solo'));
    });
  });

  group('Members', () {
    testApi('listMembers has data', () async {
      final r = await _c!.dio.get<Map<dynamic, dynamic>>('/v0.1/merchants/$_mc/members');
      final items = r.data!['items'] as List;
      expect(items.isNotEmpty, isTrue);
      final m = items.first as Map;
      expect(m['id'], isNotEmpty);
    });
  });

  group('Roles', () {
    testApi('listRoles has Admin', () async {
      final r = await _c!.dio.get<Map<dynamic, dynamic>>('/v0.1/merchants/$_mc/roles');
      final items = r.data!['items'] as List;
      expect(items.isNotEmpty, isTrue);
      final admin = items.cast<Map<dynamic, dynamic>>().firstWhere((r) => r['name'] == 'Admin');
      expect(admin['is_predefined'], isTrue);
    });
  });

  group('Profile', () {
    testApi('me returns profile', () async {
      final r = await _c!.dio.get<Map<dynamic, dynamic>>('/v0.1/me');
      final d = r.data!;
      expect(d['account']['username'], equals('purplesoft@sumup.com'));
      expect(d['personal_profile']['first_name'], equals('James'));
    });
  });

  group('Customers', () {
    testApi('createCustomer', () async {
      final r = await _c!.dio.post<Map<dynamic, dynamic>>('/v0.1/customers', data: {
        'customer_id': 'dart-test-cust-001',
        'personal_details': {'first_name': 'James', 'last_name': 'Bond', 'email': 'purplesoft@sumup.com'},
      });
      expect(r.data!['customer_id'], equals('dart-test-cust-001'));
    });

    testApi('getCustomer', () async {
      final r = await _c!.dio.get<Map<dynamic, dynamic>>('/v0.1/customers/dart-test-cust-001');
      final d = r.data!;
      expect(d['customer_id'], equals('dart-test-cust-001'));
      expect(d['personal_details']['first_name'], equals('James'));
    });
  });

  group('Transaction detail', () {
    testApi('getTransaction by id', () async {
      // First get a transaction ID from history
      final hist = await _c!.dio.get<Map<dynamic, dynamic>>('/v2.1/merchants/$_mc/transactions/history');
      final txId = (hist.data!['items'] as List).first['id'] as String;
      // Then fetch it by ID
      final r = await _c!.dio.get<Map<dynamic, dynamic>>('/v2.1/merchants/$_mc/transactions', queryParameters: {'id': txId});
      final d = r.data!;
      expect(d['id'], equals(txId));
      expect(d['currency'], equals('EUR'));
      expect(d['merchant_code'], equals(_mc));
      expect(d['card']['type'], isNotEmpty);
    });
  });

  group('Reader detail', () {
    testApi('getReaderStatus', () async {
      final r = await _c!.dio.get<Map<dynamic, dynamic>>(
        '/v0.1/merchants/$_mc/readers/rdr_5HPCVA8X1B8ZYVPPHR773GF6FM/status');
      final data = r.data!['data'] as Map<dynamic, dynamic>;
      expect(data['status'], isNotEmpty);
      expect(data['battery_level'], isA<num>());
      expect(data['firmware_version'], isNotEmpty);
    });
  });

  group('Checkout detail', () {
    testApi('getCheckout by id', () async {
      final r = await _c!.dio.get<Map<dynamic, dynamic>>(
        '/v0.1/checkouts/62d303db-3660-4999-bf82-6ea598947e69');
      final d = r.data!;
      expect(d['id'], equals('62d303db-3660-4999-bf82-6ea598947e69'));
      expect(d['status'], isNotEmpty);
    });
  });
}
