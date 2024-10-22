import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderDetailsPage extends StatelessWidget {
  final String orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la commande'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reservations')
            .doc(orderId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Une erreur est survenue'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Commande non trouvée'));
          }

          final orderData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard('Numéro de commande', orderId.substring(0, 6)),
                _buildInfoCard('Statut',
                    orderData['isValidated'] ? 'Confirmé' : 'En attente',
                    color: orderData['isValidated']
                        ? Colors.green
                        : Colors.orange),
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(orderData['postId'])
                      .get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    final postData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoCard(
                            'Type de panier', postData['basketType']),

                        // Ajoutez d'autres détails du Deal Express ici
                      ],
                    );
                  },
                ),
                _buildInfoCard(
                    'Date de retrait',
                    DateFormat('dd/MM/yyyy HH:mm').format(
                        (orderData['pickupDate'] as Timestamp).toDate())),
                _buildInfoCard('Quantité', orderData['quantity'].toString()),
                _buildInfoCard('Prix', '${orderData['price']} €'),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, {Color? color}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: color ?? Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
