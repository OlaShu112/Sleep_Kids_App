import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool _isLoading = false;

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF56CCF2), Color(0xFF2F80ED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Welcome Back 👋",
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2F80ED)),
                      ),
                      const SizedBox(height: 10),
                      const Text("Login to continue", style: TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 20),

                      // 🔹 Email Field
                      _buildTextField("Email Address", Icons.email, (value) => email = value, isEmail: true),

                      // 🔹 Password Field
                      _buildTextField("Password", Icons.lock, (value) => password = value, isPassword: true),

                      // 🔹 Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _resetPassword,
                          child: const Text("Forgot Password?", style: TextStyle(color: Color(0xFF2F80ED))),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // 🔹 Login Button
                      _buildLoginButton(),

                      const SizedBox(height: 10),

                      // 🔹 Sign Up Link
                      TextButton(
                        onPressed: () {
                          context.go('/signup');
                        },
                        child: const Text(
                          "Don't have an account? Sign Up",
                          style: TextStyle(color: Color(0xFF2F80ED), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Fancy TextField
  Widget _buildTextField(String label, IconData icon, Function(String) onChanged,
      {bool isPassword = false, bool isEmail = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 3))],
        ),
        child: TextFormField(
          obscureText: isPassword,
          keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: Color(0xFF2F80ED)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) return 'This field is required';
            if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Enter a valid email';
            if (isPassword && value.length < 6) return 'Password must be at least 6 characters';
            return null;
          },
        ),
      ),
    );
  }

 // 🔹 Fancy Login Button with Hover Animation
Widget _buildLoginButton() {
  return TweenAnimationBuilder<Color?>(
    tween: ColorTween(begin: Color(0xFF2F80ED), end: _isHovering ? Colors.blueAccent : Color(0xFF2F80ED)),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: _isHovering ? 8 : 4, // Subtle elevation effect
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Login', style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ),
      );
    },
  );
}

// Declare _isHovering as a State variable in your class:
bool _isHovering = false;

}
