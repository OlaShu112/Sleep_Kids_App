import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sleep_kids_app/core/models/achievement_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add a new achievement to Firestore
  Future<void> addAchievement(Achievement achievement) async {
    try {
      await _db.collection('achievements').add(achievement.toMap());
    } catch (e) {
      print("Error adding achievement: $e");
      throw Exception('Failed to add achievement');
    }
  }

  // Fetch achievements for a specific user
  Future<List<Achievement>> getAchievements(String userId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('achievements')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp',
              descending: true) // Sort by timestamp in descending order
          .get();

      return snapshot.docs
          .map((doc) => Achievement.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Error fetching achievements: $e");
      throw Exception('Failed to fetch achievements');
    }
  }

  // Update progress of a specific achievement
  Future<void> updateProgress(String achievementId, int progress) async {
    try {
      // Only update if the progress value is between 0 and 100
      if (progress < 0 || progress > 100) {
        throw Exception('Progress must be between 0 and 100');
      }

      await _db.collection('achievements').doc(achievementId).update({
        'progress': progress,
        'isUnlocked':
            progress == 100, // Unlock achievement when progress hits 100
      });
    } catch (e) {
      print("Error updating achievement progress: $e");
      throw Exception('Failed to update achievement progress');
    }
  }

  // Real-time listener for achievements (Stream)
  Stream<List<Achievement>> getAchievementsStream(String userId) {
    return _db
        .collection('achievements')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Achievement.fromFirestore(doc))
            .toList());
  }
}
