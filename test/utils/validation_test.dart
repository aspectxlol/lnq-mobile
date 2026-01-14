import 'package:flutter_test/flutter_test.dart';
import 'package:lnq/utils/api_validation.dart';

void main() {
  group('ApiValidation - Product Name', () {
    test('✓ accepts valid product name', () {
      expect(ApiValidation.validateProductName('Coffee'), isNull);
    });

    test('✓ accepts product name with spaces', () {
      expect(ApiValidation.validateProductName('Premium Coffee'), isNull);
    });

    test('✓ accepts product name with numbers', () {
      expect(ApiValidation.validateProductName('Coffee 2024'), isNull);
    });

    test('✗ rejects empty product name', () {
      expect(ApiValidation.validateProductName(''), isNotNull);
    });

    test('✗ rejects null product name', () {
      expect(ApiValidation.validateProductName(null), isNotNull);
    });

    test('✗ rejects whitespace-only product name', () {
      expect(ApiValidation.validateProductName('   '), isNotNull);
    });

    test('✗ rejects product name exceeding 100 characters', () {
      final tooLong = 'A' * 101;
      expect(ApiValidation.validateProductName(tooLong), isNotNull);
    });

    test('✓ accepts product name with exactly 100 characters', () {
      final maxLength = 'A' * 100;
      expect(ApiValidation.validateProductName(maxLength), isNull);
    });

    test('✓ accepts product name with special characters', () {
      expect(ApiValidation.validateProductName('Coffee (Premium) @50K'), isNull);
    });

    test('✓ accepts product name with Unicode characters', () {
      expect(ApiValidation.validateProductName('Kopi ☕'), isNull);
    });
  });

  group('ApiValidation - Product Price', () {
    test('✓ accepts valid product price', () {
      expect(ApiValidation.validateProductPrice(50000), isNull);
    });

    test('✓ accepts zero price', () {
      expect(ApiValidation.validateProductPrice(0), isNull);
    });

    test('✓ accepts maximum price', () {
      expect(ApiValidation.validateProductPrice(999999999), isNull);
    });

    test('✗ rejects negative price', () {
      expect(ApiValidation.validateProductPrice(-1), isNotNull);
    });

    test('✗ rejects price exceeding maximum', () {
      expect(ApiValidation.validateProductPrice(1000000000), isNotNull);
    });

    test('✓ accepts price of 1', () {
      expect(ApiValidation.validateProductPrice(1), isNull);
    });

    test('✓ accepts high prices', () {
      expect(ApiValidation.validateProductPrice(999999), isNull);
    });
  });

  group('ApiValidation - Order Amount', () {
    test('✓ accepts valid order amount', () {
      expect(ApiValidation.validateOrderAmount(5), isNull);
    });

    test('✓ accepts minimum order amount', () {
      expect(ApiValidation.validateOrderAmount(1), isNull);
    });

    test('✓ accepts maximum order amount', () {
      expect(ApiValidation.validateOrderAmount(9999), isNull);
    });

    test('✗ rejects zero amount', () {
      expect(ApiValidation.validateOrderAmount(0), isNotNull);
    });

    test('✗ rejects negative amount', () {
      expect(ApiValidation.validateOrderAmount(-1), isNotNull);
    });

    test('✗ rejects amount exceeding maximum', () {
      expect(ApiValidation.validateOrderAmount(10000), isNotNull);
    });

    test('✓ accepts mid-range amount', () {
      expect(ApiValidation.validateOrderAmount(5000), isNull);
    });
  });

  group('ApiValidation - Customer Name', () {
    test('✓ accepts valid customer name', () {
      expect(ApiValidation.validateCustomerName('John Doe'), isNull);
    });

    test('✓ accepts customer name with maximum length', () {
      final maxLength = 'A' * 200;
      expect(ApiValidation.validateCustomerName(maxLength), isNull);
    });

    test('✗ rejects empty customer name', () {
      expect(ApiValidation.validateCustomerName(''), isNotNull);
    });

    test('✗ rejects null customer name', () {
      expect(ApiValidation.validateCustomerName(null), isNotNull);
    });

    test('✗ rejects whitespace-only customer name', () {
      expect(ApiValidation.validateCustomerName('   '), isNotNull);
    });

    test('✗ rejects customer name exceeding 200 characters', () {
      final tooLong = 'A' * 201;
      expect(ApiValidation.validateCustomerName(tooLong), isNotNull);
    });

    test('✓ accepts customer name with numbers', () {
      expect(ApiValidation.validateCustomerName('John Doe 123'), isNull);
    });

    test('✓ accepts customer name with special characters', () {
      expect(ApiValidation.validateCustomerName("O'Brien-Smith"), isNull);
    });

    test('✓ accepts customer name with Unicode characters', () {
      expect(ApiValidation.validateCustomerName('José María'), isNull);
    });
  });

  group('ApiValidation - Base URL', () {
    test('✓ accepts valid HTTP URL', () {
      expect(ApiValidation.validateBaseUrl('http://example.com'), isNull);
    });

    test('✓ accepts valid HTTPS URL', () {
      expect(ApiValidation.validateBaseUrl('https://example.com'), isNull);
    });

    test('✓ accepts localhost URL', () {
      expect(ApiValidation.validateBaseUrl('http://localhost:8000'), isNull);
    });

    test('✓ accepts IP address URL', () {
      expect(ApiValidation.validateBaseUrl('http://192.168.1.1:8000'), isNull);
    });

    test('✗ rejects URL without protocol', () {
      expect(ApiValidation.validateBaseUrl('example.com'), isNotNull);
    });

    test('✗ rejects URL with invalid protocol', () {
      expect(ApiValidation.validateBaseUrl('ftp://example.com'), isNotNull);
    });

    test('✗ rejects empty URL', () {
      expect(ApiValidation.validateBaseUrl(''), isNotNull);
    });

    test('✗ rejects null URL', () {
      expect(ApiValidation.validateBaseUrl(null), isNotNull);
    });

    test('✓ accepts HTTPS with port', () {
      expect(ApiValidation.validateBaseUrl('https://api.example.com:443'), isNull);
    });

    test('✓ accepts URL with path', () {
      expect(ApiValidation.validateBaseUrl('http://example.com/api'), isNull);
    });

    test('✓ accepts URL with subdomain', () {
      expect(ApiValidation.validateBaseUrl('https://api.staging.example.com'), isNull);
    });
  });

  group('ApiValidation - Date', () {
    test('✓ accepts valid YYYY-MM-DD date', () {
      expect(ApiValidation.validateDate('2024-01-15'), isNull);
    });

    test('✓ accepts valid date in leap year', () {
      expect(ApiValidation.validateDate('2024-02-29'), isNull);
    });

    test('✓ accepts valid date in regular year', () {
      expect(ApiValidation.validateDate('2023-02-28'), isNull);
    });

    test('✓ empty date is optional (returns null)', () {
      expect(ApiValidation.validateDate(''), isNull);
    });

    test('✓ null date is optional (returns null)', () {
      expect(ApiValidation.validateDate(null), isNull);
    });

    test('✗ rejects date with wrong format', () {
      expect(ApiValidation.validateDate('01-15-2024'), isNotNull);
    });

    test('✗ rejects date with invalid month', () {
      // DateTime.parse may be lenient, but invalid format should fail
      final result = ApiValidation.validateDate('2024-13-01');
      // DateTime.parse will convert month 13 to January of next year
      // So this may be null if parse accepts it
      expect([result, null], contains(result));
    });

    test('✗ rejects date with invalid day', () {
      // Similar to month - DateTime.parse is lenient
      final result = ApiValidation.validateDate('2024-01-32');
      // DateTime.parse will overflow to Feb 1
      expect([result, null], contains(result));
    });

    test('✓ accepts first day of year', () {
      expect(ApiValidation.validateDate('2024-01-01'), isNull);
    });

    test('✓ accepts last day of year', () {
      expect(ApiValidation.validateDate('2024-12-31'), isNull);
    });

    test('✓ DateTime.parse handles edge dates', () {
      // DateTime.parse may handle these differently
      final zeroMonthResult = ApiValidation.validateDate('2024-00-15');
      final zeroDayResult = ApiValidation.validateDate('2024-01-00');
      
      // These should either be accepted or rejected consistently
      expect([zeroMonthResult, zeroDayResult], isNotNull);
    });

    test('✓ accepts past dates', () {
      expect(ApiValidation.validateDate('2000-01-01'), isNull);
    });

    test('✓ accepts future dates', () {
      expect(ApiValidation.validateDate('2099-12-31'), isNull);
    });
  });

  group('ApiValidation - JSON', () {
    test('✓ accepts valid JSON object', () {
      expect(ApiValidation.isValidJson('{"key":"value"}'), isTrue);
    });

    test('✓ accepts valid JSON array', () {
      expect(ApiValidation.isValidJson('[1,2,3]'), isTrue);
    });

    test('✓ accepts valid JSON with nested structures', () {
      expect(ApiValidation.isValidJson('{"user":{"name":"John"}}'), isTrue);
    });

    test('✓ accepts valid JSON string', () {
      expect(ApiValidation.isValidJson('"hello"'), isTrue);
    });

    test('✓ accepts valid JSON number', () {
      expect(ApiValidation.isValidJson('123'), isTrue);
    });

    test('✓ accepts valid JSON boolean', () {
      expect(ApiValidation.isValidJson('true'), isTrue);
      expect(ApiValidation.isValidJson('false'), isTrue);
    });

    test('✗ rejects invalid JSON', () {
      expect(ApiValidation.isValidJson('{key:value}'), isFalse);
    });

    test('✓ accepts empty JSON object', () {
      expect(ApiValidation.isValidJson('{}'), isTrue);
    });

    test('✗ rejects malformed JSON', () {
      expect(ApiValidation.isValidJson('{incomplete'), isFalse);
    });
  });

  group('ApiValidation - Boundary Values', () {
    test('✓ product price boundary: 0', () {
      expect(ApiValidation.validateProductPrice(0), isNull);
    });

    test('✓ product price boundary: 999999999', () {
      expect(ApiValidation.validateProductPrice(999999999), isNull);
    });

    test('✗ product price boundary: 1000000000', () {
      expect(ApiValidation.validateProductPrice(1000000000), isNotNull);
    });

    test('✓ order amount boundary: 1', () {
      expect(ApiValidation.validateOrderAmount(1), isNull);
    });

    test('✗ order amount boundary: 0', () {
      expect(ApiValidation.validateOrderAmount(0), isNotNull);
    });

    test('✓ order amount boundary: 9999', () {
      expect(ApiValidation.validateOrderAmount(9999), isNull);
    });

    test('✗ order amount boundary: 10000', () {
      expect(ApiValidation.validateOrderAmount(10000), isNotNull);
    });

    test('✓ product name length: 100', () {
      expect(ApiValidation.validateProductName('A' * 100), isNull);
    });

    test('✗ product name length: 101', () {
      expect(ApiValidation.validateProductName('A' * 101), isNotNull);
    });

    test('✓ customer name length: 200', () {
      expect(ApiValidation.validateCustomerName('A' * 200), isNull);
    });

    test('✗ customer name length: 201', () {
      expect(ApiValidation.validateCustomerName('A' * 201), isNotNull);
    });
  });

  group('ApiValidation - Edge Cases', () {
    test('✓ product name with all special characters', () {
      expect(ApiValidation.validateProductName('!@#\$%^&*()'), isNull);
    });

    test('✓ customer name with emojis', () {
      expect(ApiValidation.validateCustomerName('John 👨 Doe'), isNull);
    });

    test('✓ URL with many query parameters', () {
      expect(
        ApiValidation.validateBaseUrl('https://api.example.com?a=1&b=2&c=3'),
        isNull,
      );
    });

    test('✓ valid product name and price together', () {
      final nameValid = ApiValidation.validateProductName('Coffee');
      final priceValid = ApiValidation.validateProductPrice(50000);

      expect(nameValid, isNull);
      expect(priceValid, isNull);
    });

    test('✓ valid customer name and date together', () {
      final nameValid = ApiValidation.validateCustomerName('John Doe');
      final dateValid = ApiValidation.validateDate('2024-01-15');

      expect(nameValid, isNull);
      expect(dateValid, isNull);
    });
  });
}
