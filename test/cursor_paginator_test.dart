import 'package:test/test.dart';
import 'package:sumup_api_client/src/pagination/cursor_paginator.dart';

void main() {
  group('CursorPage', () {
    test('stores items and next cursor', () {
      final page = CursorPage<int>([1, 2, 3], 'cursor_next');
      expect(page.items, equals([1, 2, 3]));
      expect(page.nextCursor, equals('cursor_next'));
    });

    test('nextCursor is null for last page', () {
      final page = CursorPage<String>(['a'], null);
      expect(page.nextCursor, isNull);
    });
  });

  group('CursorPaginator', () {
    test('all() yields all pages via stream', () async {
      final pages = [
        CursorPage<int>([1, 2], 'page2'),
        CursorPage<int>([3, 4], 'page3'),
        CursorPage<int>([5], null),
      ];
      var pageIndex = 0;

      final paginator = CursorPaginator<int>((String? cursor) async {
        final page = pages[pageIndex];
        pageIndex++;
        return page;
      });

      final results = <int>[];
      await for (final item in paginator.all()) {
        results.add(item);
      }

      expect(results, equals([1, 2, 3, 4, 5]));
    });

    test('all() handles single page', () async {
      final paginator = CursorPaginator<String>((_) async {
        return CursorPage<String>(['only'], null);
      });

      final results = <String>[];
      await for (final item in paginator.all()) {
        results.add(item);
      }

      expect(results, equals(['only']));
    });

    test('all() handles empty page', () async {
      final paginator = CursorPaginator<int>((_) async {
        return CursorPage<int>([], null);
      });

      final results = <int>[];
      await for (final item in paginator.all()) {
        results.add(item);
      }

      expect(results, isEmpty);
    });

    test('fetchPage passes cursor correctly', () async {
      String? receivedCursor;
      final paginator = CursorPaginator<String>((cursor) async {
        receivedCursor = cursor;
        return CursorPage<String>([], null);
      });

      await paginator.fetchPage(cursor: 'test_cursor');
      expect(receivedCursor, equals('test_cursor'));

      await paginator.fetchPage();
      expect(receivedCursor, isNull);
    });
  });
}
