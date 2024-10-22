import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class StripeTestWidget extends StatelessWidget {
  const StripeTestWidget({super.key});

  Future<void> _testStripeConnection(BuildContext context) async {
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('testStripeConnection')
          .call();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Test réussi. Account ID: ${result.data['accountId']}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: const Text('Tester la connexion Stripe'),
      onPressed: () => _testStripeConnection(context),
    );
  }
}
