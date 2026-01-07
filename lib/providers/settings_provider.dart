import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _baseUrlKey = 'base_url';
  static const String _localeKey = 'locale';
  static const String _defaultBaseUrl = 'http://localhost:3000';

  String _baseUrl = _defaultBaseUrl;
  Locale _locale = const Locale('id', 'ID');

  String get baseUrl => _baseUrl;
  Locale get locale => _locale;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _baseUrl = prefs.getString(_baseUrlKey) ?? _defaultBaseUrl;
      
      final localeCode = prefs.getString(_localeKey) ?? 'id';
      _locale = Locale(localeCode, localeCode == 'id' ? 'ID' : 'US');
      
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load settings: $e');
    }
  }

  Future<void> setBaseUrl(String url) async {
    try {
      // Remove trailing slash if present
      final cleanUrl = url.endsWith('/')
          ? url.substring(0, url.length - 1)
          : url;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_baseUrlKey, cleanUrl);
      _baseUrl = cleanUrl;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to save base URL: $e');
      rethrow;
    }
  }

  Future<void> resetToDefault() async {
    await setBaseUrl(_defaultBaseUrl);
  }

  Future<void> setLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
      _locale = locale;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to save locale: $e');
      rethrow;
    }
  }
}
