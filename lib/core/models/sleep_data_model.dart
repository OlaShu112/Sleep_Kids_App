import 'package:cloud_firestore/cloud_firestore.dart';

class SleepData {
  String sleepId; // Changed to String to match Firestore ID format
 
  List<String>? awakeningsId;
  DateTime date;
  DateTime bedtime;
  DateTime wakeUpTime; // Ensure field name is consistent
  int sleepDuration; // in minutes
  int sleepQuality; // on a scale from 1 to 10
  String notes;
  bool watchConnected; // New field to indicate if the watch is connected

  SleepData({
    required this.sleepId,
    required this.date,
    required this.bedtime,
    this.awakeningsId,
    required this.wakeUpTime,
    required this.sleepDuration,
    required this.sleepQuality,
    required this.notes,
    required this.watchConnected, // Add the watch connection status
  });

  // Factory constructor from a DocumentSnapshot
  factory SleepData.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return SleepData(
      sleepId: doc.id,

      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      awakeningsId: data['awakeningsId'] != null
          ? List<String>.from(data['awakeningsId'])
          : null,
      bedtime: (data['bedtime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      wakeUpTime: (data['wakeUpTime'] as Timestamp?)?.toDate() ??
          DateTime.now(), // Use 'wakeUpTime' for consistency
      sleepDuration: data['sleepDuration'] ?? 0,
      sleepQuality: data['sleepQuality'] ?? 0,
      notes: data['notes'] ?? '',
      watchConnected:
          data['watchConnected'] ?? false, // Default to false if not set
    );
  }

  // Factory constructor from a Map
  factory SleepData.fromMap(Map<String, dynamic> map, {String? sleepId}) {
    return SleepData(
      sleepId: sleepId ?? '',

      awakeningsId: map['awakeningsId'] != null
          ? List<String>.from(map['awakeningsId'])
          : null,
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      bedtime: (map['bedtime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      wakeUpTime: (map['wakeUpTime'] as Timestamp?)?.toDate() ??
          DateTime.now(), // Consistent naming
      sleepDuration: map['sleepDuration'] ?? 0,
      sleepQuality: map['sleepQuality'] ?? 0,
      notes: map['notes'] ?? '',
      watchConnected: map['watchConnected'] ?? false, // Default to false
    );
  }

  // Convert the SleepData instance to a Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {

      'date': Timestamp.fromDate(date),
      'sleepDuration': sleepDuration,
      'awakeningsId': awakeningsId ?? [],
      'sleepQuality': sleepQuality,
      'notes': notes,
      'watchConnected': watchConnected, // Save watch connection status
      'wakeUpTime':
          Timestamp.fromDate(wakeUpTime), // Ensure consistency in field name
    };
  }
}
