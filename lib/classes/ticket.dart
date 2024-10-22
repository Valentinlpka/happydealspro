import 'package:cloud_firestore/cloud_firestore.dart';

enum TicketStatus { open, inProgress, completed, cancelled }

class TicketMessage {
  final String id;
  final String content;
  final String senderId;
  final DateTime createdAt;

  TicketMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.createdAt,
  });

  factory TicketMessage.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return TicketMessage(
      id: doc.id,
      content: data['content'] ?? '',
      senderId: data['senderId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'content': content,
      'senderId': senderId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class Ticket {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  TicketStatus status;
  final String userId;
  List<TicketMessage> messages;

  Ticket({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.status = TicketStatus.open,
    required this.userId,
    this.messages = const [],
  });

  factory Ticket.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Ticket(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      status: TicketStatus.values.firstWhere(
        (e) => e.toString() == 'TicketStatus.${data['status']}',
        orElse: () => TicketStatus.open,
      ),
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.toString().split('.').last,
      'userId': userId,
    };
  }
}
