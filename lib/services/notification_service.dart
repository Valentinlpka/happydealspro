import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:happy_deals_pro/classes/notification.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }

  Future<void> markAsRead(String notificationId) {
    return _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }
}
