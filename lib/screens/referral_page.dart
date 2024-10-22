import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:happy_deals_pro/classes/referral.dart';
import 'package:happy_deals_pro/providers/company_provider.dart';
import 'package:happy_deals_pro/widgets/cards/referral_card.dart';
import 'package:happy_deals_pro/widgets/forms/form_referral.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ReferralPage extends StatefulWidget {
  const ReferralPage({super.key});

  @override
  _ReferralPageState createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> {
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 50),
        child: Container(
          padding: const EdgeInsets.only(left: 10, bottom: 50),
          child: AppBar(
            title: Container(
              alignment: Alignment.centerLeft,
              child: const Text(
                "Mes parrainages",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('posts')
              .where('type', isEqualTo: 'referral')
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
              return const Center(child: Text('Aucun parrainage trouvé'));
            }

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final referral = Referral.fromDocument(doc);
                return Dismissible(
                  key: Key(referral.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  child: Stack(
                    children: [
                      ReferralCard(post: referral),
                      Positioned(
                        top: 10,
                        right: 50,
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () => _editReferral(referral),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.white),
                          onPressed: () => _deleteReferral(referral.id),
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

  void _editReferral(Referral referral) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormReferral(referral: referral),
      ),
    );
  }

  void _deleteReferral(String referralId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmer la suppression"),
          content:
              const Text("Êtes-vous sûr de vouloir supprimer ce parrainage ?"),
          actions: [
            TextButton(
              child: const Text("Annuler"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Supprimer"),
              onPressed: () async {
                await _firestore.collection('posts').doc(referralId).delete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
