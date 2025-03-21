import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sleep_kids_app/views/home/change_password.dart';
import 'package:sleep_kids_app/views/home/personal_information_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String lastName = "";
  String email = "";
  String profileImageUrl = ""; // ✅ Fixed missing initialization

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
          profileImageUrl = userDoc.get('profileImageUrl') ?? ""; // ✅ Fixed missing profile image
        });
      }
    }
  }

  // 🔹 Pick and Upload Profile Image
  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage == null) return;

    File imageFile = File(pickedImage.path);
    await _uploadImageToFirebase(imageFile);
  }

  // 🔹 Upload Image to Firebase Storage
  Future<void> _uploadImageToFirebase(File imageFile) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      String filePath = 'profile_images/${user.uid}.jpg';
      Reference storageRef = FirebaseStorage.instance.ref().child(filePath);

      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      String downloadURL = await snapshot.ref.getDownloadURL();

      await _firestore.collection('users').doc(user.uid).update({
        'profileImageUrl': downloadURL,
      });

      setState(() {
        profileImageUrl = downloadURL; // ✅ Update UI immediately
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile picture updated successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload profile picture.")),
      );
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
                // Profile Image (Tap to Upload)
                GestureDetector(
                  onTap: _pickAndUploadImage,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: profileImageUrl.isNotEmpty
                        ? Image.network(
                            profileImageUrl,
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
                ),
                SizedBox(height: 10),

                // Display Last Name
                Text(
                  lastName.isNotEmpty ? lastName : "No Last Name",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                // Display Email
                Text(
                  email.isNotEmpty ? email : "No Email",
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePassword()));
            },
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
