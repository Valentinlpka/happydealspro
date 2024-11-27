import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double tva;
  final List<String> images;
  final int stock;
  final bool isActive;
  final String merchantId;
  final String sellerId;
  final String stripeProductId;
  final String stripePriceId;

  // Nouveaux champs pour le Happy Deal
  final bool hasActiveHappyDeal;
  final double? discountedPrice;
  final double? discountPercentage;
  final DateTime? happyDealStartDate;
  final DateTime? happyDealEndDate;

  Product({
    required this.id,
    required this.name,
    required this.tva,
    required this.description,
    required this.price,
    required this.images,
    required this.stock,
    required this.isActive,
    required this.merchantId,
    required this.sellerId,
    required this.stripeProductId,
    required this.stripePriceId,
    this.hasActiveHappyDeal = false,
    this.discountedPrice,
    this.discountPercentage,
    this.happyDealStartDate,
    this.happyDealEndDate,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      tva: (data['tva'] ?? 0).toDouble(),
      images: List<String>.from(data['images'] ?? []),
      stock: data['stock'] ?? 0,
      isActive: data['isActive'] ?? false,
      sellerId: data['sellerId'] ?? FirebaseAuth.instance.currentUser?.uid,
      merchantId: data['merchantId'] ?? '',
      stripeProductId: data['stripeProductId'] ?? '',
      stripePriceId: data['stripePriceId'] ?? '',
      hasActiveHappyDeal: data['hasActiveHappyDeal'] ?? false,
      discountedPrice: data['discountedPrice']?.toDouble(),
      discountPercentage: data['discountPercentage']?.toDouble(),
      happyDealStartDate: data['happyDealStartDate'] != null
          ? (data['happyDealStartDate'] as Timestamp).toDate()
          : null,
      happyDealEndDate: data['happyDealEndDate'] != null
          ? (data['happyDealEndDate'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': id,
      'name': name,
      'description': description,
      'price': price,
      'tva': tva,
      'images': images,
      'stock': stock,
      'isActive': isActive,
      'sellerId': sellerId,
      'merchantId': merchantId,
      'stripeProductId': stripeProductId,
      'stripePriceId': stripePriceId,
      'hasActiveHappyDeal': hasActiveHappyDeal,
      'discountedPrice': discountedPrice,
      'discountPercentage': discountPercentage,
      'happyDealStartDate': happyDealStartDate != null
          ? Timestamp.fromDate(happyDealStartDate!)
          : null,
      'happyDealEndDate': happyDealEndDate != null
          ? Timestamp.fromDate(happyDealEndDate!)
          : null,
    };
  }

  Product copyWith({
    String? id,
    bool? hasActiveHappyDeal,
    double? discountedPrice,
    double? discountPercentage,
    DateTime? happyDealStartDate,
    DateTime? happyDealEndDate,
  }) {
    return Product(
      id: this.id,
      name: name,
      description: description,
      price: price,
      tva: tva,
      images: images,
      stock: stock,
      isActive: isActive,
      merchantId: merchantId,
      sellerId: sellerId,
      stripeProductId: stripeProductId,
      stripePriceId: stripePriceId,
      hasActiveHappyDeal: hasActiveHappyDeal ?? this.hasActiveHappyDeal,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      happyDealStartDate: happyDealStartDate ?? this.happyDealStartDate,
      happyDealEndDate: happyDealEndDate ?? this.happyDealEndDate,
    );
  }
}
