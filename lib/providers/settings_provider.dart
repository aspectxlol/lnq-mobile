import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _baseUrlKey = 'base_url';
  static const String _defaultBaseUrl = 'http://localhost:3000';

  String _baseUrl = _defaultBaseUrl;

  String get baseUrl => _baseUrl;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _baseUrl = prefs.getString(_baseUrlKey) ?? _defaultBaseUrl;
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
}
