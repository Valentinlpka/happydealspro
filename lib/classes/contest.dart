import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:happy_deals_pro/classes/post.dart';

class Gift {
  final String name;
  final String imageUrl;

  Gift({
    required this.name,
    required this.imageUrl,
  });

  factory Gift.fromMap(Map<String, dynamic> data) {
    return Gift(
      name: data['name'],
      imageUrl: data['image'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': imageUrl,
    };
  }
}

class Contest extends Post {
  final String id;
  final String title;
  final String searchText;
  final String description;
  final List<Gift> gifts;
  final String companyId;
  final String howToParticipate;
  final String conditions;
  final DateTime startDate;
  final DateTime endDate;
  final String giftPhoto;

  Contest({
    required this.id,
    required super.timestamp,
    required this.searchText,
    required this.title,
    required this.description,
    required this.gifts,
    required this.companyId,
    required this.howToParticipate,
    required this.conditions,
    required this.startDate,
    required this.endDate,
    required this.giftPhoto,
    super.views,
    super.likes,
    super.likedBy,
    super.commentsCount,
    super.comments,
  }) : super(
          type: 'contest',
        );

  factory Contest.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Contest(
      id: doc.id,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      title: data['title'],
      searchText: data['searchText'],
      description: data['description'],
      gifts: (data['gifts'] as List<dynamic>)
          .map((giftsData) => Gift.fromMap(giftsData as Map<String, dynamic>))
          .toList(),
      companyId: data['companyId'],
      howToParticipate: data['howToParticipate'],
      conditions: data['conditions'],
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      giftPhoto: data['giftPhoto'],
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
      'title': title,
      'searchText': searchText,
      'description': description,
      'gifts': gifts,
      'companyId': companyId,
      'howToParticipate': howToParticipate,
      'conditions': conditions,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'giftPhoto': giftPhoto,
    });
    return map;
  }

  Map<String, dynamic> toEditableMap() {
    return {
      'title': title,
      'searchText': searchText,
      'description': description,
      'gifts': gifts,
      'howToParticipate': howToParticipate,
      'conditions': conditions,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'giftPhoto': giftPhoto,
    };
  }
}
