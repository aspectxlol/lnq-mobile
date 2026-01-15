import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../services/backend_discovery_service.dart';

class SettingsProvider with ChangeNotifier {
  String _baseUrl = AppConstants.defaultBaseUrl;
  Locale _locale = Locale(
    AppConstants.defaultLocale,
    AppConstants.defaultLocaleCountry,
  );
  bool _isDiscoveringBackend = false;
  bool _isInitialized = false;

  String get baseUrl => _baseUrl;
  Locale get locale => _locale;
  bool get isDiscoveringBackend => _isDiscoveringBackend;
  bool get isInitialized => _isInitialized;

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

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load settings: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Wait for settings to be loaded from SharedPreferences
  /// This ensures the saved backend URL is available
  Future<void> ensureInitialized() async {
    if (_isInitialized) return;
    
    // Wait for initialization with timeout
    int attempts = 0;
    while (!_isInitialized && attempts < 50) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
  }

  /// Attempt to discover and connect to a backend server
  /// First tries to verify the current backend URL
  /// If that fails, scans the local network for a working backend
  Future<bool> attemptBackendDiscovery() async {
    try {
      // Ensure settings are loaded before attempting discovery
      await ensureInitialized();

      _isDiscoveringBackend = true;
      notifyListeners();

      // First, try to verify the current backend
      if (await BackendDiscoveryService.verifyBackend(_baseUrl)) {
        debugPrint('Current backend at $_baseUrl is still accessible');
        return true;
      }

      // If current backend is not accessible, discover a new one
      debugPrint('Current backend at $_baseUrl not accessible, discovering...');
      final discoveredUrl = await BackendDiscoveryService.discoverBackend();

      if (discoveredUrl != null && discoveredUrl != _baseUrl) {
        debugPrint('Discovered backend at $discoveredUrl');
        await setBaseUrl(discoveredUrl);
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Backend discovery failed: $e');
      return false;
    } finally {
      _isDiscoveringBackend = false;
      notifyListeners();
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
