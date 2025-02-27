import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({Key? key}) : super(key: key);

  @override
  _EducationScreenState createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  int? expandedIndex;
  List<Map<String, dynamic>> _cachedEducationList = [];
  String currentUserId = "user123"; // Replace with the actual user ID

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
    _fetchEducation().then((list) {
      setState(() {
        _cachedEducationList = list;
      });
    });
  }

  Stream<QuerySnapshot> _fetchChildIssues() {
    return FirebaseFirestore.instance
        .collection('children')
        .where('guardianId', isEqualTo: currentUserId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sleep Education")),
      body: _cachedEducationList.isEmpty
          ? const Center(
              child: CircularProgressIndicator()) // Show loader initially
          : ListView.builder(
              padding: const EdgeInsets.all(16),
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
                      color: isExpanded ? Colors.teal[300] : Colors.teal[100],
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
                            isExpanded ? "Show Less ▲" : "Read More ▼",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        if (isExpanded) _buildChildAdvice(),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // Widget to display child issues and solutions
  Widget _buildChildAdvice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          "Advice for your kids:",
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: _fetchChildIssues(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No advice available.'));
            }

            final childData = snapshot.data!.docs
                .map((childDoc) {
                  final childName = childDoc['name'] ?? 'Unknown';
                  final issues =
                      childDoc['issues'] as Map<String, dynamic>? ?? {};
                  return issues.entries.map((entry) {
                    return {
                      'childName': childName,
                      'issue': entry.value['issue'] ?? 'Unknown Issue',
                      'solution':
                          entry.value['solution'] ?? 'No solution provided',
                    };
                  }).toList();
                })
                .expand((i) => i)
                .toList();

            return ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.all(16),
              itemCount: childData.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final item = childData[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(vertical: 5),
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
                        "👶 Child: ${item['childName']}",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "🛌 Issue: ${item['issue']}",
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "💡 Solution: ${item['solution']}",
                        style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.green),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
