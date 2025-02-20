import 'package:cloud_firestore/cloud_firestore.dart';

class StoriesModel {
  String storyId;
  String description;
  String context;
  String? profileImageUrl;

  StoriesModel({
    required this.storyId,
    required this.description,
    required this.context,
    this.profileImageUrl,
  });

  // Factory constructor to create a UserModel instance from a Firestore document
  factory StoriesModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return StoriesModel(
      storyId: doc.id,
      description: data['description'],
      context: data['context'],
      profileImageUrl: data['profileImageUrl'] ?? '',
    );
  }

  // Factory constructor to create a UserModel instance from a map
  factory StoriesModel.fromMap(Map<String, dynamic> map) {
    return StoriesModel(
      storyId: map['storyId'],
      description: map['description'],
      context: map['context'],
      profileImageUrl: map['profileImageUrl'] ?? '',
    );
  }

  // Method to convert the UserModel instance to a map
  Map<String, dynamic> toMap() {
    return {
      'storyId': storyId,
      'description': description,
      'context': context,
      'profileImageUrl': profileImageUrl,
    };
  }
}
