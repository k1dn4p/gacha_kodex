import 'dart:convert';
import '../models/ticket.dart';
import '../constants/theme_config.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../advent/village_config.dart';

enum OpenDayResult { opened, alreadyOpened, locked, busy, unavailable }

class AdventProvider extends ChangeNotifier {
  final int seasonYear;
  final List<AdventDay> days;
  final DateTime Function() _clock;
  late final Future<void> ready;
  Set<int> _openedDays = {};
  List<Ticket> _tickets = [];
  Ticket? selectedTicket;
  String get progressKey => 'advent_progress_v2_$seasonYear';
  List<Ticket> get tickets => List.unmodifiable(_tickets);
  int get ticketBalance =>
      (_openedDays.length - _tickets.where((t) => t.isOpened).length)
          .clamp(0, 25);
  bool get canDraw =>
      !_loading && !_saving && _error == null && ticketBalance > 0;

  List<Ticket> _newTickets() {
    final levels = <String>[];
    for (final entry in defaultPrizeCounts[defaultThemeName]!.entries) {
      levels.addAll(List.filled(entry.value, entry.key));
    }
    levels.shuffle();
    return List.generate(levels.length,
        (i) => Ticket(id: i + 1, prizeLevel: levels[i], themeName: 'advent'));
  }

  Future<bool> selectTicket(Ticket ticket) async {
    if (!canDraw || ticket.isOpened || !_tickets.contains(ticket)) return false;
    _saving = true;
    _notify();
    try {
      final next = [
        for (final t in _tickets)
          Ticket(
              id: t.id,
              prizeLevel: t.prizeLevel,
              themeName: 'advent',
              isOpened: t.isOpened || t.id == ticket.id)
      ];
      await _save(_openedDays, tickets: next);
      _tickets = next;
      selectedTicket = next.firstWhere((t) => t.id == ticket.id);
      return true;
    } finally {
      _saving = false;
      _notify();
    }
  }

  bool _loading = true;
  bool _saving = false;
  bool _disposed = false;
  String? _error;

  // Development controls are session-only, never persisted as player state.
  DateTime? _testNow;
  bool _ignoreLocks = false;
  bool _showHotspots = false;
  int _resetVersion = 0;

  AdventProvider({int? year, DateTime Function()? clock, List<AdventDay>? days})
      : seasonYear = year ?? DateTime.now().year,
        days =
            List.unmodifiable(days ?? villageDays(year ?? DateTime.now().year)),
        _clock = clock ?? DateTime.now {
    ready = load();
  }

  String get storageKey => 'advent_opened_days_v1_$seasonYear';
  Set<int> get openedDays => Set.unmodifiable(_openedDays);
  bool get isLoading => _loading;
  bool get isSaving => _saving;
  String? get error => _error;
  int get resetVersion => _resetVersion;
  DateTime get effectiveNow => kDebugMode ? _testNow ?? _clock() : _clock();
  DateTime? get testNow => kDebugMode ? _testNow : null;
  bool get ignoreLocks => kDebugMode && _ignoreLocks;
  bool get showHotspots => kDebugMode && _showHotspots;

  AdventDay? day(int id) {
    for (final entry in days) {
      if (entry.dayId == id) return entry;
    }
    return null;
  }

  AdventDayState? stateFor(int id) {
    final config = day(id);
    return config == null
        ? null
        : AdventDayState(config, isOpened: _openedDays.contains(id));
  }

  bool canOpen(int id) {
    final config = day(id);
    return config != null &&
        (_openedDays.contains(id) ||
            ignoreLocks ||
            !effectiveNow.isBefore(config.unlockAt));
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(progressKey);
      final data =
          saved == null ? null : jsonDecode(saved) as Map<String, dynamic>;
      _tickets = data == null
          ? _newTickets()
          : (data['tickets'] as List)
              .map((t) => Ticket.fromJson(Map<String, dynamic>.from(t as Map)))
              .toList();
      _openedDays = (data == null
              ? (prefs.getStringList(storageKey) ?? [])
              : (data['opened'] as List).cast<String>())
          .map(int.tryParse)
          .whereType<int>()
          .where((id) => id >= 1 && id <= 25)
          .toSet();
    } catch (_) {
      _error = '개봉 기록을 불러오지 못했어요. 다시 시도해 주세요.';
    } finally {
      _loading = false;
      _notify();
    }
  }

  Future<OpenDayResult> openDay(int id) async {
    if (_loading || _saving || _error != null) return OpenDayResult.busy;
    if (day(id) == null) return OpenDayResult.unavailable;
    if (_openedDays.contains(id)) return OpenDayResult.alreadyOpened;
    if (!canOpen(id)) return OpenDayResult.locked;
    _saving = true;
    _notify();
    try {
      final next = {..._openedDays, id};
      await _save(next);
      _openedDays = next;
      return OpenDayResult.opened;
    } finally {
      _saving = false;
      _notify();
    }
  }

  Future<void> _save(Set<int> opened, {List<Ticket>? tickets}) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = opened.toList()..sort();
    if (!await prefs.setString(
        progressKey,
        jsonEncode({
          'opened': ids.map((id) => '$id').toList(),
          'tickets': (tickets ?? _tickets).map((t) => t.toJson()).toList(),
        }))) {
      throw StateError('Could not save advent progress');
    }
  }

  void setTestNow(DateTime? value) {
    if (!kDebugMode) return;
    _testNow = value;
    _notify();
  }

  void setIgnoreLocks(bool value) {
    if (!kDebugMode) return;
    _ignoreLocks = value;
    _notify();
  }

  void setShowHotspots(bool value) {
    if (!kDebugMode) return;
    _showHotspots = value;
    _notify();
  }

  Future<void> resetOpenedDays() async {
    if (!kDebugMode || _loading || _saving || _error != null) return;
    _saving = true;
    _notify();
    try {
      final fresh = _newTickets();
      await _save({}, tickets: fresh);
      _tickets = fresh;
      selectedTicket = null;
      _openedDays = {};
      _resetVersion++;
    } finally {
      _saving = false;
      _notify();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
