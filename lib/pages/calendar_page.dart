import '../widgets/advent_ticket_badge.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../advent/village_config.dart';
import '../providers/advent_provider.dart';
import '../providers/app_settings_provider.dart';
import '../widgets/advent_debug_panel.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/village_scene.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  bool _showingGift = false;

  Future<void> _openDay(int id) async {
    if (_showingGift) return;
    final advent = context.read<AdventProvider>();
    final day = advent.day(id);
    if (day == null) return;
    _showingGift = true;
    try {
      final result = await advent.openDay(id);
      if (!mounted) return;
      if (result == OpenDayResult.locked) {
        final date = day.unlockAt;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('${date.year}년 ${date.month}월 ${date.day}일 00:00에 열 수 있어요.'),
        ));
        return;
      }
      if (result != OpenDayResult.opened &&
          result != OpenDayResult.alreadyOpened) {
        return;
      }
      await showDialog<void>(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.18),
        builder: (context) => AlertDialog(
          alignment: Alignment.bottomCenter,
          backgroundColor: adventCream,
          scrollable: true,
          title: Text('${day.dayId}일 · ${day.gift.title}'),
          content: Text(day.gift.message, style: const TextStyle(height: 1.7)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('마을로 돌아가기'))
          ],
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('개봉 기록을 저장하지 못했어요. 다시 시도해 주세요.')),
        );
      }
    } finally {
      _showingGift = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = context.watch<AppSettingsProvider>().adventCalendar;
    final advent = context.watch<AdventProvider>();
    return Scaffold(
      backgroundColor: adventCream,
      appBar: AppBar(
          actions: const [AdventTicketBadge()],
          title: const Text('Christmas Advent Calendar'),
          centerTitle: true,
          backgroundColor: adventCream,
          foregroundColor: adventGreen),
      body: !enabled
          ? const Center(child: Text('설정에서 크리스마스 어드벤트 모드를 켜 주세요.'))
          : advent.isLoading
              ? const Center(child: CircularProgressIndicator())
              : advent.error != null
                  ? Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(advent.error!),
                      TextButton(
                          onPressed: advent.load, child: const Text('다시 시도')),
                    ]))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(12, 16, 12, 28),
                      child: Center(
                          child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 680),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text('DECEMBER ${advent.seasonYear} · 01 — 25',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: adventGreen,
                                      fontSize: 12,
                                      letterSpacing: 2)),
                              const SizedBox(height: 12),
                              const Text('눈 내리는 크리스마스 마을',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: adventGreen,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(
                                  '1일·2일·12일의 숫자를 눌러 마을을 채워 주세요.\n${advent.days.where((day) => advent.openedDays.contains(day.dayId)).length} / ${advent.days.length}개의 선물을 열었어요.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: adventGreen, height: 1.6)),
                              const SizedBox(height: 16),
                              VillageScene(advent: advent, onDayTap: _openDay),
                              const SizedBox(height: 16),
                              const Text(
                                  '한 번 연 선물은 언제든 다시 볼 수 있어요.\n지금은 1일·2일·12일의 선물을 만날 수 있어요.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: adventGreen, height: 1.6)),
                              if (kDebugMode) ...[
                                const SizedBox(height: 20),
                                AdventDebugPanel(advent: advent),
                              ],
                            ]),
                      )),
                    ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}
