import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sleep_kids_app/core/providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String currentTime = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isWatchConnected = false;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _fetchUserData();
  }

  void _updateTime() {
    setState(() {
      currentTime = DateFormat('hh:mm a').format(DateTime.now());
    });
    Future.delayed(const Duration(seconds: 1), _updateTime);
  }

  void _fetchUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomNavbar(
        authProvider: authProvider,
        isWatchConnected: isWatchConnected,
        onWatchToggle: _toggleWatchConnection,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF240046), Color(0xFF5A189A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 30),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                      onPressed: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  currentTime,
                  style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Raleway',
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Sleep Kids",
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                    fontFamily: 'Comfortaa',
                  ),
                ),
                const Spacer(),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleWatchConnection() {
    setState(() {
      isWatchConnected = !isWatchConnected;
    });
  }
}

class CustomNavbar extends StatelessWidget {
  final AuthProvider authProvider;
  final bool isWatchConnected;
  final VoidCallback onWatchToggle;

  const CustomNavbar({
    super.key,
    required this.authProvider,
    required this.isWatchConnected,
    required this.onWatchToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.deepPurple.shade900.withOpacity(0.95),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome,',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  authProvider.lastName ?? 'User',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Row(
                  children: const [
                    Icon(Icons.nightlight_round, color: Colors.white),
                    SizedBox(width: 8),
                    Text("Dream Mode", style: TextStyle(color: Colors.white)),
                  ],
                )
              ],
            ),
          ),
          _buildNavItem(context, "Sleep Tracking", Icons.bedtime, '/sleep-tracking'),
          _buildNavItem(context, "Analytics", Icons.bar_chart, '/analytics'),
          _buildNavItem(context, "Bedtime Stories", Icons.menu_book, '/bedtime-stories'),
          _buildNavItem(context, "Achievements", Icons.emoji_events, '/achievements'),
          _buildNavItem(context, "Profile", Icons.person, '/profile'),
          _buildNavItem(
            context,
            isWatchConnected ? "Disconnect Watch" : "Connect Watch",
            isWatchConnected ? Icons.sync_disabled : Icons.watch,
            null,
            onTap: onWatchToggle,
          ),
          const Divider(color: Colors.white24),
          _buildNavItem(context, "Settings", Icons.settings, '/settings'),
          _buildNavItem(context, "Logout", Icons.logout, '/login', isLogout: true),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String title, IconData icon,
      String? routeName, {VoidCallback? onTap, bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.redAccent : Colors.white),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.redAccent : Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap ??
          () {
            if (isLogout) {
              authProvider.logout();
            }
            if (routeName != null) {
              context.go(routeName);
            }
          },
    );
  }
}
