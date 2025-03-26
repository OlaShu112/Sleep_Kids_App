import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final bool
      isWatchConnected; // Add a field to receive the watch connection status

  // Constructor with the watch connection status passed as a parameter
  const CustomNavBar({super.key, required this.selectedIndex, required this.isWatchConnected});

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
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) => _onItemTapped(context, index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.bedtime), label: "Sleep"),
        BottomNavigationBarItem(icon: Icon(Icons.analytics), label: "Stats"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        BottomNavigationBarItem(icon: Icon(Icons.flag), label: "Goals"),
        BottomNavigationBarItem(
          icon: Icon(
            isWatchConnected
                ? Icons.sync
                : Icons.watch, // Conditional icon based on connection status
          ),
          label: isWatchConnected
              ? "Connected"
              : "Connect", // Conditional label based on connection status
        ),
      ],
    );
  }
}
