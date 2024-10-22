// lib/services/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> getStripeAccountId(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        return userData['stripeAccountId'] as String?;
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération du stripeAccountId: $e');
      return null;
    }
  }
}
