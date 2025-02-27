import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Import for AuthProvider
import 'package:sleep_kids_app/core/providers/auth_provider.dart';

//import 'package:sleep_kids_app/views/home/sleep_tracking_screen.dart';
//import 'package:sleep_kids_app/views/home/analytics_screen.dart';
//import 'package:sleep_kids_app/views/home/bedtime_stories_screen.dart';
//import 'package:sleep_kids_app/views/home/profile_screen.dart';
//import 'package:sleep_kids_app/views/home/achievements_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String currentTime = '';
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // Added key for the Scaffold

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
    final authProvider =
        Provider.of<AuthProvider>(context); // Access AuthProvider

    return Scaffold(
      key: _scaffoldKey, // Use the global key for Scaffold
      backgroundColor: Colors.transparent,
      drawer:
          CustomNavbar(authProvider: authProvider), // Custom navigation drawer
      body: Stack(
        fit: StackFit.expand,
        children: [
          // The background image
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
          // The overlay content (current time, Sleep Kids text, and the menu icon)
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 100), // Space for the app bar
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
          // Hamburger menu button
          Positioned(
            top: 40, // Position it at the top of the screen
            left: 20, // Position it to the left
            child: IconButton(
              icon: Icon(Icons.menu, color: Colors.white, size: 30),
              onPressed: () {
                _scaffoldKey.currentState
                    ?.openDrawer(); // Open the drawer using the key
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CustomNavbar extends StatelessWidget {
  final AuthProvider authProvider;

  const CustomNavbar({Key? key, required this.authProvider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              padding: EdgeInsets.zero,
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
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
                      authProvider.lastName ??
                          'User', // ✅ Fetch and display last name
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Spacer(),
                    // Removed logout button here to place it in the list
                  ],
                ),
              ),
            ),
            ListTile(
              title:
                  Text('Sleep Tracking', style: TextStyle(color: Colors.white)),
              onTap: () => context.go('/sleep-tracking'),
            ),
            ListTile(
              title: Text('Analytics', style: TextStyle(color: Colors.white)),
              onTap: () => context.go('/analytics'),
            ),
            ListTile(
              title: Text('Bedtime Stories',
                  style: TextStyle(color: Colors.white)),
              onTap: () => context.go('/bedtime-stories'),
            ),
            ListTile(
              title:
                  Text('Achievements', style: TextStyle(color: Colors.white)),
              onTap: () => context.go('/achievements'),
            ),
            ListTile(
              title: Text('Profile', style: TextStyle(color: Colors.white)),
              onTap: () => context.go('/profile'),
            ),
            Divider(color: Colors.white70), // Adds a visual separator

            // New menu items added:
            ListTile(
              title: Text('Sleep Routine Overview',
                  style: TextStyle(color: Colors.white)),
              onTap: () => context.go('/sleep-routine-overview'),
            ),
            ListTile(
              title: Text('Notifications & Reminders',
                  style: TextStyle(color: Colors.white)),
              onTap: () => context.go('/notifications-reminders'),
            ),
            ListTile(
              title: Text('Recent Activities',
                  style: TextStyle(color: Colors.white)),
              onTap: () => context.go('/recent-activities'),
            ),
            ListTile(
              title: Text('Mood & Sleep Quality Rating',
                  style: TextStyle(color: Colors.white)),
              onTap: () => context.go('/mood-sleep-rating'),
            ),
            ListTile(
              title: Text('Parenting Tips & Sleep Education',
                  style: TextStyle(color: Colors.white)),
              onTap: () => context.go('/parenting-tips'),
            ),
            ListTile(
              title: Text('Quick Access to Settings',
                  style: TextStyle(color: Colors.white)),
              onTap: () => context.go('/settings'),
            ),
            Divider(color: Colors.white70), // Adds a visual separator

            // Moved the logout here into the ListTile
            ListTile(
              title: Text('Logout',
                  style: TextStyle(
                      color: Colors.redAccent, fontWeight: FontWeight.bold)),
              leading: Icon(Icons.logout, color: Colors.redAccent),
              onTap: () {
                authProvider.logout(); // Call the logout function
                context.go('/login'); // Navigate to the login screen
              },
            ),
          ],
        ),
      ),
    );
  }
}
