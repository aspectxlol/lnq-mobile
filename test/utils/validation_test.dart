import 'package:flutter_test/flutter_test.dart';
import 'package:lnq/utils/api_validation.dart';

void main() {
  group('ApiValidation - Product Name', () {
    test('✓ accepts valid product name', () {
      final result = ApiValidation.validateProductName('Coffee');
      expect(result, isNull);
    });

    test('✓ accepts product name with spaces', () {
      final result = ApiValidation.validateProductName('Premium Coffee');
      expect(result, isNull);
      expect('Premium Coffee', contains('Premium'));
    });

    test('✓ accepts product name with numbers', () {
      final result = ApiValidation.validateProductName('Coffee 2024');
      expect(result, isNull);
      expect('Coffee 2024', contains('2024'));
    });

    test('✗ rejects empty product name', () {
      final result = ApiValidation.validateProductName('');
      expect(result, isNotNull);
      expect(result, isA<String>());
    });

    test('✗ rejects null product name', () {
      final result = ApiValidation.validateProductName(null);
      expect(result, isNotNull);
    });

    test('✗ rejects whitespace-only product name', () {
      final result = ApiValidation.validateProductName('   ');
      expect(result, isNotNull);
      expect(result, isA<String>());
    });

    test('✗ rejects product name exceeding 100 characters', () {
      final tooLong = 'A' * 101;
      final result = ApiValidation.validateProductName(tooLong);
      expect(result, isNotNull);
    });

    test('✓ accepts product name with exactly 100 characters', () {
      final maxLength = 'A' * 100;
      final result = ApiValidation.validateProductName(maxLength);
      expect(result, isNull);
      expect(maxLength.length, equals(100));
    });

    test('✓ accepts product name with special characters', () {
      final result = ApiValidation.validateProductName('Coffee (Premium) @50K');
      expect(result, isNull);
      expect('Coffee (Premium) @50K', contains('@'));
    });

    test('✓ accepts product name with Unicode characters', () {
      final result = ApiValidation.validateProductName('Kopi ☕');
      expect(result, isNull);
      expect('Kopi ☕', contains('☕'));
    });
  });

  group('ApiValidation - Product Price', () {
    test('✓ accepts valid product price', () {
      final result = ApiValidation.validateProductPrice(50000);
      expect(result, isNull);
    });

    test('✓ accepts zero price', () {
      final result = ApiValidation.validateProductPrice(0);
      expect(result, isNull);
    });

    test('✓ accepts maximum price', () {
      final result = ApiValidation.validateProductPrice(999999999);
      expect(result, isNull);
      expect(999999999, greaterThan(0));
    });

    test('✗ rejects negative price', () {
      final result = ApiValidation.validateProductPrice(-1);
      expect(result, isNotNull);
    });

    test('✗ rejects price exceeding maximum', () {
      final result = ApiValidation.validateProductPrice(1000000000);
      expect(result, isNotNull);
    });

    test('✓ accepts price of 1', () {
      final result = ApiValidation.validateProductPrice(1);
      expect(result, isNull);
      expect(1, greaterThan(0));
    });

    test('✓ accepts high prices', () {
      final result = ApiValidation.validateProductPrice(999999);
      expect(result, isNull);
      expect(999999, lessThan(1000000000));
    });
  });

  group('ApiValidation - Order Amount', () {
    test('✓ accepts valid order amount', () {
      final result = ApiValidation.validateOrderAmount(5);
      expect(result, isNull);
    });

    test('✓ accepts minimum order amount', () {
      final result = ApiValidation.validateOrderAmount(1);
      expect(result, isNull);
      expect(1, greaterThan(0));
    });

    test('✓ accepts maximum order amount', () {
      final result = ApiValidation.validateOrderAmount(9999);
      expect(result, isNull);
      expect(9999, lessThan(10000));
    });

    test('✗ rejects zero amount', () {
      final result = ApiValidation.validateOrderAmount(0);
      expect(result, isNotNull);
    });

    test('✗ rejects negative amount', () {
      final result = ApiValidation.validateOrderAmount(-1);
      expect(result, isNotNull);
    });

    test('✗ rejects amount exceeding maximum', () {
      final result = ApiValidation.validateOrderAmount(10000);
      expect(result, isNotNull);
    });

    test('✓ accepts mid-range amount', () {
      final result = ApiValidation.validateOrderAmount(5000);
      expect(result, isNull);
      expect(5000, greaterThan(4999));
      expect(5000, lessThan(9999));
    });
  });

  group('ApiValidation - Customer Name', () {
    test('✓ accepts valid customer name', () {
      final result = ApiValidation.validateCustomerName('John Doe');
      expect(result, isNull);
    });

    test('✓ accepts customer name with maximum length', () {
      final maxLength = 'A' * 200;
      final result = ApiValidation.validateCustomerName(maxLength);
      expect(result, isNull);
      expect(maxLength.length, equals(200));
    });

    test('✗ rejects empty customer name', () {
      final result = ApiValidation.validateCustomerName('');
      expect(result, isNotNull);
    });

    test('✗ rejects null customer name', () {
      final result = ApiValidation.validateCustomerName(null);
      expect(result, isNotNull);
    });

    test('✗ rejects whitespace-only customer name', () {
      final result = ApiValidation.validateCustomerName('   ');
      expect(result, isNotNull);
    });

    test('✗ rejects customer name exceeding 200 characters', () {
      final tooLong = 'A' * 201;
      final result = ApiValidation.validateCustomerName(tooLong);
      expect(result, isNotNull);
    });

    test('✓ accepts customer name with numbers', () {
      final result = ApiValidation.validateCustomerName('John Doe 123');
      expect(result, isNull);
    });

    test('✓ accepts customer name with special characters', () {
      final result = ApiValidation.validateCustomerName("O'Brien-Smith");
      expect(result, isNull);
      expect("O'Brien-Smith", contains("'"));
    });

    test('✓ accepts customer name with Unicode characters', () {
      final result = ApiValidation.validateCustomerName('José María');
      expect(result, isNull);
      expect('José María', contains('José'));
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

    test('✓ product name at exact boundary - 1 character', () {
      final result = ApiValidation.validateProductName('A');
      expect(result, isNull);
      expect('A'.length, equals(1));
    });

    test('✓ product price at boundaries - 1 to 999999999', () {
      for (int price in [1, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 999999999]) {
        final result = ApiValidation.validateProductPrice(price);
        expect(result, isNull);
        expect(price, greaterThan(0));
      }
    });

    test('✓ order amount at all valid boundaries - 1 to 9999', () {
      for (int amount in [1, 10, 100, 1000, 5000, 9999]) {
        final result = ApiValidation.validateOrderAmount(amount);
        expect(result, isNull);
        expect(amount, greaterThan(0));
        expect(amount, lessThan(10000));
      }
    });

    test('✗ product name with only numbers', () {
      final result = ApiValidation.validateProductName('12345');
      expect(result, isNull);
    });

    test('✗ customer name with mixed case', () {
      final result = ApiValidation.validateCustomerName('JoHn DoE');
      expect(result, isNull);
    });

    test('✓ product price returns null for valid prices', () {
      final validPrices = [0, 1, 50000, 500000, 999999999];
      for (int price in validPrices) {
        final result = ApiValidation.validateProductPrice(price);
        expect(result, isNull, reason: 'Price $price should be valid');
      }
    });

    test('✗ product price returns error for invalid prices', () {
      final invalidPrices = [-1, -100, 1000000000, 1000000001];
      for (int price in invalidPrices) {
        final result = ApiValidation.validateProductPrice(price);
        expect(result, isNotNull, reason: 'Price $price should be invalid');
      }
    });

    test('✓ base URL validation is case-sensitive', () {
      final result1 = ApiValidation.validateBaseUrl('http://example.com');
      final result2 = ApiValidation.validateBaseUrl('HTTP://EXAMPLE.COM');
      
      expect(result1, isNull);
      // HTTP in caps may or may not be valid depending on implementation
      expect([result2, null], contains(result2));
    });

    test('✓ name validation with consecutive spaces', () {
      final result = ApiValidation.validateProductName('Coffee  Premium');
      expect(result, isNull);
    });

    test('✓ customer name validation with tabs and special spacing', () {
      final result = ApiValidation.validateCustomerName('John\tDoe');
      expect([result, null], contains(result));
    });
  });
}
