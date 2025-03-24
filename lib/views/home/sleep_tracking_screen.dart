import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sleep_kids_app/core/models/child_profile_model.dart';
import 'package:sleep_kids_app/core/models/sleep_data_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sleep_kids_app/core/models/issue_model.dart';
import 'dart:io';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:sleep_kids_app/core/models/child_profile_model.dart';

class SleepTrackingScreen extends StatefulWidget {
  const SleepTrackingScreen({super.key});

  @override
  _SleepTrackingScreenState createState() => _SleepTrackingScreenState();
}

class _SleepTrackingScreenState extends State<SleepTrackingScreen> {
  bool _isDarkMode = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  File? _imageFile;
  List<ChildProfile> children =[];
  User? _user;

  @override
void initState() {
  super.initState();
  _auth.authStateChanges().listen((User? user) {
    setState(() {
      _user = user;
    });
    if (_user != null) {
      _fetchChildren(); // Fetch children when user logs in
    }
  });
}
void _fetchChildren() async {
  if (_user == null) {
    print("❌ Error: No user signed in!");
    return;
  }

  try {
    print("🚀 Fetching children for user: ${_user!.uid}");
    
    var snapshot = await _firestore
        .collection('child_profiles')  // ✅ Fetch from correct collection
        .where('guardianId', arrayContains: _user!.uid)  // ✅ Match guardian ID
        .get();

    if (snapshot.docs.isEmpty) {
      print("❌ No children found in Firestore.");
    } else {
      List<ChildProfile> childrenList = snapshot.docs
          .map((doc) => ChildProfile.fromDocument(doc))
          .toList();

      setState(() {
        children = childrenList;
      });

      print("✅ Successfully fetched ${children.length} children.");
    }
  } catch (e) {
    print("❌ Error fetching children: $e");
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Tracking'),
        actions: [
          _user != null
              ? IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  onPressed: _signOut,
                )
              : IconButton(
                  icon: const Icon(Icons.login),
                  onPressed: _signIn,
                ),
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: _toggleDarkMode,
          ),
        ],
      ),
      body: Container(
        color: _isDarkMode ? Colors.black : Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: _user == null
            ? Center(child: Text("Please sign in to track sleep."))
            : children.isEmpty
                ? const Center(child: Text("No children added yet."))
                : ListView.builder(
                    itemCount: children.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          _showChildProfile(context, children[index]);
                        },
                        child: _buildChildSleepCard(children[index]),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddChildDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  Widget _buildChildSleepCard(ChildProfile child) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blueAccent,
              radius: 30,
              backgroundImage: child.profileImageUrl != null &&
                      child.profileImageUrl!.isNotEmpty
                  ? NetworkImage(child.profileImageUrl!)
                  : null,
              child: child.profileImageUrl == null ||
                      child.profileImageUrl!.isEmpty
                  ? const Icon(Icons.person, color: Colors.white, size: 30)
                  : null,
            ),
            title: Text(child.childName,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: StreamBuilder(
              stream: _firestore
                  .collection('sleepData')
                  .where('child_id', isEqualTo: child.childId)
                  .orderBy('date', descending: true)
                  .limit(1)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text("No sleep data available.");
                }

                SleepData sleepData =
                    SleepData.fromDocument(snapshot.data!.docs.first);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        "🛏️ Bedtime: ${sleepData.bedtime.toLocal().toString()}"),
                    Text(
                        "⏰ Wake Time: ${sleepData.wakeUpTime.toLocal().toString()}"),
                    Text(
                        "💤 Total Sleep: ${_formatDuration(sleepData.sleepDuration)}"),
                    Text(
                        "🛏️ Awakenings: ${sleepData.notes.isEmpty ? '0' : sleepData.notes}"),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final Duration duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '$hours hours, $minutes minutes';
  }

Future<void> _showAddChildDialog(BuildContext context) async {
  final TextEditingController nameController = TextEditingController();
  DateTime? selectedDate;
  List<IssueModel> availableIssues = [];
  List<String> selectedIssues = [];
  File? selectedImage;

  try {
    // ✅ Fetch issues from Firestore (Ensure collection name is correct)
    var snapshot = await _firestore.collection('Issue').get();
    availableIssues = snapshot.docs.map((doc) => IssueModel.fromDocument(doc)).toList();
  } catch (e) {
    print("❌ Error fetching issues: $e");
  }

  // Show Dialog
   showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Add Child"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔹 Child Name Input
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Child's Name"),
                  ),
                  const SizedBox(height: 10),

                  // 🔹 Date Picker
                  ElevatedButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );

                      if (pickedDate != null) {
                        setDialogState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                    child: Text(
                      selectedDate == null
                          ? "Pick Date of Birth"
                          : "DOB: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}",
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 🔹 Show Health Issues
                  const Text("Select Health Issues (Max 3)",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),

                  // 🔹 Display Issues as Choice Chips
                  availableIssues.isNotEmpty
                      ? Wrap(
                          spacing: 8.0,
                          children: availableIssues.map((issue) {
                            final isSelected = selectedIssues.contains(issue.issueId);
                            return ChoiceChip(
                              label: Text(issue.issueContext),
                              selected: isSelected,
                              onSelected: (selected) {
                                setDialogState(() {
                                  if (selected && selectedIssues.length < 3) {
                                    selectedIssues.add(issue.issueId);
                                  } else {
                                    selectedIssues.remove(issue.issueId);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        )
                      : const Text("❌ No Issues Available", style: TextStyle(color: Colors.red)),

                  const SizedBox(height: 10),
                ],
              ),
            ),
            actions: [
              // Add Child Button
              TextButton(
                onPressed: () async {
                  final String name = nameController.text;
                  if (_user != null && name.isNotEmpty && selectedDate != null) {
                    await _firestore.collection('child_profiles').add({
                      'childName': name,
                      'dateOfBirth': DateFormat('yyyy-MM-dd').format(selectedDate!),
                      'issueId': selectedIssues,
                      'guardianId': [_user!.uid],
                    });

                    _fetchChildren();
                    Navigator.of(context).pop();
                  }
                },
                child: const Text("Add Child"),
              ),
              // Cancel Button
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel"),
              ),
            ],
          );
        },
      );
    },
  );
}

  void _showChildProfile(BuildContext context, ChildProfile child) async {
  List<String> issueNames = [];

  // ✅ Fetch issue names based on stored IDs
  if (child.issueId != null && child.issueId!.isNotEmpty) {
    for (String issueId in child.issueId!) {
      var issueSnapshot = await _firestore.collection('Issue').doc(issueId).get();
      if (issueSnapshot.exists) {
        issueNames.add(issueSnapshot['IssueContext']); // ✅ Get readable issue name
      } else {
        issueNames.add("Unknown Issue"); // Handle missing issues
      }
    }
  }

  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: child.profileImageUrl != null &&
                      child.profileImageUrl!.isNotEmpty
                  ? NetworkImage(child.profileImageUrl!)
                  : null,
              child: child.profileImageUrl == null ||
                      child.profileImageUrl!.isEmpty
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            const SizedBox(height: 16),
            Text("Name: ${child.childName}"),
            Text("Date of Birth: ${child.dateOfBirth}"),
            Text("Health Issues: ${issueNames.isNotEmpty ? issueNames.join(', ') : 'None'}"),
          ],
        ),
      );
    },
  );
}


  Future<void> _signIn() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: "test@example.com",
        password: "password",
      );
    } catch (e) {
      print("Error signing in: $e");
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Error signing out: $e");
    }
  }
}
