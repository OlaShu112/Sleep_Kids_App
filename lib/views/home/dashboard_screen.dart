import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Welcome Text
            Text(
              'Welcome to Your Dashboard!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Sleep Tracking Card
            _buildDashboardCard(
              context, // Pass context here
              title: "Sleep Tracking",
              description: "Track and monitor your child's sleep patterns.",
              icon: Icons.bedtime,
              route: '/sleep-tracking',
            ),

            // Analytics Card
            _buildDashboardCard(
              context, // Pass context here
              title: "Analytics",
              description: "View detailed insights into sleep analytics.",
              icon: Icons.analytics,
              route: '/analytics',
            ),

            // Bedtime Stories Card
            _buildDashboardCard(
              context, // Pass context here
              title: "Bedtime Stories",
              description: "Listen to relaxing bedtime stories.",
              icon: Icons.menu_book,
              route: '/bedtime-stories',
            ),

            // Profile Card
            _buildDashboardCard(
              context, // Pass context here
              title: "Profile",
              description: "Manage your profile and settings.",
              icon: Icons.person,
              route: '/profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
      BuildContext context, { // Pass BuildContext as a parameter
        required String title,
        required String description,
        required IconData icon,
        required String route,
      }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        leading: Icon(icon, color: Colors.deepPurple),
        onTap: () {
          Navigator.pushNamed(context, route); // Now context is available
        },
      ),
    );
  }
}
