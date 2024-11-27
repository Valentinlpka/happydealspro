import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:happy_deals_pro/classes/post.dart';

class PromoCodePost extends Post {
  final String code;
  final double value;
  final bool isPercentage;
  final DateTime expiresAt;
  final String description;
  final int? maxUses;
  final int currentUses;
  final bool isStoreWide;
  final List<String> applicableProductIds;
  final String companyId; // Ajout du companyId
  final String sellerId; // Ajout du sellerId

  PromoCodePost({
    required super.timestamp,
    required this.code,
    required this.companyId, // Ajout du companyId comme paramètre requis
    required this.sellerId, // Ajout du sellerId comme paramètre requis
    required this.value,
    required this.isPercentage,
    required this.expiresAt,
    required this.description,
    this.maxUses,
    this.currentUses = 0,
    required this.isStoreWide,
    required this.applicableProductIds,
    super.views,
    super.likes,
    super.likedBy,
    super.commentsCount,
    super.comments,
  }) : super(
          type: 'promo_code',
        );

  factory PromoCodePost.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PromoCodePost(
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      code: data['code'] ?? '',
      value: (data['value'] ?? 0).toDouble(),
      isPercentage: data['isPercentage'] ?? false,
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
      description: data['description'] ?? '',
      maxUses: data['maxUses'],
      companyId: data['companyId'],
      sellerId: data['sellerId'],
      currentUses: data['currentUses'] ?? 0,
      isStoreWide: data['isStoreWide'] ?? true,
      applicableProductIds:
          List<String>.from(data['applicableProductIds'] ?? []),
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
      'code': code,
      'value': value,
      'isPercentage': isPercentage,
      'expiresAt': Timestamp.fromDate(expiresAt),
      'description': description,
      'maxUses': maxUses,
      'sellerId': sellerId,
      'companyId': companyId,
      'currentUses': currentUses,
      'isStoreWide': isStoreWide,
      'applicableProductIds': applicableProductIds,
    });
    return map;
  }
}
