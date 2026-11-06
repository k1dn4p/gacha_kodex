import '../providers/advent_provider.dart';
import '../providers/app_settings_provider.dart';
import '../widgets/gacha_image.dart';
import '../widgets/advent_ticket_badge.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ticket.dart';
import '../providers/ticket_provider.dart';
import '../widgets/app_bottom_nav.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: const [AdventTicketBadge()],
        title: const Text('쿠지 현황판'),
        centerTitle: true,
      ),
      body: Consumer<TicketProvider>(
        builder: (context, ticketProvider, child) {
          final isAdvent = context.watch<AppSettingsProvider>().adventCalendar;
          final allTickets = isAdvent
              ? context.watch<AdventProvider>().tickets
              : ticketProvider.tickets;
          final levels = isAdvent
              ? (allTickets.map((t) => t.prizeLevel).toSet().toList()..sort())
              : ticketProvider.prizeLevels;
          final groupedTickets = <String, List<Ticket>>{};

          for (final level in levels) {
            groupedTickets[level] = allTickets
                .where((ticket) => ticket.prizeLevel == level)
                .toList();
          }

          final remainingCount =
              allTickets.where((ticket) => !ticket.isOpened).length;

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
                    '${isAdvent ? '남은 뽑기 카드' : '남은 티켓'} : $remainingCount / ${allTickets.length}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ...levels.map((level) {
                  final tickets = groupedTickets[level] ?? [];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: _StatusRow(
                      prizeLevel: level,
                      tickets: tickets,
                      prizeNames: isAdvent
                          ? const <String, String>{}
                          : ticketProvider.currentPrizeNames,
                      themeName: isAdvent ? 'advent' : ticketProvider.themeName,
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.prizeLevel,
    required this.tickets,
    required this.prizeNames,
    required this.themeName,
  });

  final String prizeLevel;
  final List<Ticket> tickets;
  final Map<String, String> prizeNames;
  final String themeName;

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
      constraints: BoxConstraints(
        minHeight: (MediaQuery.sizeOf(context).width * 0.22)
            .clamp(180.0, 220.0)
            .toDouble(),
      ),
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
                      _prizeImagePath(prizeLevel),
                      errorBuilder: missingGachaImage,
                      height: 88,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      prizeNames[prizeLevel] ?? '$prizeLevel Prize',
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

  String _prizeImagePath(String prizeLevel) {
    return switch (prizeLevel) {
      'A' => 'assets/images/$themeName/prize_A.png',
      'B' => 'assets/images/$themeName/prize_B.png',
      'C' => 'assets/images/$themeName/prize_C.png',
      'D' => 'assets/images/$themeName/prize_D.png',
      'E' => 'assets/images/$themeName/prize_E.png',
      'F' => 'assets/images/$themeName/prize_F.png',
      'G' => 'assets/images/$themeName/prize_G.png',
      'H' => 'assets/images/$themeName/prize_H.png',
      'I' => 'assets/images/$themeName/prize_I.png',
      'J' => 'assets/images/$themeName/prize_J.png',
      'K' => 'assets/images/$themeName/prize_K.png',
      _ => 'assets/images/$themeName/prize_H.png',
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
    final sortedTickets = [...tickets]..sort((a, b) {
        if (a.isOpened == b.isOpened) {
          return a.id.compareTo(b.id);
        }
        return a.isOpened ? -1 : 1;
      });

    return LayoutBuilder(
      builder: (context, constraints) {
        const ticketsPerRow = 5;
        final cardWidth =
            (constraints.maxWidth * 0.32).clamp(140.0, 190.0).toDouble();
        final cardHeight = cardWidth * 0.4;
        final horizontalStep = cardWidth * 0.6; //
        //(constraints.maxWidth - cardWidth) / (ticketsPerRow - 1);
        final verticalStep = cardHeight * 1.1;
        final rowCount = (tickets.length / ticketsPerRow).ceil();
        final totalHeight = (rowCount - 1) * verticalStep + cardHeight;

        return SizedBox(
          width: constraints.maxWidth,
          height: totalHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (var index = sortedTickets.length - 1; index >= 0; index--)
                Positioned(
                  left: (index % ticketsPerRow) * horizontalStep,
                  top: (index ~/ ticketsPerRow) * verticalStep,
                  child: _TicketCard(
                    ticket: sortedTickets[index],
                    width: cardWidth,
                    height: cardHeight,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    required this.ticket,
    required this.width,
    required this.height,
  });

  final Ticket ticket;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
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
          errorBuilder: missingGachaImage,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
