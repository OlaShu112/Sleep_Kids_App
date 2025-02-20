import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sleep_kids_app/services/firebase_service.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({Key? key}) : super(key: key);

  @override
  _GoalScreenState createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String? currentUserId; // ✅ Fix: Use nullable type

  @override
  void initState() {
    super.initState();
    _getCurrentUserId(); // ✅ Fetch user ID
  }

  // 🔹 Get the currently logged-in user's ID
  void _getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sleep Goals")),
      body: currentUserId == null
          ? const Center(child: CircularProgressIndicator()) // ✅ Wait for user ID
          : StreamBuilder<QuerySnapshot>(
              stream: _firebaseService.fetchChildren(currentUserId!), // ✅ Ensure user ID is set
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No children found."));
                }

                final children = snapshot.data!.docs;

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: children.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final childData = children[index];
                    final String childId = childData.id;
                    final String childName = childData['childName'];

                    return FutureBuilder<DocumentSnapshot?>(
                      future: _firebaseService.fetchChildGoal(childId), // ✅ Use FirebaseService
                      builder: (context, goalSnapshot) {
                        if (goalSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        bool hasGoal = goalSnapshot.data != null && goalSnapshot.data!.exists;
                        double targetBedtime = hasGoal ? (goalSnapshot.data!['bedTime'] ?? 22.0) : 22.0;
                        double targetWakeup = hasGoal ? (goalSnapshot.data!['wakeUpTime'] ?? 7.0) : 7.0;

                        return StatefulBuilder(
                          builder: (context, setChildState) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
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
                                    "Child: $childName",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  if (hasGoal) ...[
                                    Text("Target Bedtime: ${targetBedtime.toInt()}:00"),
                                    Slider(
                                      value: targetBedtime,
                                      min: 18,
                                      max: 24,
                                      divisions: 6,
                                      label: "${targetBedtime.toInt()}:00",
                                      onChanged: (value) {
                                        setChildState(() {
                                          targetBedtime = value;
                                        });
                                      },
                                    ),

                                    Text("Target Wake-up Time: ${targetWakeup.toInt()}:00"),
                                    Slider(
                                      value: targetWakeup,
                                      min: 4,
                                      max: 10,
                                      divisions: 6,
                                      label: "${targetWakeup.toInt()}:00",
                                      onChanged: (value) {
                                        setChildState(() {
                                          targetWakeup = value;
                                        });
                                      },
                                    ),

                                    const SizedBox(height: 10),

                                    // Save Button
                                    Center(
                                      child: ElevatedButton(
                                        onPressed: () => _firebaseService.saveGoal(childId, targetBedtime, targetWakeup), // ✅ Use FirebaseService
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                          backgroundColor: Colors.blueAccent,
                                        ),
                                        child: const Text("Update Goal", style: TextStyle(color: Colors.white)),
                                      ),
                                    ),
                                  ] else ...[
                                    // Show "No goal set" message and Add Goal button
                                    const Text(
                                      "No goal set.",
                                      style: TextStyle(fontSize: 16, color: Colors.red),
                                    ),
                                    const SizedBox(height: 10),
                                    Center(
                                      child: ElevatedButton(
                                        onPressed: () => _firebaseService.saveGoal(childId, 22.0, 7.0), // ✅ Use FirebaseService
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                          backgroundColor: Colors.green,
                                        ),
                                        child: const Text("Add Goal", style: TextStyle(color: Colors.white)),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
