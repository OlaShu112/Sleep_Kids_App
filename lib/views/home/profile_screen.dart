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
  String profileImageUrl = "";
  bool dataSharingEnabled = false; // Default privacy setting for data sharing

  bool emailNotificationsEnabled = false; // Email notifications default state
  bool pushNotificationsEnabled = false; // Push notifications default state

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
          profileImageUrl = userDoc.get('profileImageUrl') ?? "";
          dataSharingEnabled = userDoc.get('dataSharingEnabled') ??
              false; // Fetch privacy setting
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
                // Profile image
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(50), // Circular profile image
                  child: profileImageUrl.isNotEmpty
                      ? Image.network(
                          profileImageUrl, // Load image from Firestore URL
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.deepPurple),
                        )
                      : Icon(Icons.person, size: 80, color: Colors.deepPurple),
                ),
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
            onTap: () {
              _changePassword();
            },
          ),
          _buildProfileCard(
            title: "Privacy Settings",
            description: "Manage your privacy preferences and data sharing.",
            icon: Icons.privacy_tip,
            onTap: () {
              _openPrivacySettingsDialog();
            },
          ),
          _buildProfileCard(
            title: "Notification Preferences",
            description:
                "Choose the types of notifications you want to receive.",
            icon: Icons.notifications_active,
            onTap: () {
              _openNotificationPreferencesDialog();
            },
          ),
        ],
      ),
    );
  }

  // 🔹 Change Password Logic
  void _changePassword() async {
    final _currentPasswordController = TextEditingController();
    final _newPasswordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Current Password'),
              ),
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'New Password'),
              ),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Confirm New Password'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_newPasswordController.text ==
                    _confirmPasswordController.text) {
                  try {
                    User? user = _auth.currentUser;
                    String email = user?.email ?? "";

                    // Reauthenticate the user before changing the password
                    AuthCredential credential = EmailAuthProvider.credential(
                      email: email,
                      password: _currentPasswordController.text,
                    );
                    await user?.reauthenticateWithCredential(credential);
                    await user?.updatePassword(_newPasswordController.text);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Password changed successfully')),
                    );
                  } catch (e) {
                    print(e); // Handle error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to change password')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Passwords do not match')),
                  );
                }
              },
              child: Text('Change'),
            ),
          ],
        );
      },
    );
  }

  // 🔹 Privacy Settings Dialog
  void _openPrivacySettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Privacy Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: Text('Enable Data Sharing'),
                value: dataSharingEnabled,
                onChanged: (bool value) {
                  setState(() {
                    dataSharingEnabled = value;
                  });
                  _updatePrivacySettings();
                },
                subtitle: Text(
                    'Allow us to share your data with third parties for enhanced features.'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // 🔹 Update privacy settings in Firestore
  void _updatePrivacySettings() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'dataSharingEnabled': dataSharingEnabled,
      });
    }
  }

  // 🔹 Notification Preferences Dialog
  void _openNotificationPreferencesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Notification Preferences'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: Text('Email Notifications'),
                value: emailNotificationsEnabled,
                onChanged: (bool value) {
                  setState(() {
                    emailNotificationsEnabled = value;
                  });
                },
                subtitle: Text(
                    'Receive email notifications for updates, offers, and alerts.'),
              ),
              SwitchListTile(
                title: Text('Push Notifications'),
                value: pushNotificationsEnabled,
                onChanged: (bool value) {
                  setState(() {
                    pushNotificationsEnabled = value;
                  });
                },
                subtitle: Text(
                    'Receive push notifications for real-time updates and events.'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
            TextButton(
              onPressed: () {
                _updateNotificationPreferences();
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // 🔹 Update notification preferences
  void _updateNotificationPreferences() {
    // Here you can save the user's preferences to Firestore or any other backend service
    print('Email Notifications: $emailNotificationsEnabled');
    print('Push Notifications: $pushNotificationsEnabled');
  }

  // 🔹 Profile Card Widget
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
