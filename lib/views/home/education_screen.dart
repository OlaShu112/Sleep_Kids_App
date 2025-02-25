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

  Future<List<Map<String, dynamic>>> _fetchEducation() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Education').get();
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
        _cachedEducationList = list; // Cache the list after fetching
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sleep Education")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchEducation(), // Fetch only once
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _cachedEducationList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("❌ Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("⚠️ No education available."));
          }

          // Use cached data for faster rendering
          final educationList = _cachedEducationList.isNotEmpty ? _cachedEducationList : snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: educationList.length,
            itemBuilder: (context, index) {
              final education = educationList[index];
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
                          overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                          maxLines: isExpanded ? null : 2,
                          style: const TextStyle(fontSize: 16, color: Colors.black54),
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
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
