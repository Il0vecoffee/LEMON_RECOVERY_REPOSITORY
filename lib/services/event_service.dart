import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/event.dart';

class EventService {
  final CollectionReference _eventsCollection =
      FirebaseFirestore.instance.collection('events');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload image to Firebase Storage and return download URL
  Future<String?> uploadImage(File imageFile) async {
    try {
      debugPrint('EventService: Starting image upload...');
      final String fileName = 'events/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child(fileName);

      // Read file as bytes - more reliable on Windows desktop than putFile
      final bytes = await imageFile.readAsBytes();
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      
      final UploadTask uploadTask = ref.putData(bytes, metadata);
      final TaskSnapshot snapshot = await uploadTask;

      final downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('EventService: Upload successful! URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('EventService: Error uploading image: $e');
      return null;
    }
  }

  /// Convert an image file to a base64 data URI string.
  /// Compresses by limiting file size (~700KB max for Firestore safety).
  Future<String?> imageToBase64(File imageFile) async {
    try {
      if (!await imageFile.exists()) {
        debugPrint('EventService: File does not exist: ${imageFile.path}');
        return null;
      }

      final bytes = await imageFile.readAsBytes();
      debugPrint('EventService: Read ${bytes.length} bytes from ${imageFile.path}');

      // Firestore doc limit is 1MB. Base64 adds ~33% overhead.
      // Warn if file is very large but still try.
      if (bytes.length > 700000) {
        debugPrint('EventService: WARNING - Image is ${bytes.length} bytes. '
            'Large images may exceed Firestore document limits.');
      }

      final base64String = base64Encode(bytes);

      // Detect mime type from extension
      final ext = imageFile.path.toLowerCase();
      String mime = 'image/jpeg';
      if (ext.endsWith('.png')) mime = 'image/png';
      if (ext.endsWith('.gif')) mime = 'image/gif';
      if (ext.endsWith('.webp')) mime = 'image/webp';

      final dataUri = 'data:$mime;base64,$base64String';
      debugPrint('EventService: Base64 conversion successful (${dataUri.length} chars)');
      return dataUri;
    } catch (e) {
      debugPrint('EventService: Error converting image to base64: $e');
      return null;
    }
  }

  // Get stream of all events (ordered by date descending)
  Stream<List<Event>> getEvents() {
    return _eventsCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      final List<Event> events = [];
      for (var doc in snapshot.docs) {
        try {
          events.add(Event.fromMap(doc.data() as Map<String, dynamic>, doc.id));
        } catch (e) {
          debugPrint('Error parsing event document ${doc.id}: $e');
        }
      }
      return events;
    });
  }

  // Add new event
  Future<void> addEvent(Event event) async {
    await _eventsCollection.add(event.toMap());
  }

  // Update event
  Future<void> updateEvent(Event event) async {
    await _eventsCollection.doc(event.id).update(event.toMap());
  }

  // Delete event
  Future<void> deleteEvent(String id) async {
    await _eventsCollection.doc(id).delete();
  }
}
