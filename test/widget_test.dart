import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gacha_codex/main.dart';
import 'package:gacha_codex/pages/calendar_page.dart';
import 'package:gacha_codex/providers/app_settings_provider.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('mode changes home and tabs, persists, and preserves tickets',
      (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text('Calendar'), findsNothing);
    final prefs = await SharedPreferences.getInstance();
    final ticketsBefore = prefs.getString('tickets');
    await tester.tap(find.text('설정'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(find.text('Calendar'), findsOneWidget);
    expect(prefs.getBool(AppSettingsProvider.storageKey), isTrue);
    expect(prefs.getString('tickets'), ticketsBefore);
    expect(
        tester
            .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
            .currentIndex,
        4);

    await tester.tap(find.text('메인'));
    await tester.pumpAndSettle();
    expect(find.text('히경이의 크리스마스'), findsOneWidget);
    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarPage), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('1'), 250,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('1'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('히경이의 크리스마스'), findsOneWidget);
    await tester.tap(find.text('설정'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(find.text('Calendar'), findsNothing);
    expect(
        tester
            .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
            .currentIndex,
        3);
    await tester.tap(find.text('메인'));
    await tester.pumpAndSettle();
    expect(find.text('히경이 쿠지샵'), findsOneWidget);
    expect(prefs.getBool(AppSettingsProvider.storageKey), isFalse);
    expect(prefs.getString('tickets'), ticketsBefore);
  });

  testWidgets('calendar fits a narrow screen with larger text', (tester) async {
    SharedPreferences.setMockInitialValues(
        {AppSettingsProvider.storageKey: true});
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('1'), 250,
        scrollable: find.byType(Scrollable).first);
    expect(tester.takeException(), isNull);
  });
}
