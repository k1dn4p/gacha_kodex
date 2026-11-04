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
      _openedDays = (prefs.getStringList(storageKey) ?? [])
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

  Future<void> _save(Set<int> opened) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = opened.toList()..sort();
    if (!await prefs.setStringList(
        storageKey, ids.map((id) => '$id').toList())) {
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
      await _save({});
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
