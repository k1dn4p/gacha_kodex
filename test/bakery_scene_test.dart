import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gacha_codex/advent/bakery_config.dart';
import 'package:gacha_codex/pages/calendar_page.dart';
import 'package:gacha_codex/providers/advent_provider.dart';
import 'package:gacha_codex/providers/app_settings_provider.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(
      {AppSettingsProvider.storageKey: true}));

  Future<void> mount(WidgetTester tester, AdventProvider state) async {
    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
      ChangeNotifierProvider.value(value: state),
    ], child: const MaterialApp(home: CalendarPage())));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final context = tester.element(find.byType(CalendarPage));
      for (final layer in bakeryLayers) {
        await precacheImage(AssetImage(layer.assetPath), context);
      }
    });
    await tester.pumpAndSettle();
  }

  double opacity(WidgetTester tester, String id) => tester
      .widget<FadeTransition>(find.byKey(ValueKey('opacity-$id')))
      .opacity
      .value;

  Future<void> capture(WidgetTester tester, String name) async {
    if (!const bool.fromEnvironment('BAKERY_PREVIEW')) return;
    final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const ValueKey('bakery-scene')));
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 1.5);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await Directory('build/advent_preview').create(recursive: true);
      await File('build/advent_preview/$name.png')
          .writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }

  testWidgets(
      'locked taps, gifts, cumulative layers, replay, restore and reset',
      (tester) async {
    tester.view.physicalSize = const Size(600, 1050);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    if (const bool.fromEnvironment('BAKERY_PREVIEW')) {
      final loader = FontLoader('Roboto')
        ..addFont(Future.value(ByteData.sublistView(
            File('C:/Windows/Fonts/malgun.ttf').readAsBytesSync())));
      await tester.runAsync(() async {
        await loader.load();
        final icons = FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
        await icons.load();
      });
    }
    final state =
        AdventProvider(year: 2026, clock: () => DateTime(2026, 11, 30));
    await mount(tester, state);
    expect(opacity(tester, 'closed_door'), 1);
    for (final id in ['window_light', 'open_door', 'bread', 'wreath']) {
      expect(opacity(tester, id), 0);
    }
    await capture(tester, 'closed');
    await tester.tap(find.byKey(const ValueKey('day-1')));
    await tester.pumpAndSettle();
    expect(find.text('2026년 12월 1일 00:00에 열 수 있어요.'), findsOneWidget);
    expect(state.openedDays, isEmpty);
    state.setTestNow(DateTime(2026, 12, 3));
    await tester.pumpAndSettle();
    for (final id in [1, 2, 3]) {
      await tester.tap(find.byKey(ValueKey('day-$id')));
      await tester.pumpAndSettle();
      expect(find.text('$id일 · ${state.day(id)!.gift.title}'), findsOneWidget);
      await tester.tap(find.text('마을로 돌아가기'));
      await tester.pumpAndSettle();
      expect(state.openedDays.length, id);
    }
    expect(opacity(tester, 'closed_door'), 0);
    for (final id in ['window_light', 'open_door', 'bread', 'wreath']) {
      expect(opacity(tester, id), 1);
    }
    await capture(tester, 'opened');
    await tester.tap(find.byKey(const ValueKey('day-2')));
    await tester.pump();
    expect(opacity(tester, 'open_door'), 1);
    expect(opacity(tester, 'bread'), 1);
    await tester.pumpAndSettle();
    expect(find.text('2일 · 갓 구운 행복'), findsOneWidget);
    await tester.tap(find.text('마을로 돌아가기'));
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
    final restored = AdventProvider(year: 2026);
    await mount(tester, restored);
    expect(restored.openedDays, {1, 2, 3});
    expect(opacity(tester, 'open_door'), 1);
    expect(opacity(tester, 'wreath'), 1);
    // Debug panel actions are exercised through the actual UI.
    await tester.ensureVisible(find.text('터치 영역 테두리 표시'));
    await tester.tap(find.text('터치 영역 테두리 표시'));
    await tester.pumpAndSettle();
    expect(restored.showHotspots, isTrue);
    await tester.ensureVisible(find.text('개봉 상태 전체 초기화'));
    await tester.tap(find.text('개봉 상태 전체 초기화'));
    await tester.pumpAndSettle();
    expect(restored.openedDays, isEmpty);
    expect(opacity(tester, 'closed_door'), 1);
    expect(opacity(tester, 'window_light'), 0);
    expect(opacity(tester, 'bread'), 0);
    expect(opacity(tester, 'wreath'), 0);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    restored.dispose();
  });

  testWidgets('animation only runs on a visibility change, never on restore',
      (tester) async {
    final state =
        AdventProvider(year: 2026, clock: () => DateTime(2026, 12, 3));
    await mount(tester, state);
    await state.openDay(1);
    await tester.pump();
    expect(opacity(tester, 'window_light'), 0);
    await tester.pump(const Duration(milliseconds: 300));
    expect(opacity(tester, 'window_light'), greaterThan(0));
    expect(opacity(tester, 'window_light'), lessThan(1));
    await tester.pumpAndSettle();
    await state.openDay(1);
    state.setShowHotspots(true);
    await tester.pump();
    expect(opacity(tester, 'window_light'), 1);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
    final restored = AdventProvider(year: 2026);
    await restored.ready;
    // Loading is complete BEFORE first mount: first-frame visibility must be 1.
    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
      ChangeNotifierProvider.value(value: restored),
    ], child: const MaterialApp(home: CalendarPage())));
    await tester.pump();
    expect(opacity(tester, 'window_light'), 1);
    await tester.pumpWidget(const SizedBox.shrink());
    restored.dispose();
  });

  for (final width in [320.0, 600.0, 1000.0]) {
    testWidgets('assets and hit regions share scale at width $width',
        (tester) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final state =
          AdventProvider(year: 2026, clock: () => DateTime(2026, 12, 3));
      await mount(tester, state);
      final scene = tester.getRect(find.byKey(const ValueKey('bakery-scene')));
      final scale = scene.width / bakeryCanvas.width;
      for (final hotspot in bakeryHotspots) {
        final actual =
            tester.getRect(find.byKey(ValueKey('day-${hotspot.dayId}')));
        expect(actual.left,
            closeTo(scene.left + hotspot.bounds.left * scale, 0.01));
        expect(
            actual.top, closeTo(scene.top + hotspot.bounds.top * scale, 0.01));
        expect(actual.width, closeTo(hotspot.bounds.width * scale, 0.01));
        expect(actual.shortestSide, greaterThanOrEqualTo(48));
      }
      for (final layer in bakeryLayers) {
        final actual =
            tester.getRect(find.byKey(ValueKey('asset-${layer.id}')));
        expect(
            actual.left, closeTo(scene.left + layer.bounds.left * scale, 0.01));
        expect(actual.top, closeTo(scene.top + layer.bounds.top * scale, 0.01));
        expect(actual.size.width, closeTo(layer.bounds.width * scale, 0.01));
      }
      // A real tap at the transformed door centre still opens day 2.
      await tester.ensureVisible(find.byKey(const ValueKey('day-2')));
      await tester.tap(find.byKey(const ValueKey('day-2')));
      await tester.pumpAndSettle();
      expect(state.openedDays, {2});
      expect(find.text('2일 · 갓 구운 행복'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      state.dispose();
    });
  }
}


