// lib/services/stripe_service.dart
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StripeService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<String> createConnectAccount() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Utilisateur non authentifié');

      final result =
          await _functions.httpsCallable('createConnectAccount').call();

      if (result.data != null && result.data['url'] != null) {
        return result.data['url'] as String;
      } else {
        throw Exception('URL d\'onboarding non reçue');
      }
    } catch (e) {
      print('Erreur lors de la création du compte Connect: $e');
      rethrow;
    }
  }

  Future<String> getStripeDashboardLink() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Utilisateur non authentifié');

      final result =
          await _functions.httpsCallable('getStripeDashboardLink').call();

      if (result.data != null && result.data['url'] != null) {
        return result.data['url'] as String;
      } else {
        throw Exception('URL du tableau de bord non reçue');
      }
    } catch (e) {
      print(
          'Erreur lors de l\'obtention du lien du tableau de bord Stripe: $e');
      rethrow;
    }
  }
}
