import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sleep_kids_app/core/models/child_profile_model.dart';
import 'package:sleep_kids_app/core/models/issue_model.dart';
import 'package:sleep_kids_app/services/firebase_service.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  _EducationScreenState createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _firebaseService = FirebaseService();
  int? expandedIndex;
  List<Map<String, dynamic>> _cachedEducationList = [];
  List<IssueModel> Issues = [];
  // Replace with the actual user ID

  Future<List<Map<String, dynamic>>> _fetchEducation() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('Education').get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return {
        'title': data['title'] ?? "No Title",
        'context': data['context'] ?? "No Content Available",
      };
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchChildIssues();
    _fetchEducation().then((list) {
      setState(() {
        _cachedEducationList = list;
      });
    });
  }

  Future<List<Map<String, dynamic>>> _fetchChildIssues() async {
  User? user = _auth.currentUser;
  if (user == null) return [];

  print("🚀 Fetching children for user: ${user.uid}");

  List<ChildProfile> children = await _firebaseService.getChildProfiles(user.uid);
  List<Map<String, dynamic>> childDataList = [];

  for (var child in children) {
    // 🔹 Fetch only the issues for this specific child
    List<IssueModel> childIssues = await _firebaseService.getChildIssues(child.issueId!);

    childDataList.add({
      'childName': child.childName,
      'issues': childIssues, // List of IssueModel
    });
  }

  if (childDataList.isEmpty) {
    print("❌ No children found.");
  } else {
    print("✅ Successfully fetched ${childDataList.length} children with issues.");
  }

  return childDataList;
}



@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Sleep Education", style: TextStyle(color: Colors.white),),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    ),
    body: Stack(
      children: [
        // 🔹 Background Image
        Positioned.fill(
          child: Image.asset(
            'assets/images/night_sky.jpeg',
            fit: BoxFit.cover,
          ),
        ),

        // 🔹 Content
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Education Section
              _cachedEducationList.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _cachedEducationList.length,
                      itemBuilder: (context, index) {
                        final education = _cachedEducationList[index];
                        bool isExpanded = expandedIndex == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              expandedIndex = isExpanded ? null : index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: isExpanded
                                  ? Colors.teal[300]?.withOpacity(0.9)
                                  : Colors.teal[100]?.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 5,
                                  offset: const Offset(3, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  education['title'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: Text(
                                    education['context'],
                                    overflow: isExpanded
                                        ? TextOverflow.visible
                                        : TextOverflow.ellipsis,
                                    maxLines: isExpanded ? null : 2,
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.black54),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    isExpanded
                                        ? "Show Less ▲"
                                        : "Read More ▼",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

              const SizedBox(height: 20),

              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.green.withOpacity(0.9),
                ),
                child: const Text(
                  "Personalized Advice",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white),
                ),
              ),

              const SizedBox(height: 10),
              _buildChildAdvice(),
            ],
          ),
        ),
      ],
    ),
  );
}


  // Widget to display child issues and solutions
  Widget _buildChildAdvice() {
  return FutureBuilder<List<Map<String, dynamic>>>(
    future: _fetchChildIssues(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Center(child: Text('No advice available.'));
      }

      final childrenData = snapshot.data!;

      return Column(
        children: childrenData.map((childData) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.lightGreen[100],
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Child: ${childData['childName']}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                ..._buildIssuesList(childData['issues']),
              ],
            ),
          );
        }).toList(),
      );
    },
  );
}


// 🔹 Build List of Issues & Solutions
List<Widget> _buildIssuesList(List<IssueModel> issues) {
  if (issues.isEmpty) {
    return [const Text("No health issues found.", style: TextStyle(color: Colors.redAccent))];
  }

  return issues.map((issue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Text(
          "Issue: ${issue.issueContext}",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          "Solution: ${issue.solution}",
          style: const TextStyle(
              fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black),
        ),
        const Divider(),
      ],
    );
  }).toList();
}


}


//fetch children
//List all children
//List their Issues and solution.