import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/advent_provider.dart';
import '../providers/app_settings_provider.dart';

class AdventTicketBadge extends StatelessWidget {
  const AdventTicketBadge({super.key});

  @override
  Widget build(BuildContext context) {
    if (!context.watch<AppSettingsProvider>().adventCalendar) {
      return const SizedBox.shrink();
    }
    final advent = context.watch<AdventProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Center(
          child: Text(
        'Ticket ${advent.isLoading ? '…' : advent.ticketBalance}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      )),
    );
  }
}
