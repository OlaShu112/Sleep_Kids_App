import 'package:cloud_firestore/cloud_firestore.dart';

class ChildProfile {
  // List UserId
  String childId;
  String childName;
  List<String>? issueId;
  List<String>? sleepId; //multiple sleepId for a child and is optional
  DateTime dateOfBirth;
  String? profileImageUrl;
  List<String> guardianId;

  ChildProfile({
    required this.childId,
    required this.childName,
    this.issueId,
    this.sleepId,
    required this.dateOfBirth,
    this.profileImageUrl,
    required this.guardianId,
  });

  // Factory constructor to create a ChildProfile from Firestore document snapshot
  // Factory constructor to create a ChildProfile from Firestore document snapshot
factory ChildProfile.fromDocument(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;

  // Print the fetched data to inspect the values
  print('Fetched data for guardianId: ${data['guardianId']}');
  print('Fetched data for issueId: ${data['issueId']}');
  print('Fetched data for sleepId: ${data['sleepId']}');

  // Handle null fields and ensure that we always work with a valid list or a default value
  return ChildProfile(
    childId: doc.id,
    childName: data['childName'] ?? 'Unknown', // Default to 'Unknown' if childName is null
    issueId: _getListFromField(data['issueId']),
    sleepId: _getListFromField(data['sleepId']),
    dateOfBirth: _getDateFromField(data['dateOfBirth']),
    profileImageUrl: data['profileImageUrl'] ?? '', // Default to empty string if profileImageUrl is null
    guardianId: _getListFromField(data['guardianId']),
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
    // If it's a List, make sure all elements are strings
    return List<String>.from(field.map((e) => e.toString()));
  } else if (field is String) {
    // If it's a single String, return it as a list with one element
    return [field];
  }
  // If it's neither a List nor String, return an empty list
  return [];
}


  // Method to convert ChildProfile to a map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'childName': childName,
      'issueId': issueId ?? [],
      'sleepId': sleepId ?? [],
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'profileImageUrl': profileImageUrl ?? '',
      'guardianId': guardianId ?? [],
    };
  }
}
