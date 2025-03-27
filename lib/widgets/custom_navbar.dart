import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final bool isWatchConnected;

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.isWatchConnected,
  });

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/sleep-tracking');
        break;
      case 2:
        context.go('/analytics');
        break;
      case 3:
        context.go('/profile');
        break;
      case 4:
        context.go('/goal');
        break;
      case 5:
        context.go('/icon-watch/:sleepId'); // ✅ Add correct route for watch
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/nav_bg.jpg'),
          fit: BoxFit.cover,
        ),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => _onItemTapped(context, index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: Colors.transparent,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          const BottomNavigationBarItem(icon: Icon(Icons.bedtime), label: "Sleep"),
          const BottomNavigationBarItem(icon: Icon(Icons.analytics), label: "Stats"),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          const BottomNavigationBarItem(icon: Icon(Icons.flag), label: "Goals"),
          BottomNavigationBarItem(
            icon: Icon(
              isWatchConnected ? Icons.sync : Icons.watch,
            ),
            label: isWatchConnected ? "Connected" : "Connect",
          ),
        ],
      ),
    );
  }
}
