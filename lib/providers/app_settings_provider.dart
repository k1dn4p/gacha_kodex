import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsProvider extends ChangeNotifier {
  static const storageKey = 'advent_calendar';
  bool _adventCalendar = false;
  bool _isBusy = true;

  bool get adventCalendar => _adventCalendar;
  bool get isBusy => _isBusy;

  AppSettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _adventCalendar = prefs.getBool(storageKey) ?? false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> setAdventCalendar(bool enabled) async {
    if (_isBusy) return;
    _isBusy = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!await prefs.setBool(storageKey, enabled)) {
        throw StateError('Unable to save advent mode');
      }
      _adventCalendar = enabled;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }
}
