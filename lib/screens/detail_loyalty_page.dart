import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:happy_deals_pro/screens/loyalty_form_page.dart';

class LoyaltyDashboard extends StatefulWidget {
  const LoyaltyDashboard({super.key});

  @override
  _LoyaltyDashboardState createState() => _LoyaltyDashboardState();
}

class _LoyaltyDashboardState extends State<LoyaltyDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
                "Programme de fidélité",
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
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore
            .collection('companys')
            .doc(_auth.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Une erreur est survenue'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Profil d\'entreprise non trouvé'));
          }

          Map<String, dynamic> companyData =
              snapshot.data!.data() as Map<String, dynamic>;
          String? loyaltyProgramId = companyData['loyaltyProgramId'];

          if (loyaltyProgramId == null) {
            return Center(
              child: ElevatedButton(
                child: const Text('Créer un programme de fidélité'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoyaltyProgramForm()),
                  );
                },
              ),
            );
          } else {
            return StreamBuilder<DocumentSnapshot>(
              stream: _firestore
                  .collection('LoyaltyPrograms')
                  .doc(loyaltyProgramId)
                  .snapshots(),
              builder: (context, programSnapshot) {
                if (programSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (programSnapshot.hasError || !programSnapshot.hasData) {
                  return const Center(
                      child: Text('Erreur lors du chargement du programme'));
                }

                Map<String, dynamic> programData =
                    programSnapshot.data!.data() as Map<String, dynamic>;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Détails du Programme',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      _buildProgramDetails(programData),
                      const SizedBox(height: 30),
                      const Text('Adhérents',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      _buildAdherentsList(loyaltyProgramId),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildProgramDetails(Map<String, dynamic> programData) {
    String type = programData['type'];
    Widget details;

    switch (type) {
      case 'visits':
        details = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Type: Carte de passage'),
            Text('Passages requis: ${programData['targetValue']}'),
            Text(
                'Récompense: ${programData['rewardValue']}${programData['isPercentage'] ? '%' : '€'}'),
          ],
        );
        break;
      case 'amount':
        details = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Type: Carte à montant'),
            Text('Montant à atteindre: ${programData['targetValue']}€'),
            Text(
                'Récompense: ${programData['rewardValue']}${programData['isPercentage'] ? '%' : '€'}'),
          ],
        );
        break;
      case 'points':
        List<Map<String, dynamic>> tiers =
            List<Map<String, dynamic>>.from(programData['tiers']);
        details = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Type: Carte à points'),
            const SizedBox(height: 10),
            const Text('Paliers:'),
            ...tiers.map((tier) => Text(
                '${tier['points']} points = ${tier['reward']}${tier['isPercentage'] ? '%' : '€'}')),
          ],
        );
        break;
      default:
        details = const Text('Type de programme inconnu');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: details,
      ),
    );
  }

  Widget _buildAdherentsList(String programId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('LoyaltyCards')
          .where('loyaltyProgramId', isEqualTo: programId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Text('Erreur lors du chargement des adhérents');
        }

        List<DocumentSnapshot> adherents = snapshot.data?.docs ?? [];

        if (adherents.isEmpty) {
          return const Text('Aucun adhérent pour le moment');
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: adherents.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> adherentData =
                adherents[index].data() as Map<String, dynamic>;
            return ListTile(
              title: Text('Client ID: ${adherentData['customerId']}'),
              subtitle:
                  Text('Valeur actuelle: ${adherentData['currentValue']}'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // TODO: Implémenter la modification de la valeur de la carte
                },
              ),
            );
          },
        );
      },
    );
  }
}
