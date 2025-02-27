import 'package:flutter/material.dart';
import 'package:sleep_kids_app/views/auth/login_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sleep_kids_app/core/models/user_model.dart';
import 'package:sleep_kids_app/services/firebase_service.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for input fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool agreeToTerms = false;
  final FirebaseService firebaseService =
      FirebaseService(); // Initialize Firebase Service

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Sign Up'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create an Account',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
              SizedBox(height: 20),
              _buildTextField('First Name', Icons.person, _firstNameController),
              _buildTextField('Last Name', Icons.person, _lastNameController),

              // ✅ Date of Birth with Date Picker
              TextFormField(
                controller: _dateOfBirthController,
                readOnly: true, // Prevent manual input
                decoration: InputDecoration(
                  labelText: "Date of Birth",
                  prefixIcon: Icon(Icons.calendar_today, color: Colors.blue),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000, 1, 1),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );

                  if (picked != null) {
                    setState(() {
                      _dateOfBirthController.text =
                          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select your date of birth";
                  }
                  return null;
                },
              ),

              _buildTextField('Email Address', Icons.email, _emailController,
                  isEmail: true),
              _buildTextField('Password', Icons.lock, _passwordController,
                  isPassword: true),
              _buildTextField(
                  'Confirm Password', Icons.lock, _confirmPasswordController,
                  isPassword: true),

              SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: agreeToTerms,
                    onChanged: (value) {
                      setState(() {
                        agreeToTerms = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'I agree to the ',
                        style: TextStyle(fontSize: 14),
                        children: [
                          TextSpan(
                            text: 'Terms & Conditions',
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate() && agreeToTerms) {
                      print('Creating Account...');

                      String firstName = _firstNameController.text;
                      String lastName = _lastNameController.text;
                      String email = _emailController.text;
                      String password = _passwordController.text;

                      // ✅ Convert Date String to DateTime with Error Handling
                      DateTime parsedDate;
                      try {
                        parsedDate =
                            DateTime.parse(_dateOfBirthController.text);
                      } catch (e) {
                        print(
                            '❌ Invalid Date Format: $_dateOfBirthController.text');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Invalid Date Format")),
                        );
                        return;
                      }

                      // Check if passwords match
                      if (password != _confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Passwords do not match")),
                        );
                        return;
                      }

                      try {
                        // ✅ Create user in Firebase Auth
                        UserCredential userCredential = await FirebaseAuth
                            .instance
                            .createUserWithEmailAndPassword(
                          email: email,
                          password: password,
                        );

                        // ✅ Generate userId
                        String userId = userCredential.user!.uid;

                        // ✅ Create UserModel object
                        UserModel newUser = UserModel(
                          userId: userId, // 🔹 Firebase Auth userId
                          firstName: firstName,
                          lastName: lastName,
                          email: email,
                          dateOfBirth: parsedDate, // 🔹 Now properly parsed
                          profileImageUrl: "", // 🔹 Default empty profile image
                          role: "Parent",
                        );

                        // ✅ Save to Firestore with proper error handling
                        await firebaseService.insertUser(newUser);
                        print('✅ User added to Firestore');

                        // ✅ Navigate to LoginScreen after successful sign-up
                        context.go('/login');
                      } catch (e) {
                        print('❌ Error adding user to Firestore: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Firestore Error: $e")),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text('Sign Up',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () {
                    context.go('/login');
                  },
                  child: Text('Already have an account? Login',
                      style: TextStyle(color: Colors.blue)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Inserted _buildTextField function
  Widget _buildTextField(
      String label, IconData icon, TextEditingController controller,
      {bool isPassword = false, bool isEmail = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'This field is required';
          if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value))
            return 'Enter a valid email';
          if (isPassword && value.length < 6)
            return 'Password must be at least 6 characters';
          return null;
        },
      ),
    );
  }
}
