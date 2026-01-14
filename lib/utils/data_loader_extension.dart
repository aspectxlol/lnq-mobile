import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/api_service.dart';

/// Extension to provide common data loading patterns
extension DataLoaderExtension on State {
  /// Get API service initialized with current settings
  /// Usage: final apiService = getApiService();
  ApiService getApiService() {
    final baseUrl = context.read<SettingsProvider>().baseUrl;
    return ApiService(baseUrl);
  }

  /// Load data with consistent error handling
  /// Usage: loadData(() => apiService.getProducts(), (data) => setState(...))
  Future<T?> loadData<T>(Future<T> Function() loader) async {
    try {
      return await loader();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
      return null;
    }
  }
}
