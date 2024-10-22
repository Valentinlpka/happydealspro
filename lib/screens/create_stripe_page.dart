// lib/screens/create_stripe_account_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/stripe_service.dart';

class CreateStripeAccountScreen extends StatelessWidget {
  final StripeService _stripeService = StripeService();

  CreateStripeAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte Stripe')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Commencer l\'intégration Stripe'),
          onPressed: () async {
            try {
              String url = await _stripeService.createConnectAccount();
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                throw 'Impossible d\'ouvrir l\'URL: $url';
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erreur: $e')),
              );
            }
          },
        ),
      ),
    );
  }
}
