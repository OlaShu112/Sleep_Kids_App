
import 'package:cloud_firestore/cloud_firestore.dart';

class SleepData {
  String sleepId;
  String childId; // ✅ Add this
  List<String>? awakeningsId;
  DateTime bedtime;
  DateTime wakeUpTime;
  int sleepDuration;
  String notes;
  bool watchConnected;

  SleepData({
    required this.sleepId,
    required this.childId, // ✅ Include in constructor
    required this.bedtime,
    this.awakeningsId,
    required this.wakeUpTime,
    required this.sleepDuration,
    required this.notes,
    required this.watchConnected,
  });

  factory SleepData.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return SleepData(
      sleepId: doc.id,
      childId: data['childId'] ?? '', // ✅ Read from Firestore
      awakeningsId: data['awakeningsId'] != null
          ? List<String>.from(data['awakeningsId'])
          : null,
      bedtime: (data['bedtime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      wakeUpTime: (data['wakeUpTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      sleepDuration: data['sleepDuration'] ?? 0,
      notes: data['notes'] ?? '',
      watchConnected: data['watchConnected'] ?? false,
    );
  }

  factory SleepData.fromMap(Map<String, dynamic> map, {String? sleepId}) {
    return SleepData(
      sleepId: sleepId ?? '',
      childId: map['childId'] ?? '',
      awakeningsId: map['awakeningsId'] != null
          ? List<String>.from(map['awakeningsId'])
          : null,
      bedtime: (map['bedtime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      wakeUpTime: (map['wakeUpTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      sleepDuration: map['sleepDuration'] ?? 0,
      notes: map['notes'] ?? '',
      watchConnected: map['watchConnected'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'childId': childId, // ✅ Save to Firestore
      'bedtime': Timestamp.fromDate(bedtime),
      'wakeUpTime': Timestamp.fromDate(wakeUpTime),
      'sleepDuration': sleepDuration,
      'awakeningsId': awakeningsId ?? [],
      'notes': notes,
      'watchConnected': watchConnected,
    };
  }
}
