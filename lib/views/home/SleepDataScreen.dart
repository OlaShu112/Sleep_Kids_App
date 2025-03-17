import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    print("✅ Firebase initialized successfully!");

    // Sign in anonymously for testing
    await FirebaseAuth.instance.signInAnonymously();
    print("✅ User signed in anonymously!");
  } catch (e) {
    print("❌ Firebase initialization or sign-in error: $e");
  }
  runApp(MyApp());
}

void checkAuthStatus() {
  var user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    print("✅ User Authenticated: \${user.uid}");
  } else {
    print("❌ No authenticated user. Login required!");
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sleep Kids App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SleepDataScreen(
          sleepId:
              'goRZJ8ykhqkTFynbeAKD'), // Use your provided Firestore ID here
    );
  }
}

class SleepDataScreen extends StatefulWidget {
  final String sleepId;

  const SleepDataScreen({Key? key, required this.sleepId}) : super(key: key);

  @override
  _SleepDataScreenState createState() => _SleepDataScreenState();
}

class _SleepDataScreenState extends State<SleepDataScreen> {
  bool isConnected = false;
  String sleepDataMessage = "Connecting...";
  bool showData = false;

  @override
  void initState() {
    super.initState();

    // Simulate a connection delay
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        isConnected = true;
        sleepDataMessage = "Sleep Kids App Connected";
        print("✅ Updated message: $sleepDataMessage");
      });

      // Fetch data manually to verify Firestore connection
      fetchSleepData();
    });
  }

  void toggleData() {
    setState(() {
      showData = !showData;
    });
  }

  // Manual fetch for debugging
  void fetchSleepData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Watch_Data')
          .doc(widget.sleepId)
          .get();

      if (doc.exists) {
        print("✅ Manual Fetch Data: ${doc.data()}");
      } else {
        print("🚫 Manual Fetch: No data found for ID: ${widget.sleepId}");
      }
    } catch (e) {
      print("❌ Firestore Fetch Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    print("🛠 Current message: $sleepDataMessage");

    return Scaffold(
      appBar: AppBar(
        title:
            Text("Watch Data", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isConnected)
              Image.asset(
                'assets/images/watch_icon.png', // Ensure this file exists
                width: 200,
                height: 250,
              )
            else
              Icon(Icons.error_outline, size: 50, color: Colors.red),
            SizedBox(height: 10),
            Text(
              sleepDataMessage,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (sleepDataMessage == "Sleep Kids App Connected") ...[
              TextButton(
                onPressed: toggleData,
                child: Text(
                  showData ? "Hide Sleep Data" : "Reveal Sleep Data",
                  style: TextStyle(fontSize: 18, color: Colors.blue),
                ),
              ),
            ],
            if (showData)
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Watch_Data')
                    .doc(widget.sleepId)
                    .snapshots(),
                builder: (context, snapshot) {
                  print(
                      "📡 Firestore Stream Status: ${snapshot.connectionState}");

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    print("⏳ Waiting for data...");
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    print("❌ Firestore Error: ${snapshot.error}");
                    return Text('Error: ${snapshot.error}');
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    print("🚫 No data found for ID: ${widget.sleepId}");
                    return Text('No sleep data available.');
                  }

                  var sleepData = snapshot.data!.data() as Map<String, dynamic>;
                  print("📋 Fetched Sleep Data: $sleepData");

                  // Convert Firestore Timestamps to DateTime
                  DateTime bedtime =
                      (sleepData['bedtime'] as Timestamp).toDate();
                  DateTime wakeUpTime =
                      (sleepData['wakeUpTime'] as Timestamp).toDate();

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Bedtime: ${bedtime.toString()}",
                            style: TextStyle(fontSize: 16)),
                        Text("Wake Up Time: ${wakeUpTime.toString()}",
                            style: TextStyle(fontSize: 16)),
                        Text(
                            "Sleep Duration: ${sleepData['sleepDuration'] ?? 'Not available'} minutes",
                            style: TextStyle(fontSize: 16)),
                        Text(
                            "Sleep Quality: ${sleepData['sleepQuality'] ?? 'Not available'}",
                            style: TextStyle(fontSize: 16)),
                        Text("Notes: ${sleepData['notes'] ?? 'Not available'}",
                            style: TextStyle(fontSize: 16)),
                        Text(
                            "Awakenings: ${sleepData['awakenings']?.join(', ') ?? 'Not available'}",
                            style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ); //test
                },
              ),
          ],
        ),
      ),
    );
  }
}
