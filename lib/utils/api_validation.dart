import 'dart:convert';
import '../constants/app_constants.dart';

/// Validation utilities for API requests
class ApiValidation {
  /// Validate product name
  static String? validateProductName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Product name is required';
    }
    if (value.length > AppConstants.maxProductNameLength) {
      return 'Product name must not exceed ${AppConstants.maxProductNameLength} characters';
    }
    return null;
  }

  /// Validate product price
  static String? validateProductPrice(int? value) {
    if (value == null || value < AppConstants.minProductPrice) {
      return 'Price must be greater than or equal to ${AppConstants.minProductPrice}';
    }
    if (value > AppConstants.maxProductPrice) {
      return 'Price must not exceed ${AppConstants.maxProductPrice}';
    }
    return null;
  }

  /// Validate order amount
  static String? validateOrderAmount(int? value) {
    if (value == null || value < AppConstants.minOrderAmount) {
      return 'Amount must be at least ${AppConstants.minOrderAmount}';
    }
    if (value > AppConstants.maxOrderAmount) {
      return 'Amount must not exceed ${AppConstants.maxOrderAmount}';
    }
    return null;
  }

  /// Validate customer name
  static String? validateCustomerName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Customer name is required';
    }
    if (value.length > 200) {
      return 'Customer name must not exceed 200 characters';
    }
    return null;
  }

  /// Validate base URL format
  static String? validateBaseUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'URL is required';
    }
    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      return 'URL must start with http:// or https://';
    }
    try {
      Uri.parse(value);
      return null;
    } catch (e) {
      return 'Invalid URL format';
    }
  }

  /// Validate date format (YYYY-MM-DD)
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return 'Invalid date format. Use YYYY-MM-DD';
    }
  }

  /// Check if string is valid JSON
  static bool isValidJson(String? value) {
    if (value == null || value.isEmpty) return false;
    try {
      json.decode(value);
      return true;
    } catch (e) {
      return false;
    }
  }
}
