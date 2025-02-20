import 'package:cloud_firestore/cloud_firestore.dart';

class Goal {
  String goalId;
  String childId;
  String goalDescription;
  int duration;
  DateTime WakeUpTime;
  DateTime BedTime;
  bool isCompleted;
  DateTime targetDate;

  Goal({
    required this.goalId,
    required this.childId,
    required this.goalDescription,
    required this.duration,
    required this.WakeUpTime,
    required this.BedTime,
    required this.isCompleted,
    required this.targetDate,
  });

  factory Goal.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Goal(
      goalId: doc.id,
      childId: data['childId'],
      goalDescription: data['goalDescription'] ?? '',
      duration: data['duration'] ?? 0,
      WakeUpTime: data['WakeUpTIme'] ?? 0,
      BedTime: data['BedTime'] ?? 0,
      isCompleted: data['isCompleted'] ?? false,
      targetDate:
          (data['targetDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'childId': childId,
      'goalDescription': goalDescription,
      'duration': duration,
      'WakeUpTime': WakeUpTime,
      'BedTime' : BedTime,
      'isCompleted': isCompleted,
      'targetDate': Timestamp.fromDate(targetDate),
    };
  }
}
