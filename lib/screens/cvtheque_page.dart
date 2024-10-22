import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'profile_detail_dialog.dart';

class CVthequePage extends StatelessWidget {
  const CVthequePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('desiredPosition', isNotEqualTo: '')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Une erreur est survenue'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return GridView.builder(
            padding: const EdgeInsets.all(5),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _getCrossAxisCount(context),
              childAspectRatio: 2.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var userData =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return ProfileCard(userData: userData);
            },
          );
        },
      ),
    );
  }
}

int _getCrossAxisCount(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth > 1200) {
    return 4; // Pour les grands écrans
  } else if (screenWidth > 800) {
    return 3; // Pour les écrans moyens
  } else if (screenWidth > 600) {
    return 2; // Pour les petits écrans
  } else {
    return 1; // Pour les très petits écrans
  }
}

class ProfileCard extends StatelessWidget {
  final Map<String, dynamic> userData;

  const ProfileCard({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd/MM/yyyy').format(
      (userData['timestampProfile'] as Timestamp).toDate(),
    );

    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => ProfileDetailDialog(userData: userData),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(userData['image_profile'] ??
                        'https://via.placeholder.com/50'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${userData['firstName']} ${userData['lastName']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          userData['desiredPosition'] ?? '',
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          userData['industrySector'] ?? '',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Mis à jour le $formattedDate',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
