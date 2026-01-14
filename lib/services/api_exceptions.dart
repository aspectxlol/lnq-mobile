/// Custom exception class for API errors
/// Provides better error categorization and handling throughout the app
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ApiException(
    this.message, {
    this.statusCode,
    this.originalError,
  });

  /// Create ApiException from HTTP status code
  factory ApiException.fromStatusCode(int statusCode, String message) {
    return ApiException(
      message,
      statusCode: statusCode,
    );
  }

  /// Create ApiException for network errors
  factory ApiException.networkError(String message) {
    return ApiException('Network error: $message');
  }

  /// Create ApiException for timeout errors
  factory ApiException.timeout() {
    return ApiException(
      'Request timeout. Please check your connection.',
      statusCode: 408,
    );
  }

  @override
  String toString() => message;

  /// Get user-friendly error message
  String get userMessage {
    if (statusCode == 404) return 'Resource not found';
    if (statusCode == 401) return 'Unauthorized. Please check your credentials';
    if (statusCode == 500) return 'Server error. Please try again later';
    if (statusCode == 503) return 'Service unavailable. Please try again later';
    return message;
  }
}
