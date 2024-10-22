// lib/widgets/stripe_dashboard_button.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/stripe_service.dart';

class StripeDashboardButton extends StatelessWidget {
  final StripeService _stripeService = StripeService();

  StripeDashboardButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.dashboard),
      label: const Text('Gérer ma page Stripe'),
      onPressed: () async {
        try {
          String url = await _stripeService.getStripeDashboardLink();
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
    );
  }
}
