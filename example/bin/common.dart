import 'dart:io';
import 'package:sumup_api_client/sumup_api_client.dart';

/// Abstract command pattern for CLI operations.
abstract class Command {
  String get name;
  String get description;
  Future<void> execute(SumUpClient client, String merchantCode, List<String> args);
}

/// Shared formatting helpers.
class Fmt {
  static String date(String? iso) {
    if (iso == null) return '-';
    try {
      final dt = DateTime.parse(iso);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  static String money(dynamic amount, String? currency) {
    if (amount == null) return '-';
    final d = amount is double ? amount : amount.toDouble();
    return '${d.toStringAsFixed(2)} ${currency ?? ''}'.trim();
  }

  static String pad(String s, int width) => s.padRight(width).substring(0, width);

  static void table(List<String> headers, List<List<String>> rows,
      {List<int>? colWidths}) {
    final widths = colWidths ??
        headers.asMap().entries.map((e) {
          final maxRow = rows.fold<int>(e.value.length, (m, r) => r[e.key].length > m ? r[e.key].length : m);
          return maxRow;
        }).toList();

    final sep = '+-${widths.map((w) => '-' * (w + 1)).join('-+-')}-+';
    stdout.writeln(sep);
    stdout.writeln('| ${headers.asMap().entries.map((e) => pad(e.value, widths[e.key] + 1)).join('| ')}|');
    stdout.writeln(sep);
    for (final row in rows) {
      stdout.writeln('| ${row.asMap().entries.map((e) => pad(e.value, widths[e.key] + 1)).join('| ')}|');
    }
    stdout.writeln(sep);
    stdout.writeln('${rows.length} row(s)');
  }
}

/// Shared header printer.
void printHeader(String title) {
  stdout.writeln();
  stdout.writeln('═' * 60);
  stdout.writeln('  $title');
  stdout.writeln('═' * 60);
}
