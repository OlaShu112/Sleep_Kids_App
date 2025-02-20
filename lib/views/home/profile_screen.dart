import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sleep_kids_app/views/home/personal_information_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String lastName = "";
  String email = "";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // 🔹 Fetch user data from Firestore
  void _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          lastName = userDoc.get('lastName') ?? 'Unknown';
          email = userDoc.get('email') ?? 'No Email';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                const Icon(Icons.person, size: 80, color: Colors.deepPurple),
                SizedBox(height: 10),
                Text(
                  lastName,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  email,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Text("Manage Your Profile",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          _buildProfileCard(
            title: "Personal Information",
            description: "Edit your name, email, and other personal details.",
            icon: Icons.info_outline,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PersonalInformationScreen()),
              );
            },
          ),
          _buildProfileCard(
            title: "Change Password",
            description: "Update your password for better account security.",
            icon: Icons.lock_outline,
            onTap: () {},
          ),
          _buildProfileCard(
            title: "Privacy Settings",
            description: "Manage your privacy preferences and data sharing.",
            icon: Icons.privacy_tip,
            onTap: () {},
          ),
          _buildProfileCard(
            title: "Notification Preferences",
            description: "Choose the types of notifications you want to receive.",
            icon: Icons.notifications_active,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        leading: Icon(icon, color: Colors.blue),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
