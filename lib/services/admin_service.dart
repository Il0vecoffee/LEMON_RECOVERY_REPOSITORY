import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin.dart';
import '../models/invitation.dart';

class AdminService {
  final CollectionReference _adminsCollection =
      FirebaseFirestore.instance.collection('admins');
  final CollectionReference _invitationsCollection =
      FirebaseFirestore.instance.collection('invitations');

  // Get stream of all admins
  Stream<List<Admin>> getAdmins() {
    return _adminsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Admin.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Get stream of all active invitations
  Stream<List<AdminInvitation>> getInvitations() {
    return _invitationsCollection
        .where('isUsed', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AdminInvitation.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Add new admin entry
  Future<void> addAdmin(Admin admin) async {
    // Check for 5 admin limit (admins + unused invitations)
    final adminSnapshot = await _adminsCollection.get();
    final inviteSnapshot = await _invitationsCollection.where('isUsed', isEqualTo: false).get();
    
    if (adminSnapshot.docs.length + inviteSnapshot.docs.length >= 5) {
       throw Exception('Maximum limit of 5 administrators (including pending) reached.');
    }
    
    await _adminsCollection.doc(admin.uid).set(admin.toMap());
  }

  // Create new invitation
  Future<String> createInvitation() async {
    final adminSnapshot = await _adminsCollection.get();
    final inviteSnapshot = await _invitationsCollection.where('isUsed', isEqualTo: false).get();
    
    if (adminSnapshot.docs.length + inviteSnapshot.docs.length >= 5) {
       throw Exception('Maximum limit of 5 administrators (including pending) reached.');
    }

    final docRef = _invitationsCollection.doc(); // Auto-generated ID as token
    final invitation = AdminInvitation(
      token: docRef.id,
      isUsed: false,
      createdAt: DateTime.now(),
    );
    
    await docRef.set(invitation.toMap());
    return docRef.id;
  }

  // Fetch invitation by token
  Future<AdminInvitation?> getInvitation(String token) async {
    final doc = await _invitationsCollection.doc(token).get();
    if (!doc.exists) return null;
    return AdminInvitation.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  // Delete admin entry
  Future<void> deleteAdmin(String uid) async {
    await _adminsCollection.doc(uid).delete();
  }

  // Delete invitation
  Future<void> deleteInvitation(String token) async {
    await _invitationsCollection.doc(token).delete();
  }
}
