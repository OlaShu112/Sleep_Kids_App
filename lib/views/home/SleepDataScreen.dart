import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For formatting the Date and Time
import 'package:sleep_kids_app/core/models/sleep_data_model.dart';

class SleepDataScreen extends StatelessWidget {
  final String
      sleepId; // This will be passed to identify which sleep data to display

  // Constructor to receive sleepId
  const SleepDataScreen({Key? key, required this.sleepId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Scaffold widget to build the screen
    return Scaffold(
      appBar: AppBar(
        title: Text('Sleep Data Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('sleepData')
            .doc(sleepId) // Get document based on sleepId
            .get(), // Fetch the data
        builder: (context, snapshot) {
          // Show loading indicator while waiting for data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Show error if there's an issue with the request
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // If no data is returned
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No sleep data found.'));
          }

          // Convert the document data into a SleepData object
          SleepData sleepData = SleepData.fromDocument(snapshot.data!);

          // Format the date and time
          String formattedDate =
              DateFormat('yyyy-MM-dd').format(sleepData.date);
          String formattedBedtime =
              DateFormat('hh:mm a').format(sleepData.bedtime);
          String formattedWakeUpTime =
              DateFormat('hh:mm a').format(sleepData.wakeUpTime);

          // Display the data in a Column widget
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Child ID: ${sleepData.childId}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  'Date: $formattedDate',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  'Bedtime: $formattedBedtime',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  'Wake Up Time: $formattedWakeUpTime',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  'Sleep Duration: ${sleepData.sleepDuration} minutes',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  'Sleep Quality: ${sleepData.sleepQuality}/10',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  'Notes: ${sleepData.notes}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                if (sleepData.awakeningsId != null &&
                    sleepData.awakeningsId!.isNotEmpty)
                  Text(
                    'Awakenings: ${sleepData.awakeningsId!.join(', ')}',
                    style: TextStyle(fontSize: 18),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
