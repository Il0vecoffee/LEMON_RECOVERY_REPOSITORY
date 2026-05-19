import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/section.dart';

class SectionService {
  final CollectionReference _sectionsCollection =
      FirebaseFirestore.instance.collection('sections');

  // Get stream of all sections
  Stream<List<Section>> getSections() {
    return _sectionsCollection.snapshots().map((snapshot) {
      final List<Section> sections = [];
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            sections.add(Section.fromMap(data, doc.id));
          }
        } catch (e) {
          debugPrint('Error parsing section document ${doc.id}: $e');
        }
      }
      return sections;
    });
  }

  // Add new section
  Future<void> addSection(Section section, String sectionName) async {
    await _sectionsCollection.doc(sectionName).set(section.toMap());
  }

  // Update section
  Future<void> updateSection(Section section) async {
    await _sectionsCollection.doc(section.id).update(section.toMap());
  }

  // Delete section
  Future<void> deleteSection(String id) async {
    await _sectionsCollection.doc(id).delete();
  }
}
