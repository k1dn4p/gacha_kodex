import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ticket.dart';
import '../providers/ticket_provider.dart';
import '../widgets/app_bottom_nav.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({Key? key}) : super(key: key);

  static const _prizeOrder = ['A', 'B', 'C', 'D', 'E', 'F', 'G'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Status'),
        centerTitle: true,
      ),
      body: Consumer<TicketProvider>(
        builder: (context, ticketProvider, child) {
          final groupedTickets = <String, List<Ticket>>{};

          for (final level in _prizeOrder) {
            groupedTickets[level] = ticketProvider.tickets
                .where((ticket) => ticket.prizeLevel == level)
                .toList();
          }

          final remainingCount = ticketProvider.tickets
              .where((ticket) => !ticket.isOpened)
              .length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Remaining tickets: $remainingCount / ${ticketProvider.tickets.length}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ..._prizeOrder.map((level) {
                  final tickets = groupedTickets[level] ?? [];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: _StatusRow(
                      prizeLevel: level,
                      tickets: tickets,
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.prizeLevel,
    required this.tickets,
  });

  final String prizeLevel;
  final List<Ticket> tickets;

  @override
  Widget build(BuildContext context) {
    final openedCount = tickets.where((ticket) => ticket.isOpened).length;
    final remainingCount = tickets.length - openedCount;
    final totalCount = tickets.length;
    final sortedTickets = [...tickets]..sort((a, b) {
      if (a.isOpened == b.isOpened) {
        return a.id.compareTo(b.id);
      }
      return a.isOpened ? -1 : 1;
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final imageWidth = constraints.maxWidth * 0.4;
          final ticketsWidth = constraints.maxWidth - imageWidth;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: imageWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      _prizeimagePathTicket(prizeLevel),
                      height: 88,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$prizeLevel Prize',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$remainingCount left / $totalCount Total',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: ticketsWidth,
                child: Center(
                  child: _TicketGrid(
                    tickets: sortedTickets,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _prizeimagePathTicket(String prizeLevel) {
    return switch (prizeLevel) {
      'A' => 'assets/images/prize_A.png',
      'B' => 'assets/images/prize_B.png',
      'C' => 'assets/images/prize_C.png',
      'D' => 'assets/images/prize_D.png',
      'E' => 'assets/images/prize_E.png',
      'F' => 'assets/images/prize_F.png',
      'G' => 'assets/images/prize_G.png',
      _ => 'assets/images/prize.png',
    };
  }
}

class _TicketGrid extends StatelessWidget {
  const _TicketGrid({
    required this.tickets,
  });

  final List<Ticket> tickets;

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) {
      return const SizedBox.shrink();
    }

    const ticketsPerRow = 5;
    const cardWidth = 42.0;
    const cardHeight = 52.0;
    const horizontalStep = 25.0;
    const verticalStep = 36.0;

    final rowCount = (tickets.length / ticketsPerRow).ceil();
    final totalHeight = (rowCount - 1) * verticalStep + cardHeight;
    final sortedTickets = [...tickets]..sort((a, b) {
      if (a.isOpened == b.isOpened) {
        return a.id.compareTo(b.id);
      }
      return a.isOpened ? -1 : 1;
    });

    return SizedBox(
      width: cardWidth + (ticketsPerRow - 1) * horizontalStep,
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var index= sortedTickets.length - 1; index >= 0; index--)
            Positioned(
              left: (index % ticketsPerRow ) * horizontalStep,
              top: (index ~/ ticketsPerRow) * verticalStep,
              child: _TicketCard(ticket: sortedTickets[index]),
            ),

        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    required this.ticket,
  });

  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(1),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          ticket.imagePathTicket,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
