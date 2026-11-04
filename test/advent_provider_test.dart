import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gacha_codex/providers/advent_provider.dart';
import 'package:gacha_codex/advent/village_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('day one and two unlock boundaries, replay, restart and reset',
      () async {
    var now = DateTime(2026, 11, 30, 23, 59, 59);
    final state = AdventProvider(year: 2026, clock: () => now);
    await state.ready;
    expect(state.openedDays, isEmpty);
    expect(await state.openDay(1), OpenDayResult.locked);
    expect(state.openedDays, isEmpty);
    now = DateTime(2026, 12, 1);
    expect(await state.openDay(1), OpenDayResult.opened);
    expect(state.stateFor(1)!.isOpened, isTrue);
    expect(await state.openDay(2), OpenDayResult.locked);
    now = DateTime(2026, 12, 2);
    expect(await state.openDay(2), OpenDayResult.opened);
    expect(await state.openDay(3), OpenDayResult.unavailable);
    expect(state.openedDays, {1, 2});
    expect(await state.openDay(4), OpenDayResult.unavailable);
    expect(await state.openDay(25), OpenDayResult.unavailable);
    expect(await state.openDay(26), OpenDayResult.unavailable);
    expect(await state.openDay(1), OpenDayResult.alreadyOpened);
    state.dispose();

    final restored =
        AdventProvider(year: 2026, clock: () => DateTime(2026, 1, 1));
    await restored.ready;
    expect(restored.openedDays, {1, 2});
    // Previously opened gifts remain readable even if the test clock goes back.
    expect(await restored.openDay(1), OpenDayResult.alreadyOpened);
    await restored.resetOpenedDays();
    expect(restored.openedDays, isEmpty);
    final reset = AdventProvider(year: 2026);
    await reset.ready;
    expect(reset.openedDays, isEmpty);
    restored.dispose();
    reset.dispose();
  });

  test('development controls do not open gifts and are not persisted',
      () async {
    final state = AdventProvider(year: 2026, clock: () => DateTime(2026, 1, 1));
    await state.ready;
    state.setIgnoreLocks(true);
    state.setTestNow(DateTime(2026, 12, 3));
    state.setShowHotspots(true);
    expect(state.openedDays, isEmpty);
    state.setTestNow(null);
    expect(await state.openDay(1), OpenDayResult.opened);
    expect(state.openedDays, {1});
    state.setIgnoreLocks(false);
    expect(await state.openDay(1), OpenDayResult.alreadyOpened);
    final restarted = AdventProvider(year: 2026);
    await restarted.ready;
    expect(restarted.ignoreLocks, isFalse);
    expect(restarted.testNow, isNull);
    expect(restarted.showHotspots, isFalse);
    expect(restarted.openedDays, {1});
    state.dispose();
    restarted.dispose();
  });

  test('day twelve unlocks independently and progress accumulates and restores',
      () async {
    var now = DateTime(2026, 12, 11, 23, 59, 59);
    final state = AdventProvider(year: 2026, clock: () => now);
    await state.ready;
    expect(await state.openDay(12), OpenDayResult.locked);
    now = DateTime(2026, 12, 12);
    expect(await state.openDay(12), OpenDayResult.opened);
    expect(state.openedDays, {12});
    expect(await state.openDay(1), OpenDayResult.opened);
    expect(state.openedDays, {1, 12});
    state.dispose();

    final restored = AdventProvider(year: 2026);
    await restored.ready;
    expect(restored.openedDays, {1, 12});
    expect(await restored.openDay(12), OpenDayResult.alreadyOpened);
    await restored.resetOpenedDays();
    expect(restored.openedDays, isEmpty);
    restored.dispose();
  });

  test('village overlays are independently visible and cumulative', () {
    Set<String> visible(Set<int> opened) => villageLayers
        .where((layer) => layer.isVisible(opened))
        .map((layer) => layer.id)
        .toSet();
    expect(visible({}), {'village'});
    expect(visible({1}), {'village', 'day1_window'});
    expect(visible({2}), {'village', 'day2_attic_window'});
    expect(visible({12}), {'village', 'day12_walking_couple'});
    expect(
        visible({1, 12}), {'village', 'day1_window', 'day12_walking_couple'});
    expect(visible({1, 2, 12}), {
      'village',
      'day1_window',
      'day2_attic_window',
      'day12_walking_couple'
    });
    expect(visible({3, 25}), {'village'});
    expect(villageLayers.first.bounds, villageBounds);
    expect(villageLayers.map((layer) => layer.id).toSet().length,
        villageLayers.length);
    for (final layer in villageLayers) {
      if (layer.dayId != null) {
        expect(
            villageDays(2026).any((day) => day.dayId == layer.dayId), isTrue);
      }
    }
  });

  test('records are scoped to season and day 25 requires real configuration',
      () async {
    SharedPreferences.setMockInitialValues({
      'advent_opened_days_v1_2025': ['1', '2', '3']
    });
    final state =
        AdventProvider(year: 2026, clock: () => DateTime(2026, 12, 25), days: [
      AdventDay(
          dayId: 25,
          unlockAt: DateTime(2026, 12, 25),
          gift: const AdventGift('Christmas', 'Merry Christmas')),
    ]);
    await state.ready;
    expect(state.openedDays, isEmpty);
    expect(await state.openDay(25), OpenDayResult.opened);
    expect(state.openedDays, {25});
    state.dispose();
  });
}
