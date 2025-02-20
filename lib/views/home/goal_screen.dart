import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({Key? key}) : super(key: key);

  @override
  _GoalScreenState createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  String currentUserId = "user123"; 

  // Fetch children linked to the current user (guardian)
  Stream<QuerySnapshot> _fetchChildren() {
    return FirebaseFirestore.instance
        .collection('children')
        .where('guardianId', isEqualTo: currentUserId)
        .snapshots();
  }

  // Save updated sleep goal to Firestore
  Future<void> _saveGoal(String childId, double bedtime, double wakeupTime) async {
    try {
      await FirebaseFirestore.instance.collection('goals').doc(childId).set({
        'bedTime': bedtime,
        'wakeUpTime': wakeupTime,
      }, SetOptions(merge: true));
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sleep goal updated for child $childId")),
      );
    } catch (e) {
      print("Error saving goal: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sleep Goals")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _fetchChildren(),
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
              double targetBedtime = 22.0; // Default bedtime: 10 PM
              double targetWakeup = 7.0; // Default wake-up time: 7 AM

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

                        // Bedtime Slider
                        Text("Target Bedtime: ${targetBedtime.toInt()}:00"),
                        Slider(
                          value: targetBedtime,
                          divisions: 6,
                          label: "${targetBedtime.toInt()}:00",
                          onChanged: (value) {
                            setChildState(() {
                              targetBedtime = value;
                            });
                          },
                        ),

                        // Wake-up Slider
                        Text("Target Wake-up Time: ${targetWakeup.toInt()}:00"),
                        Slider(
                          value: targetWakeup,
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
                            onPressed: () => _saveGoal(childId, targetBedtime, targetWakeup),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              backgroundColor: Colors.blueAccent,
                            ),
                            child: const Text("Save Goal", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
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
