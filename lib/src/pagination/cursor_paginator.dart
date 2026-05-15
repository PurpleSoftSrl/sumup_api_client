/// Helper for cursor-based paginated SumUp APIs.
///
/// SumUp uses `has_more` and `cursor` for pagination.
/// Use [CursorPaginator.all] to get a [Stream] of all results,
/// or call [fetchPage] manually for page-by-page access.
class CursorPaginator<T> {
  final Future<CursorPage<T>> Function(String? cursor) _fetcher;

  CursorPaginator(this._fetcher);

  /// Returns a [Stream] that automatically fetches all pages.
  Stream<T> all() async* {
    String? cursor;
    do {
      final page = await _fetcher(cursor);
      for (final item in page.items) {
        yield item;
      }
      cursor = page.nextCursor;
    } while (cursor != null);
  }

  /// Fetches a single page starting from [cursor] (null for first page).
  Future<CursorPage<T>> fetchPage({String? cursor}) => _fetcher(cursor);
}

class CursorPage<T> {
  final List<T> items;
  final String? nextCursor;

  const CursorPage(this.items, this.nextCursor);
}
