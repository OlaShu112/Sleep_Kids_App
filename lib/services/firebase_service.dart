
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sleep_kids_app/core/models/goals_model.dart';
import 'package:sleep_kids_app/core/models/user_model.dart';
import 'package:sleep_kids_app/core/models/child_profile_model.dart';


class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Insert User
  Future<void> insertUser(UserModel user) async {
    await _db.collection("users").doc(user.userId).set({
      "userId": user.userId, // ✅ Store userId from Firebase Auth
      "firstName": user.firstName,
      "lastName": user.lastName,
      "email": user.email,
      "dateOfBirth": Timestamp.fromDate(user.dateOfBirth), // ✅ Convert DateTime to Firestore Timestamp
      "profileImageUrl": user.profileImageUrl,
      "role": user.role,
    });
  }
  // ✅ Retrieve UserModel from Firestore
  Future<UserModel?> getUser(String userId) async {
    DocumentSnapshot doc = await _db.collection("users").doc(userId).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // ✅ Save Child Profile to Firestore
  Future<void> addChildProfile(ChildProfile childProfile) async {
    try {
      await _db.collection('child_profiles')
          .doc(childProfile.childId) // ✅ Use childId for consistency
          .set(childProfile.toMap()); // ✅ Use .set() instead of .add()
      print("✅ Child Profile Added Successfully!");
    } catch (e) {
      print("❌ Error Adding Child Profile: $e");
    }
  }

  // ✅ Get Child Profile by Guardian ID
  Future<List<ChildProfile>> getChildProfiles(String guardianId) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('child_profiles')
          .where('guardianId', isEqualTo: guardianId)
          .get();

      return querySnapshot.docs
          .map((doc) => ChildProfile.fromDocument(doc)) // ✅ Use `fromDocument`
          .toList();
    } catch (e) {
      print("❌ Error Fetching Child Profiles: $e");
      return [];
    }
  } 

//Fetch all children linked to the current user
  Stream<QuerySnapshot> fetchChildren(String guardianId) {
  return FirebaseFirestore.instance
      .collection('child_profiles')
      .where('guardianId', isEqualTo: guardianId)
      .snapshots();
}

//2️⃣ Fetch a child's sleep goal data
Future<DocumentSnapshot?> fetchChildGoal(String childId) async {
  final goalDoc = await FirebaseFirestore.instance.collection('goals').doc(childId).get();
  return goalDoc.exists ? goalDoc : null;
}

//Save or update a child's sleep goal
Future<void> saveGoal(String childId, double bedTime, double wakeUpTime) async {
  try {
    await FirebaseFirestore.instance.collection('goals').doc(childId).set({
      'bedTime': bedTime,
      'wakeUpTime': wakeUpTime,
    }, SetOptions(merge: true)); // ✅ Merge to update existing goal
  } catch (e) {
    print("❌ Error saving goal: $e");
  }
}
Future<void> addGoal(Goal NewGoal) async {
    try {
      await _db.collection('goals')
          .doc(NewGoal.goalId) // ✅ Use childId for consistency
          .set(NewGoal.toMap()); // ✅ Use .set() instead of .add()
      print("✅ Child Profile Added Successfully!");
    } catch (e) {
      print("❌ Error Adding Child Profile: $e");
    }
  }


}



  

//   // Insert Admin
//   Future<void> insertAdmin(String userId, String position, String accessLevel) async {
//     await _db.collection("admins").add({
//       "user_id": userId,
//       "position": position,
//       "access_level": accessLevel,
//       "created_at": Timestamp.now(),
//     });
//   }

//   // Insert Child
//   Future<void> insertChild(String userId, String name, int age, String gender) async {
//     await _db.collection("children").add({
//       "user_id": userId,
//       "name": name,
//       "age": age,
//       "gender": gender,
//       "created_at": Timestamp.now(),
//     });
//   }

//   // Insert Sleep Tracking Record
//   Future<void> insertSleepTracking(String childId, DateTime startTime, int settleDuration, int awakeningsCount, int awakeDuration, DateTime wakeTime) async {
//     await _db.collection("sleep_tracking").add({
//       "child_id": childId,
//       "start_time": startTime,
//       "settle_duration": settleDuration,
//       "awakenings_count": awakeningsCount,
//       "awake_duration": awakeDuration,
//       "wake_time": wakeTime,
//       "created_at": Timestamp.now(),
//     });
//   }

//   // Insert Sleep Plan
//   Future<void> insertSleepPlan(String childId, String details, DateTime startDate, DateTime? endDate, String status) async {
//     await _db.collection("sleep_plans").add({
//       "child_id": childId,
//       "details": details,
//       "start_date": startDate,
//       "end_date": endDate,
//       "status": status,
//       "created_at": Timestamp.now(),
//     });
//   }

//   // Insert Gamification Record
//   Future<void> insertGamification(String childId, int points, String? badge, String challengeStatus) async {
//     await _db.collection("gamification").add({
//       "child_id": childId,
//       "points": points,
//       "badge": badge,
//       "challenge_status": challengeStatus,
//       "created_at": Timestamp.now(),
//     });
//   }

//   // Insert Educational Content
//   Future<void> insertEducationalContent(String title, String contentType, String contentUrl, String category) async {
//     await _db.collection("educational_content").add({
//       "title": title,
//       "content_type": contentType,
//       "content_url": contentUrl,
//       "category": category,
//       "created_at": Timestamp.now(),
//     });
//   }

//   // Insert Alert Notification
//   Future<void> insertAlertNotification(String userId, String message, String type) async {
//     await _db.collection("alerts_notifications").add({
//       "user_id": userId,
//       "message": message,
//       "type": type,
//       "created_at": Timestamp.now(),
//     });
//   }

//   // Insert Progress Tracking Record
//   Future<void> insertProgressTracking(String childId, DateTime reportDate, double sleepHours, String moodAssessment, double goalAchievementRate) async {
//     await _db.collection("progress_tracking").add({
//       "child_id": childId,
//       "report_date": reportDate,
//       "sleep_hours": sleepHours,
//       "mood_assessment": moodAssessment,
//       "goal_achievement_rate": goalAchievementRate,
//       "created_at": Timestamp.now(),
//     });
//   }
// }
