import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sleep_kids_app/core/models/child_profile_model.dart';
import 'package:sleep_kids_app/core/models/sleep_data_model.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:sleep_kids_app/services/firebase_service.dart';
import 'package:sleep_kids_app/core/models/awakenings_model.dart'; // Add import for AwakeningModel

class SleepTrackingScreen extends StatefulWidget {
  const SleepTrackingScreen({super.key});

  @override
  _SleepTrackingScreenState createState() => _SleepTrackingScreenState();
}

class _SleepTrackingScreenState extends State<SleepTrackingScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _firebaseService = FirebaseService();
  bool _isDarkMode = false;
  bool _isSleepTimerRunning = false;
  bool _isAwakeningTimerRunning = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ChildProfile> children = [];

  late Timer _sleepTimer;
  late Timer _awakeningTimer;
  int _sleepDuration = 0; // in seconds
  int _awakeningDuration = 0; // in seconds

  DateTime _bedtime = DateTime.now(); // Store bedtime
  DateTime _wakeUpTime = DateTime.now(); // Store wake-up time
  DateTime _awakeningTime = DateTime.now();
  DateTime _awakeningsEnd = DateTime.now(); // Store awakening time
  String _formattedBedtime = "Not set"; // Store formatted bedtime string
  String _formattedWakeUpTime =
      "Not set"; // Store formatted wake-up time string
  String _formattedAwakenings = "Not set";
  String _formattedAwakeningsEnd = "Not set";

  @override
  void initState() {
    super.initState();
    _fetchChildren(); // Fetch children when the screen is loaded
  }

  // Fetch children data from Firestore
  //fetch based on userId
  void _fetchChildren() async {
    User? user = _auth.currentUser;
    try {
      var snapshot = await _firestore
          .collection('child_profiles') // Fetch from correct collection
          .get();

      if (snapshot.docs.isEmpty) {
        print("❌ No children found in Firestore.");
      } else {
        if (user != null) {
          List<ChildProfile> childrenList =
              await _firebaseService.getChildProfiles(user.uid);

          setState(() {
            children = childrenList;
          });

          print("✅ Successfully fetched ${children.length} children.");
        }
      }
    } catch (e) {
      print("❌ Error fetching children: $e");
    }
  }

  // Start or Stop the sleep timer
  void _toggleSleepTimer(String childId) {
    if (_isSleepTimerRunning) {
      _wakeUpTime =
          DateTime.now(); // Capture the wake-up time when the timer stops
      _formattedWakeUpTime = DateFormat('yyyy-MM-dd HH:mm:ss')
          .format(_wakeUpTime); // Format wake-up time
      _sleepTimer.cancel(); // Stop the sleep timer
      _isSleepTimerRunning = false;
      _saveSleepData(childId); // Save the sleep data
    } else {
      _bedtime = DateTime.now(); // Store bedtime when timer starts
      _formattedBedtime =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(_bedtime); // Format for UI
      _sleepDuration = 0; // Reset sleep duration for the new session
      _sleepTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _sleepDuration++;
        });
      });
      _isSleepTimerRunning = true;
    }
    setState(() {});
  }

  // Start or Stop the awakening timer
  void _toggleAwakeningTimer(String childId) {
    if (_isAwakeningTimerRunning) {
      _awakeningsEnd =
          DateTime.now(); // Capture the wake-up time when the timer stops
      _formattedAwakeningsEnd =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(_awakeningsEnd);
      _awakeningTimer.cancel(); // Stop the awakening timer
      _isAwakeningTimerRunning = false;
      _saveAwakeningData(childId); // Save the awakening data
    } else {
      _awakeningTime =
          DateTime.now(); // Store awakening end time when timer starts
      _formattedAwakenings = DateFormat('yyyy-MM-dd HH:mm:ss')
          .format(_awakeningTime); // Format for UI
      _awakeningDuration = 0; // Reset awakening duration for the new session
      _awakeningTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _awakeningDuration++;
        });
      });
      _isAwakeningTimerRunning = true;
    }
    setState(() {});
  }

  // Save sleep data to Firestore
  Future<void> _saveSleepData(String childId) async {
    try {
      // Create a new document reference for sleep data
      DocumentReference sleepDocRef =
          await _firestore.collection('sleep_data').add({
        'bedtime': _bedtime,
        'wakeUpTime': _wakeUpTime,
        'sleepDuration': _sleepDuration,
        'notes': 'Sleep data recorded',
        'watchConnected': false, // Assuming watch connection status as false
        'awakeningsId': [], // Initialize empty list for awakenings
      });

      // After saving, get the generated sleepId
      String sleepId = sleepDocRef.id;

      // Update the child profile with the new sleepId
      DocumentSnapshot childDoc =
          await _firestore.collection('child_profiles').doc(childId).get();
      if (childDoc.exists) {
        await _firestore.collection('child_profiles').doc(childId).update({
          'sleepIds': FieldValue.arrayUnion(
              [sleepId]), // Add sleepId to the child's profile
        });
      }

      print("✅ Sleep Data saved with sleepId: $sleepId");
    } catch (e) {
      print("❌ Error saving sleep data: $e");
    }
  }

  // Save awakening data to Firestore
  Future<void> _saveAwakeningData(String childId) async {
    try {
      // Create a new awakening document
      final awakening = AwakeningsModel(
        awakeningId: DateTime.now()
            .millisecondsSinceEpoch
            .toString(), // Generate unique awakening ID
        duration: _awakeningDuration,
        wakeUp: _awakeningTime,
        bedtime: _awakeningTime.subtract(Duration(seconds: _awakeningDuration)),
      );

      // Save the awakening to Firestore
      DocumentReference awakeningRef =
          await _firestore.collection('awakenings').add(awakening.toMap());

      // Add the awakeningId to the corresponding sleep data document
      DocumentReference sleepDocRef =
          _firestore.collection('sleep_data').doc(childId);
      await sleepDocRef.update({
        'awakeningsId': FieldValue.arrayUnion([
          awakeningRef.id
        ]), // Add the awakeningId to the sleep data document
      });

      print(
          "✅ Awakening data saved and added to sleep data with awakeningId: ${awakeningRef.id}");
    } catch (e) {
      print("❌ Error saving awakening data: $e");
    }
  }

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  // Format duration to include hours, minutes, and seconds
  String _formatDuration(int seconds) {
    final Duration duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final secs = duration.inSeconds % 60;
    return '$hours h, $minutes m, $secs s';
  }

  Widget _buildExpandableChildContainer(ChildProfile child) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent,
          radius: 30,
          backgroundImage:
              child.profileImageUrl != null && child.profileImageUrl!.isNotEmpty
                  ? NetworkImage(child.profileImageUrl!)
                  : null,
          child: child.profileImageUrl == null || child.profileImageUrl!.isEmpty
              ? const Icon(Icons.person, color: Colors.white, size: 30)
              : null,
        ),
        title: Text(child.childName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          // Display the buttons and bedtime when the tile is expanded
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Column(
              children: [
                Text(
                  'Bedtime: $_formattedBedtime', // Display formatted bedtime
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Wake Up Time: $_formattedWakeUpTime', // Display formatted wake-up time
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Duration: ${_formatDuration(_sleepDuration)}', // Display timer with hours, minutes, and seconds
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Awakenings: $_formattedAwakenings', // Display awakening time
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Awakenings End: $_formattedAwakeningsEnd', // Display awakening end time
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'duration: ${_formatDuration(_awakeningDuration)}', // Display awakening duration
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(40),
                        side: BorderSide(color: Colors.red),
                      ),
                      onPressed: () {
                        _toggleSleepTimer(child.childId);
                      },
                      child: Text(_isSleepTimerRunning ? "Stop " : "Start "),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(40),
                        side: BorderSide(color: Colors.red),
                      ),
                      onPressed: () {
                        _toggleAwakeningTimer(child.childId);
                      },
                      child:
                          Text(_isAwakeningTimerRunning ? " End" : "Awakening"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: _toggleDarkMode,
          ),
        ],
      ),
      body: Container(
        color: _isDarkMode ? Colors.black : Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: children.isEmpty
            ? const Center(child: Text("No children added yet."))
            : ListView.builder(
                itemCount: children.length,
                itemBuilder: (context, index) {
                  return _buildExpandableChildContainer(children[index]);
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add logic to show Add Child Dialog
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
