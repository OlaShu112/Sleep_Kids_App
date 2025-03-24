import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String email = '';
  String password = '';
  bool _isLoading = false; // To manage loading state

  // Firebase Authentication Instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔹 Login Function
  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      print("✅ Login successful!");
      context.go('/home');
    } on FirebaseAuthException catch (e) {
      String errorMessage = "🔥 Login failed. Please try again.";
      if (e.code == 'user-not-found') {
        errorMessage = "❌ No user found for this email.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "❌ Incorrect password.";
      }
      _showErrorDialog(errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 🔹 Forgot Password Function
  Future<void> _resetPassword() async {
    if (email.isEmpty) {
      _showErrorDialog("Please enter your email first.");
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showSuccessDialog("✅ Password reset link sent! Check your email.");
    } catch (e) {
      _showErrorDialog("❌ Error sending reset link. Please try again.");
    }
  }

  // 🔹 Error Dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  // 🔹 Success Dialog
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Success"),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Login'),
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
                'Welcome Back',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
              SizedBox(height: 20),
              _buildTextField(
                  'Email Address', Icons.email, (value) => email = value,
                  isEmail: true),
              _buildTextField(
                  'Password', Icons.lock, (value) => password = value,
                  isPassword: true),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : _loginUser, // Disable button when loading
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(
                          color: Colors.white) // Show loading indicator
                      : Text('Login',
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () {
                    context.go('/signup'); // Navigate to SignUp screen
                  },
                  child: Text("Don't have an account? Sign Up",
                      style: TextStyle(color: Colors.blue)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, IconData icon, Function(String) onChanged,
      {bool isPassword = false, bool isEmail = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: TextFormField(
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        onChanged: onChanged,
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

  // 🔹 Fancy Login Button with Hover Animation
  Widget _buildLoginButton() {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(
          begin: Color(0xFF2F80ED),
          end: _isHovering ? Colors.blueAccent : Color(0xFF2F80ED)),
      duration: const Duration(milliseconds: 300),
      builder: (context, color, child) {
        return MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _loginUser,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                elevation: _isHovering ? 8 : 4, // Subtle elevation effect
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Login',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ),
        );
      },
    );
  }

// Declare _isHovering as a State variable in your class:
  bool _isHovering = false;
}
