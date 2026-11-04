import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../providers/advent_provider.dart';

class AdventDebugPanel extends StatelessWidget {
  final AdventProvider advent;
  const AdventDebugPanel({super.key, required this.advent});

  Future<void> _chooseDate(BuildContext context) async {
    final current = advent.effectiveNow;
    final date = await showDatePicker(
        context: context,
        initialDate: current,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
        context: context, initialTime: TimeOfDay.fromDateTime(current));
    if (time == null) return;
    advent.setTestNow(
        DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    final now = advent.effectiveNow;
    final label =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return Card(
        child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('개발용 테스트 패널', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('${advent.testNow == null ? '실제 시각' : '테스트 시각'}: $label'),
        Wrap(spacing: 8, children: [
          TextButton(
              onPressed: () => _chooseDate(context),
              child: const Text('날짜·시간 변경')),
          TextButton(
              onPressed: () => advent.setTestNow(null),
              child: const Text('실제 시각 사용')),
          for (final day in [0, ...advent.days.map((entry) => entry.dayId)])
            OutlinedButton(
              onPressed: () =>
                  advent.setTestNow(DateTime(advent.seasonYear, 12, day)),
              child: Text(day == 0 ? '11/30' : '12/$day'),
            ),
        ]),
        SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('날짜 잠금 무시'),
            subtitle: const Text('상태는 바꾸지 않고 개봉만 허용합니다.'),
            value: advent.ignoreLocks,
            onChanged: advent.setIgnoreLocks),
        SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('터치 영역 테두리 표시'),
            value: advent.showHotspots,
            onChanged: advent.setShowHotspots),
        OutlinedButton.icon(
            onPressed: advent.isSaving
                ? null
                : () async {
                    try {
                      await advent.resetOpenedDays();
                    } catch (_) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('초기화하지 못했어요. 다시 시도해 주세요.')));
                    }
                  },
            icon: const Icon(Icons.restart_alt),
            label: const Text('개봉 상태 전체 초기화')),
      ]),
    ));
  }
}
