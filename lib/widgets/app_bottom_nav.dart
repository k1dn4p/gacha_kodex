import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      selectedItemColor: Colors.amber[800],
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
      ),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Main',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.redeem),
          label: 'Gacha',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Status',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
      onTap: (index) {
        if (index == currentIndex) return;

        if (index == 0) {
          Navigator.pushReplacementNamed(context, '/');
        } else if (index == 1) {
          Navigator.pushReplacementNamed(context, '/gacha');
        } else if (index == 2) {
          Navigator.pushReplacementNamed(context, '/status');
        } else if (index == 3) {
          Navigator.pushReplacementNamed(context, '/settings');
        }
      },
    );
  }
}
