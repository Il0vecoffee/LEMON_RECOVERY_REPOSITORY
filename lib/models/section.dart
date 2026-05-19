import 'package:cloud_firestore/cloud_firestore.dart';

class Section {
  final String id;
  final String name; // Document ID usually acts as name in LIME, but let's see.
  // Actually LIME uses doc.id as the section name mostly.
  final List<String> teacherUids;
  final String? adviserUid;
  final List<String> studentUids;
  final List<Map<String, dynamic>> schedule;
  final int gradeLevel;

  Section({
    required this.id,
    required this.name,
    this.teacherUids = const [],
    this.adviserUid,
    this.studentUids = const [],
    this.schedule = const [],
    this.gradeLevel = 0,
  });

  factory Section.fromMap(Map<String, dynamic> map, String id) {
    // Handle potential DocumentReference for adviser_uid
    dynamic rawAdviser = map['adviser_uid'] ?? map['adviserUid'] ?? map['adviser'];
    String? adviserId;
    if (rawAdviser is DocumentReference) {
      adviserId = rawAdviser.id;
    } else if (rawAdviser != null) {
      adviserId = rawAdviser.toString();
    }

    return Section(
      id: id,
      name: id, // LIME uses doc ID as section name
      teacherUids: (map['teacher_uids'] as List?)?.map((e) => e.toString()).toList() ?? 
                   (map['teacherUids'] as List?)?.map((e) => e.toString()).toList() ?? [],
      adviserUid: adviserId,
      studentUids: (map['student_uids'] as List?)?.map((e) => e.toString()).toList() ??
                   (map['studentUids'] as List?)?.map((e) => e.toString()).toList() ?? [],
      schedule: (map['schedule'] as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [],
      gradeLevel: int.tryParse(map['grade_level']?.toString() ?? map['gradeLevel']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'teacher_uids': teacherUids,
      'adviser_uid': adviserUid,
      'student_uids': studentUids,
      'schedule': schedule,
      'grade_level': gradeLevel,
    };
  }
}
