import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final User? userId = FirebaseAuth.instance.currentUser;
  late String? userUid = userId?.uid;

  final Map<String, String> postTypeTranslations = {
    'job_offer': 'Offre d\'emploi',
    'contest': 'Jeu concours',
    'happy_deal': 'Happy deal',
    'express_deal': 'Deal express',
    'referral': 'Parrainage',
    'event': 'Événement',
  };

  void _navigateToPostType(BuildContext context, String postType) {
    // Ici, vous pouvez implémenter la navigation vers la page spécifique
    // Pour l'instant, nous afficherons juste un SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Naviguer vers $postType')),
    );
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
                "Tableau de bord",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('companyId', isEqualTo: userUid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var posts = snapshot.data!.docs;
          var postCounts = {
            for (var type in postTypeTranslations.keys) type: 0
          };

          for (var post in posts) {
            var type = post['type'] as String?;
            if (type != null && postCounts.containsKey(type)) {
              postCounts[type] = (postCounts[type] ?? 0) + 1;
            }
          }

          return Column(
            children: [
              SizedBox(
                height: 120, // Hauteur fixe pour la ligne de carrés
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(8.0),
                  children: postCounts.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: InkWell(
                        onTap: () => _navigateToPostType(context, entry.key),
                        child: Card(
                          child: Container(
                            width: 100, // Largeur fixe pour chaque carré
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${entry.value}',
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  postTypeTranslations[entry.key] ?? entry.key,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Ajoutez ici d'autres widgets pour le reste du tableau de bord
                      const SizedBox(height: 20),
                      Text('Autres statistiques à venir...',
                          style: Theme.of(context).textTheme.titleLarge),
                      // Exemple de widget supplémentaire :
                      const Card(
                        margin: EdgeInsets.all(16),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Espace pour d\'autres widgets'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
