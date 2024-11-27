// conversation_provider_pro.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:happy_deals_pro/classes/conversation_pro.dart';

class ConversationService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Conversation>> getUserConversations(String userId) {
    return _firestore
        .collection('conversations')
        .where(Filter.or(
          Filter('particulierId', isEqualTo: userId),
          Filter('entrepriseId', isEqualTo: userId),
          Filter('memberIds', arrayContains: userId), // Pour les groupes
        ))
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Conversation.fromFirestore(doc))
            .toList());
  }

  Future<String> createGroupConversation(
    String creatorId,
    List<Map<String, dynamic>> members,
    String groupName,
  ) async {
    // Créer la conversation de groupe
    final docRef = await _firestore.collection('conversations').add({
      'isGroup': true,
      'groupName': groupName,
      'creatorId': creatorId,
      'members': members,
      'memberIds': members.map((m) => m['id']).toList(),
      'lastMessage': 'Groupe créé',
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
      'lastMessageSenderId': creatorId,
      'unreadCount': 0,
      'unreadBy': [],
    });

    // Ajouter le message système de création
    await _firestore
        .collection('conversations')
        .doc(docRef.id)
        .collection('messages')
        .add({
      'content': 'Groupe "$groupName" créé',
      'senderId': creatorId,
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'system',
    });

    return docRef.id;
  }

  Stream<List<Message>> getConversationMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList());
  }

  Future<void> sendMessage(
    String conversationId,
    String senderId,
    String content,
  ) async {
    try {
      final conversationDoc = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .get();
      if (!conversationDoc.exists) return;

      final conversationData = conversationDoc.data()!;
      final bool isGroup = conversationData['isGroup'] ?? false;

      // Ajouter le message
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add({
        'senderId': senderId,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
        'isDeleted': false,
        'isEdited': false,
      });

      // Mettre à jour la conversation
      if (isGroup) {
        // Pour les groupes, marquer comme non lu pour tous les membres sauf l'expéditeur
        final List<String> memberIds =
            List<String>.from(conversationData['memberIds'] ?? []);
        final List<String> unreadBy =
            memberIds.where((id) => id != senderId).toList();

        await _firestore
            .collection('conversations')
            .doc(conversationId)
            .update({
          'lastMessage': content,
          'lastMessageTimestamp': FieldValue.serverTimestamp(),
          'unreadCount': unreadBy.length,
          'unreadBy': unreadBy,
          'lastMessageSenderId': senderId,
        });
      } else {
        // Pour les conversations normales
        final recipientId = conversationData['particulierId'] == senderId
            ? conversationData['entrepriseId']
            : conversationData['particulierId'];

        await _firestore
            .collection('conversations')
            .doc(conversationId)
            .update({
          'lastMessage': content,
          'lastMessageTimestamp': FieldValue.serverTimestamp(),
          'unreadCount': 1,
          'unreadBy': recipientId,
          'lastMessageSenderId': senderId,
        });
      }

      notifyListeners();
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  Future<void> markMessageAsRead(String conversationId, String userId) async {
    try {
      final conversationDoc = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .get();
      final conversationData = conversationDoc.data()!;
      final bool isGroup = conversationData['isGroup'] ?? false;

      if (isGroup) {
        // Pour les groupes
        final List<dynamic> currentUnreadBy =
            List<dynamic>.from(conversationData['unreadBy'] ?? []);
        if (currentUnreadBy.contains(userId)) {
          currentUnreadBy.remove(userId);
          await _firestore
              .collection('conversations')
              .doc(conversationId)
              .update({
            'unreadBy': currentUnreadBy,
            'unreadCount': currentUnreadBy.length,
          });
        }
      } else {
        // Pour les conversations normales
        if (conversationData['unreadBy'] == userId) {
          await _firestore
              .collection('conversations')
              .doc(conversationId)
              .update({
            'unreadCount': 0,
            'unreadBy': null,
          });
        }
      }
      notifyListeners();
    } catch (e) {
      print('Error marking message as read: $e');
    }
  }

  // Ajouter un membre au groupe
  Future<void> addGroupMember(
    String conversationId,
    Map<String, dynamic> newMember,
  ) async {
    try {
      await _firestore.collection('conversations').doc(conversationId).update({
        'members': FieldValue.arrayUnion([newMember]),
        'memberIds': FieldValue.arrayUnion([newMember['id']]),
      });

      // Ajouter un message système
      await sendSystemMessage(
        conversationId,
        '${newMember['name']} a rejoint le groupe',
      );
    } catch (e) {
      print('Error adding group member: $e');
      rethrow;
    }
  }

  // Envoyer un message système
  Future<void> sendSystemMessage(String conversationId, String content) async {
    await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .add({
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'system',
    });

    await _firestore.collection('conversations').doc(conversationId).update({
      'lastMessage': content,
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<String> getOrCreateConversation(
    String particulierId,
    String entrepriseId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('conversations')
          .where('particulierId', isEqualTo: particulierId)
          .where('entrepriseId', isEqualTo: entrepriseId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      }

      final docRef = await _firestore.collection('conversations').add({
        'particulierId': particulierId,
        'entrepriseId': entrepriseId,
        'lastMessage': '',
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
        'unreadCount': 0,
        'unreadBy': '',
        'lastMessageSenderId': '',
      });

      return docRef.id;
    } catch (e) {
      print('Error in getOrCreateConversation: $e');
      rethrow;
    }
  }

  Future<void> deleteMessage(String conversationId, String messageId) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .update({
        'isDeleted': true,
        'content': 'Message supprimé',
      });
    } catch (e) {
      print('Error deleting message: $e');
      rethrow;
    }
  }

  Future<void> editMessage(
    String conversationId,
    String messageId,
    String newContent,
  ) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .update({
        'content': newContent,
        'isEdited': true,
        'editedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error editing message: $e');
      rethrow;
    }
  }
}
