import 'package:cloud_firestore/cloud_firestore.dart';

enum UserType { company, admin }

class Users {
  final String id;
  final String email;
  final UserType type;

  Users({required this.id, required this.email, required this.type});

  factory Users.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Users(
      id: doc.id,
      email: data['email'] ?? '',
      type: UserType.values.firstWhere(
        (e) => e.toString() == 'UserType.${data['type']}',
        orElse: () => UserType.company,
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'type': type.toString().split('.').last,
    };
  }
}
