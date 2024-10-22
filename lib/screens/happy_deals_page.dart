import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:happy_deals_pro/classes/happy_deal.dart';
import 'package:happy_deals_pro/providers/company_provider.dart';
import 'package:happy_deals_pro/widgets/cards/happy_deals_card.dart';
import 'package:happy_deals_pro/widgets/forms/form_happy_deal.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HappyDealsPage extends StatefulWidget {
  const HappyDealsPage({super.key});

  @override
  _HappyDealsPageState createState() => _HappyDealsPageState();
}

class _HappyDealsPageState extends State<HappyDealsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CompanyProvider>(context, listen: false).loadCompanyData();
    });
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(
          top: 20,
          left: 20.0,
          right: 20,
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('posts')
              .where('type', isEqualTo: 'happy_deal')
              .where('companyId', isEqualTo: _auth.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Une erreur est survenue'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('Aucun Happy Deal trouvé'));
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final happyDeal = HappyDeal.fromDocument(doc);
                return Dismissible(
                  key: Key(happyDeal.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.black),
                  ),
                  child: Stack(
                    children: [
                      HappyDealCard(
                        happyDeal: happyDeal,
                      ),
                      Positioned(
                        top: 10,
                        right: 50,
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.black),
                          onPressed: () => _editHappyDeal(happyDeal),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.black),
                          onPressed: () => _deleteHappyDeal(happyDeal.id),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _editHappyDeal(HappyDeal deal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HappyDealForm(happyDeal: deal),
      ),
    );
  }

  void _deleteHappyDeal(String dealId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmer la suppression"),
          content:
              const Text("Êtes-vous sûr de vouloir supprimer ce Happy Deal ?"),
          actions: [
            TextButton(
              child: const Text("Annuler"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Supprimer"),
              onPressed: () async {
                try {
                  // Récupérer le Happy Deal
                  DocumentSnapshot dealDoc =
                      await _firestore.collection('posts').doc(dealId).get();
                  HappyDeal happyDeal = HappyDeal.fromDocument(dealDoc);

                  // Supprimer le Happy Deal
                  await _firestore.collection('posts').doc(dealId).delete();

                  // Mettre à jour le produit associé
                  await _firestore
                      .collection('products')
                      .doc(happyDeal.productId)
                      .update({
                    'hasActiveHappyDeal': false,
                    'discountedPrice': FieldValue.delete(),
                    'discountPercentage': FieldValue.delete(),
                    'happyDealStartDate': FieldValue.delete(),
                    'happyDealEndDate': FieldValue.delete(),
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Happy Deal supprimé avec succès')),
                  );
                } catch (e) {
                  print('Erreur lors de la suppression du Happy Deal: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Erreur lors de la suppression: $e')),
                  );
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
