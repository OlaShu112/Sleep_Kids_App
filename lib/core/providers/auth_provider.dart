import 'package:flutter/material.dart';
import 'package:sleep_kids_app/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoggedIn = false;
  String? _lastName;

  bool get isLoggedIn => _isLoggedIn;
  String? get lastName => _lastName;

  // 🔹 Check if User is Logged In
  Future<void> checkUserLoggedIn() async {
    if (_authService.currentUser != null) {
      _isLoggedIn = true;
      await fetchUserData();
    } else {
      _isLoggedIn = false;
    }
    notifyListeners();
  }

  // 🔹 Fetch User Data
  Future<void> fetchUserData() async {
    final userData = await _authService.getUserData();
    if (userData != null) {
      _lastName = userData['lastName'];
      notifyListeners();
    }
  }

  // 🔹 Login
  Future<void> login(String email, String password) async {
    final user = await _authService.signIn(email, password);
    if (user != null) {
      _isLoggedIn = true;
      await fetchUserData();
      notifyListeners();
    }
  }

  // 🔹 Logout
  Future<void> logout() async {
    await _authService.signOut();
    _isLoggedIn = false;
    _lastName = null;
    notifyListeners();
  }
}
