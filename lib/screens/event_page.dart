import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:happy_deals_pro/classes/event.dart';
import 'package:happy_deals_pro/providers/company_provider.dart';
import 'package:happy_deals_pro/widgets/cards/event_card.dart';
import 'package:happy_deals_pro/widgets/forms/form_event.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
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
        preferredSize: const Size.fromHeight(
            kToolbarHeight + 50), // Hauteur standard + 50 pour la marge
        child: Container(
          padding: const EdgeInsets.only(
            left: 10,
            bottom: 50,
          ), // Marge en bas de 50
          child: AppBar(
            title: Container(
              alignment: Alignment.centerLeft,
              child: const Text(
                "Mes évènements",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            backgroundColor: Colors.transparent, // Fond transparent
            elevation: 0, // Pas d'ombre
            automaticallyImplyLeading:
                false, // Supprime le bouton de retour par défaut
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('posts')
              .where('type', isEqualTo: 'event')
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
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final event = Event.fromDocument(doc);
                return Dismissible(
                  key: Key(event.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  child: Stack(
                    children: [
                      EvenementCard(event: event),
                      Positioned(
                        top: 10,
                        right: 50,
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () => _editEvent(event),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.white),
                          onPressed: () => _deleteEvent(event.id),
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

  void _editEvent(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormEvent(event: event),
      ),
    );
  }

  void _deleteEvent(String eventId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmer la suppression"),
          content:
              const Text("Êtes-vous sûr de vouloir supprimer cet évènement ?"),
          actions: [
            TextButton(
              child: const Text("Annuler"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Supprimer"),
              onPressed: () async {
                await _firestore.collection('posts').doc(eventId).delete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
