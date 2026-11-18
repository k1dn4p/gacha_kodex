import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gacha_codex/providers/advent_provider.dart';
import 'package:gacha_codex/providers/app_settings_provider.dart';
import 'package:gacha_codex/providers/ticket_provider.dart';
import 'package:gacha_codex/pages/gacha_page.dart';
import 'package:gacha_codex/widgets/ticket_tear_dialog.dart';
import 'package:gacha_codex/widgets/advent_ticket_badge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('earn once, spend once, restore, reset and isolate seasons', () async {
    final state =
        AdventProvider(year: 2026, clock: () => DateTime(2026, 12, 25));
    await state.ready;
    expect(state.ticketBalance, 0);
    expect(await state.selectTicket(state.tickets.first), false);
    await state.openDay(1);
    await state.openDay(1);
    expect(state.ticketBalance, 1);
    final ticket = state.tickets.first;
    final results = await Future.wait([
      state.selectTicket(ticket),
      state.selectTicket(ticket),
    ]);
    expect(results.where((r) => r).length, 1);
    expect(state.ticketBalance, 0);
    expect(state.tickets.where((t) => t.isOpened).length, 1);
    expect(await state.selectTicket(state.tickets[1]), false);
    await state.openDay(2);
    final restored = AdventProvider(year: 2026);
    await restored.ready;
    expect(restored.ticketBalance, 1);
    expect(restored.tickets.first.isOpened, true);
    expect(restored.tickets.first.prizeLevel, ticket.prizeLevel);
    expect(restored.tickets.first.imagePathPrize, contains('/advent/'));
    final nextYear = AdventProvider(year: 2027);
    await nextYear.ready;
    expect(nextYear.ticketBalance, 0);
    await restored.resetOpenedDays();
    expect(restored.ticketBalance, 0);
    expect(restored.tickets.every((t) => !t.isOpened), true);
    state.dispose();
    restored.dispose();
    nextYear.dispose();
  });

  test('old opened days receive credit without altering ordinary records',
      () async {
    SharedPreferences.setMockInitialValues({
      'advent_opened_days_v1_2026': ['1', '2'],
      'tickets': 'ordinary records',
    });
    final state = AdventProvider(year: 2026);
    await state.ready;
    expect(state.ticketBalance, 2);
    expect(await state.selectTicket(state.tickets.first), true);
    final restored = AdventProvider(year: 2026);
    await restored.ready;
    expect(restored.ticketBalance, 1);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('tickets'), 'ordinary records');
    state.dispose();
    restored.dispose();
  });

  testWidgets(
      'ticket badge sparkles on an award and returns to rest without looping',
      (tester) async {
    SharedPreferences.setMockInitialValues({'advent_calendar': true});
    final state =
        AdventProvider(year: 2026, clock: () => DateTime(2026, 12, 25));
    await state.ready;
    final settings = AppSettingsProvider();

    Widget badge(int celebrationId) => MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: state),
              ChangeNotifierProvider.value(value: settings),
            ],
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(actions: [
                  AdventTicketBadge(celebrationId: celebrationId),
                ]),
              ),
            ));

    double scale() => tester
        .widget<Transform>(find.descendant(
          of: find.byKey(const ValueKey('ticket-sparkle')),
          matching: find.byType(Transform),
        ))
        .transform
        .entry(0, 0);

    await tester.pumpWidget(badge(0));
    await tester.pumpAndSettle();
    expect(scale(), 1);
    await state.openDay(1);
    await tester.pumpWidget(badge(1));
    await tester.pump(const Duration(milliseconds: 400));
    expect(scale(), greaterThan(1));
    expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('advent-ticket-balance')))
            .data,
        '1');
    await tester.pumpAndSettle();
    expect(scale(), 1);
    // Ordinary rebuilds and revisiting an opened day do not replay the effect.
    await state.openDay(1);
    await tester.pumpWidget(badge(1));
    await tester.pump(const Duration(milliseconds: 400));
    expect(scale(), 1);
    await state.openDay(2);
    await tester.pumpWidget(badge(2));
    await tester.pump(const Duration(milliseconds: 400));
    expect(scale(), greaterThan(1));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    state.dispose();
    settings.dispose();
  });

  testWidgets(
      'zero balance blocks gacha; earned credit enables tear and spends on completion',
      (tester) async {
    SharedPreferences.setMockInitialValues({'advent_calendar': true});
    final state =
        AdventProvider(year: 2026, clock: () => DateTime(2026, 12, 25));
    await state.ready;
    final settings = AppSettingsProvider();
    final ordinary = TicketProvider();
    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider.value(value: state),
      ChangeNotifierProvider.value(value: settings),
      ChangeNotifierProvider.value(value: ordinary),
    ], child: const MaterialApp(home: GachaPage())));
    await tester.pumpAndSettle();
    expect(find.image(const AssetImage('assets/images/advent/ticket.png')),
        findsOneWidget);
    final balance = find.byKey(const ValueKey('advent-ticket-balance'));
    expect(tester.widget<Text>(balance).data, '0');
    final card = find.byType(GestureDetector).first;
    await tester.tap(card);
    await tester.pumpAndSettle();
    expect(find.byType(TicketTearDialog), findsNothing);
    expect(find.text('티켓이 부족합니다. 하루만 기다려 주세요.'), findsOneWidget);
    ScaffoldMessenger.of(tester.element(find.byType(GachaPage)))
        .removeCurrentSnackBar();
    await tester.pumpAndSettle();
    await state.openDay(1);
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(balance).data, '1');
    // Let the asset decode so the dialog can use its intrinsic dimensions.
    await tester.runAsync(() => precacheImage(
        AssetImage(state.tickets.first.imagePathTicket),
        tester.element(find.byType(GachaPage))));
    await tester.pumpAndSettle();
    await tester.tap(card);
    await tester.pumpAndSettle();
    expect(find.byType(TicketTearDialog), findsOneWidget);
    expect(state.ticketBalance, 1);
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect(state.ticketBalance, 1);
    expect(find.byType(TicketTearDialog), findsNothing);
    await tester.tap(card);
    await tester.pumpAndSettle();
    final drag = find
        .descendant(
            of: find.byType(TicketTearDialog),
            matching: find.byType(GestureDetector))
        .first;
    final rect = tester.getRect(drag);
    final gesture =
        await tester.startGesture(rect.centerLeft + const Offset(10, 0));
    await gesture.moveBy(const Offset(25, 0));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.moveBy(Offset(rect.width * 1.1, 0));
    await tester.pumpAndSettle();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(state.ticketBalance, 0);
    expect(find.text('결과 보기'), findsOneWidget);
    expect(ordinary.tickets.every((t) => !t.isOpened), true);
    await tester.pumpWidget(const SizedBox());
    state.dispose();
    settings.dispose();
    ordinary.dispose();
  });
}
