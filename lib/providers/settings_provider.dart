import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class SettingsProvider with ChangeNotifier {
  String _baseUrl = AppConstants.defaultBaseUrl;
  Locale _locale = Locale(
    AppConstants.defaultLocale,
    AppConstants.defaultLocaleCountry,
  );

  String get baseUrl => _baseUrl;
  Locale get locale => _locale;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _baseUrl = prefs.getString(AppConstants.storageBaseUrlKey) ??
          AppConstants.defaultBaseUrl;

      final localeCode =
          prefs.getString(AppConstants.storageLocaleKey) ?? AppConstants.defaultLocale;
      _locale = Locale(
        localeCode,
        localeCode == AppConstants.defaultLocale
            ? AppConstants.defaultLocaleCountry
            : AppConstants.englishLocaleCountry,
      );

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
      await prefs.setString(AppConstants.storageBaseUrlKey, cleanUrl);
      _baseUrl = cleanUrl;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to save base URL: $e');
      rethrow;
    }
  }

  Future<void> resetToDefault() async {
    await setBaseUrl(AppConstants.defaultBaseUrl);
  }

  Future<void> setLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.storageLocaleKey,
        locale.languageCode,
      );
      _locale = locale;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to save locale: $e');
      rethrow;
    }
  }
}
