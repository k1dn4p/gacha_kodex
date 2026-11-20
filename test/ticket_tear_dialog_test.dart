import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gacha_codex/models/ticket.dart';
import 'package:gacha_codex/widgets/ticket_tear_dialog.dart';

void main() {
  late Ticket ticket;
  late int openedCount;

  setUp(() {
    ticket = Ticket(id: 1, prizeLevel: 'A', themeName: 'Cherry');
    openedCount = 0;
  });

  Future<void> showTicket(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        return TextButton(
          onPressed: () => TicketTearDialog.show(
            context,
            unopenedImagePath: ticket.imagePathTicket,
            openedImagePath: ticket.openedImagePathTicket,
            prizeLevel: ticket.prizeLevel,
            onOpened: () {
              ticket.isOpened = true;
              openedCount++;
            },
          ),
          child: const Text('Open'),
        );
      }),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  Finder getDragTarget() => find
      .descendant(
        of: find.byType(TicketTearDialog),
        matching: find.byType(GestureDetector),
      )
      .first;

  Future<TestGesture> moveTicket(WidgetTester tester, double fraction) async {
    final rect = tester.getRect(getDragTarget());
    final gesture =
        await tester.startGesture(rect.centerLeft + const Offset(10, 0));
    // First cross the drag recognizer's touch slop, then move the ticket.
    await gesture.moveBy(const Offset(25, 0));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.moveBy(Offset(rect.width * fraction, 0));
    await tester.pump(const Duration(milliseconds: 200));
    return gesture;
  }

  testWidgets('shake continues while held and stops when opened',
      (tester) async {
    await showTicket(tester);
    await tester.runAsync(() => precacheImage(
        AssetImage(ticket.imagePathTicket), tester.element(getDragTarget())));
    await tester.pumpAndSettle();
    final gesture = await moveTicket(tester, 0.5);
    final target = find.byKey(const ValueKey('tear-shake'));
    final first = tester.widget<Transform>(target).transform.clone();
    await tester.pump(const Duration(milliseconds: 37));
    final second = tester.widget<Transform>(target).transform;
    expect(second, isNot(first));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(
        tester.widget<Transform>(target).transform.getTranslation().length, 0);
    expect(openedCount, 1);
  });

  for (final level in ['A', 'B', 'C']) {
    testWidgets('$level reveal pauses and zooms only for top prizes',
        (tester) async {
      ticket = Ticket(id: 1, prizeLevel: level, themeName: 'Cherry');
      await showTicket(tester);
      await tester.runAsync(() => precacheImage(
          AssetImage(ticket.imagePathTicket), tester.element(getDragTarget())));
      await tester.pumpAndSettle();
      final rect = tester.getRect(getDragTarget());
      final gesture =
          await tester.startGesture(rect.centerLeft + const Offset(10, 0));
      await gesture.moveBy(const Offset(25, 0));
      await tester.pump();
      await gesture.moveBy(Offset(rect.width * 1.1, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final scale = tester
          .widget<Transform>(find.byKey(const ValueKey('tear-reveal-scale')))
          .transform
          .entry(0, 0);
      expect(openedCount, level == 'C' ? 1 : 0);
      expect(scale, level == 'C' ? 1.0 : greaterThan(1.0));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(openedCount, 1);
      expect(
          tester
              .widget<Transform>(
                  find.byKey(const ValueKey('tear-reveal-scale')))
              .transform
              .entry(0, 0),
          1.0);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('cancelling during the reveal hold prevents delayed opening',
      (tester) async {
    await showTicket(tester);
    await tester.runAsync(() => precacheImage(
        AssetImage(ticket.imagePathTicket), tester.element(getDragTarget())));
    await tester.pumpAndSettle();
    final rect = tester.getRect(getDragTarget());
    final gesture =
        await tester.startGesture(rect.centerLeft + const Offset(10, 0));
    await gesture.moveBy(const Offset(25, 0));
    await tester.pump();
    await gesture.moveBy(Offset(rect.width * 1.1, 0));
    await tester.pump();
    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(openedCount, 0);
    expect(ticket.isOpened, isFalse);
    final retry = await moveTicket(tester, 1.1);
    await retry.up();
    await tester.pumpAndSettle();
    expect(openedCount, 1);
    expect(tester.takeException(), isNull);
  });
  for (final theme in ['Cherry', 'advent']) {
    testWidgets('$theme uses the original image ratio throughout tearing',
        (tester) async {
      ticket = Ticket(id: 1, prizeLevel: 'A', themeName: theme);
      final unopenedPath = ticket.imagePathTicket;
      await showTicket(tester);
      await tester.runAsync(() => precacheImage(
          AssetImage(unopenedPath), tester.element(getDragTarget())));
      await tester.pumpAndSettle();

      final original = tester
          .widget<RawImage>(find.descendant(
            of: find.image(AssetImage(unopenedPath)),
            matching: find.byType(RawImage),
          ))
          .image!;
      final before = tester.getSize(getDragTarget());
      expect(before.width / before.height,
          closeTo(original.width / original.height, 0.0001));

      final gesture = await moveTicket(tester, 0.5);
      expect(tester.getSize(getDragTarget()), before);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(tester.getSize(getDragTarget()), before);
      expect(openedCount, 1);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('short drag rolls back and a retry opens exactly once',
      (tester) async {
    await showTicket(tester);
    expect(ticket.isOpened, isFalse);
    final shortDrag = await moveTicket(tester, 0.15);
    await shortDrag.up();
    await tester.pumpAndSettle();
    expect(find.text('쿠지를 뜯어주세요'), findsOneWidget);
    expect(find.text('결과 보기'), findsNothing);
    expect(openedCount, 0);
    expect(ticket.isOpened, isFalse);

    final fullDrag = await moveTicket(tester, 0.5);
    await fullDrag.up();
    await tester.pumpAndSettle();
    expect(find.text('쿠지가 열렸어요!'), findsOneWidget);
    expect(ticket.isOpened, isTrue);
    expect(openedCount, 1);
    // Only the stationary opened image remains visible after completion.
    expect(find.byType(Opacity), findsNothing);
    await tester.tap(find.text('결과 보기'));
    await tester.pumpAndSettle();
    expect(find.byType(TicketTearDialog), findsNothing);
    expect(openedCount, 1);
  });

  testWidgets('cancelled drag resets without consuming the ticket',
      (tester) async {
    await showTicket(tester);
    await tester.runAsync(() => precacheImage(
        AssetImage(ticket.imagePathTicket), tester.element(getDragTarget())));
    await tester.pumpAndSettle();
    final gesture = await moveTicket(tester, 0.5);
    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(find.text('쿠지를 뜯어주세요'), findsOneWidget);
    expect(find.text('결과 보기'), findsNothing);
    expect(ticket.isOpened, isFalse);
    expect(openedCount, 0);
  });

  testWidgets('dragging to the end completes without waiting for release',
      (tester) async {
    await showTicket(tester);
    final gesture = await moveTicket(tester, 1.1);
    await tester.pumpAndSettle();
    expect(ticket.isOpened, isTrue);
    expect(openedCount, 1);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(openedCount, 1);
  });
}
