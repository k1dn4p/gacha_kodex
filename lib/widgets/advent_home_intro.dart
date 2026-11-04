import 'package:flutter/material.dart';
import '../advent/bakery_config.dart';

class AdventHomeIntro extends StatelessWidget {
  const AdventHomeIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
          color: adventGreen, borderRadius: BorderRadius.circular(28)),
      child: Column(children: [
        const Icon(Icons.auto_awesome, color: adventGold, size: 40),
        const SizedBox(height: 20),
        const Text('A LITTLE CHRISTMAS MAGIC',
            textAlign: TextAlign.center,
            style:
                TextStyle(color: adventGold, letterSpacing: 2, fontSize: 11)),
        const SizedBox(height: 16),
        const Text('오늘의 작은 선물을\n기다리는 즐거움',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: adventCream,
                fontSize: 30,
                height: 1.35,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 18),
        const Text(
            '12월 1일부터 25일까지,\n하루씩 따뜻해지는 크리스마스 마을.\n먼저 빵집의 1~3일 선물을 만나보세요.',
            textAlign: TextAlign.center,
            style: TextStyle(color: adventCream, fontSize: 15, height: 1.8)),
        const SizedBox(height: 24),
        FilledButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/calendar'),
            style: FilledButton.styleFrom(
                backgroundColor: adventGold,
                foregroundColor: adventGreen,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
            icon: const Icon(Icons.calendar_month_outlined),
            label: const Text('빵집에 놀러 가기')),
        const SizedBox(height: 12),
        const Text('창문과 문, 장식에 숨은 숫자를 찾아보세요',
            style: TextStyle(color: adventGold, fontSize: 12)),
      ]),
    );
  }
}
