import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String userId;
  List<String>? childId;
  String firstName;
  String lastName;
  String email;
  DateTime dateOfBirth;
  String? profileImageUrl;
  String role;

  UserModel({
    required this.userId,
    this.childId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.dateOfBirth,
    this.profileImageUrl,
    required this.role,
  });

  // Factory constructor to create a UserModel from a DocumentSnapshot
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      userId: doc.id,
      childId: data['childId'],
      firstName: data['firstName'],
      lastName: data['lastName'],
      email: data['email'],
      dateOfBirth:
          (data['dateOfBirth'] as Timestamp?)?.toDate() ?? DateTime.now(),
      profileImageUrl: data['profileImageUrl'] ?? '',
      role: data['role'] ?? 'Parent',
    );
  }

  // Factory constructor to create a UserModel from a map
  factory UserModel.fromMap(Map<String, dynamic> map, {String? user_id}) {
    return UserModel(
      userId: user_id ?? '',
      childId: map['childId'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['email'],
      dateOfBirth:
          (map['dateOfBirth'] as Timestamp?)?.toDate() ?? DateTime.now(),
      profileImageUrl: map['profileImageUrl'] ?? '',
      role: map['role'] ?? 'user',
    );
  }

  // Method to convert the UserModel instance to a map
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'childId': childId ?? [], 
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'profileImageUrl': profileImageUrl ?? '',
      'role': role,
    };
  }
}
