// ✅ Interacts with Firebase Firestore
// ✅ Stores, retrieves, updates, and deletes user data
// ✅ Does NOT handle login state or UI updates

// How It Works----------
// Saves user data in Firestore (createUser())
// Fetches user data from Firestore (getUser())
// Updates user data in Firestore (updateUser())
// Deletes user from Firestore (deleteUser())
// When to Use?-------------
// When you want to store and retrieve user information from Firebase Firestore.
// When you need CRUD (Create, Read, Update, Delete) operations for user data.
// When you want to store additional user details (e.g., profile picture, date of birth, etc.).
// ❌ What It Doesn’t Do----------------
// It does not manage authentication (login/logout).
// It does not handle UI state updates.

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sleep_kids_app/core/models/goals_model.dart';
import 'package:sleep_kids_app/core/models/user_model.dart';
import 'package:sleep_kids_app/core/models/child_profile_model.dart';
import 'package:sleep_kids_app/core/models/issue_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance; // ✅ Firebase Storage instance

 

  // Insert User
  Future<void> insertUser(UserModel user) async {
    await _db.collection("users").doc(user.userId).set({
      "userId": user.userId,
      "firstName": user.firstName,
      "lastName": user.lastName,
      "email": user.email,
      "dateOfBirth": Timestamp.fromDate(user.dateOfBirth),
      "profileImageUrl": user.profileImageUrl,
      "role": user.role,
    });
  }
//insertGoal
  Future<void> insertGoal(Goal goal) async {
    await _db.collection("goals").doc(goal.goalId).set({
      "goalId": goal.goalId,
      "childId": goal.childId,
      "wakeUpTime": Timestamp.fromDate(goal.wakeUpTime),
      "bedtime": Timestamp.fromDate(goal.bedtime),

      "duration": goal.duration,
      "isComplete": goal.isCompleted,
    });
  }
// set goal for a child
Future<Goal?> fetchGoalForChild(String childId) async {
  try {
    // Query the 'goals' collection to fetch the goal document by the 'childId' field.
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('goals')
        .where('childId', isEqualTo: childId)
        .get();

    if (querySnapshot.docs.isEmpty) {
      print("❌ Goal for child $childId not found.");
      return null; // Return null if no goal document found for this child.
    }

    // Fetch the first document from the query snapshot (since there should only be one goal per child)
    DocumentSnapshot goalDoc = querySnapshot.docs.first;

    // Parse and return the Goal from Firestore document
    return Goal.fromDocument(goalDoc);
  } catch (e) {
    print("❌ Error fetching goal for child $childId: $e");
    return null; // Return null in case of an error.
  }
}



  // Retrieve UserModel from Firestore
  Future<UserModel?> getUser(String userId) async {
    DocumentSnapshot doc = await _db.collection("users").doc(userId).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }


  // Save Child Profile to Firestore
  Future<void> addChildProfile(ChildProfile childProfile) async {
    try {
      await _db.collection('child_profiles')
          .doc(childProfile.childId)
          .set(childProfile.toMap());
      print("✅ Child Profile Added Successfully!");
    } catch (e) {
      print("❌ Error Adding Child Profile: $e");
    }
  }
  Future<void> removeChildProfile(String childId) async {
  await FirebaseFirestore.instance.collection('child_profiles').doc(childId).delete();
}




Future<List<IssueModel>> getChildIssues(List<String> issueIds) async {
  try {
    if (issueIds.isEmpty) {
      print("❌ No issues linked to this child.");
      return [];
    }

    print("🚀 Fetching Issues: ${issueIds.join(', ')}");

    QuerySnapshot querySnapshot = await _db
        .collection('Issue')
        .where(FieldPath.documentId, whereIn: issueIds) // ✅ Fetch issues by ID
        .get();

    print("✅ Firestore returned ${querySnapshot.docs.length} issues.");
    return querySnapshot.docs
        .map((doc) => IssueModel.fromDocument(doc))
        .toList();
  } catch (e) {
    print("❌ Error Fetching Issues: $e");
    return [];
  }
}





  // Get Child Profile by Guardian ID
  Future<List<ChildProfile>> getChildProfiles(String guardianId) async {
  try {
    print("🚀 Fetching child profiles for guardianId: $guardianId");

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('child_profiles')
        .where('guardianId', arrayContains: guardianId) // ✅ Ensuring arrayContains
        .get();

    if (querySnapshot.docs.isEmpty) {
      print("❌ No children found in Firestore.");
    } else {
      print("✅ Firestore returned ${querySnapshot.docs.length} children.");
      for (var doc in querySnapshot.docs) {
        print("👶 Found child: ${doc['childName']} (ID: ${doc.id})");
      }
    }

    return querySnapshot.docs
        .map((doc) => ChildProfile.fromDocument(doc))
        .toList();
  } catch (e) {
    print("❌ Error Fetching Child Profiles: $e");
    return [];
  }
}


  // Fetch all children linked to the current user
Future<List<Map<String, dynamic>>> fetchChildren(String guardianId) async {
  try {
    QuerySnapshot querySnapshot = await _db
        .collection('child_profiles')
        .where('guardianId', arrayContains: guardianId)
        .get();

    return querySnapshot.docs.map((doc) => {
      "id": doc.id,
      ...doc.data() as Map<String, dynamic>,
    }).toList();
  } catch (e) {
    print("❌ Error fetching children: $e");
    return [];
  }
}


  // Fetch a child's sleep goal data
  Future<DocumentSnapshot?> fetchChildGoal(String childId) async {
    final goalDoc = await _db.collection('goals').doc(childId).get();
    return goalDoc.exists ? goalDoc : null;
  }

  // Save or update a child's sleep goal
  Future<void> saveGoal(String childId, double bedTime, double wakeUpTime) async {
    try {
      await _db.collection('goals').doc(childId).set({
        'bedTime': bedTime,
        'wakeUpTime': wakeUpTime,
      }, SetOptions(merge: true));
    } catch (e) {
      print("❌ Error saving goal: $e");
    }
  }

  Future<void> addGoal(Goal newGoal) async {
    try {
      await _db.collection('goals')
          .doc(newGoal.goalId)
          .set(newGoal.toMap());
      print("✅ Goal Added Successfully!");
    } catch (e) {
      print("❌ Error Adding Goal: $e");
    }
  }

  // Change user password
  Future<void> changeUserPassword(String currentPassword, String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception("No user is logged in.");

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
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

   // ✅ Upload Profile Image to Firebase Storage
  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return null;

      String filePath = 'profile_images/${user.uid}.jpg';
      Reference storageRef = _storage.ref().child(filePath);

      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("❌ Error uploading image: $e");
      return null;
    }
  }

  // ✅ Update Profile Image URL in Firestore
  Future<void> updateProfileImageUrl(String downloadUrl) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      await _db.collection('users').doc(user.uid).update({
        'profileImageUrl': downloadUrl,
      });
    } catch (e) {
      print("❌ Error updating profile image URL: $e");
    }
  }

  Future<List<IssueModel>> fetchIssues() async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Issue') 
        .get();

    return querySnapshot.docs.map((doc) => IssueModel.fromDocument(doc)).toList();
  } catch (e) {
    print("❌ Error Fetching Issues: $e");
    return [];
  }
}
}