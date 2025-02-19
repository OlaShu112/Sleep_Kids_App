import 'package:flutter/material.dart';



class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sleep Analytics")),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text("Track and Analyze Your Child's Sleep",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          _buildAnalyticsCard(
            title: "Sleep Duration",
            description:
                "Track the total hours of sleep your child gets each night.",
            icon: Icons.access_time,
          ),
          _buildAnalyticsCard(
            title: "Sleep Quality",
            description:
                "Analyze the quality of your child's sleep using sleep scores.",
            icon: Icons.star_rate,
          ),
          _buildAnalyticsCard(
            title: "Sleep Consistency",
            description:
                "Monitor how consistent your child's bedtime and wake-up times are.",
            icon: Icons.schedule,
          ),
          _buildAnalyticsCard(
            title: "Sleep Disturbances",
            description:
                "View trends in awakenings or disturbances throughout the night.",
            icon: Icons.notifications_active,
          ),
          SizedBox(height: 20),
          const Center(
              child: Icon(Icons.bar_chart, size: 80, color: Colors.deepPurple)),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(
      {required String title,
      required String description,
      required IconData icon}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        leading: Icon(icon, color: Colors.blue),
      ),
    );
  }
}
