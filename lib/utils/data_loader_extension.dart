import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/api_service.dart';

/// Extension to provide common data loading patterns
/// Deprecated: Use StateExtensions from state_extension.dart instead
/// This is kept for backward compatibility
extension DataLoaderExtension on State {
  /// Get API service initialized with current settings
  /// Use: final apiService = getApiService();
  /// Prefer using StateExtension.getApiService() for consistency
  ApiService getApiService() {
    final baseUrl = context.read<SettingsProvider>().baseUrl;
    return ApiService(baseUrl);
  }

  /// Load data with consistent error handling
  /// Use: loadData(() => apiService.getProducts(), (data) => setState(...))
  /// Prefer using StateExtension.ifMounted() for new code
  Future<T?> loadData<T>(Future<T> Function() loader) async {
    try {
      return await loader();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.tr(context, 'error')}: $e')),
        );
      }
      return null;
    }
  }
}
