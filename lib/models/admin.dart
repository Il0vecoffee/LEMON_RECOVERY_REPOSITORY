import 'package:cloud_firestore/cloud_firestore.dart';

class Admin {
  final String uid;
  final String email;
  final String name;
  final DateTime createdAt;

  Admin({
    required this.uid,
    required this.email,
    required this.name,
    required this.createdAt,
  });

  factory Admin.fromMap(Map<String, dynamic> map, String uid) {
    return Admin(
      uid: uid,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      createdAt: (map['createdAt'] as Timestamp? ?? Timestamp.now()).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
