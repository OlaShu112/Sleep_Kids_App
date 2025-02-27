import 'package:cloud_firestore/cloud_firestore.dart';

class SleepData {
  String sleepId; // Changed to String to match Firestore ID format
  String childId; // Changed to match Firebase schema
  List<String>? awakeningsId;
  DateTime date;
  DateTime bedtime;
  DateTime wakeUpTime;
  int sleepDuration; // in minutes
  int sleepQuality; // on a scale from 1 to 10
  String notes;

  SleepData({
    required this.sleepId,
    required this.childId,
    required this.date,
    required this.bedtime,
    this.awakeningsId,
    required this.wakeUpTime,
    required this.sleepDuration,
    required this.sleepQuality,
    required this.notes,
  });

  // Factory constructor from a DocumentSnapshot
  factory SleepData.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return SleepData(
      sleepId: doc.id,
      childId: data['child_id'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      awakeningsId: data['awakeningsId'] != null
          ? List<String>.from(data['awakeningsId'])
          : null,
      bedtime: (data['bedtime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      wakeUpTime:
          (data['wakeUptime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      sleepDuration: data['sleepDuration'] ?? 0,
      sleepQuality: data['sleepQuality'] ?? 0,
      notes: data['notes'] ?? '',
    );
  }

  // Factory constructor from a Map
  factory SleepData.fromMap(Map<String, dynamic> map, {String? sleepId}) {
    return SleepData(
      sleepId: sleepId ?? '',
      childId: map['child_id'] ?? '',
      awakeningsId:map['awakeningsId'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      bedtime: (map['bedtime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      wakeUpTime: (map['wakeUp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      sleepDuration: map['sleepDuration'] ?? 0,
      sleepQuality: map['sleepQuality'] ?? 0,
      notes: map['notes'] ?? '',
    );
  }

  // Convert the SleepData instance to a Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'child_id': childId, // Matches Firebase foreign key
      'date': Timestamp.fromDate(date),
      'sleepDuration': sleepDuration,
      'awakeningsId': awakeningsId ?? [],
      'sleepQuality': sleepQuality,
      'notes': notes,
    };
  }
}
