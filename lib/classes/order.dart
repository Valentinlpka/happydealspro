// lib/models/order.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Orders {
  final String id;
  final String userId;
  final String merchantId;
  final List<OrderItem> items;
  final double totalAmount;
  String status;
  final DateTime createdAt;
  String? pickupCode;
  final DocumentReference reference;
  final String entrepriseId;

  Orders({
    required this.id,
    required this.userId,
    required this.merchantId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.pickupCode,
    required this.reference,
    required this.entrepriseId,
  });

  factory Orders.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Orders(
      id: doc.id,
      userId: data['userId'] ?? '',
      merchantId: data['merchantId'] ?? '',
      items: (data['items'] as List? ?? [])
          .map((item) => OrderItem.fromMap(item))
          .toList(),
      totalAmount: (data['totalPrice'] ?? 0).toDouble(),
      status: data['status'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      pickupCode: data['pickupCode'],
      entrepriseId: data['entrepriseId'],
      reference: doc.reference,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'merchantId': merchantId,
      'totalAmount': totalAmount,
      'items': items,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'pickupCode': pickupCode,
      'entrepriseId': entrepriseId
    };
  }
}

class OrderItem {
  final String productId;
  final String image;
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.image,
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      image: map['image'] ?? '',
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'image': image,
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }
}
