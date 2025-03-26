import 'package:cloud_firestore/cloud_firestore.dart';

class Achievement {
  final String userId;
  final String title;
  final String description;
  final Timestamp timestamp; // Automatically set by Firestore
  final String? iconUrl; // URL to an icon image (optional)
  final bool isUnlocked; // Whether the achievement is unlocked or not
  final int progress; // Progress towards completion (0-100)
  final DateTime dateEarned; // Date when the achievement was earned
  final int points; // Points for completing the achievement
  final String
      category; // Category of the achievement (e.g., "Sleep", "Fitness")

  Achievement({
    required this.userId,
    required this.title,
    required this.description,
    required this.timestamp,
    this.iconUrl,
    required this.isUnlocked,
    required this.progress,
    required this.dateEarned,
    required this.points,
    required this.category,
  });

  // Convert Achievement to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'timestamp': FieldValue.serverTimestamp(),
      'iconUrl': iconUrl,
      'isUnlocked': isUnlocked,
      'progress': progress,
      'dateEarned': Timestamp.fromDate(dateEarned),
      'points': points,
      'category': category,
    };
  }

  // Create an Achievement object from Firestore document
  factory Achievement.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Achievement(
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      iconUrl: data['iconUrl'],
      isUnlocked: data['isUnlocked'] ?? false,
      progress: data['progress'] ?? 0,
      dateEarned: (data['dateEarned'] as Timestamp).toDate(),
      points: data['points'] ?? 0,
      category: data['category'] ?? 'General',
    );
  }
}
