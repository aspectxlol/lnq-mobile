import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../services/api_service.dart';

/// Handles errors and provides user-friendly messages
class ErrorHandler {
  /// Get a localized error message based on exception type
  static String getLocalizedMessage(
    BuildContext context,
    dynamic error,
  ) {
    if (error is ApiException) {
      return _handleApiException(context, error);
    } else if (error is FormatException) {
      return AppStrings.tr(context, 'invalidDataFormat');
    } else {
      return '${AppStrings.tr(context, 'error')}: ${error.toString()}';
    }
  }

  /// Handle API-specific exceptions
  static String _handleApiException(BuildContext context, ApiException error) {
    switch (error.statusCode) {
      case 400:
        return AppStrings.tr(context, 'badRequest');
      case 401:
        return AppStrings.tr(context, 'unauthorized');
      case 403:
        return AppStrings.tr(context, 'forbidden');
      case 404:
        return AppStrings.tr(context, 'notFound');
      case 500:
        return AppStrings.tr(context, 'serverError');
      case 503:
        return AppStrings.tr(context, 'serviceUnavailable');
      default:
        return error.message;
    }
  }

  /// Show error snackbar
  static void showError(BuildContext context, dynamic error) {
    final message = getLocalizedMessage(context, error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show success snackbar
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
