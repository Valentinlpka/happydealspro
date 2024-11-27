import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:happy_deals_pro/classes/post.dart';

class ExpressDeal extends Post {
  final String id;
  final String title;
  final String searchText;
  List<DateTime> pickupTimes; // Remplace pickupTime
  final String content;
  final String companyId;
  final int basketCount;
  final int price;
  final String stripeAccountId;
  final String stripeProductId;
  final String stripePriceId;

  ExpressDeal({
    required this.id,
    required super.timestamp,
    required this.title,
    required this.searchText,
    required this.content,
    required this.companyId,
    required this.basketCount,
    required this.price,
    required this.stripeAccountId,
    required this.pickupTimes,
    super.views,
    super.likes,
    super.likedBy,
    super.commentsCount,
    super.comments,
    required this.stripeProductId,
    required this.stripePriceId,
  }) : super(
          type: 'express_deal',
        );

  factory ExpressDeal.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExpressDeal(
      id: doc.id,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      title: data['title'],
      searchText: data['searchText'],
      content: data['content'],
      companyId: data['companyId'],
      stripePriceId: data['stripePriceId'] ?? "",
      stripeProductId: data['stripeProductId'] ?? "",
      basketCount: data['basketCount'],
      price: data['price'],
      stripeAccountId: data['stripeAccountId'] ?? '',
      views: data['views'] ?? 0,
      likes: data['likes'] ?? 0,
      pickupTimes: (data['pickupTimes'] as List<dynamic>?)
              ?.map((item) => (item as Timestamp).toDate())
              .toList() ??
          [],
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
      'title': title,
      'searchText': searchText,
      'pickupTimes':
          pickupTimes.map((time) => Timestamp.fromDate(time)).toList(),
      'content': content,
      'companyId': companyId,
      'basketCount': basketCount,
      'price': price,
      'stripeAccountId': stripeAccountId,
      'stripePriceId': stripePriceId,
      'stripeProductId': stripeProductId,
    });
    return map;
  }

  Map<String, dynamic> toEditableMap() {
    return {
      'title': title,
      'searchText': searchText,
      'pickupTimes':
          pickupTimes.map((time) => Timestamp.fromDate(time)).toList(),
      'content': content,
      'basketCount': basketCount,
      'price': price,
      'stripeAccountId': stripeAccountId,
      'stripeProductId': stripeProductId,
      'stripePriceId': stripePriceId,
    };
  }
}
