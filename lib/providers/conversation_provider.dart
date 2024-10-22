import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:happy_deals_pro/classes/conversation.dart';

class ConversationService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Conversation>> getUserConversations(String userId) {
    return _firestore
        .collection('conversations')
        .where(Filter.or(
          Filter('particulierId', isEqualTo: userId),
          Filter('entrepriseId', isEqualTo: userId),
        ))
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final conversation = Conversation.fromFirestore(doc);
              return conversation;
            }).toList());
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
      String conversationId, String senderId, String content) async {
    final message = Message(
      id: '',
      senderId: senderId,
      content: content,
      timestamp: DateTime.now(),
    );

    final conversationDoc =
        await _firestore.collection('conversations').doc(conversationId).get();
    final conversationData = conversationDoc.data() as Map<String, dynamic>;

    final recipientId = conversationData['particulierId'] == senderId
        ? conversationData['entrepriseId']
        : conversationData['particulierId'];

    await _firestore.collection('conversations').doc(conversationId).update({
      'lastMessage': content,
      'lastMessageTimestamp': Timestamp.fromDate(message.timestamp),
      'unreadCount': FieldValue.increment(1),
      'unreadBy': recipientId,
    });

    await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .add(message.toFirestore());

    notifyListeners();
  }

  Future<void> markMessageAsRead(String conversationId, String userId) async {
    final conversationDoc =
        await _firestore.collection('conversations').doc(conversationId).get();
    final conversationData = conversationDoc.data() as Map<String, dynamic>;

    if (conversationData['unreadBy'] == userId) {
      await _firestore.collection('conversations').doc(conversationId).update({
        'unreadCount': 0,
        'unreadBy': null,
      });
      notifyListeners();
    }
  }

  Future<String> getOrCreateConversation(
      String particulierId, String entrepriseId) async {
    // Vérifier si une conversation existe déjà
    final querySnapshot = await _firestore
        .collection('conversations')
        .where('particulierId', isEqualTo: particulierId)
        .where('entrepriseId', isEqualTo: entrepriseId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Une conversation existe déjà, retourner son ID
      return querySnapshot.docs.first.id;
    } else {
      // Aucune conversation n'existe, en créer une nouvelle
      final conversation = Conversation(
        id: '',
        particulierId: particulierId,
        entrepriseId: entrepriseId,
        lastMessage: '',
        lastMessageTimestamp: DateTime.now(),
      );

      final docRef = await _firestore
          .collection('conversations')
          .add(conversation.toFirestore());
      return docRef.id;
    }
  }
}
