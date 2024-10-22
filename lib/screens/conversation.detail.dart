import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:happy_deals_pro/classes/conversation.dart';
import 'package:happy_deals_pro/providers/conversation_provider.dart';
import 'package:provider/provider.dart';

class ConversationDetailScreen extends StatefulWidget {
  final String conversationId;

  const ConversationDetailScreen(
      {super.key, required this.conversationId, required String otherUserName});

  @override
  State<ConversationDetailScreen> createState() =>
      _ConversationDetailScreenState();
}

class _ConversationDetailScreenState extends State<ConversationDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isFirstLoad) {
        final conversationService =
            Provider.of<ConversationService>(context, listen: false);
        final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
        conversationService.markMessageAsRead(
            widget.conversationId, currentUserId);
        _isFirstLoad = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversationService =
        Provider.of<ConversationService>(context, listen: false);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      appBar: AppBar(title: const Text('Conversation')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: conversationService
                  .getConversationMessages(widget.conversationId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Aucun message'));
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final message = snapshot.data![index];
                    return MessageBubble(
                      message: message,
                      isMe: message.senderId == currentUserId,
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Entrez votre message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      conversationService.sendMessage(
                        widget.conversationId,
                        currentUserId,
                        _messageController.text,
                      );
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message.content,
          style: TextStyle(color: isMe ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}
