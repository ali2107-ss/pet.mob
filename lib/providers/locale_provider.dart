import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('ru');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadSavedLocale();
  }

  void _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('language_code')) {
        final languageCode = prefs.getString('language_code');
        if (languageCode != null) {
          _locale = Locale(languageCode);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading locale: $e');
    }
  }

  void setLocale(Locale loc) async {
    if (_locale == loc) return;
    _locale = loc;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', loc.languageCode);
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }
  }
}
