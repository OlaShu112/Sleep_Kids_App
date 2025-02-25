import 'package:cloud_firestore/cloud_firestore.dart';

class Education {
  String eduId;
  String title;
  String context;

  Education({
    required this.eduId,
    required this.title,
    required this.context,
  });

  //Sleep duration
  //Diets and Sleep
  //How to get deep sleep
  //How sleep effects mood


  factory Education.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Education(
      eduId: doc.id,
      title: data['tittle'] ?? '',
      context: data['context'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eduId': eduId,
      'title': title,
      'context': context,
    };
  }
}
