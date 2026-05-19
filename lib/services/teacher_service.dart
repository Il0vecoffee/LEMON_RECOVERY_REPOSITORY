import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/teacher.dart';

class TeacherService {
  final CollectionReference _teachersCollection =
      FirebaseFirestore.instance.collection('teachers');

  // Get stream of all teachers
  Stream<List<Teacher>> getTeachers() {
    return _teachersCollection.orderBy('name').snapshots().map((snapshot) {
      final List<Teacher> teachers = [];
      for (var doc in snapshot.docs) {
        try {
          teachers.add(Teacher.fromMap(doc.data() as Map<String, dynamic>, doc.id));
        } catch (e) {
          debugPrint('Error parsing teacher document ${doc.id}: $e');
        }
      }
      return teachers;
    });
  }

  // Add new teacher
  Future<void> addTeacher(Teacher teacher) async {
    await _teachersCollection.doc(teacher.uid).set(teacher.toMap());
  }

  // Update teacher
  Future<void> updateTeacher(Teacher teacher) async {
    await _teachersCollection.doc(teacher.uid).update(teacher.toMap());
  }

  // Toggle suspension
  Future<void> toggleSuspension(String uid, bool currentStatus) async {
    await _teachersCollection.doc(uid).update({
      'is_suspended': !currentStatus,
      'isSuspended': !currentStatus,
    });
  }

  // Delete teacher
  Future<void> deleteTeacher(String uid) async {
    await _teachersCollection.doc(uid).delete();
  }

  // Update warning message
  Future<void> updateWarning(String uid, String? message) async {
    await _teachersCollection.doc(uid).update({'warning': message});
  }
}
