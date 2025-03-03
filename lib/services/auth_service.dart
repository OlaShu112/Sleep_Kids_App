import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 Get Current User
  User? get currentUser => _auth.currentUser;

  // 🔹 Sign In
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("❌ Error signing in: $e");
      return null;
    }
  }

  // 🔹 Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 🔹 Fetch User Data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    if (currentUser != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(currentUser!.uid).get();
      return userDoc.data() as Map<String, dynamic>?;
    }
    return null;
  }

  // 🔹 Update Password with Re-authentication
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception("No user is logged in.");

      // ✅ Step 1: Re-authenticate user
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // ✅ Step 2: Update Password
      await user.updatePassword(newPassword);

      print("✅ Password updated successfully!");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception("Current password is incorrect.");
      } else if (e.code == 'weak-password') {
        throw Exception("New password is too weak.");
      } else if (e.code == 'requires-recent-login') {
        throw Exception("Please log out and log in again before changing your password.");
      } else {
        throw Exception("An error occurred while changing the password.");
      }
    }
  }
}
