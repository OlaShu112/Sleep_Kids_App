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

  String guardianId;

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
      issueId:
          data['issueId'] != null ? List<String>.from(data['issueId']) : null,
      sleepId:
          data['sleepId'] != null ? List<String>.from(data['sleepId']) : null,
      awakeningsId: data['awakeningsId'] != null
          ? List<String>.from(data['awakeningsId'])
          : null,
      dateOfBirth: (data['dateOfBirth'] as Timestamp).toDate(),
      profileImageUrl: data['profileImageUrl'],
      guardianId: data['guardianId'] ?? '',
    );
  }

// A helper method to handle both Timestamp and String for Date
  static DateTime _getDateFromField(dynamic field) {
    if (field is Timestamp) {
      // If it's a Timestamp, convert it to DateTime
      return field.toDate();
    } else if (field is String) {
      // If it's a String, convert it to DateTime (ensure correct format)
      try {
        return DateTime.parse(
            field); // Make sure the String is in a valid format
      } catch (e) {
        print('Error parsing date: $field');
        return DateTime.now();
      }
    } else {
      // Return a default value if the field is neither a String nor a Timestamp
      return DateTime.now(); // Or handle it based on your requirement
    }
  }

// A helper method to handle Lists and Strings for fields that should be lists of Strings
  static List<String> _getListFromField(dynamic field) {
    if (field is List) {
      // If the field is already a list, return it as a list of Strings.
      return List<String>.from(field);
    } else if (field is String) {
      // If the field is a string, wrap it in a list and return.
      return [field];
    }
    // Return an empty list if the field is null or another type.
    return [];
  }

  // Method to convert ChildProfile to a map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'childName': childName,
      'issueId': issueId ?? [],
      'sleepId': sleepId ?? [],
      'awakeningsId': sleepId ?? [],
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'profileImageUrl': profileImageUrl ?? '',
      'guardianId': guardianId,
    };
  }
}
