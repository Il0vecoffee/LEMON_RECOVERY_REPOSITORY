import 'package:flutter/foundation.dart';
class Student {
  final String uid;
  final String name;
  final String studentId;
  final Map<String, Map<String, double>> grades;
  final String? profileImageUrl;
  final bool isSuspended;
  final String? warning;

  Student({
    required this.uid,
    required this.name,
    required this.studentId,
    this.grades = const {},
    this.profileImageUrl,
    this.isSuspended = false,
    this.warning,
  });

  factory Student.fromMap(Map<String, dynamic> map, String uid) {
    // Parse grades safely
    final rawGrades = map['grades'] as Map<dynamic, dynamic>? ?? {};
    final Map<String, Map<String, double>> parsedGrades = {};

    rawGrades.forEach((subject, value) {
      if (value is Map) {
        parsedGrades[subject.toString()] = Map<String, double>.from(
          value.map((k, v) => MapEntry(k.toString(), (v as num?)?.toDouble() ?? 0.0))
        );
      }
    });

    return Student(
      uid: uid,
      name: map['name'] ?? '',
      studentId: map['studentId'] ?? map['student_id'] ?? '',
      grades: parsedGrades,
      profileImageUrl: map['profileImageUrl'] ?? map['profile_image_url'] ?? map['photoURL'] ?? map['profilePhotoUrl'],
      isSuspended: (map['is_suspended'] == true) || (map['isSuspended'] == true),
      warning: map['warning']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'studentId': studentId,
      'grades': grades,
      'profileImageUrl': profileImageUrl,
      'uid': uid, // LIME stores UID inside the doc too
      'is_suspended': isSuspended,
      'isSuspended': isSuspended,
      'warning': warning,
    };
  }
  
  // Helper to calculate overall average (simplified)
  double get overallAverage {
    try {
      if (grades.isEmpty) return 0.0;
      
      final List<double> subjectAverages = [];
      
      grades.forEach((_, quarters) {
        final values = quarters.values.where((v) => v > 0).toList();
        if (values.isNotEmpty) {
          subjectAverages.add(values.reduce((a, b) => a + b) / values.length);
        }
      });

      if (subjectAverages.isEmpty) return 0.0;
      return subjectAverages.reduce((a, b) => a + b) / subjectAverages.length;
    } catch (e) {
      debugPrint('Error calculating average for student $uid: $e');
      return 0.0;
    }
  }
}
