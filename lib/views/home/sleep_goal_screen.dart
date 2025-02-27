import 'package:flutter/material.dart';

class SleepGoalScreen extends StatefulWidget {
  const SleepGoalScreen({super.key});

  @override
  _SleepGoalScreenState createState() => _SleepGoalScreenState();
}

class _SleepGoalScreenState extends State<SleepGoalScreen> {
  double targetBedtime = 22.0; // Default 10:00 PM
  double targetWakeup = 7.0; // Default 7:00 AM

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sleep Goals")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Set Your Sleep Goals",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text("Target Bedtime: \${targetBedtime.toInt()}:00"),
            Slider(
              value: targetBedtime,
              min: 18,
              max: 24,
              divisions: 6,
              label: "\${targetBedtime.toInt()}:00",
              onChanged: (value) {
                setState(() => targetBedtime = value);
              },
            ),
            Text("Target Wake-up Time: \${targetWakeup.toInt()}:00"),
            Slider(
              value: targetWakeup,
              min: 4,
              max: 10,
              divisions: 6,
              label: "\${targetWakeup.toInt()}:00",
              onChanged: (value) {
                setState(() => targetWakeup = value);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Sleep goals updated!")),
                );
              },
              child: const Text("Save Goals"),
            ),
          ],
        ),
      ),
    );
  }
}
