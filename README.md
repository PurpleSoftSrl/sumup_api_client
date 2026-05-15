# SumUp API Client

[![pub package](https://img.shields.io/pub/v/sumup_api_client.svg)](https://pub.dev/packages/sumup_api_client)
[![pub points](https://img.shields.io/pub/points/sumup_api_client)](https://pub.dev/packages/sumup_api_client/score)
[![CI](https://github.com/PurpleSoftSrl/sumup_api_client/actions/workflows/ci.yml/badge.svg)](https://github.com/PurpleSoftSrl/sumup_api_client/actions/workflows/ci.yml)
[![Publish](https://github.com/PurpleSoftSrl/sumup_api_client/actions/workflows/publish.yml/badge.svg)](https://github.com/PurpleSoftSrl/sumup_api_client/actions/workflows/publish.yml)
[![Stars](https://img.shields.io/github/stars/PurpleSoftSrl/sumup_api_client.svg)](https://github.com/PurpleSoftSrl/sumup_api_client)
[![License](https://img.shields.io/badge/license-AGPL%20v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)

Enterprise-ready SumUp REST API client for Dart and Flutter. Built on `dio`, with automatic OAuth2 token management, rate limiting, retry, cursor-based pagination, and a clean federated architecture.

## Features

- **OAuth2 client_credentials** — automatic token fetch, cache, and refresh
- **API Key** and **Personal Token** authentication support
- **Rate limiting** — exponential backoff on 429 responses
- **Automatic retry** — retries on 5xx, connection, and timeout errors
- **Cursor pagination** — `CursorPaginator<T>.all()` stream helper
- **Pluggable token storage** — in-memory (Dart-only) or custom implementations (flutter_secure_storage)
- **10 API services** — Checkouts, Customers, Memberships, Members, Merchants, Payouts, Readers, Receipts, Roles, Transactions
- **Zero build_runner** — no code generation required

## Quick Start

```dart
import 'package:sumup_api_client/sumup_api_client.dart';

void main() async {
  // OAuth2 (recommended)
  final client = SumUpClient.withOAuth2(
    clientId: 'your-client-id',
    clientSecret: 'your-client-secret',
  );

  // API Key (legacy)
  // final client = SumUpClient.withApiKey('sup_sk_...');

  // List transactions
  final result = await client.transactions.listTransactionsV21(
    merchantCode: 'YOUR_MERCHANT_CODE',
  );
  print(result);
}
```

## Installation

```yaml
dependencies:
  sumup_api_client: ^0.1.0
```

## Commands

```bash
# Run the CLI example
export SUMUP_API_KEY=sup_sk_...
export SUMUP_MERCHANT_CODE=MESLTVGX
dart run example/bin/main.dart dashboard
dart run example/bin/main.dart transactions
dart run example/bin/main.dart checkouts
dart run example/bin/main.dart readers
```

## License

AGPL v3. For commercial licensing, contact [developers@purplesoft.io](mailto:developers@purplesoft.io).
