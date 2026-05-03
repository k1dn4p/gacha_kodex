import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  /// BottomNavigationBar에서 현재 선택된 탭 인덱스.
  /// 0 = 메인, 1 = 가챠페이지, 2=현황, 3 = 설정
  final int currentIndex;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: Colors.amber[800],
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: TextStyle(
        color: Colors.amber[800],
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(
        color: Colors.grey[600],
      ),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '메인',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.redeem),
          label: '뽑기',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: '현황',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: '설정',
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
          // 아직 설정 페이지 없으면 임시 처리
        }
      },
    );
  }
}
