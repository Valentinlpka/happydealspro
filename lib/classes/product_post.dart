import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:happy_deals_pro/classes/post.dart';
import 'package:happy_deals_pro/classes/product.dart';

class ProductPost extends Post {
  final String id;
  final String name;
  final String description;
  final double price;
  final double tva;
  final List<String> images;
  final int stock;
  final bool isActive;
  final String productId;
  final String sellerId;
  final String companyId;
  final bool hasActiveHappyDeal;
  final double? discountedPrice;
  final double? discountPercentage;

  ProductPost({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.tva,
    required this.images,
    required this.stock,
    required this.isActive,
    required this.productId,
    required this.sellerId,
    required this.companyId,
    required super.timestamp,
    this.hasActiveHappyDeal = false,
    this.discountedPrice,
    this.discountPercentage,
    super.views = 0,
    super.likes = 0,
    super.likedBy = const [],
    super.commentsCount = 0,
    super.comments = const [],
  }) : super(type: 'product');

  factory ProductPost.fromProduct(Product product) {
    return ProductPost(
      id: product.id, // Utiliser l'ID du produit
      name: product.name,
      description: product.description,
      price: product.price,
      tva: product.tva,
      images: product.images,
      stock: product.stock,
      isActive: product.isActive,
      productId: product.id, // Utiliser le même ID
      sellerId: product.sellerId,
      companyId: product.sellerId,
      timestamp: DateTime.now(),
      hasActiveHappyDeal: product.hasActiveHappyDeal,
      discountedPrice: product.discountedPrice,
      discountPercentage: product.discountPercentage,
    );
  }

// Ajouter une méthode spécifique pour créer un ProductPost avec un ID de produit spécifique
  static ProductPost fromProductWithId(Product product, String productId) {
    return ProductPost(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      tva: product.tva,
      images: product.images,
      stock: product.stock,
      isActive: product.isActive,
      productId: productId,
      sellerId: product.sellerId,
      companyId: product.sellerId,
      timestamp: DateTime.now(),
      hasActiveHappyDeal: product.hasActiveHappyDeal,
      discountedPrice: product.discountedPrice,
      discountPercentage: product.discountPercentage,
    );
  }

  factory ProductPost.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductPost(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      tva: (data['tva'] ?? 0.0).toDouble(),
      images: List<String>.from(data['images'] ?? []),
      stock: data['stock'] ?? 0,
      isActive: data['isActive'] ?? true,
      productId: data['productId'] ?? '',
      sellerId: data['sellerId'] ?? '',
      companyId: data['companyId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      hasActiveHappyDeal: data['hasActiveHappyDeal'] ?? false,
      discountedPrice: data['discountedPrice']?.toDouble(),
      discountPercentage: data['discountPercentage']?.toDouble(),
      views: data['views'] ?? 0,
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      commentsCount: data['commentsCount'] ?? 0,
      comments: (data['comments'] as List<dynamic>?)
              ?.map((commentData) => Comment.fromMap(commentData))
              .toList() ??
          [],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'tva': tva,
      'images': images,
      'stock': stock,
      'isActive': isActive,
      'productId': productId,
      'sellerId': sellerId,
      'companyId': companyId,
      'hasActiveHappyDeal': hasActiveHappyDeal,
      'discountedPrice': discountedPrice,
      'discountPercentage': discountPercentage,
    });
    return map;
  }

  // Méthode pour créer une copie avec des modifications
  ProductPost copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? tva,
    List<String>? images,
    int? stock,
    bool? isActive,
    String? productId,
    String? sellerId,
    String? companyId,
    DateTime? timestamp,
    bool? hasActiveHappyDeal,
    double? discountedPrice,
    double? discountPercentage,
    int? views,
    int? likes,
    List<String>? likedBy,
    int? commentsCount,
    List<Comment>? comments,
  }) {
    return ProductPost(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      tva: tva ?? this.tva,
      images: images ?? this.images,
      stock: stock ?? this.stock,
      isActive: isActive ?? this.isActive,
      productId: productId ?? this.productId,
      companyId: companyId ?? this.companyId,
      sellerId: sellerId ?? this.sellerId,
      timestamp: timestamp ?? this.timestamp,
      hasActiveHappyDeal: hasActiveHappyDeal ?? this.hasActiveHappyDeal,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
      commentsCount: commentsCount ?? this.commentsCount,
      comments: comments ?? this.comments,
    );
  }
}
