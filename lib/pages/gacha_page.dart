import '../providers/advent_provider.dart';
import '../providers/app_settings_provider.dart';
import '../widgets/gacha_image.dart';
import '../widgets/advent_ticket_badge.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ticket_provider.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/ticket_tear_dialog.dart';

class GachaPage extends StatelessWidget {
  const GachaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isAdvent = context.watch<AppSettingsProvider>().adventCalendar;
    final advent = context.watch<AdventProvider>();
    return Scaffold(
      appBar: AppBar(
        actions: const [AdventTicketBadge()],
        title: const Text('티켓을 골라주세요!'),
        centerTitle: true,
      ),
      body: Consumer<TicketProvider>(
        builder: (context, ticketProvider, child) {
          final tickets = isAdvent ? advent.tickets : ticketProvider.tickets;
          final unopenedTickets =
              tickets.where((ticket) => !ticket.isOpened).toList();
          final openedCount = tickets.length - unopenedTickets.length;
          final spentAmount = openedCount * ticketProvider.ticketPrice;

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${isAdvent ? '남은 뽑기 카드' : '남은 티켓 수'} : ${unopenedTickets.length} / ${tickets.length}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isAdvent
                          ? '선물 개봉으로 Ticket을 받아 주세요. 가챠 1회에 1개 사용해요.'
                          : '소비 금액: $spentAmount',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 1,
                            crossAxisSpacing: 8,
                            childAspectRatio: 1.6,
                          ),
                          itemCount: tickets.length,
                          itemBuilder: (context, index) {
                            final ticket = tickets[index];
                            final isUnopened = !ticket.isOpened;

                            return GestureDetector(
                              onTap: isUnopened && (!isAdvent || advent.canDraw)
                                  ? () async {
                                      final unopenedImagePath =
                                          ticket.imagePathTicket;
                                      final shouldShowResult =
                                          await TicketTearDialog.show(
                                        context,
                                        unopenedImagePath: unopenedImagePath,
                                        openedImagePath:
                                            ticket.openedImagePathTicket,
                                        commitOpening: isAdvent
                                            ? () => advent.selectTicket(ticket)
                                            : null,
                                        onOpened: isAdvent
                                            ? null
                                            : () => ticketProvider
                                                .selectTicket(ticket),
                                      );

                                      if (shouldShowResult && context.mounted) {
                                        Navigator.pushNamed(context, '/result');
                                      }
                                    }
                                  : null,
                              child: Image.asset(
                                ticket.imagePathTicket,
                                errorBuilder: missingGachaImage,
                                width: 80,
                                height: 40,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}
