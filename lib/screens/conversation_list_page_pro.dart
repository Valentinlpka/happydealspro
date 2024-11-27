// conversation_list_page_pro.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:happy_deals_pro/classes/conversation_pro.dart';
import 'package:happy_deals_pro/providers/conversation_provider_pro.dart';
import 'package:happy_deals_pro/screens/conversation.detail_pro.dart';
import 'package:happy_deals_pro/widgets/date_formatter.dart';
import 'package:provider/provider.dart';

class ConversationsListScreen extends StatefulWidget {
  final String currentUserId;

  const ConversationsListScreen({super.key, required this.currentUserId});

  @override
  State<ConversationsListScreen> createState() =>
      _ConversationsListScreenState();
}

class _ConversationsListScreenState extends State<ConversationsListScreen> {
  String? selectedConversationId;
  String? selectedOtherUserName;

  @override
  Widget build(BuildContext context) {
    final conversationService = Provider.of<ConversationService>(context);

    return Scaffold(
      body: Row(
        children: [
          // Liste des conversations (sidebar)
          Container(
            width: 300,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'Messages',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<Conversation>>(
                    stream: conversationService
                        .getUserConversations(widget.currentUserId),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Erreur: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final conversations = snapshot.data!;
                      if (conversations.isEmpty) {
                        return const Center(child: Text('Aucune conversation'));
                      }

                      return ListView.builder(
                        itemCount: conversations.length,
                        itemBuilder: (context, index) {
                          final conversation = conversations[index];

                          if (conversation.isGroup) {
                            return _buildGroupConversationItem(conversation);
                          } else {
                            return _buildUserConversationItem(conversation);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Zone de conversation
          Expanded(
            child: selectedConversationId != null
                ? ConversationDetailScreen(
                    conversationId: selectedConversationId!,
                    otherUserName: selectedOtherUserName!,
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.message_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Sélectionnez une conversation',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupConversationItem(Conversation conversation) {
    final isUnread = conversation.unreadBy == widget.currentUserId;

    return ConversationListItem(
      name: conversation.groupName ?? 'Groupe',
      lastMessage: conversation.lastMessage,
      timestamp: conversation.lastMessageTimestamp,
      profilePicUrl: '', // Utilisez une icône de groupe à la place
      isUnread: isUnread,
      isGroup: true,
      memberCount: conversation.members?.length ?? 0,
      onTap: () {
        setState(() {
          selectedConversationId = conversation.id;
          selectedOtherUserName = conversation.groupName ?? 'Groupe';
        });
      },
    );
  }

  Widget _buildUserConversationItem(Conversation conversation) {
    final otherUserId = conversation.particulierId == widget.currentUserId
        ? conversation.entrepriseId
        : conversation.particulierId;

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const SizedBox(height: 72);
        }

        final userData = userSnapshot.data!.data() as Map<String, dynamic>;
        final String firstName = userData['firstName'] ?? '';
        final String lastName = userData['lastName'] ?? '';
        final String profilePicUrl = userData['image_profile'] ?? '';
        final bool isUnread = conversation.unreadBy == widget.currentUserId;

        return ConversationListItem(
          name: '$firstName $lastName',
          lastMessage: conversation.lastMessage,
          timestamp: conversation.lastMessageTimestamp,
          profilePicUrl: profilePicUrl,
          isUnread: isUnread,
          isGroup: false,
          onTap: () {
            setState(() {
              selectedConversationId = conversation.id;
              selectedOtherUserName = '$firstName $lastName';
            });
          },
        );
      },
    );
  }
}

class ConversationListItem extends StatelessWidget {
  final String name;
  final String lastMessage;
  final DateTime timestamp;
  final String profilePicUrl;
  final bool isUnread;
  final bool isGroup;
  final int? memberCount;
  final VoidCallback onTap;

  const ConversationListItem({
    super.key,
    required this.name,
    required this.lastMessage,
    required this.timestamp,
    required this.profilePicUrl,
    required this.isUnread,
    required this.onTap,
    this.isGroup = false,
    this.memberCount,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUnread ? Colors.blue.withOpacity(0.1) : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: isGroup ? Colors.grey[300] : Colors.blue[100],
              backgroundImage: !isGroup && profilePicUrl.isNotEmpty
                  ? NetworkImage(profilePicUrl)
                  : null,
              child: (isGroup || profilePicUrl.isEmpty)
                  ? Icon(
                      isGroup ? Icons.group : Icons.person,
                      color: Colors.white,
                      size: 24,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight:
                          isUnread ? FontWeight.bold : FontWeight.normal,
                      fontSize: 15,
                    ),
                  ),
                  if (isGroup && memberCount != null)
                    Text(
                      '$memberCount membres',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
                    style: TextStyle(
                      color: isUnread ? Colors.black87 : Colors.grey[600],
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatRelativeTime(timestamp),
                  style: TextStyle(
                    color: isUnread ? Colors.blue : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                if (isUnread)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox(width: 8, height: 8),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
