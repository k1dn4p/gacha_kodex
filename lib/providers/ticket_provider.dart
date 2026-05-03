import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ticket.dart';

class TicketProvider with ChangeNotifier {
  static const _ticketsStorageKey = 'tickets';
  static const _settingsStorageKey = 'ticket_settings';
  static const allPrizeLevels = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
  ];
  static const minPrizeLevelCount = 3;
  static const maxPrizeLevelCount = 26;
  static const _defaultPrizeLevels = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
  static const _defaultPrizeCounts = {
    'A': 1,
    'B': 1,
    'C': 1,
    'D': 1,
    'E': 1,
    'F': 1,
    'G': 1,
    'H': 1,
  };

  List<Ticket> _tickets = [];
  Ticket? _selectedTicket;
  List<String> _prizeLevels = List.from(_defaultPrizeLevels);
  Map<String, int> _prizeCounts = Map.from(_defaultPrizeCounts);
  int _ticketPrice = 0;

  List<Ticket> get tickets => _tickets;
  Ticket? get selectedTicket => _selectedTicket;
  List<String> get prizeLevels => List.unmodifiable(_prizeLevels);
  Map<String, int> get prizeCounts => Map.unmodifiable(_prizeCounts);
  int get ticketPrice => _ticketPrice;
  int get totalTicketCount =>
      _prizeCounts.values.fold(0, (total, count) => total + count);

  TicketProvider() {
    _loadData();
  }

  void _initializeTickets() {
    final List<String> ticketPrizeLevels = [];

    for (final level in _prizeLevels) {
      final count = _prizeCounts[level] ?? 0;
      ticketPrizeLevels.addAll(List.filled(count, level));
    }
    ticketPrizeLevels.shuffle();

    _tickets = List.generate(
      ticketPrizeLevels.length,
      (index) => Ticket(
        themeName: 'Cherry',
        id: index + 1,
        prizeLevel: ticketPrizeLevels[index],
      ),
    );
  }

  Future<void> _loadData() async {
    await _loadSettings();
    await _loadTickets();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSettings = prefs.getString(_settingsStorageKey);

    if (savedSettings == null) {
      await _saveSettings();
      return;
    }

    final decodedSettings = jsonDecode(savedSettings) as Map<String, dynamic>;
    final savedPrizeLevels =
        (decodedSettings['prizeLevels'] as List<dynamic>?)
            ?.map((level) => level.toString())
            .where((level) => allPrizeLevels.contains(level))
            .toList();
    final savedPrizeCounts =
        decodedSettings['prizeCounts'] as Map<String, dynamic>? ?? {};

    if (savedPrizeLevels != null &&
        savedPrizeLevels.length >= minPrizeLevelCount) {
      _prizeLevels = savedPrizeLevels.take(maxPrizeLevelCount).toList();
    }
    _prizeCounts = {
      for (final level in _prizeLevels)
        level: (savedPrizeCounts[level] as num?)?.toInt() ??
            _defaultPrizeCounts[level] ??
            0,
    };
    _ticketPrice = (decodedSettings['ticketPrice'] as num?)?.toInt() ?? 0;
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

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedSettings = jsonEncode({
      'prizeLevels': _prizeLevels,
      'prizeCounts': _prizeCounts,
      'ticketPrice': _ticketPrice,
    });
    await prefs.setString(_settingsStorageKey, encodedSettings);
  }

  Future<void> _saveTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedTickets =
        jsonEncode(_tickets.map((ticket) => ticket.toJson()).toList());
    await prefs.setString(_ticketsStorageKey, encodedTickets);
  }

  Future<void> updateSettings({
    required List<String> prizeLevels,
    required Map<String, int> prizeCounts,
    required int ticketPrice,
  }) async {
    _prizeLevels = prizeLevels
        .where((level) => allPrizeLevels.contains(level))
        .take(maxPrizeLevelCount)
        .toList();
    _prizeCounts = {
      for (final level in _prizeLevels) level: prizeCounts[level] ?? 0,
    };
    _ticketPrice = ticketPrice;
    await _saveSettings();
    await initializeTickets();
  }

  Future<void> initializeTickets() async {
    _selectedTicket = null;
    _initializeTickets();
    await _saveTickets();
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
