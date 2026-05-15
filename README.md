# sumup_api_client

> Enterprise-ready SumUp REST API client for Dart and Flutter. OAuth2, pagination, rate limiting, retry, and caching — all with zero code generation at build time.

[![pub.dev](https://img.shields.io/pub/v/sumup_api_client?label=pub.dev&logo=dart&color=0175C2)](https://pub.dev/packages/sumup_api_client)
[![CI](https://github.com/PurpleSoftSrl/sumup_api_client/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/PurpleSoftSrl/sumup_api_client/actions/workflows/ci.yml)
[![Publish](https://github.com/PurpleSoftSrl/sumup_api_client/actions/workflows/publish.yml/badge.svg)](https://github.com/PurpleSoftSrl/sumup_api_client/actions/workflows/publish.yml)
[![Stars](https://img.shields.io/github/stars/PurpleSoftSrl/sumup_api_client?color=yellow)](https://github.com/PurpleSoftSrl/sumup_api_client/stargazers)
[![License](https://img.shields.io/badge/license-AGPL%20v3%20%7C%20Commercial-blue)](LICENSE)
[![tests](https://img.shields.io/badge/tests-44%2F44-brightgreen)](https://github.com/PurpleSoftSrl/sumup_api_client/actions)

---

## Partner Links

Support this project by purchasing SumUp terminals through our affiliate links for your country:

- **Argentina (es-AR):** [Acquista ora su SumUp](https://store.sumup.com/es-AR/product-selection/?partner=P7A4LPHS)
- **Australia (en-AU):** [Buy now on SumUp](https://store.sumup.com/en-AU/product-selection/?partner=P7A4LPHS)
- **Austria (de-AT):** [Jetzt kaufen auf SumUp](https://store.sumup.com/de-AT/product-selection/?partner=P7A4LPHS)
- **Belgium (nl-BE):** [Koop nu op SumUp](https://store.sumup.com/nl-BE/product-selection/?partner=P7A4LPHS)
- **Belgium (fr-BE):** [Achetez maintenant sur SumUp](https://store.sumup.com/fr-BE/product-selection/?partner=P7A4LPHS)
- **Brazil (pt-BR):** [Compre agora na SumUp](https://store.sumup.com/pt-BR/product-selection/?partner=P7A4LPHS)
- **Bulgaria (bg-BG):** [Купете сега от SumUp](https://store.sumup.com/bg-BG/product-selection/?partner=P7A4LPHS)
- **Canada (en-CA):** [Buy now on SumUp](https://store.sumup.com/en-CA/product-selection/?partner=P7A4LPHS)
- **Canada (fr-CA):** [Achetez maintenant sur SumUp](https://store.sumup.com/fr-CA/product-selection/?partner=P7A4LPHS)
- **Chile (es-CL):** [Compra ahora en SumUp](https://store.sumup.com/es-CL/product-selection/?partner=P7A4LPHS)
- **Colombia (es-CO):** [Compra ahora en SumUp](https://store.sumup.com/es-CO/product-selection/?partner=P7A4LPHS)
- **Croatia (hr-HR):** [Kupite sada na SumUp](https://store.sumup.com/hr-HR/product-selection/?partner=P7A4LPHS)
- **Czech Republic (cs-CZ):** [Koupit nyní na SumUp](https://store.sumup.com/cs-CZ/product-selection/?partner=P7A4LPHS)
- **Estonia (et-EE):** [Osta kohe SumUp](https://store.sumup.com/et-EE/product-selection/?partner=P7A4LPHS)
- **France (fr-FR):** [Achetez maintenant sur SumUp](https://store.sumup.com/fr-FR/product-selection/?partner=P7A4LPHS)
- **Germany (de-DE):** [Jetzt kaufen auf SumUp](https://store.sumup.com/de-DE/product-selection/?partner=P7A4LPHS)
- **Greece (el-GR):** [Αγοράστε τώρα στο SumUp](https://store.sumup.com/el-GR/product-selection/?partner=P7A4LPHS)
- **Hungary (hu-HU):** [Vásároljon most a SumUp](https://store.sumup.com/hu-HU/product-selection/?partner=P7A4LPHS)
- **Ireland (en-IE):** [Buy now on SumUp](https://store.sumup.com/en-IE/product-selection/?partner=P7A4LPHS)
- **Italy (it-IT):** [Acquista ora su SumUp](https://store.sumup.com/it-IT/product-selection/?partner=P7A4LPHS)
- **Latvia (lv-LV):** [Pērc tagad SumUp](https://store.sumup.com/lv-LV/product-selection/?partner=P7A4LPHS)
- **Lithuania (lt-LT):** [Pirkti dabar SumUp](https://store.sumup.com/lt-LT/product-selection/?partner=P7A4LPHS)
- **Luxembourg (fr-LU):** [Achetez maintenant sur SumUp](https://store.sumup.com/fr-LU/product-selection/?partner=P7A4LPHS)
- **Netherlands (nl-NL):** [Koop nu op SumUp](https://store.sumup.com/nl-NL/product-selection/?partner=P7A4LPHS)
- **Norway (nb-NO):** [Kjøp nå på SumUp](https://store.sumup.com/nb-NO/product-selection/?partner=P7A4LPHS)
- **Peru (es-PE):** [Compra ahora en SumUp](https://store.sumup.com/es-PE/product-selection/?partner=P7A4LPHS)
- **Poland (pl-PL):** [Kup teraz na SumUp](https://store.sumup.com/pl-PL/product-selection/?partner=P7A4LPHS)
- **Portugal (pt-PT):** [Compre agora na SumUp](https://store.sumup.com/pt-PT/product-selection/?partner=P7A4LPHS)
- **Romania (ro-RO):** [Cumpărați acum pe SumUp](https://store.sumup.com/ro-RO/product-selection/?partner=P7A4LPHS)
- **Slovakia (sk-SK):** [Kúpiť teraz na SumUp](https://store.sumup.com/sk-SK/product-selection/?partner=P7A4LPHS)
- **Slovenia (sl-SI):** [Kupite zdaj na SumUp](https://store.sumup.com/sl-SI/product-selection/?partner=P7A4LPHS)
- **Spain (es-ES):** [Compra ahora en SumUp](https://store.sumup.com/es-ES/product-selection/?partner=P7A4LPHS)
- **Sweden (sv-SE):** [Köp nu på SumUp](https://store.sumup.com/sv-SE/product-selection/?partner=P7A4LPHS)
- **Switzerland (de-CH):** [Jetzt kaufen auf SumUp](https://store.sumup.com/de-CH/product-selection/?partner=P7A4LPHS)
- **Switzerland (fr-CH):** [Achetez maintenant sur SumUp](https://store.sumup.com/fr-CH/product-selection/?partner=P7A4LPHS)
- **Switzerland (it-CH):** [Acquista ora su SumUp](https://store.sumup.com/it-CH/product-selection/?partner=P7A4LPHS)
- **United Kingdom (en-GB):** [Buy now on SumUp](https://store.sumup.com/en-GB/product-selection/?partner=P7A4LPHS)
- **United States (en-US):** [Buy now on SumUp](https://store.sumup.com/en-US/product-selection/?partner=P7A4LPHS)

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
  sumup_api_client: ^0.1.1
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

AGPL v3 for open-source use. For commercial licensing, contact [developers@purplesoft.io](mailto:developers@purplesoft.io).
