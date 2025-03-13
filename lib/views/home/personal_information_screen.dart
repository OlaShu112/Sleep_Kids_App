import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sleep_kids_app/core/models/issue_model.dart';
import 'package:sleep_kids_app/services/firebase_service.dart';
import 'package:sleep_kids_app/core/models/child_profile_model.dart';
import 'package:intl/intl.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

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
  List<IssueModel> availableIssue = [];
  List<String> selectedIssues = []; // ✅ Store selected issues


  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchChildren();
    _fetchIssues();
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

void _fetchIssues() async {
  List<IssueModel> fetchedIssues = await _firebaseService.fetchIssues();
  setState(() {
    availableIssue = fetchedIssues; 
  });
  print("✅ Issues Fetched: ${availableIssue.length}");
}

  // 🔹 Fetch child profiles from Firestore
  void _fetchChildren() async {
  User? user = _auth.currentUser;
  if (user != null) {
    print("🚀 Fetching children for user: ${user.uid}");
    
    List<ChildProfile> fetchedChildren = await _firebaseService.getChildProfiles(user.uid);

    setState(() {
      children = fetchedChildren;
    });

    if (fetchedChildren.isEmpty) {
      print("❌ No children found.");
    } else {
      print("✅ Successfully fetched ${fetchedChildren.length} children.");
    }
  }
}


  // 🔹 Save updated user data
  void _saveUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
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

  // Show Date Picker for Child's Date of Birth
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

  // Add Child Profile (from the early code)
  void _addChild() async {
    User? user = _auth.currentUser;
    if (user != null &&
        _childNameController.text.isNotEmpty &&
        _selectedDate != null) {
      ChildProfile newChild = ChildProfile(
        childId: FirebaseFirestore.instance
            .collection('child_profiles')
            .doc()
            .id, // Generate unique ID
        childName: _childNameController.text,
        issueId: selectedIssues.isNotEmpty
            ? selectedIssues
            : [], // store selected issues
        sleepId: [],
        dateOfBirth: _selectedDate!,
        profileImageUrl: "",
        guardianId: [user.uid],
      );

      await _firebaseService.addChildProfile(newChild);
      _fetchChildren(); // Refresh the listr

      _childNameController.clear();
      setState(() {
        _selectedDate = null;
        selectedIssues = []; // Reset issues selection
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

  // 🔹 Remove Child Profile
  void _removeChild(String childId) async {
    try {
      await _firebaseService.removeChildProfile(childId);
      _fetchChildren(); // Refresh the list after deletion

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Child Removed Successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error removing child!")),
      );
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Personal Information")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
  children: children.isNotEmpty 
      ? children.map((child) {
          print("✅ Displaying Child: ${child.childName}"); // 🔹 Debugging

          // Convert Issue ID to IssueContext
          List<String> issueNames = child.issueId != null && child.issueId!.isNotEmpty
              ? child.issueId!.map((id) => 
                  availableIssue.firstWhere(
                    (issue) => issue.issueId == id,
                    orElse: () => IssueModel(issueId: '', issueContext: 'Unknown Issue', solution: ''),
                  ).issueContext
                ).toList()
              : [];

          return Card(
            margin: EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Child Name: ${child.childName}",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                          "DOB: ${DateFormat('yyyy-MM-dd').format(child.dateOfBirth)}"),
                      Text(
                        "Health Issues: ${issueNames.isNotEmpty ? issueNames.join(", ") : "None"}",
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList()
      : [Text("❌ No children found", style: TextStyle(color: Colors.red))], // Show message if empty
),



          SizedBox(height: 20),

          Text("Add Child",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),

          // Child Name Input
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
            children: availableIssue.map((issue) {
              final isSelected = selectedIssues.contains(issue.issueId);
              return ChoiceChip(
                label: Text(issue.issueContext),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected && selectedIssues.length < 3) {
                      selectedIssues.add(issue.issueId);
                    } else {
                      selectedIssues.remove(issue.issueId);
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
        ]),
      ),
    );
  }
}