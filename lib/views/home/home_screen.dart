import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


// === Custom Navigation Drawer ===
class CustomNavbar extends StatelessWidget {
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
                child: Text(
                  'Menu',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ),
            ),
            ListTile(
              title: Text('Sleep Tracking', style: TextStyle(color: Colors.white)),
              onTap: () => context.go('/sleep-tracking'),
            ),
            ListTile(
              title: Text('Analytics', style: TextStyle(color: Colors.white)),
              onTap: () => context.go('/analytics'),
            ),
            ListTile(
              title: Text('Bedtime Stories', style: TextStyle(color: Colors.white)),
              onTap: () => context.go('/bedtime-stories'),
            ),
            ListTile(
              title: Text('Achievements', style: TextStyle(color: Colors.white)),
              onTap: () => context.go('/achievements'),
            ),
            ListTile(
              title: Text('Profile', style: TextStyle(color: Colors.white)),
              onTap: () => context.go('/profile'),
            ),
            Divider(color: Colors.white70), // Adds a visual separator
            ListTile(
              title: Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              leading: Icon(Icons.logout, color: Colors.redAccent),
              onTap: () {
                context.go('/'); // Navigate back to main.dart (Login Page)
              },
            ),
          ],
        ),
      ),
    );
  }
}

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
  }

  void _updateTime() {
    setState(() {
      currentTime = DateFormat('hh:mm a').format(DateTime.now());
    });
    Future.delayed(Duration(seconds: 1), _updateTime);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: CustomNavbar(), // ✅ Add CustomNavbar as a drawer
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
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Builder(
                    builder: (context) {
                      return IconButton(
                        icon: Icon(Icons.menu, size: 36, color: Colors.white),
                        onPressed: () {
                          Scaffold.of(context).openDrawer(); // ✅ Open drawer on tap
                        },
                      );
                    },
                  ),
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

