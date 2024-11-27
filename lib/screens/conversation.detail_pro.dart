// conversation_detail_pro.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:happy_deals_pro/classes/conversation_pro.dart';
import 'package:happy_deals_pro/providers/conversation_provider_pro.dart';
import 'package:provider/provider.dart';

class ConversationDetailScreen extends StatefulWidget {
  final String conversationId;
  final String otherUserName;

  const ConversationDetailScreen({
    super.key,
    required this.conversationId,
    required this.otherUserName,
  });

  @override
  State<ConversationDetailScreen> createState() =>
      _ConversationDetailScreenState();
}

class _ConversationDetailScreenState extends State<ConversationDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isFirstLoad = true;
  String? _selectedMessageId;
  bool _showActions = false;
  Map<String, String> _memberNames = {};
  bool isGroup = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_isFirstLoad) {
        final conversationService =
            Provider.of<ConversationService>(context, listen: false);
        final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
        conversationService.markMessageAsRead(
            widget.conversationId, currentUserId);
        _isFirstLoad = false;
        // Charger les infos du groupe
        final doc = await FirebaseFirestore.instance
            .collection('conversations')
            .doc(widget.conversationId)
            .get();
        if (!mounted) return;

        setState(() {
          isGroup = doc.data()?['isGroup'] ?? false;
          if (isGroup) {
            final members =
                List<Map<String, dynamic>>.from(doc.data()?['members'] ?? []);
            _memberNames = Map.fromEntries(members.map((member) =>
                MapEntry(member['id'] as String, member['name'] as String)));
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      body: Material(
        // Ajout du Material widget
        child: Column(
          children: [
            // En-tête
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.otherUserName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isGroup)
                    IconButton(
                      icon: const Icon(Icons.group),
                      onPressed: _showGroupInfo,
                      tooltip: 'Voir les membres',
                    ),
                ],
              ),
            ),
            // Liste des messages
            Expanded(
              child: StreamBuilder<List<Message>>(
                stream: Provider.of<ConversationService>(context)
                    .getConversationMessages(widget.conversationId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data!;

                  // Grouper les messages par date
                  final groupedMessages = <DateTime, List<Message>>{};
                  for (var message in messages) {
                    final date = DateTime(
                      message.timestamp.year,
                      message.timestamp.month,
                      message.timestamp.day,
                    );
                    if (!groupedMessages.containsKey(date)) {
                      groupedMessages[date] = [];
                    }
                    groupedMessages[date]!.add(message);
                  }

                  final dates = groupedMessages.keys.toList()
                    ..sort((a, b) => b.compareTo(a));

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    itemCount: dates.length * 2 - 1,
                    itemBuilder: (context, index) {
                      if (index.isOdd) {
                        final dateIndex = index ~/ 2;
                        return _buildDateDivider(dates[dateIndex]);
                      }

                      final dateIndex = index ~/ 2;
                      final date = dates[dateIndex];
                      final messagesForDate = groupedMessages[date]!
                        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

                      return Column(
                        children: messagesForDate.map((message) {
                          final bool isMe = message.senderId == currentUserId;
                          return MessageBubble(
                            message: message,
                            isMe: isMe,
                            isSelected: _selectedMessageId == message.id,
                            showActions: _showActions && isMe,
                            senderName: isGroup && !isMe
                                ? _memberNames[message.senderId]
                                : null,
                            onTap: isMe
                                ? () {
                                    setState(() {
                                      if (_selectedMessageId == message.id) {
                                        _selectedMessageId = null;
                                        _showActions = false;
                                      } else {
                                        _selectedMessageId = message.id;
                                        _showActions = true;
                                      }
                                    });
                                  }
                                : null,
                            onEdit: isMe
                                ? () => _showEditDialog(context, message)
                                : null,
                            onDelete: isMe
                                ? () => _showDeleteDialog(context, message)
                                : null,
                          );
                        }).toList(),
                      );
                    },
                  );
                },
              ),
            ),
            // Zone de saisie
            Material(
              // Ajout du Material widget pour le TextField
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Tapez votre message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(currentUserId),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () => _sendMessage(currentUserId),
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateDivider(DateTime date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey[300])),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _formatDate(date),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey[300])),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return "Aujourd'hui";
    } else if (date == yesterday) {
      return "Hier";
    } else if (now.difference(date).inDays < 7) {
      return _getWeekDay(date);
    } else {
      return _formatFullDate(date);
    }
  }

  String _getWeekDay(DateTime date) {
    switch (date.weekday) {
      case 1:
        return 'Lundi';
      case 2:
        return 'Mardi';
      case 3:
        return 'Mercredi';
      case 4:
        return 'Jeudi';
      case 5:
        return 'Vendredi';
      case 6:
        return 'Samedi';
      case 7:
        return 'Dimanche';
      default:
        return '';
    }
  }

  String _formatFullDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = _getMonthName(date.month);
    final year = date.year != DateTime.now().year ? ' ${date.year}' : '';
    return '$day $month$year';
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'janvier';
      case 2:
        return 'février';
      case 3:
        return 'mars';
      case 4:
        return 'avril';
      case 5:
        return 'mai';
      case 6:
        return 'juin';
      case 7:
        return 'juillet';
      case 8:
        return 'août';
      case 9:
        return 'septembre';
      case 10:
        return 'octobre';
      case 11:
        return 'novembre';
      case 12:
        return 'décembre';
      default:
        return '';
    }
  }

  void _sendMessage(String currentUserId) {
    if (_messageController.text.trim().isEmpty) return;

    Provider.of<ConversationService>(context, listen: false).sendMessage(
      widget.conversationId,
      currentUserId,
      _messageController.text,
    );

    _messageController.clear();
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _showEditDialog(BuildContext context, Message message) {
    final TextEditingController editController =
        TextEditingController(text: message.content);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le message'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(
            hintText: 'Nouveau message...',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Provider.of<ConversationService>(context, listen: false)
                  .editMessage(
                widget.conversationId,
                message.id,
                editController.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  void _showGroupInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.otherUserName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_memberNames.length} membres',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 16),
            ...(_memberNames.entries
                .map((entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue[100],
                            child: Text(
                              entry.value[0].toUpperCase(),
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(entry.value),
                        ],
                      ),
                    ))
                .toList()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Message message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le message'),
        content: const Text('Voulez-vous vraiment supprimer ce message ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Provider.of<ConversationService>(context, listen: false)
                  .deleteMessage(widget.conversationId, message.id);
              setState(() {
                _selectedMessageId = null;
                _showActions = false;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Message supprimé'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool isSelected;
  final bool showActions;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final String? senderName;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.isSelected = false,
    this.showActions = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.senderName, // Ajoutez ce paramètre
  });

  @override
  Widget build(BuildContext context) {
    if (message.isDeleted) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Message supprimé',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (showActions) ...[
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: onEdit,
                color: Colors.grey[600],
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: onDelete,
                color: Colors.red[400],
              ),
            ],
            Flexible(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isMe ? Colors.blue[400] : Colors.grey[300])
                      : (isMe ? Colors.blue[600] : Colors.grey[200]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (!isMe && senderName != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          senderName!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    Text(
                      message.content,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                    if (message.isEdited)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Modifié',
                          style: TextStyle(
                            color: isMe ? Colors.white70 : Colors.grey[600],
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          color: isMe ? Colors.white70 : Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
