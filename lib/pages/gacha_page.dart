import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ticket_provider.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/ticket_tear_dialog.dart';

class GachaPage extends StatelessWidget {
  const GachaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('티켓을 골라주세요!'),
        centerTitle: true,
      ),
      body: Consumer<TicketProvider>(
        builder: (context, ticketProvider, child) {
          final unopenedTickets = ticketProvider.tickets
              .where((ticket) => !ticket.isOpened)
              .toList();
          final openedCount = ticketProvider.tickets.length - unopenedTickets.length;
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
                      '남은 티켓 수 : ${unopenedTickets.length} / ${ticketProvider.tickets.length}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '소비 금액: $spentAmount',
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
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 240,
                            mainAxisSpacing: 1,
                            crossAxisSpacing: 20,
                            childAspectRatio: 1.6,
                          ),
                          itemCount: ticketProvider.tickets.length,
                          itemBuilder: (context, index) {
                            final ticket = ticketProvider.tickets[index];
                            final isUnopened = !ticket.isOpened;

                            return GestureDetector(
                              onTap: isUnopened
                                  ? () async {
                                      final unopenedImagePath =
                                          ticket.imagePathTicket;
                                      ticketProvider.selectTicket(ticket);
                                      final shouldShowResult =
                                          await TicketTearDialog.show(
                                        context,
                                        unopenedImagePath: unopenedImagePath,
                                        openedImagePath: ticket.imagePathTicket,
                                      );

                                      if (shouldShowResult && context.mounted) {
                                        Navigator.pushNamed(context, '/result');
                                      }
                                    }
                                  : null,
                              child: Container(
                                  child: 
                                    // Text(
                                    //   isUnopened ? '🎟️' : '✅',
                                    //   style: const TextStyle(fontSize: 40),
                                    // ),
                                    Image.asset(
                                      ticket.imagePathTicket,
                                      width: 80,
                                      height: 40,
                                    )
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
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),

    );
  }
}
