import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;

  CustomNavBar({required this.selectedIndex});

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
      ],
    );
  }
}
