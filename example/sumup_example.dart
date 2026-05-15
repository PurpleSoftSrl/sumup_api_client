import 'package:sumup_api_client/sumup_api_client.dart';

Future<void> main(List<String> args) async {
  if (args.length < 2) {
    print('Usage: dart run example/sumup_example.dart <client_id> <client_secret>');
    return;
  }

  final clientId = args[0];
  final clientSecret = args[1];

  final client = SumUpClient.withOAuth2(
    clientId: clientId,
    clientSecret: clientSecret,
  );

  print('Connected to SumUp API');

  try {
    final result = await client.merchants.getMerchant(merchantCode: 'your_merchant_code');
    print('Merchant: $result');
  } catch (e) {
    print('Error fetching merchant: $e');
  }

  try {
    final result = await client.checkouts.listCheckouts();
    print('Checkouts: $result');
  } catch (e) {
    print('Error listing checkouts: $e');
  }
}
