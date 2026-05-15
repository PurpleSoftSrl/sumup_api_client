## 0.1.0

- Initial release
- OAuth2 client_credentials token management with auto-refresh
- API Key and Personal Token authentication support
- Rate limiting with exponential backoff (429 handling)
- Automatic retry on 5xx and connection errors
- Cursor-based pagination helper (CursorPaginator)
- In-memory token storage (pluggable TokenStorage interface)
- Re-exports all generated SumUp API models and services
