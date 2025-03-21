import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sleep_kids_app/core/models/goals_model.dart';
import 'package:sleep_kids_app/services/firebase_service.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  _GoalScreenState createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String? currentUserId;

  final TextEditingController _goalWakeUpController = TextEditingController();
  final TextEditingController _goalBedTimeController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
  }

  // Get Current User ID
  void _getCurrentUserId() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
    }
  }

  // Save or Update Goal Data in Firestore
  // Save or Update Goal Data in Firestore
void _saveGoalData(String childId) async {
  if (_goalWakeUpController.text.isEmpty || _goalBedTimeController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please fill in all required fields!")),
    );
    return;
  }

  try {
    // Get current date to append to the entered time
    DateTime currentDate = DateTime.now();

    // Parse wake-up time (e.g., 07:30)
    String wakeUpTimeInput = _goalWakeUpController.text;
    DateTime wakeUpTime = DateTime(
      currentDate.year, 
      currentDate.month, 
      currentDate.day, 
      int.parse(wakeUpTimeInput.split(":")[0]), 
      int.parse(wakeUpTimeInput.split(":")[1])
    );

    // Parse bedtime (e.g., 22:00)
    String bedTimeInput = _goalBedTimeController.text;
    DateTime bedTime = DateTime(
      currentDate.year, 
      currentDate.month, 
      currentDate.day, 
      int.parse(bedTimeInput.split(":")[0]), 
      int.parse(bedTimeInput.split(":")[1])
    );

    // Calculate duration (in minutes)
    double duration = wakeUpTime.difference(bedTime).inMinutes / 60.0;

    // Save to Firestore
    await FirebaseFirestore.instance.collection('goals').doc(childId).set({
      'childId': childId,
      'wakeUpTime': wakeUpTime.toIso8601String(), // Store as full DateTime string
      'bedtime': bedTime.toIso8601String(),       // Store as full DateTime string
      'duration': duration,
      'isCompleted': false,
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Goal Saved Successfully!")),
    );

    Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: ${e.toString()}")),
    );
  }
}



  // Show Add/Edit Goal Popup
  void _showGoalForm(String childId, {Goal? goal}) {
    if (goal != null) {
      _goalWakeUpController.text = goal.wakeUpTime.toIso8601String().split("T")[1].substring(0, 5);
      _goalBedTimeController.text = goal.bedtime.toIso8601String().split("T")[1].substring(0, 5);
    } else {
      _goalWakeUpController.clear();
      _goalBedTimeController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(goal == null ? "Add Goal" : "Edit Goal",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _goalBedTimeController,
              decoration: const InputDecoration(
                labelText: "Bedtime (HH:mm)",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _goalWakeUpController,
              decoration: const InputDecoration(
                labelText: "Wake-Up Time (HH:mm)",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _saveGoalData(childId),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text("Save Goal", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sleep Goals")),
      body: currentUserId == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: _firebaseService.fetchChildren(currentUserId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No children found."));
                }

                final children = snapshot.data!;

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: children.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final child = children[index];
                    final String childId = child["id"];
                    final String childName = child["childName"];

                    return FutureBuilder<Goal?>(
                      future: _firebaseService.fetchGoalForChild(childId),
                      builder: (context, goalSnapshot) {
                        if (goalSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        Goal? goal = goalSnapshot.data;

                        return _buildChildCard(childId, childName, goal);
                      },
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildChildCard(String childId, String childName, Goal? goal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Child: $childName",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          if (goal != null) ...[
            Text("⏰ Wake-up Time: ${goal.wakeUpTime.toIso8601String().split('T')[1].substring(0, 5)}"),
            Text("🌙 Bedtime: ${goal.bedtime.toIso8601String().split('T')[1].substring(0, 5)}"),
            Text("📊 Duration: ${goal.duration.toStringAsFixed(1)} hours"),
            Text("🎯 Complete: ${goal.isCompleted ? '✅' : '❌'}"),
            const SizedBox(height: 10),
          ] else
            const Text("Goal is not set."),

          Center(
            child: ElevatedButton(
              onPressed: () => _showGoalForm(childId, goal: goal),
              style: ElevatedButton.styleFrom(
                backgroundColor: goal != null ? Colors.blue : Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text(goal != null ? "Edit Goal" : "Add Goal",
                  style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
