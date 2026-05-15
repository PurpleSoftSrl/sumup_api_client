/// Enterprise-ready SumUp REST API client for Dart and Flutter.
///
/// Provides OAuth2 token management, rate limiting, retry, pagination,
/// and response caching on top of the generated SumUp API classes.
///
/// ```dart
/// final client = SumUpClient.withOAuth2(
///   clientId: 'xxx',
///   clientSecret: 'xxx',
/// );
/// final checkout = await client.checkouts.createReaderCheckout(...);
/// ```
library sumup_api_client;

export 'src/sumup_client.dart';
export 'src/auth/token.dart';
export 'src/auth/oauth2_manager.dart';
export 'src/auth/token_storage/memory_storage.dart';
export 'src/pagination/cursor_paginator.dart';
export 'src/generated/generated.dart';
