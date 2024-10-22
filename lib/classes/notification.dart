import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String message;
  final String relatedId;
  final DateTime timestamp;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.message,
    required this.relatedId,
    required this.timestamp,
    this.isRead = false,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: data['type'] ?? '',
      message: data['message'] ?? '',
      relatedId: data['relatedId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'message': message,
      'relatedId': relatedId,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }
}
