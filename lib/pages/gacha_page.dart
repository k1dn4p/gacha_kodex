import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ticket_provider.dart';
import '../widgets/app_bottom_nav.dart';

class GachaPage extends StatelessWidget {
  const GachaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Your Ticket'),
        centerTitle: true,
      ),
      body: Consumer<TicketProvider>(
        builder: (context, ticketProvider, child) {
          final unopenedTickets = ticketProvider.tickets
              .where((ticket) => !ticket.isOpened)
              .toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    '가챠를 열어보세요!',
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
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
                            ? () {
                                ticketProvider.selectTicket(ticket);
                                Navigator.pushNamed(context, '/result');
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
                                width: 40,
                                height: 20,
                              )
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      ticketProvider.initializeTickets();
                    },
                    child: const Text('Reset Tickets'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                    },
                    child: const Text('Return to Main'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),

    );
  }
}
