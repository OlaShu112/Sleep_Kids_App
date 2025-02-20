import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sleep_kids_app/services/firebase_service.dart';
import 'package:sleep_kids_app/core/models/child_profile_model.dart';
import 'package:intl/intl.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({Key? key}) : super(key: key);

  @override
  _PersonalInformationScreenState createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _firebaseService = FirebaseService();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _childNameController = TextEditingController();
  DateTime? _selectedDate;

  bool isEditing = false;
  List<ChildProfile> children = [];
  List<String> selectedIssues = []; // ✅ Store selected issues

  final List<String> availableIssues = [
    "Sleep Apnea",
    "Insomnia",
    "Night Terrors"
  ]; // ✅ Issues list

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchChildren();
  }

  // 🔹 Fetch user data from Firestore
  void _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      var userData = await _firebaseService.getUser(user.uid);
      if (userData != null) {
        setState(() {
          _firstNameController.text = userData.firstName;
          _lastNameController.text = userData.lastName;
          _emailController.text = userData.email;
        });
      }
    }
  }

  // 🔹 Fetch child profiles from Firestore
  void _fetchChildren() async {
    User? user = _auth.currentUser;
    if (user != null) {
      List<ChildProfile> fetchedChildren =
          await _firebaseService.getChildProfiles(user.uid);
      setState(() {
        children = fetchedChildren;
      });
    }
  }

  // 🔹 Save updated user data
  void _saveUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
      });

      setState(() {
        isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile Updated Successfully!")),
      );
    }
  }

  // 🔹 Show Date Picker for Child's Date of Birth
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // 🔹 Add Child Profile (from the early code)
  void _addChild() async {
    User? user = _auth.currentUser;
    if (user != null &&
        _childNameController.text.isNotEmpty &&
        _selectedDate != null) {
      ChildProfile newChild = ChildProfile(
        childId: FirebaseFirestore.instance.collection('child_profiles').doc().id, // ✅ Generate unique ID
        childName: _childNameController.text,
        issueId: selectedIssues.isNotEmpty ? selectedIssues : [], // ✅ Store selected issues
        sleepId: [],
        awakeningsId: [],
        dateOfBirth: _selectedDate!,
        profileImageUrl: "",
        guardianId: user.uid,
      );

      await _firebaseService.addChildProfile(newChild);
      _fetchChildren(); // ✅ Refresh the list

      _childNameController.clear();
      setState(() {
        _selectedDate = null;
        selectedIssues = []; // ✅ Reset issues selection
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Child Added Successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all required fields!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Personal Information")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Personal Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),

            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(
                  labelText: "First Name", border: OutlineInputBorder()),
              readOnly: !isEditing,
            ),
            SizedBox(height: 10),

            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(
                  labelText: "Last Name", border: OutlineInputBorder()),
              readOnly: !isEditing,
            ),
            SizedBox(height: 10),

            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                  labelText: "Email Address", border: OutlineInputBorder()),
              readOnly: true,
            ),
            SizedBox(height: 20),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: isEditing
                    ? _saveUserData
                    : () {
                        setState(() {
                          isEditing = true;
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEditing ? Colors.green : Colors.blue,
                ),
                child: Text(isEditing ? "Save Changes" : "Edit"),
              ),
            ),

            SizedBox(height: 30),

            Text("Children",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),

            Column(
              children: children.map((child) {
                return Card(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Child Name: ${child.childName}",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("DOB: ${DateFormat('yyyy-MM-dd').format(child.dateOfBirth)}"),
                        Text(
                          "Health Issues: ${child.issueId != null && child.issueId!.isNotEmpty ? child.issueId!.join(", ") : "None"}",
                          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 20),

        Text("Add Child",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),

        // 🔹 Child Name Input
        TextField(
          controller: _childNameController,
          decoration: InputDecoration(
              labelText: "Child Name", border: OutlineInputBorder()),
        ),
        SizedBox(height: 10),

        // 🔹 Select Health Issues
        Text("Select Health Issues (Max 3)",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),

        Wrap(
          spacing: 8.0,
          children: availableIssues.map((issue) {
            final isSelected = selectedIssues.contains(issue);
            return ChoiceChip(
              label: Text(issue),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected && selectedIssues.length < 3) {
                    selectedIssues.add(issue);
                  } else {
                    selectedIssues.remove(issue);
                  }
                });
              },
            );
          }).toList(),
        ),
        SizedBox(height: 10),

        // 🔹 Date of Birth Picker
        Text(
          "Select Date of Birth",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),

        ElevatedButton(
          onPressed: () => _pickDate(context),
          child: Text(
            _selectedDate == null
                ? "Pick Date of Birth"
                : "DOB: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}",
          ),
        ),
        SizedBox(height: 10),

        ElevatedButton(
          onPressed: _addChild,
          child: Text("Add Child"),
        ),
          ]
                ),
              ),
            );
          }
        }
