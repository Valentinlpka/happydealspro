import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:happy_deals_pro/classes/dealexpress.dart';
import 'package:happy_deals_pro/providers/company_provider.dart';
import 'package:happy_deals_pro/widgets/cards/deal_express_card.dart';
import 'package:happy_deals_pro/widgets/forms/form_deal_express.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ExpressDealPage extends StatefulWidget {
  const ExpressDealPage({super.key});
  @override
  _ExpressDealPageState createState() => _ExpressDealPageState();
}

class _ExpressDealPageState extends State<ExpressDealPage> {
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
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('posts')
              .where('type', isEqualTo: 'express_deal')
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
              return const Center(child: Text('Aucun Express Deal trouvé'));
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final expressDeal = ExpressDeal.fromDocument(doc);
                return Stack(
                  children: [
                    DealsExpressCard(deal: expressDeal),
                    Positioned(
                      top: 10,
                      right: 50,
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.black),
                        onPressed: () => _editExpressDeal(expressDeal),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.black),
                        onPressed: () => _deleteExpressDeal(expressDeal.id),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FormExpressDeal()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _editExpressDeal(ExpressDeal post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormExpressDeal(expressDeal: post),
      ),
    );
  }

  void _deleteExpressDeal(String postId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmer la suppression"),
          content: const Text(
              "Êtes-vous sûr de vouloir supprimer cet Express Deal ?"),
          actions: [
            TextButton(
              child: const Text("Annuler"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Supprimer"),
              onPressed: () async {
                await _firestore.collection('posts').doc(postId).delete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
