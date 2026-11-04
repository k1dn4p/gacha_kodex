import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final advent = context.watch<AppSettingsProvider>().adventCalendar;
    // Keep page IDs stable when the optional Calendar tab is inserted.
    final pageIds = [0, 1, 2, if (advent) 4, 3];
    const routes = ['/', '/gacha', '/status', '/settings', '/calendar'];
    return BottomNavigationBar(
      currentIndex:
          pageIds.contains(currentIndex) ? pageIds.indexOf(currentIndex) : 0,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      selectedItemColor: advent ? const Color(0xFF254F43) : Colors.amber[800],
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
      ),
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '메인',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.redeem),
          label: '가챠',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: '현황',
        ),
        if (advent)
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Calendar',
          ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: '설정',
        ),
      ],
      onTap: (index) {
        final pageId = pageIds[index];
        if (pageId == currentIndex) return;
        Navigator.pushReplacementNamed(context, routes[pageId]);
      },
    );
  }
}
