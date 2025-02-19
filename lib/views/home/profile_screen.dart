import 'package:flutter/material.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text("Manage Your Profile",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          _buildProfileCard(
            title: "Personal Information",
            description: "Edit your name, email, and other personal details.",
            icon: Icons.info_outline,
          ),
          _buildProfileCard(
            title: "Change Password",
            description: "Update your password for better account security.",
            icon: Icons.lock_outline,
          ),
          _buildProfileCard(
            title: "Privacy Settings",
            description: "Manage your privacy preferences and data sharing.",
            icon: Icons.privacy_tip,
          ),
          _buildProfileCard(
            title: "Notification Preferences",
            description:
                "Choose the types of notifications you want to receive.",
            icon: Icons.notifications_active,
          ),
          SizedBox(height: 20),
          const Center(
              child: Icon(Icons.person, size: 80, color: Colors.deepPurple)),
        ],
      ),
    );
  }

  Widget _buildProfileCard(
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
