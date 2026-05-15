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
