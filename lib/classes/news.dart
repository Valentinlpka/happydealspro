import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:happy_deals_pro/classes/post.dart';

class News extends Post {
  final String id;
  final String title;
  final String searchText;
  final String content;
  final String companyId;
  final List<String> photos;

  News({
    required this.id,
    required super.timestamp,
    required this.title,
    required this.searchText,
    required this.content,
    required this.companyId,
    required this.photos,
    super.views,
    super.likes,
    super.likedBy,
    super.commentsCount,
    super.comments,
  }) : super(type: 'news');

  factory News.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return News(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      photos: List<String>.from(data['photos'] ?? []),
      companyId: data['companyId'] ?? FirebaseAuth.instance.currentUser?.uid,
      searchText: data['searchText'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'title': title,
      'searchText': searchText,
      'content': content,
      'photos': photos,
      'timestamp': timestamp,
      'companyId': companyId,
    });
    return map;
  }

  Map<String, dynamic> toEditableMap() {
    return {
      'title': title,
      'searchText': searchText,
      'content': content,
      'photos': photos,
      'timestamp': timestamp,
      'companyId': companyId,
    };
  }
}
