import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ticket.dart';

class TicketProvider with ChangeNotifier {
  static const _ticketsStorageKey = 'tickets';

  List<Ticket> _tickets = [];
  Ticket? _selectedTicket;

  List<Ticket> get tickets => _tickets;
  Ticket? get selectedTicket => _selectedTicket;

  TicketProvider() {
    _loadTickets();
  }

  void _initializeTickets() {
    final prizeCounts = {
      'A': 1,
      'B': 1,
      'C': 1,
      'D': 1,
      'E': 6,
      'F': 8,
      'G': 12
    };
    final List<String> prizeLevels = [];

    prizeCounts.forEach((level, count) {
      prizeLevels.addAll(List.filled(count, level));
    });
    prizeLevels.shuffle();

    _tickets = List.generate(
      prizeLevels.length,
      (index) => Ticket(
        id: index + 1,
        prizeLevel: prizeLevels[index],
      ),
    );
  }

  Future<void> _loadTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTickets = prefs.getString(_ticketsStorageKey);

    if (savedTickets == null) {
      _initializeTickets();
      await _saveTickets();
      notifyListeners();
      return;
    }

    final decodedTickets = jsonDecode(savedTickets) as List<dynamic>;
    _tickets = decodedTickets
        .map((ticketJson) => Ticket.fromJson(ticketJson as Map<String, dynamic>))
        .toList();
    notifyListeners();
  }

  Future<void> _saveTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedTickets =
        jsonEncode(_tickets.map((ticket) => ticket.toJson()).toList());
    await prefs.setString(_ticketsStorageKey, encodedTickets);
  }

  void initializeTickets() {
    _selectedTicket = null;
    _initializeTickets();
    _saveTickets();
    notifyListeners();
  }

  void selectTicket(Ticket ticket) {
    if (!ticket.isOpened) {
      ticket.isOpened = true;
      _selectedTicket = ticket;
      _saveTickets();
      notifyListeners();
    }
  }

  void resetSelection() {
    _selectedTicket = null;
    notifyListeners();
  }
}
