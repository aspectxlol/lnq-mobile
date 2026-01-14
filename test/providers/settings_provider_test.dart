import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lnq/providers/settings_provider.dart';
import 'package:lnq/constants/app_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsProvider Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('SettingsProvider initializes with default values', () async {
      final provider = SettingsProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(provider.baseUrl, AppConstants.defaultBaseUrl);
      expect(provider.locale.languageCode, AppConstants.defaultLocale);
    });

    test('SettingsProvider saves and restores base URL', () async {
      final provider = SettingsProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      const newUrl = 'http://example.com:8080';
      await provider.setBaseUrl(newUrl);

      expect(provider.baseUrl, newUrl);

      // Verify it persists by creating a new instance
      final provider2 = SettingsProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      expect(provider2.baseUrl, newUrl);
    });

    test('SettingsProvider removes trailing slash from URL', () async {
      final provider = SettingsProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      const urlWithSlash = 'http://example.com/';
      const urlWithoutSlash = 'http://example.com';

      await provider.setBaseUrl(urlWithSlash);
      expect(provider.baseUrl, urlWithoutSlash);
    });

    test('SettingsProvider resets to default', () async {
      final provider = SettingsProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      const newUrl = 'http://example.com';
      await provider.setBaseUrl(newUrl);
      expect(provider.baseUrl, newUrl);

      await provider.resetToDefault();
      expect(provider.baseUrl, AppConstants.defaultBaseUrl);
    });

    test('SettingsProvider changes locale', () async {
      final provider = SettingsProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      final englishLocale = Locale('en', 'US');
      await provider.setLocale(englishLocale);

      expect(provider.locale.languageCode, 'en');

      // Verify persistence
      final provider2 = SettingsProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      expect(provider2.locale.languageCode, 'en');
    });
  });
}
