import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:happy_deals_pro/classes/job_offer.dart';
import 'package:happy_deals_pro/providers/company_provider.dart';
import 'package:happy_deals_pro/widgets/cards/job_offer_card.dart';
import 'package:happy_deals_pro/widgets/forms/form_job_offer.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class JobOfferPage extends StatefulWidget {
  const JobOfferPage({super.key});
  @override
  _JobOfferPageState createState() => _JobOfferPageState();
}

class _JobOfferPageState extends State<JobOfferPage> {
  bool _isCreatingNewOffer = false;

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
                "Mes offres d'emploi",
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
        child: Column(
          children: [
            Expanded(
              child: _isCreatingNewOffer
                  ? JobOfferForm(
                      onComplete: () {
                        setState(() {
                          _isCreatingNewOffer = false;
                        });
                      },
                    )
                  : _buildJobOffersList(),
            ),
            if (!_isCreatingNewOffer)
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                  ),
                  onPressed: () {
                    setState(() {
                      _isCreatingNewOffer = true;
                    });
                  },
                  child: const Text('Ajouter une nouvelle offre'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobOffersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('posts')
          .where('type', isEqualTo: 'job_offer')
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
          return const Center(child: Text('Aucune offre d\'emploi trouvée'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final jobOffer = JobOffer.fromDocument(doc);
            return Dismissible(
              key: Key(jobOffer.id),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                _deleteJobOffer(jobOffer.id);
              },
              child: Stack(
                children: [
                  JobOfferCard(post: jobOffer),
                  Positioned(
                    top: 10,
                    right: 50,
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.black),
                      onPressed: () => _editJobOffer(jobOffer),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      icon:
                          const Icon(Icons.delete_outline, color: Colors.black),
                      onPressed: () => _deleteJobOffer(jobOffer.id),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _editJobOffer(JobOffer post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobOfferForm(
          jobOffer: post,
          onComplete: () {
            setState(() {
              _isCreatingNewOffer = false;
            });
          },
        ),
      ),
    );
  }

  void _deleteJobOffer(String postId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmer la suppression"),
          content: const Text(
              "Êtes-vous sûr de vouloir supprimer cette offre d'emploi ?"),
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
