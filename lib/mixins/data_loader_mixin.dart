import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/api_service.dart';

/// Mixin to provide common data loading functionality for screens
/// Reduces boilerplate code for API initialization and state management
mixin DataLoaderMixin<T extends StatefulWidget> on State<T> {
  late ApiService _apiService;

  /// Initialize API service from SettingsProvider
  /// Call this once in initState() or when settings change
  void initializeApiService() {
    final baseUrl = context.read<SettingsProvider>().baseUrl;
    _apiService = ApiService(baseUrl);
  }

  /// Get the initialized API service
  ApiService get apiService => _apiService;

  /// Helper to load data and update state
  /// Provides consistent pattern across screens
  void loadData<TData>(
    Future<TData> Function() loader,
    void Function(TData data) onSuccess,
  ) async {
    try {
      final data = await loader();
      if (mounted) {
        onSuccess(data);
      }
    } catch (e) {
      if (mounted) {
        _handleError(e);
      }
    }
  }

  /// Override this to handle errors in your screen
  void _handleError(dynamic error) {
    // Default: do nothing. Override in your State class.
  }
}
