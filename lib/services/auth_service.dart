import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final User? user = result.user;
      
      if (user != null) {
        // Check if any admins exist (Bootstrap logic)
        final QuerySnapshot adminCheck = await _firestore.collection('admins').limit(1).get();
        if (adminCheck.docs.isEmpty) {
          debugPrint('No admins found in database. Bootstrapping first admin: ${user.email}');
          await createAdminEntry(user.uid, user.email ?? '', 'Initial Admin');
          return user;
        }

        // Verify admin status
        final bool isAdmin = await _checkIfAdmin(user.uid);
        if (!isAdmin) {
          // Fetch existing admins to provide a hint
          final QuerySnapshot adminSnapshot = await _firestore.collection('admins').get();
          final List<String> adminEmails = adminSnapshot.docs
              .map((doc) => (doc.data() as Map<String, dynamic>)['email']?.toString() ?? 'unknown')
              .toList();

          await _auth.signOut();
          String hint = adminEmails.isNotEmpty 
              ? '\n\nHint: Registered admins are: ${adminEmails.join(", ")}'
              : '\n\nNo admins are currently registered.';
              
          throw Exception('Access Denied: Your account (${user.email}) is not an administrator.$hint');
        }
        return user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        throw Exception('Network error. Please check your internet connection.');
      } else if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception('Invalid email or password.');
      }
      throw Exception('Authentication error [${e.code}]: ${e.message}');
    } catch (e) {
      debugPrint('Login error: $e');
      if (e.toString().contains('Access Denied')) rethrow;
      throw Exception('An internal error occurred during sign-in ($e). Please try again.');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Check if user exists in 'admins' collection
  Future<bool> _checkIfAdmin(String uid) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('admins').doc(uid).get();
      return doc.exists;
    } catch (e) {
      debugPrint('Error checking admin status: $e');
      // If there's a permission error or something else, we don't want to just return false
      // but here we are in a fail-safe mode.
      return false;
    }
  }

  // Create a new admin account (For setup/setup by invitation)
  Future<User?> registerAdmin(String email, String password, String name, {String? invitationToken}) async {
    try {
      final admins = await _firestore.collection('admins').get();
      final invites = await _firestore.collection('invitations').where('isUsed', isEqualTo: false).get();

      // If registering via invitation, we don't need to re-check the limit here strictly 
      // as it was checked when the invitation was created, but for local safety:
      if (invitationToken == null && admins.docs.length + invites.docs.length >= 5) {
        throw Exception('Registration Failed: Maximum limit of 5 administrators (including pending) reached.');
      }

      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final User? user = result.user;
      if (user != null) {
        await createAdminEntry(user.uid, email, name);
        
        // Mark invitation as used
        if (invitationToken != null) {
          await _firestore.collection('invitations').doc(invitationToken).update({'isUsed': true});
        }
        return user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('This email is already registered.');
      } else if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      }
      throw Exception('Registration error [${e.code}]: ${e.message}');
    } catch (e) {
      debugPrint('Registration error: $e');
      throw Exception('An internal error occurred during setup ($e).');
    }
  }

  // Helper to create an admin
  Future<void> createAdminEntry(String uid, String email, String name) async {
     await _firestore.collection('admins').doc(uid).set({
       'email': email,
       'name': name,
       'createdAt': FieldValue.serverTimestamp(),
     });
  }
}
