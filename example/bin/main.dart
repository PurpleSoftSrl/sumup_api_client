/// SumUp API Client — Enterprise CLI Example
///
/// Usage:
///   dart run example/bin/main.dart <command>
///
/// Environment:
///   SUMUP_API_KEY        API key
///   SUMUP_MERCHANT_CODE  Merchant code
///
/// Commands:
///   dashboard    — KPIs overview (tx count, paired readers)
///   transactions — List recent transactions (table)
///   checkouts    — List checkouts with status (table)
///   readers      — List paired readers (table)
///   help         — This help
library sumup_example;

import 'dart:io';
import 'package:sumup_api_client/sumup_api_client.dart' show SumUpClient;

void main(List<String> args) async {
  final cmd = args.isNotEmpty ? args[0] : 'help';
  final apiKey = Platform.environment['SUMUP_API_KEY'] ?? '';
  final mc = Platform.environment['SUMUP_MERCHANT_CODE'] ?? '';

  if (cmd == 'help') {
    stdout.writeln('\nSumUp API Client CLI');
    stdout.writeln('  dashboard    — KPIs overview');
    stdout.writeln('  transactions — Recent transactions');
    stdout.writeln('  checkouts    — Checkouts with status');
    stdout.writeln('  readers      — Paired readers');
    stdout.writeln('  help         — This help\n');
    return;
  }

  if (apiKey.isEmpty || mc.isEmpty) {
    stderr.writeln('Set SUMUP_API_KEY and SUMUP_MERCHANT_CODE env vars');
    exit(1);
  }

  final client = SumUpClient.withApiKey(apiKey);

  try {
    switch (cmd) {
      case 'dashboard':
        await _dashboard(client, mc);
      case 'transactions':
        await _transactions(client, mc);
      case 'checkouts':
        await _checkouts(client, mc);
      case 'readers':
        await _readers(client, mc);
      default:
        stderr.writeln('Unknown: $cmd');
        exit(1);
    }
  } catch (e) {
    stderr.writeln('Error: $e');
    exit(1);
  }
}

Future<void> _dashboard(SumUpClient c, String mc) async {
  _title('Dashboard');
  final results = await Future.wait<Map<dynamic, dynamic>>([
    c.dio
        .get<Map<dynamic, dynamic>>('/v2.1/merchants/$mc/transactions/history')
        .then((r) => r.data!),
    c.dio
        .get<Map<dynamic, dynamic>>('/v0.1/merchants/$mc/readers')
        .then((r) => r.data!),
  ]);
  final txItems = results[0]['items'] as List? ?? [];
  final readers = results[1]['items'] as List? ?? [];
  final paired = readers.where((r) => (r as Map)['status'] == 'paired').length;

  _table([
    'KPI',
    'Value'
  ], [
    ['Transactions', '${txItems.length}'],
    ['Paired Readers', '$paired'],
  ]);
}

Future<void> _transactions(SumUpClient c, String mc) async {
  _title('Transactions');
  final r = await c.dio
      .get<Map<dynamic, dynamic>>('/v2.1/merchants/$mc/transactions/history');
  final items = (r.data as Map<dynamic, dynamic>)['items'] as List? ?? [];
  if (items.isEmpty) return stdout.writeln('No transactions.');
  _table(
    ['Status', 'Amount', 'Currency', 'Type', 'Date'],
    items
        .cast<Map<dynamic, dynamic>>()
        .take(20)
        .map((tx) => [
              '${tx['status'] ?? '-'}',
              '${tx['amount'] ?? '-'}',
              '${tx['currency'] ?? '-'}',
              '${tx['payment_type'] ?? '-'}',
              _date('${tx['timestamp']}'),
            ])
        .toList(),
  );
}

Future<void> _checkouts(SumUpClient c, String mc) async {
  _title('Checkouts');
  final r = await c.dio.get<dynamic>('/v0.1/checkouts');
  final items = (r.data is List)
      ? r.data as List
      : (r.data as Map<dynamic, dynamic>)['items'] as List? ?? [];
  if (items.isEmpty) return stdout.writeln('No checkouts.');
  _table(
    ['ID', 'Status', 'Amount', 'Currency', 'Date'],
    items
        .cast<Map<dynamic, dynamic>>()
        .take(20)
        .map((ch) => [
              '${ch['id']}'.substring(0, 12),
              '${ch['status'] ?? '-'}',
              '${ch['amount'] ?? '-'}',
              '${ch['currency'] ?? '-'}',
              _date('${ch['date']}'),
            ])
        .toList(),
  );
}

Future<void> _readers(SumUpClient c, String mc) async {
  _title('Readers');
  final r =
      await c.dio.get<Map<dynamic, dynamic>>('/v0.1/merchants/$mc/readers');
  final data = r.data as Map;
  final items = data['items'] as List? ?? [];
  if (items.isEmpty) return stdout.writeln('No readers.');
  _table(
    ['Name', 'Status', 'Model', 'Serial'],
    items
        .cast<Map<dynamic, dynamic>>()
        .take(20)
        .map((rd) => [
              '${rd['name'] ?? '-'}',
              '${rd['status'] ?? '-'}',
              '${rd['device']?['model'] ?? '-'}',
              '${rd['device']?['identifier'] ?? '-'}',
            ])
        .toList(),
  );
}

// Helpers
void _title(String t) => stdout.writeln('\n${'═' * 60}\n  $t\n${'═' * 60}');

void _table(List<String> h, List<List<String>> rows) {
  final w = h.asMap().entries.map((e) {
    final m = rows.fold<int>(
        e.value.length, (mx, r) => r[e.key].length > mx ? r[e.key].length : mx);
    return m;
  }).toList();
  final sep = '+-${w.map((x) => '-' * (x + 1)).join('-+-')}-+';
  stdout.writeln(sep);
  stdout.writeln(
      '| ${h.asMap().entries.map((e) => _pad(e.value, w[e.key] + 1)).join('| ')}|');
  stdout.writeln(sep);
  for (final row in rows) {
    stdout.writeln(
        '| ${row.asMap().entries.map((e) => _pad(e.value, w[e.key] + 1)).join('| ')}|');
  }
  stdout.writeln(sep);
  stdout.writeln('${rows.length} row(s)');
}

String _pad(String s, int width) => s.padRight(width).substring(0, width);

String _date(String iso) {
  try {
    final dt = DateTime.parse(iso);
    return '${dt.year}-${_p(dt.month)}-${_p(dt.day)} ${_p(dt.hour)}:${_p(dt.minute)}';
  } catch (_) {
    return iso;
  }
}

String _p(int n) => n.toString().padLeft(2, '0');
