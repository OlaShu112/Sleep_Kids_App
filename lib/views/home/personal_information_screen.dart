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
  final TextEditingController _newParentEmailController =TextEditingController();

  DateTime? _selectedDate;

  bool isEditing = false;
  List<ChildProfile> children = [];
  List<IssueModel> availableIssue = [];
  List<String> selectedIssues = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchChildren();
    _fetchIssues();
  }

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
  }

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

  Future<void> _addParent() async {
    final String email = _newParentEmailController.text;
    User? user = _auth.currentUser;

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter an email")),
      );
      return;
    }

    try {
      if (user != null) {
        await _firebaseService.addGuardianToChildren(email, user.uid);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Parent added successfully")),
        );
        Navigator.pop(context);
        _newParentEmailController.clear();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  void _addChild() async {
    User? user = _auth.currentUser;
    if (user != null &&
        _childNameController.text.isNotEmpty &&
        _selectedDate != null) {
      ChildProfile newChild = ChildProfile(
        childId:
            FirebaseFirestore.instance.collection('child_profiles').doc().id,
        childName: _childNameController.text,
        issueId: selectedIssues,
        sleepId: [],
        dateOfBirth: _selectedDate!,
        profileImageUrl: "",
        guardianId: [user.uid],
      );

      await _firebaseService.addChildProfile(newChild);
      _fetchChildren();

      _childNameController.clear();
      setState(() {
        _selectedDate = null;
        selectedIssues = [];
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

  String calculateAgeDetailed(String dob) {
    try {
      final birthDate = DateTime.parse(dob);
      final now = DateTime.now();

      int years = now.year - birthDate.year;
      int months = now.month - birthDate.month;
      int days = now.day - birthDate.day;

      if (days < 0) {
        months -= 1;
        final prevMonth = DateTime(now.year, now.month, 0);
        days += prevMonth.day;
      }
      if (months < 0) {
        years -= 1;
        months += 12;
      }
      return '$years Y, $months M, $days D';
    } catch (e) {
      return 'Invalid DOB';
    }
  }

  void _showAddParentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Add Parent"),
          content: TextField(
            controller: _newParentEmailController,
            decoration: const InputDecoration(
              labelText: "Email",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: _addParent,
              child: const Text("Add"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
            ),
          ],
        );
      },
    );
  }

  void _removeChild(String childId) async {
    try {
      await _firebaseService.removeChildProfile(childId);
      _fetchChildren();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Child Removed Successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error removing child!")),
      );
    }
  }

  void _confirmRemoveChild(String childId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to remove this child?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _removeChild(childId);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Personal Information"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Personal Details"),
            _buildTextField("First Name", _firstNameController,
                readOnly: !isEditing),
            _buildTextField("Last Name", _lastNameController,
                readOnly: !isEditing),
            _buildTextField("Email Address", _emailController, readOnly: true),
            _buildButtonRow(),
            const SizedBox(height: 30),
            _buildSectionTitle("Children"),
            ..._buildChildCards(),
            const SizedBox(height: 20),
            _buildSectionTitle("Add Child"),
            _buildTextField("Child Name", _childNameController),
            _buildIssueChips(),
            _buildDatePickerButton(),
            _buildAddChildButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );

  Widget _buildTextField(String label, TextEditingController controller,
          {bool readOnly = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
            filled: true,
            fillColor: readOnly ? Colors.grey[200] : null,
          ),
        ),
      );

  Widget _buildButtonRow() => Row(
        children: [
          ElevatedButton(
            onPressed: _showAddParentDialog,
            child: const Text("Add Parent"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: isEditing
                ? _saveUserData
                : () => setState(() => isEditing = true),
            child: Text(isEditing ? "Save Changes" : "Edit"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        ],
      );

  List<Widget> _buildChildCards() {
    if (children.isEmpty) {
      return [Text("❌ No children found", style: TextStyle(color: Colors.red))];
    }
    return children.map((child) {
      List<String> issueNames = child.issueId != null
          ? child.issueId!
              .map((id) => availableIssue
                  .firstWhere(
                    (issue) => issue.issueId == id,
                    orElse: () => IssueModel(
                        issueId: '', issueContext: 'Unknown', solution: ''),
                  )
                  .issueContext)
              .toList()
          : [];
      final age = calculateAgeDetailed(
          DateFormat('yyyy-MM-dd').format(child.dateOfBirth));
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Child Name: ${child.childName}",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                  "DOB: ${DateFormat('yyyy-MM-dd').format(child.dateOfBirth)}"),
              Text("Age: $age"),
              Text(
                  "Health Issues: ${issueNames.isNotEmpty ? issueNames.join(', ') : 'None'}",
                  style: TextStyle(
                      color: Colors.redAccent, fontWeight: FontWeight.bold)),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.delete, color: Colors.white),
                  label: Text("Remove", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => _confirmRemoveChild(child.childId),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildIssueChips() => Wrap(
        spacing: 8.0,
        children: availableIssue.map((issue) {
          final isSelected = selectedIssues.contains(issue.issueId);
          return ChoiceChip(
            label: Text(issue.issueContext),
            selected: isSelected,
            selectedColor: Colors.blueAccent,
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
      );

  Widget _buildDatePickerButton() => ElevatedButton(
        onPressed: () => _pickDate(context),
        child: Text(
          _selectedDate == null
              ? "Pick Date of Birth"
              : "DOB: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}",
        ),
      );

  Widget _buildAddChildButton() => Padding(
        padding: const EdgeInsets.only(top: 10),
        child: ElevatedButton(
          onPressed: _addChild,
          child: Text("Add Child"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
        ),
      );
}