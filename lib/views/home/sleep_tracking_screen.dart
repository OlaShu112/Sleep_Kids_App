import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sleep_kids_app/core/models/child_profile_model.dart';
import 'package:sleep_kids_app/core/models/sleep_data_model.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:sleep_kids_app/services/firebase_service.dart';
import 'package:sleep_kids_app/core/models/awakenings_model.dart';

class SleepTrackingScreen extends StatefulWidget {
  const SleepTrackingScreen({super.key});

  @override
  _SleepTrackingScreenState createState() => _SleepTrackingScreenState();
}

class _SleepTrackingScreenState extends State<SleepTrackingScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _firebaseService = FirebaseService();
  bool _isDarkMode = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ChildProfile> children = [];

  // Independent timers and states for each child
  Map<String, Timer?> _sleepTimers = {};
  Map<String, Timer?> _awakeningTimers = {};
  Map<String, bool> _isSleepTimerRunning = {};
  Map<String, bool> _isAwakeningTimerRunning = {};
  Map<String, double> _sleepDurations = {}; // Updated to double
  Map<String, double> _awakeningDurations = {}; // Updated to double

  // Child specific time management
  Map<String, DateTime> _bedtimes = {};
  Map<String, DateTime> _wakeUpTimes = {};
  Map<String, DateTime> _awakeningTimes = {};
  Map<String, DateTime> _awakeningsEnds = {};

  // Child specific formatted times
  Map<String, String> _formattedBedtimes = {};
  Map<String, String> _formattedWakeUpTimes = {};
  Map<String, String> _formattedAwakenings = {};
  Map<String, String> _formattedAwakeningsEnds = {};

  // Temporary list to store awakening IDs
  Map<String, List<String>> _tempAwakenings = {};

  @override
  void initState() {
    super.initState();
    _fetchChildren();
  }

  // Fetch children data from Firestore
  void _fetchChildren() async {
    User? user = _auth.currentUser;
    try {
      var snapshot = await _firestore.collection('child_profiles').get();

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

  // Start or Stop the sleep timer for each child
  void _toggleSleepTimer(String childId) {
    if (_isSleepTimerRunning[childId] == true) {
      // Capture the wake-up time when the timer stops
      _wakeUpTimes[childId] = DateTime.now();
      _formattedWakeUpTimes[childId] =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(_wakeUpTimes[childId]!);

      // Stop the sleep timer
      _sleepTimers[childId]?.cancel();
      _isSleepTimerRunning[childId] = false;

      // Save the sleep data and include all the awakening IDs from the temporary list
      _saveSleepData(childId);

      // Reset the temporary awakening list
      _tempAwakenings[childId] = [];

      setState(() {});
    } else {
      // Start the sleep timer and reset display values
      _bedtimes[childId] = DateTime.now();
      _formattedBedtimes[childId] =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(_bedtimes[childId]!);

      // Reset the displayed sleep duration
      _sleepDurations[childId] = 0.0; // Reset to zero when the timer starts

      // Start the sleep timer
      _sleepTimers[childId] = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _sleepDurations[childId] =
              (_sleepDurations[childId] ?? 0.0) + 1.0; // Increment duration
        });
      });

      _isSleepTimerRunning[childId] = true;

      // Reset the displayed wake-up time when timer starts
      setState(() {
        _sleepDurations[childId] = 0.0; // Reset the displayed sleep duration
        _formattedWakeUpTimes[childId] = "Not set";
        _awakeningDurations[childId] = 0.0;
        _formattedAwakenings[childId] = "Not set";
        _formattedAwakeningsEnds[childId] = "Not set";
      });
    }
  }

  // Start or Stop the awakening timer for each child
  void _toggleAwakeningTimer(String childId) {
    if (_isAwakeningTimerRunning[childId] == true) {
      _awakeningsEnds[childId] = DateTime.now();
      _formattedAwakeningsEnds[childId] =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(_awakeningsEnds[childId]!);
      _awakeningTimers[childId]?.cancel();
      _isAwakeningTimerRunning[childId] = false;
      

      _saveAwakeningData(childId);
    } else {
      _awakeningTimes[childId] = DateTime.now();
      _formattedAwakenings[childId] =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(_awakeningTimes[childId]!);
      _awakeningDurations[childId] = 0.0; // Initialize as double

      _awakeningTimers[childId] = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _formattedAwakeningsEnds[childId] = "Not Set";
          _awakeningDurations[childId] = (_awakeningDurations[childId] ?? 0.0) +
              1.0; // Increment as double
        });
      });

      _isAwakeningTimerRunning[childId] = true;
    }
    setState(() {});
  }

  // Save sleep data to Firestore, including all stored awakenings' IDs
  // Save sleep data to Firestore, including all stored awakenings' IDs


// In the class where you want to save data (e.g., _SleepTrackingScreenState)

// Save sleep data using Firebase Service
Future<void> _saveSleepData(String childId) async {
    try {
      // Create a SleepData object to pass to the Firebase service
      SleepData sleepData = SleepData(
  sleepId: DateTime.now().millisecondsSinceEpoch.toString(),
  childId: childId, // 🔥 Add this
  bedtime: _bedtimes[childId]!,
  wakeUpTime: _wakeUpTimes[childId]!,
  sleepDuration: _sleepDurations[childId]!.toInt(),
  notes: 'Sleep data recorded',
  watchConnected: false,
  awakeningsId: _tempAwakenings[childId] ?? [],
);


      // Use FirebaseService to add the sleep data
      await _firebaseService.addSleepData(sleepData);

      // Call addAwakeningsToSleepData to add the awakenings to sleep_data
      await _firebaseService.addAwakeningsToSleepData(
        sleepData.sleepId, 
        _tempAwakenings[childId] ?? []
      );

      print("✅ Sleep Data saved successfully and awakenings added to sleep data");
      
      // Reset the temporary awakening list after saving
      _tempAwakenings[childId] = [];

    } catch (e) {
      print("❌ Error saving sleep data: $e");
    }
  }

// Save awakening data using Firebase Service
Future<void> _saveAwakeningData(String childId) async {
    try {
      // Create an AwakeningsModel object to pass to the Firebase service
      final awakening = AwakeningsModel(
        awakeningId: DateTime.now().millisecondsSinceEpoch.toString(),
        duration: _awakeningDurations[childId]?.toInt() ?? 0,
        wakeUp: _awakeningTimes[childId]!,
        bedtime: _awakeningTimes[childId]!
            .subtract(Duration(seconds: _awakeningDurations[childId]!.toInt())),
      );

      // Use FirebaseService to add the awakening data
      await _firebaseService.addAwakenings(awakening);

      // Store the awakening ID temporarily in the list
      if (_tempAwakenings[childId] == null) {
        _tempAwakenings[childId] = [];
      }
      _tempAwakenings[childId]?.add(awakening.awakeningId);

      print("✅ Awakening data saved with awakeningId: ${awakening.awakeningId}");
      
    } catch (e) {
      print("❌ Error saving awakening data: $e");
    }
  }



  // Format the duration for display as h:m:s
  String _formatDuration(double seconds) {
    final Duration duration = Duration(seconds: seconds.toInt());
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Column(
              children: [
                Text(
                    'Bedtime: ${_formattedBedtimes[child.childId] ?? "Not set"}'),
                SizedBox(height: 10),
                Text(
                    'Wake Up Time: ${_formattedWakeUpTimes[child.childId] ?? "Not set"}'),
                SizedBox(height: 10),
                Text(
                    'Duration: ${_formatDuration(_sleepDurations[child.childId] ?? 0.0)}'),
                SizedBox(height: 10),
                Text(
                    'Awakenings: ${_formattedAwakenings[child.childId] ?? "Not set"}'),
                SizedBox(height: 10),
                Text(
                    'Awakenings End: ${_formattedAwakeningsEnds[child.childId] ?? "Not set"}'),
                SizedBox(height: 10),
                Text(
                    'Awakening Duration: ${_formatDuration(_awakeningDurations[child.childId] ?? 0.0)}'),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _toggleSleepTimer(child.childId),
                      child: Text(_isSleepTimerRunning[child.childId] == true
                          ? "Stop Sleep"
                          : "Start Sleep"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => _toggleAwakeningTimer(child.childId),
                      child: Text(
                          _isAwakeningTimerRunning[child.childId] == true
                              ? "End Awakening"
                              : "Start Awakening"),
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
      title: const Text("Sleep Tracking", style: TextStyle(color: Colors.white),),
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
    // 🌌 Night sky background
    Positioned.fill(
      child: Image.asset(
        'assets/images/night_sky.jpeg', // Make sure this path exists
        fit: BoxFit.cover,
      ),
    ),
    // 🌙 Foreground content with padding
    Container(
      padding: const EdgeInsets.all(16.0),
      child: children.isEmpty
          ? const Center(
              child: Text(
                "No children added yet.",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder(
              itemCount: children.length,
              itemBuilder: (context, index) {
                return _buildExpandableChildContainer(children[index]);
              },
            ),
    ),
  ],
),

    );
  }
}