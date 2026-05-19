import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';

class StudentService {
  final CollectionReference _studentsCollection =
      FirebaseFirestore.instance.collection('students');

  // Get stream of all students
  Stream<List<Student>> getStudents() {
    return _studentsCollection.orderBy('name').snapshots().map((snapshot) {
      final List<Student> students = [];
      for (var doc in snapshot.docs) {
        try {
          students.add(Student.fromMap(doc.data() as Map<String, dynamic>, doc.id));
        } catch (e) {
          debugPrint('Error parsing student document ${doc.id}: $e');
        }
      }
      return students;
    });
  }

  // Add new student
  Future<void> addStudent(Student student) async {
    await _studentsCollection.doc(student.uid).set(student.toMap());
  }

  // Update student
  Future<void> updateStudent(Student student) async {
    await _studentsCollection.doc(student.uid).update(student.toMap());
  }

  // Toggle suspension
  Future<void> toggleSuspension(String uid, bool currentStatus) async {
    final newStatus = !currentStatus;
    await _studentsCollection.doc(uid).update({
      'is_suspended': newStatus, // LEMON internal
      'isSuspended': newStatus,  // LIME expected
      'suspended': newStatus,    // LIME alternative
    });
  }

  // Delete student
  Future<void> deleteStudent(String uid) async {
    await _studentsCollection.doc(uid).delete();
  }

  // Update warning message
  Future<void> updateWarning(String uid, String? message) async {
    await _studentsCollection.doc(uid).update({
      'warning': message,        // LEMON internal
      'isWarned': message != null && message.isNotEmpty, // LIME expected
      'warnedMessage': message,  // LIME expected
    });
  }
}
