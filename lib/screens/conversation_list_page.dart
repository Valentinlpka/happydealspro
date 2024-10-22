import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:happy_deals_pro/classes/conversation.dart';
import 'package:happy_deals_pro/providers/conversation_provider.dart';
import 'package:happy_deals_pro/screens/conversation.detail.dart';
import 'package:happy_deals_pro/widgets/date_formatter.dart';
import 'package:provider/provider.dart';

class ConversationsListScreen extends StatelessWidget {
  final String currentUserId;

  const ConversationsListScreen({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final conversationService = Provider.of<ConversationService>(context);

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
                "Mes conversations",
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
      body: StreamBuilder<List<Conversation>>(
        stream: conversationService.getUserConversations(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune conversation trouvée'));
          }

          final Map<String, Conversation> uniqueConversations = {};
          for (var conversation in snapshot.data!) {
            String key = conversation.particulierId == currentUserId
                ? conversation.entrepriseId
                : conversation.particulierId;
            if (!uniqueConversations.containsKey(key) ||
                conversation.lastMessageTimestamp
                    .isAfter(uniqueConversations[key]!.lastMessageTimestamp)) {
              uniqueConversations[key] = conversation;
            }
          }

          return ListView.builder(
            itemCount: uniqueConversations.length,
            itemBuilder: (context, index) {
              final conversation = uniqueConversations.values.elementAt(index);
              final otherUserId = conversation.particulierId == currentUserId
                  ? conversation.entrepriseId
                  : conversation.particulierId;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      leading: CircleAvatar(child: CircularProgressIndicator()),
                      title: Text('Chargement...'),
                    );
                  }

                  if (userSnapshot.hasError || !userSnapshot.hasData) {
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.error)),
                      title: Text('Erreur: ${userSnapshot.error}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(formatRelativeTime(
                              conversation.lastMessageTimestamp)),
                          if (conversation.unreadCount > 0 &&
                              conversation.unreadBy == currentUserId)
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${conversation.unreadCount}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                    );
                  }

                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;
                  final String firstName = userData['firstName'] ?? '';
                  final String lastName = userData['lastName'] ?? '';
                  final String profilePicUrl = userData['profilePicUrl'] ?? '';

                  return Card(
                    elevation: 1,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: profilePicUrl.isNotEmpty
                            ? NetworkImage(profilePicUrl)
                            : null,
                        child: profilePicUrl.isEmpty
                            ? Text(firstName.isNotEmpty ? firstName[0] : '')
                            : null,
                      ),
                      title: Text('$firstName $lastName'),
                      subtitle: Text(conversation.lastMessage),
                      trailing: Text(formatRelativeTime(
                          conversation.lastMessageTimestamp)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConversationDetailScreen(
                              conversationId: conversation.id,
                              otherUserName: '$firstName $lastName',
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
