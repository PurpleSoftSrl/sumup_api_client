## 0.1.4

- Add dartdoc from OpenAPI spec descriptions (932 docs)
- Fix strict analysis compliance (0 issues with --fatal-infos)
- Fix curly braces in generated query/header parameter code
- Regenerate with latest generator v0.2.5

## 0.1.3

- Add dartdoc comments to all generated model classes (186 files)
- Improve pub.dev documentation score

## 0.1.2

- Integrate mcache_dart for token caching (LRU, O(1))
- Integrate dio_mcache for response caching (GET dedup, 5min TTL)
- Add enableCaching option to SumUpClient factories

## 0.1.1

- Fix README badges parity with other PurpleSoft packages
- Add partner links (37 countries) for SumUp terminal purchases
- Add AGPLv3 LICENSE file

## 0.1.0

- Initial release
- OAuth2 client_credentials token management with auto-refresh
- API Key and Personal Token authentication support
- Rate limiting with exponential backoff (429 handling)
- Automatic retry on 5xx and connection errors
- Cursor-based pagination helper (CursorPaginator)
- In-memory token storage (pluggable TokenStorage interface)
- Re-exports all generated SumUp API models and services
