import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sleep_kids_app/core/models/child_profile_model.dart';
import 'package:sleep_kids_app/core/models/sleep_data_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:async';
//import 'package:intl/intl.dart';

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
  late String childId;
  User? _user;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        setState(() {
          _user = user;
        });
      } else {
        setState(() {
          _user = null;
        });
      }
    });
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
            : StreamBuilder(
                stream: _firestore
                    .collection('children')
                    .where('userId', isEqualTo: _user!.uid)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No children added yet."));
                  }

                  List<ChildProfile> children = snapshot.data!.docs
                      .map((doc) => ChildProfile.fromDocument(doc))
                      .toList();

                  return ListView.builder(
                    itemCount: children.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          _showChildProfile(context, children[index]);
                        },
                        child: _buildChildSleepCard(children[index]),
                      );
                    },
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
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _dobController = TextEditingController();
    final TextEditingController _healthIssuesController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Child"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Child's Name"),
              ),
              TextField(
                controller: _dobController,
                decoration: const InputDecoration(
                    labelText: "Date of Birth (yyyy-mm-dd)"),
              ),
              TextField(
                controller: _healthIssuesController,
                decoration: const InputDecoration(
                    labelText: "Health Issues (Optional)"),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(
                      source: ImageSource.gallery, imageQuality: 50);
                  if (pickedFile != null) {
                    setState(() {
                      _imageFile = File(pickedFile.path);
                    });
                  }
                },
                child: _imageFile == null
                    ? const Icon(Icons.add_a_photo, size: 50)
                    : Image.file(_imageFile!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final String name = _nameController.text;
                final String dob = _dobController.text;
                final String healthIssues = _healthIssuesController.text;

                if (name.isNotEmpty) {
                  try {
                    if (_user != null) {
                      String imageUrl = '';
                      if (_imageFile != null) {
                        final uploadTask = await _storage
                            .ref(
                                'child_images/${_imageFile!.path.split('/').last} ')
                            .putFile(_imageFile!);
                        imageUrl = await uploadTask.ref.getDownloadURL();
                      }

                      await _firestore.collection('children').add({
                        'childName': name,
                        'dateOfBirth': dob,
                        'issueId': healthIssues,
                        'profileImageUrl': imageUrl,
                        'userId': _user!.uid,
                      });

                      Navigator.of(context).pop();
                    }
                  } catch (e) {
                    print("Error adding child: $e");
                  }
                }
              },
              child: const Text("Add Child"),
            ),
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
  }

  void _showChildProfile(BuildContext context, ChildProfile child) {
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
              Text("Health Issues: ${child.issueId ?? 'None'}"),
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
