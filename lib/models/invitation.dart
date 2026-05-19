import 'package:cloud_firestore/cloud_firestore.dart';

class AdminInvitation {
  final String token;
  final bool isUsed;
  final DateTime createdAt;

  AdminInvitation({
    required this.token,
    required this.isUsed,
    required this.createdAt,
  });

  factory AdminInvitation.fromMap(Map<String, dynamic> map, String token) {
    return AdminInvitation(
      token: token,
      isUsed: map['isUsed'] ?? false,
      createdAt: (map['createdAt'] as Timestamp? ?? Timestamp.now()).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isUsed': isUsed,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
