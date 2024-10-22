import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final String id;
  final String buyerId;
  final String companyId;
  final String postId;
  final int quantity;
  final int price;
  final DateTime pickupDate;
  final DateTime timestamp;
  final String validationCode;
  bool isValidated;

  Reservation({
    required this.id,
    required this.buyerId,
    required this.companyId,
    required this.postId,
    required this.quantity,
    required this.price,
    required this.pickupDate,
    required this.timestamp,
    required this.validationCode,
    this.isValidated = false,
  });

  factory Reservation.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Reservation(
      id: doc.id,
      buyerId: data['buyerId'],
      companyId: data['companyId'],
      postId: data['postId'],
      quantity: data['quantity'],
      price: data['price'],
      pickupDate: (data['pickupDate'] as Timestamp).toDate(),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      validationCode: data['validationCode'],
      isValidated: data['isValidated'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'buyerId': buyerId,
      'companyId': companyId,
      'postId': postId,
      'quantity': quantity,
      'price': price,
      'pickupDate': Timestamp.fromDate(pickupDate),
      'timestamp': Timestamp.fromDate(timestamp),
      'validationCode': validationCode,
      'isValidated': isValidated,
    };
  }
}
