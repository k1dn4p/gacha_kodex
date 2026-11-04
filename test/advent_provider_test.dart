import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gacha_codex/providers/advent_provider.dart';
import 'package:gacha_codex/advent/bakery_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('unlock boundary, cumulative progress, replay, restart and reset',
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
    now = DateTime(2026, 12, 3);
    expect(await state.openDay(2), OpenDayResult.opened);
    expect(await state.openDay(3), OpenDayResult.opened);
    expect(state.openedDays, {1, 2, 3});
    expect(await state.openDay(4), OpenDayResult.unavailable);
    expect(await state.openDay(25), OpenDayResult.unavailable);
    expect(await state.openDay(26), OpenDayResult.unavailable);
    expect(await state.openDay(1), OpenDayResult.alreadyOpened);
    state.dispose();

    final restored =
        AdventProvider(year: 2026, clock: () => DateTime(2026, 1, 1));
    await restored.ready;
    expect(restored.openedDays, {1, 2, 3});
    // Previously opened gifts remain readable even if the test clock goes back.
    expect(await restored.openDay(2), OpenDayResult.alreadyOpened);
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
    expect(await state.openDay(3), OpenDayResult.opened);
    expect(state.openedDays, {3});
    state.setIgnoreLocks(false);
    expect(await state.openDay(1), OpenDayResult.locked);
    final restarted = AdventProvider(year: 2026);
    await restarted.ready;
    expect(restarted.ignoreLocks, isFalse);
    expect(restarted.testNow, isNull);
    expect(restarted.showHotspots, isFalse);
    expect(restarted.openedDays, {3});
    state.dispose();
    restarted.dispose();
  });

  test('layer visibility is data driven, cumulative and door bounds match', () {
    Set<String> visible(Set<int> opened) => bakeryLayers
        .where((layer) => layer.isVisible(opened))
        .map((layer) => layer.id)
        .toSet();
    expect(visible({}), {'exterior', 'closed_door'});
    expect(visible({1}), {'exterior', 'closed_door', 'window_light'});
    expect(visible({1, 2}), {'exterior', 'window_light', 'open_door', 'bread'});
    expect(visible({1, 2, 3}),
        {'exterior', 'window_light', 'open_door', 'bread', 'wreath'});
    expect(bakeryLayers.firstWhere((layer) => layer.id == 'closed_door').bounds,
        bakeryLayers.firstWhere((layer) => layer.id == 'open_door').bounds);
    expect(bakeryLayers.map((layer) => layer.id).toSet().length,
        bakeryLayers.length);
    for (final layer in bakeryLayers) {
      if (layer.dayId != null)
        expect(bakeryDays(2026).any((day) => day.dayId == layer.dayId), isTrue);
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
