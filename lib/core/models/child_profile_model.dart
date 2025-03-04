import 'package:cloud_firestore/cloud_firestore.dart';

class ChildProfile {
  // List UserId
  String childId;
  String childName;
  List<String>? issueId;
  List<String>? sleepId; //multiple issueId for a child and is optional
  List<String>? awakeningsId;
  DateTime dateOfBirth;
  String? profileImageUrl;
  List<String> guardianId;

  ChildProfile({
    required this.childId,
    required this.childName,
    this.issueId,
    this.sleepId,
    this.awakeningsId,
    required this.dateOfBirth,
    this.profileImageUrl,
    required this.guardianId,
  });

  // Factory constructor to create a ChildProfile from Firestore document snapshot
  // Factory constructor to create a ChildProfile from Firestore document snapshot
  factory ChildProfile.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ChildProfile(
      childId: doc.id,
      childName: data['childName'] ?? 'Unknown',
      issueId: _getListFromField(data['issueId']),
      sleepId: _getListFromField(data['sleepId']),
      awakeningsId: _getListFromField(data['awakeningsId']),
      dateOfBirth: _getDateFromField(data['dateOfBirth']),
      profileImageUrl: data['profileImageUrl'],
      guardianId: data['guardianId'] != null ? List<String>.from(data['guardianId']): [],
    );
  }

// A helper method to handle both Timestamp and String for Date
  static DateTime _getDateFromField(dynamic field) {
    if (field is Timestamp) {
      return field.toDate();
    } else if (field is int) {
      return DateTime.fromMillisecondsSinceEpoch(field);
    } else if (field is String) {
      try {
        return DateTime.parse(field);
      } catch (e) {
        print('Error parsing date: $field');
        return DateTime.now(); // Use a safe default if parsing fails
      }
    }
    return DateTime
        .now(); // Use a safe default if field is null or unknown type
  }

// A helper method to handle Lists and Strings for fields that should be lists of Strings
  static List<String> _getListFromField(dynamic field) {
    if (field is List) {
      // Convert all elements to strings safely
      return field.map((e) => e.toString()).toList();
    } else if (field is String) {
      return [field]; // Wrap single string in a list
    }
    return []; // Return an empty list if field is null or another type
  }

  // Method to convert ChildProfile to a map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'childName': childName,
      'issueId': issueId ?? [],
      'sleepId': sleepId ?? [],
      'awakeningsId': awakeningsId ?? [], // Fixed this line
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'profileImageUrl': profileImageUrl ?? '',
      'guardianId': guardianId ?? [],
    };
  }
}
