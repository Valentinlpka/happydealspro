// lib/screens/shop_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:happy_deals_pro/screens/create_stripe_page.dart';
import 'package:happy_deals_pro/screens/product_list_page.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkStripeAccount(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        } else {
          bool hasStripeAccount = snapshot.data ?? false;
          if (hasStripeAccount) {
            return const ProductListScreen();
          } else {
            return Center(
              child: ElevatedButton(
                child: const Text('Créer ma boutique'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateStripeAccountScreen()),
                  );
                },
              ),
            );
          }
        }
      },
    );
  }

  Future<bool> _checkStripeAccount() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // Vérifions si le document existe et contient les données attendues
      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('stripeAccountId')) {
          return data['stripeAccountId'] != null;
        }
      }
    }
    return false;
  }
}
