import 'package:flutter/material.dart';
import '../providers/settings_provider.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';

/// Extension methods for State to reduce boilerplate
extension StateExtensions<T extends StatefulWidget> on State<T> {
  /// Execute callback only if widget is still mounted
  /// Prevents "setState called after dispose" warnings
  void ifMounted(VoidCallback callback) {
    if (mounted) {
      callback();
    }
  }

  /// Execute async callback only if widget is still mounted
  Future<void> ifMountedAsync(Future<void> Function() callback) async {
    if (mounted) {
      await callback();
    }
  }

  /// Get API service initialized with current settings
  ApiService getApiService() {
    final baseUrl = context.read<SettingsProvider>().baseUrl;
    return ApiService(baseUrl);
  }

  /// Watch settings provider
  SettingsProvider watchSettings() {
    return context.watch<SettingsProvider>();
  }

  /// Read settings provider
  SettingsProvider readSettings() {
    return context.read<SettingsProvider>();
  }
}
