import 'package:cloud_firestore/cloud_firestore.dart';

class ChildProfile {
  String childId;
  String childName;
  final List<String>? issueId;
  List<String>? sleepId; // multiple issueId for a child and is optional
  List<String>? awakeningsId;
  String? goalId;
  final DateTime dateOfBirth;
  String? profileImageUrl;
  final String guardianId;

  // Constructor
  ChildProfile({
    required this.childId,
    required this.childName,
    this.issueId,
    this.sleepId,
    this.awakeningsId,
    this.goalId,
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
      childName: data['childName'] ?? '',
      issueId: _getListFromField(data['issueId']),
      sleepId: _getListFromField(data['sleepId']),
      awakeningsId: _getListFromField(data['awakeningsId']),
      goalId: data['goalId'] as String?,
      dateOfBirth: _getDateFromField(data['dateOfBirth']), // Adjusted line
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
      'issueId': issueId ?? [], // Use empty list if issueId is null
      'sleepId': sleepId ?? [], // Use empty list if sleepId is null
      'awakeningsId':
          awakeningsId ?? [], // Use empty list if awakeningsId is null
      'goalId': goalId,
      'dateOfBirth':
          Timestamp.fromDate(dateOfBirth), // Convert DateTime to Timestamp
      'profileImageUrl': profileImageUrl ??
          '', // Default to empty string if profileImageUrl is null
      'guardianId': guardianId,
    };
  }
}
