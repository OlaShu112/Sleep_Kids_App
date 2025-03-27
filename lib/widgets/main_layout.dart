import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<String> _routes = [
    '/home',
    '/sleep-tracking',
    '/analytics',
    '/bedtime-stories',
    '/profile',
    '/goal',
    '/education',
    // '/achievement',
    '/icon-watch/:sleepId', // Added route with watch icon
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).uri.toString();
    setState(() {
      _selectedIndex = _routes.indexOf(location);
    });
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
      context.go(_routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/nav_bg.jpg'),
            fit: BoxFit.cover,
          ),
          boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black45)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: GNav(
                backgroundColor: Colors.transparent,
                color: Colors.white,
                activeColor: Colors.blueAccent,
                tabBackgroundColor: Colors.black54,
                gap: 6,
                padding: const EdgeInsets.all(12),
                selectedIndex: _selectedIndex,
                onTabChange: _onItemTapped,
                tabs: const [
                  GButton(icon: Icons.home, text: 'Home'),
                  GButton(icon: Icons.nightlight, text: 'Sleep'),
                  GButton(icon: Icons.analytics, text: 'Analytics'),
                  GButton(icon: Icons.book, text: 'Stories'),
                  GButton(icon: Icons.person, text: 'Profile'),
                  GButton(icon: Icons.flag, text: 'Goal'),
                  GButton(icon: Icons.school, text: 'Education'),
                  // GButton(icon: Icons.emoji_events, text: 'Achievements'),
                  GButton(
                      icon: Icons.watch, text: 'Watch'), // Added the watch icon
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
