// conversation_pro.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isDeleted;
  final bool isEdited;
  final String? type; // Pour les messages système dans les groupes

  Message({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.isDeleted = false,
    this.isEdited = false,
    this.type,
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isDeleted: data['isDeleted'] ?? false,
      isEdited: data['isEdited'] ?? false,
      type: data['type'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'isDeleted': isDeleted,
      'isEdited': isEdited,
      'type': type,
    };
  }
}

class Conversation {
  final String id;
  final String? particulierId;
  final String? entrepriseId;
  final String lastMessage;
  final DateTime lastMessageTimestamp;
  final int unreadCount;
  final dynamic
      unreadBy; // Changé en dynamic pour supporter les listes pour les groupes
  final String lastMessageSenderId;
  final bool isGroup;
  final String? groupName;
  final List<Map<String, dynamic>>? members;
  final String? creatorId;

  Conversation({
    required this.id,
    this.particulierId,
    this.entrepriseId,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    this.unreadCount = 0,
    required this.unreadBy,
    required this.lastMessageSenderId,
    this.isGroup = false,
    this.groupName,
    this.members,
    this.creatorId,
  });

  factory Conversation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime timestamp;
    try {
      timestamp = data['lastMessageTimestamp'] != null
          ? (data['lastMessageTimestamp'] as Timestamp).toDate()
          : DateTime.now();
    } catch (e) {
      timestamp = DateTime.now();
    }

    return Conversation(
      id: doc.id,
      particulierId: data['particulierId'],
      entrepriseId: data['entrepriseId'],
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTimestamp: timestamp,
      unreadCount: (data['unreadCount'] as num?)?.toInt() ?? 0,
      unreadBy: data['unreadBy'],
      lastMessageSenderId: data['lastMessageSenderId'] ?? '',
      isGroup: data['isGroup'] ?? false,
      groupName: data['groupName'],
      members: data['members'] != null
          ? List<Map<String, dynamic>>.from(data['members'])
          : null,
      creatorId: data['creatorId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'particulierId': particulierId,
      'entrepriseId': entrepriseId,
      'lastMessage': lastMessage,
      'lastMessageTimestamp': Timestamp.fromDate(lastMessageTimestamp),
      'unreadCount': unreadCount,
      'unreadBy': unreadBy,
      'lastMessageSenderId': lastMessageSenderId,
      'isGroup': isGroup,
      'groupName': groupName,
      'members': members,
      'creatorId': creatorId,
    }..removeWhere((key, value) => value == null); // Retire les valeurs nulles
  }

  // Méthodes utilitaires
  bool hasUnreadMessages(String userId) {
    if (isGroup) {
      return (unreadBy as List?)?.contains(userId) ?? false;
    }
    return unreadBy == userId;
  }

  String? getOtherUserId(String currentUserId) {
    if (isGroup) return null;
    return particulierId == currentUserId ? entrepriseId : particulierId;
  }

  bool isMember(String userId) {
    if (!isGroup) {
      return userId == particulierId || userId == entrepriseId;
    }
    return members?.any((member) => member['id'] == userId) ?? false;
  }
}
