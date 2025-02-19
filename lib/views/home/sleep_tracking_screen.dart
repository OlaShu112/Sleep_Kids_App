import 'package:flutter/material.dart';
import 'dart:async';

class SleepTrackingScreen extends StatefulWidget {
  const SleepTrackingScreen({super.key});

  @override
  _SleepTrackingScreenState createState() => _SleepTrackingScreenState();
}

class _SleepTrackingScreenState extends State<SleepTrackingScreen> {
  bool isRunning = false;
  int seconds = 0;
  late Timer timer;
  List<String> awakenings = [];

  // Start or Stop the stopwatch
  void _toggleTimer() {
    if (isRunning) {
      timer.cancel();
    } else {
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          seconds++;
        });
      });
    }
    setState(() {
      isRunning = !isRunning;
    });
  }

  // Record an awakening with the current time
  void _recordAwakening() {
    final duration = Duration(seconds: seconds);
    final formattedTime =
        "${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}";
    setState(() {
      awakenings.add("Awakening at $formattedTime");
    });
  }

  // Reset the stopwatch and clear awakenings
  void _resetTimer() {
    setState(() {
      timer.cancel();
      seconds = 0;
      awakenings.clear();
      isRunning = false;
    });
  }

  String get formattedTime {
    final duration = Duration(seconds: seconds);
    return "${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sleep Tracking')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Stopwatch display
            Center(
              child: Text(
                formattedTime,
                style: const TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Start/Stop Button
                ElevatedButton(
                  onPressed: _toggleTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isRunning ? Colors.redAccent : Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    isRunning ? "Stop" : "Start",
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),

                // Awakening Button
                ElevatedButton(
                  onPressed: isRunning ? _recordAwakening : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    "Awakening",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),

                // Reset Button
                ElevatedButton(
                  onPressed: _resetTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    "Reset",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Awakening List
            Expanded(
              child: ListView.builder(
                itemCount: awakenings.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.lightBlueAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blueAccent, width: 1),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        child: Text("${index + 1}"),
                      ),
                      title: Text(
                        awakenings[index],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
