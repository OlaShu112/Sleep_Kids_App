import 'package:flutter/material.dart';
import 'package:sleep_kids_app/core/models/achievement_model.dart';
import 'package:sleep_kids_app/core/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// SleepGoalScreen with interactive sliders
class SleepGoalScreen extends StatefulWidget {
  const SleepGoalScreen({super.key});

  @override
  _SleepGoalScreenState createState() => _SleepGoalScreenState();
}

class _SleepGoalScreenState extends State<SleepGoalScreen> {
  double targetBedtime = 22.0; // Default 10:00 PM
  double targetWakeup = 7.0; // Default 7:00 AM

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sleep Goals")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Set Your Sleep Goals",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text("Target Bedtime: ${targetBedtime.toInt()}:00"),
            Slider(
              value: targetBedtime,
              min: 18,
              max: 24,
              divisions: 6,
              label: "${targetBedtime.toInt()}:00",
              onChanged: (value) {
                setState(() => targetBedtime = value);
              },
            ),
            Text("Target Wake-up Time: ${targetWakeup.toInt()}:00"),
            Slider(
              value: targetWakeup,
              min: 4,
              max: 10,
              divisions: 6,
              label: "${targetWakeup.toInt()}:00",
              onChanged: (value) {
                setState(() => targetWakeup = value);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Sleep goals updated!")),
                );
              },
              child: const Text("Save Goals"),
            ),
          ],
        ),
      ),
    );
  }
}

// AchievementsScreen with Firestore integration
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: FutureBuilder<List<Achievement>>(
        future: firestoreService.getAchievements('userId'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text(
                    'Error: ${snapshot.error}')); // Fixed string interpolation
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No achievements found.'));
          }

          final achievements = snapshot.data!;
          return ListView.builder(
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: ListTile(
                  leading: const Icon(Icons.star, color: Colors.amber),
                  title: Text(
                    achievement.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(achievement.description),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Firestore Service with addAchievement method
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Method to get achievements for a user
  Future<List<Achievement>> getAchievements(String userId) async {
    try {
      final querySnapshot = await _db
          .collection('achievements')
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs.map((doc) {
        return Achievement.fromFirestore(doc);
      }).toList();
    } catch (e) {
      throw Exception('Error fetching achievements: $e');
    }
  }

  // Method to add an achievement
  Future<void> addAchievement(
      Achievement achievement, String customDocId) async {
    try {
      await _db.collection('achievements').doc(customDocId).set({
        'userId': achievement.userId,
        'title': achievement.title,
        'description': achievement.description,
        'timestamp': achievement.timestamp,
        'iconUrl': achievement.iconUrl,
        'isUnlocked': achievement.isUnlocked,
        'progress': achievement.progress,
        'dateEarned': achievement.dateEarned,
        'points': achievement.points,
        'category': achievement.category,
      });
    } catch (e) {
      throw Exception('Error adding achievement: $e');
    }
  }
}
