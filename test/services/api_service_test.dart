import 'package:flutter_test/flutter_test.dart';
import 'package:lnq/services/api_service.dart';

void main() {
  group('ApiException Tests', () {
    test('ApiException creates with message and status code', () {
      const message = 'Test error';
      const statusCode = 404;

      final exception = ApiException(message, statusCode);

      expect(exception.message, message);
      expect(exception.statusCode, statusCode);
      expect(exception.toString(), message);
    });

    test('ApiException creates with message only', () {
      const message = 'Test error';

      final exception = ApiException(message);

      expect(exception.message, message);
      expect(exception.statusCode, null);
    });

    test('ApiException implements Exception', () {
      final exception = ApiException('test');

      expect(exception, isA<Exception>());
    });
  });

  group('ApiService Tests', () {
    test('ApiService initializes with base URL', () {
      const baseUrl = 'http://example.com';
      final service = ApiService(baseUrl);

      expect(service.baseUrl, baseUrl);
    });

    test('ApiService handles trailing slash in base URL', () {
      const baseUrlWithSlash = 'http://example.com/';
      final service = ApiService(baseUrlWithSlash);

      // The service should accept the URL as-is
      // It's the responsibility of callers to clean it
      expect(service.baseUrl, baseUrlWithSlash);
    });

    test('ApiService can be created multiple times', () {
      const baseUrl = 'http://example.com';
      final service1 = ApiService(baseUrl);
      final service2 = ApiService(baseUrl);

      // Both should have the same baseUrl
      expect(service1.baseUrl, service2.baseUrl);
    });
  });
}
