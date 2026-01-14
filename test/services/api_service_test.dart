import 'package:flutter_test/flutter_test.dart';
import 'package:lnq/services/api_service.dart';

void main() {
  group('ApiException Tests', () {
    test('✓ ApiException creates with message and status code', () {
      const message = 'Test error';
      const statusCode = 404;

      final exception = ApiException(message, statusCode);

      expect(exception.message, message);
      expect(exception.statusCode, statusCode);
      expect(exception.toString(), message);
      expect(exception.message, isNotEmpty);
      expect(exception.statusCode, greaterThan(0));
    });

    test('✓ ApiException creates with message only', () {
      const message = 'Test error';

      final exception = ApiException(message);

      expect(exception.message, message);
      expect(exception.statusCode, null);
      expect(exception.message, isNotEmpty);
    });

    test('✓ ApiException implements Exception', () {
      final exception = ApiException('test');

      expect(exception, isA<Exception>());
    });

    test('✓ ApiException with different status codes', () {
      final e400 = ApiException('Bad Request', 400);
      final e500 = ApiException('Server Error', 500);

      expect(e400.statusCode, equals(400));
      expect(e500.statusCode, equals(500));
      expect(e400.statusCode, lessThan(e500.statusCode ?? 0));
    });

    test('✓ ApiException message is preserved', () {
      final message = 'Connection failed';
      final exception = ApiException(message);

      expect(exception.message, equals(message));
      expect(exception.message, contains('Connection'));
    });
  });

  group('ApiService Tests', () {
    test('✓ ApiService initializes with base URL', () {
      const baseUrl = 'http://example.com';
      final service = ApiService(baseUrl);

      expect(service.baseUrl, baseUrl);
      expect(service.baseUrl, isNotEmpty);
    });

    test('✓ ApiService handles trailing slash in base URL', () {
      const baseUrlWithSlash = 'http://example.com/';
      final service = ApiService(baseUrlWithSlash);

      // The service should accept the URL as-is
      // It's the responsibility of callers to clean it
      expect(service.baseUrl, baseUrlWithSlash);
      expect(service.baseUrl, endsWith('/'));
    });

    test('✓ ApiService can be created multiple times', () {
      const baseUrl = 'http://example.com';
      final service1 = ApiService(baseUrl);
      final service2 = ApiService(baseUrl);

      // Both should have the same baseUrl
      expect(service1.baseUrl, service2.baseUrl);
      expect(service1.baseUrl, equals(baseUrl));
    });

    test('✓ ApiService with different base URLs', () {
      const url1 = 'http://localhost:3000';
      const url2 = 'https://api.example.com';

      final service1 = ApiService(url1);
      final service2 = ApiService(url2);

      expect(service1.baseUrl, isNot(service2.baseUrl));
      expect(service1.baseUrl, contains('localhost'));
      expect(service2.baseUrl, contains('api.example.com'));
    });

    test('✓ ApiService baseUrl is accessible', () {
      const baseUrl = 'http://example.com';
      final service = ApiService(baseUrl);

      expect(service.baseUrl, isA<String>());
      expect(service.baseUrl, isNotEmpty);
    });

    test('✓ ApiService baseUrl starts with http protocol', () {
      const baseUrl = 'https://secure.example.com';
      final service = ApiService(baseUrl);

      expect(service.baseUrl.startsWith('http'), isTrue);
    });

    test('✓ ApiException comparison with different messages', () {
      final e1 = ApiException('Error 1', 400);
      final e2 = ApiException('Error 2', 400);

      expect(e1.message, isNot(e2.message));
      expect(e1.statusCode, equals(e2.statusCode));
    });
  });
}
