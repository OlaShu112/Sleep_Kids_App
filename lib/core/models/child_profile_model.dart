import 'package:cloud_firestore/cloud_firestore.dart';

class ChildProfile {
  // List UserId
  String childId;
  String childName;
  List<String>? issueId;
  List<String>? sleepId; //multiple issueId for a child and is optional
  String? goalId;
  DateTime dateOfBirth;
  String? profileImageUrl;
  List<String> guardianId;

  ChildProfile({
    required this.childId,
    required this.childName,
    this.issueId,
    this.sleepId,
    this.goalId,
    required this.dateOfBirth,
    this.profileImageUrl,
    required this.guardianId,
  });

  // Convert Firestore document to ChildProfile
  factory ChildProfile.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ChildProfile(
      childId: doc.id,
      childName: data['childName'] ?? 'Unknown',
      issueId: data['issueId'] != null ? List<String>.from(data['issueId']) : null,
      sleepId: data['sleepId'] != null ? List<String>.from(data['sleepId']) : null,
      goalId: data['goalId'] ?? '',
      dateOfBirth: (data['dateOfBirth'] as Timestamp).toDate(),
      profileImageUrl: data['profileImageUrl'],
      guardianId: data['guardianId'] ?? '',
    );
  }

  // Convert ChildProfile to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'childName': childName,
      'issueId': issueId ?? [],
      'sleepId': sleepId ?? [],
      'goalId': goalId ?? '',
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'profileImageUrl': profileImageUrl ?? '',
      'guardianId': guardianId,
    };
  }
}
