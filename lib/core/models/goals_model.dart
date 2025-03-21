import 'package:cloud_firestore/cloud_firestore.dart';

class Goal {
  String goalId;
  String childId;
  double duration;
  DateTime wakeUpTime;
  DateTime bedtime;
  bool isCompleted;


  Goal({
    required this.goalId,
    required this.childId,
    required this.duration,
    required this.wakeUpTime,
    required this.bedtime,
    required this.isCompleted,

  });

  factory Goal.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Goal(
      goalId: doc.id,
      childId: data['childId'],
      duration: data['duration'] ?? 0,
      wakeUpTime: data['wakeUpTime'] != null
          ? DateTime.parse(data['wakeUpTime']) // Parse the wakeUpTime string
          : DateTime.now(),

      bedtime: data['bedtime'] != null
          ? DateTime.parse(data['bedtime']) // Parse the bedtime string
          : DateTime.now(),

      isCompleted: data['isCompleted'] ?? false,

    );
  }

  Map<String, dynamic> toMap() {
    return {
      'childId': childId,
      'duration': duration,
      'wakeUpTime': wakeUpTime.toIso8601String(), 
      'bedtime': bedtime.toIso8601String(),  
      'isCompleted': isCompleted,

    };
  }
}
