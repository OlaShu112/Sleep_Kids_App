import 'package:cloud_firestore/cloud_firestore.dart';

class Goal {
  String goalId;
  String childId;
  int duration;
  DateTime WakeUpTime;
  DateTime BedTime;
  bool isCompleted;


  Goal({
    required this.goalId,
    required this.childId,
    required this.duration,
    required this.WakeUpTime,
    required this.BedTime,
    required this.isCompleted,

  });

  factory Goal.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Goal(
      goalId: doc.id,
      childId: data['childId'],
      duration: data['duration'] ?? 0,
      WakeUpTime: data['WakeUpTime'] ?? 0,
      BedTime: data['BedTime'] ?? 0,
      isCompleted: data['isCompleted'] ?? false,

    );
  }

  Map<String, dynamic> toMap() {
    return {
      'childId': childId,
      'duration': duration,
      'WakeUpTime': WakeUpTime,
      'BedTime' : BedTime,
      'isCompleted': isCompleted,

    };
  }
}
