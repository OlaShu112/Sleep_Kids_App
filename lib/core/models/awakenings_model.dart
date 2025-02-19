import 'package:cloud_firestore/cloud_firestore.dart';

class AwakeningsModel {
  String awakeningId;
  String childId;
  int duration;
  DateTime bedtime;
  DateTime wakeUp;

  AwakeningsModel({
    required this.childId,
    required this.awakeningId,
    required this.duration,
    required this.wakeUp,
    required this.bedtime,
  });

  // Convert Firestore document to ChildProfile
  factory AwakeningsModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AwakeningsModel(
      awakeningId: doc.id,
      childId: data['childId'],
      duration: data['duration'],
      wakeUp: (data['wakeUp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      bedtime: (data['bedtime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      



    );
  }

    factory AwakeningsModel.fromMap(Map<String, dynamic> map, {String? awakeningId}) {
    return AwakeningsModel(
      awakeningId: awakeningId ?? '',
      childId: map['child_id'] ?? '',
      duration: map['duration'] ?? 0,
      bedtime: (map['bedtime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      wakeUp: (map['wakeUp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'childId': childId,
      'duration': duration,
      'wakeUp': wakeUp,
      'bedtime': bedtime,

    };
  }
}
