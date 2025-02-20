import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Import for AuthProvider
import 'package:sleep_kids_app/core/providers/auth_provider.dart';

import 'package:sleep_kids_app/views/home/sleep_tracking_screen.dart';
import 'package:sleep_kids_app/views/home/analytics_screen.dart';
import 'package:sleep_kids_app/views/home/bedtime_stories_screen.dart';
import 'package:sleep_kids_app/views/home/profile_screen.dart';
import 'package:sleep_kids_app/views/home/achievements_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String currentTime = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _fetchUserData(); // ✅ Fetch user data when home screen loads
  }

  void _updateTime() {
    setState(() {
      currentTime = DateFormat('hh:mm a').format(DateTime.now());
    });
    Future.delayed(Duration(seconds: 1), _updateTime);
  }

  // ✅ Fetch user data
  void _fetchUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context); // Access AuthProvider

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/sleep_kidss.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Text(
                  'Image not found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Logged in as:", // ✅ Display "Logged in as"
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          authProvider.lastName ?? 'User', // ✅ Fetch and display last name
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    // 🔹 Logout Button
                    IconButton(
                      icon: Icon(Icons.logout, size: 30, color: Colors.white),
                      onPressed: () {
                        authProvider.logout(); // Call logout function
                        context.go('/login'); // Navigate to login screen
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 100),
              Text(
                currentTime,
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              Spacer(),
              Text(
                'Sleep Kids',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
