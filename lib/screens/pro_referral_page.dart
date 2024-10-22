import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProReferralsPage extends StatefulWidget {
  const ProReferralsPage({super.key});

  @override
  _ProReferralsPageState createState() => _ProReferralsPageState();
}

class _ProReferralsPageState extends State<ProReferralsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StreamController<List<Map<String, dynamic>>> _referralsController =
      StreamController<List<Map<String, dynamic>>>();
  StreamSubscription? _referralsSubscription;

  @override
  void initState() {
    super.initState();
    _initReferralsStream();
  }

  void _initReferralsStream() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final companyId = user.uid;
        final referralsQuery = FirebaseFirestore.instance
            .collection('referrals')
            .where('companyId', isEqualTo: companyId)
            .orderBy('timestamp', descending: true);

        _referralsSubscription =
            referralsQuery.snapshots().listen((snapshot) async {
          List<Map<String, dynamic>> referralsWithPostInfo = [];
          for (var doc in snapshot.docs) {
            final referral = doc.data();
            final referralId = doc.id;
            final postId = referral['referralId'];

            // Récupérer les informations de l'annonce
            final postDoc = await FirebaseFirestore.instance
                .collection('posts')
                .doc(postId)
                .get();
            final postTitle =
                postDoc.data()?['title'] ?? 'Titre non disponible';

            referralsWithPostInfo.add({
              ...referral,
              'id': referralId,
              'postTitle': postTitle,
            });
          }
          _referralsController.add(referralsWithPostInfo);
        }, onError: (error) {
          _referralsController.addError(error);
        });
      } catch (e) {
        _referralsController
            .addError('Erreur lors de la récupération des données: $e');
      }
    } else {
      _referralsController.addError('Utilisateur non connecté');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des parrainages',
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _referralsController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Une erreur est survenue: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun parrainage trouvé'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 600,
              columns: const [
                DataColumn2(label: Text('Annonce'), size: ColumnSize.L),
                DataColumn2(label: Text('Parrain'), size: ColumnSize.M),
                DataColumn2(label: Text('Filleul'), size: ColumnSize.M),
                DataColumn2(label: Text('Date'), size: ColumnSize.S),
                DataColumn2(label: Text('Statut'), size: ColumnSize.S),
                DataColumn2(label: Text('Actions'), size: ColumnSize.M),
              ],
              rows: snapshot.data!.map((referral) {
                return DataRow2(
                  cells: [
                    DataCell(Text(referral['postTitle'] ?? '')),
                    DataCell(Text(referral['sponsorName'] ?? '')),
                    DataCell(Text(referral['refereeName'] ?? '')),
                    DataCell(Text(referral['timestamp'] != null
                        ? DateFormat('dd/MM/yyyy')
                            .format(referral['timestamp'].toDate())
                        : '')),
                    DataCell(_buildStatusDropdown(
                        referral['id'], referral['status'] ?? 'Envoyé')),
                    DataCell(
                      ElevatedButton(
                        child: const Text('Détails'),
                        onPressed: () =>
                            _showReferralDetails(context, referral),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  void _showReferralDetails(
      BuildContext context, Map<String, dynamic> referral) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: Offset(0.0, 10.0))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(referral),
                const SizedBox(height: 20),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildLeftColumn(referral),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 2,
                        child: _buildRightColumn(referral),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildActionButtons(context, referral),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(Map<String, dynamic> referral) {
    return Row(
      children: [
        const CircleAvatar(
          backgroundColor: Colors.blue,
          radius: 30,
          child: Icon(Icons.people, color: Colors.white, size: 30),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Détails du parrainage',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text('ID: ${referral['id']}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildLeftColumn(Map<String, dynamic> referral) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Informations générales'),
          _buildDetailRow(Icons.work, 'Annonce', referral['postTitle']),
          _buildDetailRow(
              Icons.calendar_today, 'Date', _formatDate(referral['timestamp'])),
          _buildDetailRow(Icons.flag, 'Statut', referral['status']),
          const SizedBox(height: 20),
          _buildSectionTitle('Détails du parrain'),
          _buildDetailRow(Icons.person, 'Nom', referral['sponsorName']),
          _buildDetailRow(Icons.email, 'Email', referral['sponsorEmail']),
          _buildDetailRow(
              Icons.card_giftcard, 'Récompense', referral['sponsorReward']),
          _buildDetailRow(Icons.euro, 'Coût', '${referral['sponsorCost']} €'),
          const SizedBox(height: 20),
          _buildSectionTitle('Détails du filleul'),
          _buildDetailRow(Icons.person_outline, 'Nom', referral['refereeName']),
          _buildDetailRow(
              Icons.contact_phone, 'Contact', referral['refereeContact']),
          _buildDetailRow(Icons.contact_mail, 'Type de contact',
              referral['refereeContactType']),
          _buildDetailRow(
              Icons.card_giftcard, 'Récompense', referral['refereeReward']),
          _buildDetailRow(Icons.euro, 'Coût', '${referral['referralCost']} €'),
        ],
      ),
    );
  }

  Widget _buildRightColumn(Map<String, dynamic> referral) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Message'),
          _buildMessageBox(referral['message']),
          const SizedBox(height: 20),
          _buildSectionTitle('Historique des messages'),
          _buildMessagesList(referral['messages']),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 16),
                children: [
                  TextSpan(
                      text: '$label: ',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: value ?? 'Non spécifié'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBox(String? message) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(message ?? 'Aucun message',
          style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _buildMessagesList(List<dynamic>? messages) {
    if (messages == null || messages.isEmpty) {
      return const Text('Aucun message',
          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic));
    }
    return Column(
      children: messages.map((message) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            leading: Icon(
              message['senderType'] == 'company'
                  ? Icons.business
                  : Icons.person,
              color: Colors.blue,
            ),
            title: Text(message['text']),
            subtitle: Text(
              '${message['senderType'] == 'company' ? 'Entreprise' : 'Utilisateur'} - ${_formatDate(message['timestamp'])}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, Map<String, dynamic> referral) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.edit),
          label: const Text('Modifier'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          onPressed: () {
            Navigator.of(context).pop();
            _editReferral(referral['id'], referral);
          },
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          icon: const Icon(Icons.message),
          label: const Text('Ajouter un message'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () {
            Navigator.of(context).pop();
            _addMessage(referral['id']);
          },
        ),
      ],
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Date non spécifiée';
    if (timestamp is Timestamp) {
      return DateFormat('dd/MM/yyyy HH:mm').format(timestamp.toDate());
    }
    return 'Format de date invalide';
  }

  Widget _buildStatusDropdown(String referralId, String currentStatus) {
    return DropdownButton<String>(
      value: currentStatus,
      onChanged: (String? newValue) {
        if (newValue != null) {
          _updateReferralStatus(referralId, newValue);
        }
      },
      items: ['Envoyé', 'En cours', 'Terminé', 'Archivé']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  void _updateReferralStatus(String referralId, String newStatus) {
    FirebaseFirestore.instance.collection('referrals').doc(referralId).update({
      'status': newStatus,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Statut mis à jour: $newStatus')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur lors de la mise à jour du statut: $error')),
      );
    });
  }

  void _editReferral(String referralId, Map<String, dynamic> referral) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String sponsorReward = referral['sponsorReward'] ?? '';
        String refereeReward = referral['refereeReward'] ?? '';
        double referralCost =
            (referral['referralCost'] as num?)?.toDouble() ?? 0.0;
        double sponsorCost =
            (referral['sponsorCost'] as num?)?.toDouble() ?? 0.0;

        return AlertDialog(
          title: const Text('Modifier le parrainage'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration:
                      const InputDecoration(labelText: 'Récompense du parrain'),
                  onChanged: (value) => sponsorReward = value,
                  controller: TextEditingController(text: sponsorReward),
                ),
                TextField(
                  decoration: const InputDecoration(
                      labelText: 'Coût du parrainage pour le parrain (€)'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      sponsorCost = double.tryParse(value) ?? sponsorCost,
                  controller:
                      TextEditingController(text: sponsorCost.toString()),
                ),
                TextField(
                  decoration:
                      const InputDecoration(labelText: 'Récompense du filleul'),
                  onChanged: (value) => refereeReward = value,
                  controller: TextEditingController(text: refereeReward),
                ),
                TextField(
                  decoration: const InputDecoration(
                      labelText: 'Coût du parrainage pour le filleul (€)'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      referralCost = double.tryParse(value) ?? referralCost,
                  controller:
                      TextEditingController(text: referralCost.toString()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Enregistrer'),
              onPressed: () {
                _saveReferralChanges(referralId, sponsorReward, refereeReward,
                    referralCost, sponsorCost);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _saveReferralChanges(String referralId, String sponsorReward,
      String refereeReward, double referralCost, double sponsorCost) {
    FirebaseFirestore.instance.collection('referrals').doc(referralId).update({
      'sponsorReward': sponsorReward,
      'refereeReward': refereeReward,
      'referralCost': referralCost,
      'sponsorCost': sponsorCost,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Modifications enregistrées')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Erreur lors de l\'enregistrement des modifications: $error')),
      );
    });
  }

  void _addMessage(String referralId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String message = '';
        return AlertDialog(
          title: const Text('Ajouter un message'),
          content: TextField(
            decoration: const InputDecoration(labelText: 'Message'),
            onChanged: (value) => message = value,
            maxLines: 3,
          ),
          actions: [
            TextButton(
              child: const Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Envoyer'),
              onPressed: () {
                _saveMessage(referralId, message);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _saveMessage(String referralId, String message) {
    FirebaseFirestore.instance.collection('referrals').doc(referralId).update({
      'messages': FieldValue.arrayUnion([
        {
          'text': message,
          'timestamp': FieldValue.serverTimestamp(),
          'senderType': 'company',
        }
      ]),
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message ajouté')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'ajout du message: $error')),
      );
    });
  }

  @override
  void dispose() {
    _referralsSubscription?.cancel();
    _referralsController.close();
    super.dispose();
  }
}
