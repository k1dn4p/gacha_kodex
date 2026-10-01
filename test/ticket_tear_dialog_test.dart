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
