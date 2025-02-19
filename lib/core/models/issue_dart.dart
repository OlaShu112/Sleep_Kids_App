import 'package:cloud_firestore/cloud_firestore.dart';

class IssueModel {
  String issueId;
  String solution;
  String issueContext;

  IssueModel(
      {required this.issueId,
      required this.solution,
      required this.issueContext});

  factory IssueModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return IssueModel(
        issueId: doc.id,
        issueContext: data['issueCntext'],
        solution: data['solution']);
  }

  Map<String, dynamic> toMap() {
    return {
      'issueContext': issueContext,
      'solutionId' : solution,
    };
  }
}
