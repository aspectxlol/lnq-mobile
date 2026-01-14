import 'package:flutter_test/flutter_test.dart';
import 'package:lnq/models/product.dart';

void main() {
  group('Product Model Tests', () {
    test('✓ Product initialization with all fields', () {
      final product = Product(
        id: 1,
        name: 'Coffee',
        description: 'Premium Arabica',
        price: 50000,
        priceAtSale: 40000,
        imageId: 'img1',
        createdAt: DateTime(2024, 1, 15),
      );

      expect(product.id, equals(1));
      expect(product.name, equals('Coffee'));
      expect(product.description, equals('Premium Arabica'));
      expect(product.price, equals(50000));
      expect(product.priceAtSale, equals(40000));
      expect(product.imageId, equals('img1'));
    });

    test('✓ Product toJson serialization', () {
      final product = Product(
        id: 1,
        name: 'Tea',
        price: 30000,
        createdAt: DateTime(2024, 1, 15),
      );

      final json = product.toJson();
      expect(json['id'], equals(1));
      expect(json['name'], equals('Tea'));
      expect(json['price'], equals(30000));
    });

    test('✓ Product fromJson deserialization', () {
      final json = {
        'id': 1,
        'name': 'Coffee',
        'price': 50000,
        'createdAt': '2024-01-15T10:30:00.000Z',
      };

      final product = Product.fromJson(json);
      expect(product.id, equals(1));
      expect(product.name, equals('Coffee'));
      expect(product.price, equals(50000));
    });

    test('✓ Product round-trip JSON', () {
      final original = Product(
        id: 1,
        name: 'Coffee',
        description: 'Premium',
        price: 50000,
        priceAtSale: 40000,
        imageId: 'img1',
        createdAt: DateTime(2024, 1, 15),
      );

      final json = original.toJson();
      final reconstructed = Product.fromJson(json);

      expect(reconstructed.id, equals(original.id));
      expect(reconstructed.name, equals(original.name));
      expect(reconstructed.description, equals(original.description));
      expect(reconstructed.price, equals(original.price));
      expect(reconstructed.priceAtSale, equals(original.priceAtSale));
    });

    test('✓ Product with null optional fields', () {
      final product = Product(
        id: 1,
        name: 'Product',
        price: 50000,
        createdAt: DateTime(2024, 1, 15),
      );

      expect(product.description, isNull);
      expect(product.priceAtSale, isNull);
      expect(product.imageId, isNull);
    });

    test('✓ Product price zero is valid', () {
      final product = Product(
        id: 1,
        name: 'Free',
        price: 0,
        createdAt: DateTime(2024, 1, 15),
      );

      expect(product.price, equals(0));
    });

    test('✓ Product price max value', () {
      final product = Product(
        id: 1,
        name: 'Expensive',
        price: 999999999,
        createdAt: DateTime(2024, 1, 15),
      );

      expect(product.price, equals(999999999));
    });

    test('✓ Product getImageUrl with baseUrl', () {
      final product = Product(
        id: 1,
        name: 'Coffee',
        price: 50000,
        imageId: 'abc123',
        createdAt: DateTime(2024, 1, 15),
      );

      final url = product.getImageUrl('http://example.com');
      expect(url, equals('http://example.com/api/images/abc123'));
    });

    test('✓ Product getImageUrl null when no imageId', () {
      final product = Product(
        id: 1,
        name: 'Coffee',
        price: 50000,
        imageId: null,
        createdAt: DateTime(2024, 1, 15),
      );

      expect(product.getImageUrl('http://example.com'), isNull);
    });

    test('✓ Product with special characters in name', () {
      final product = Product(
        id: 1,
        name: 'Coffee (Premium) @50K',
        price: 50000,
        createdAt: DateTime(2024, 1, 15),
      );

      expect(product.name, equals('Coffee (Premium) @50K'));
    });

    test('✓ Product with Unicode characters', () {
      final product = Product(
        id: 1,
        name: 'Kopi ☕',
        description: '咖啡',
        price: 50000,
        createdAt: DateTime(2024, 1, 15),
      );

      expect(product.name, contains('☕'));
      expect(product.description, contains('咖'));
    });

    test('✓ Product with very long name (100 chars)', () {
      final longName = 'A' * 100;
      final product = Product(
        id: 1,
        name: longName,
        price: 50000,
        createdAt: DateTime(2024, 1, 15),
      );

      expect(product.name.length, equals(100));
    });

    test('✓ Product with very long description', () {
      final longDesc = 'This is a description. ' * 50;
      final product = Product(
        id: 1,
        name: 'Product',
        description: longDesc,
        price: 50000,
        createdAt: DateTime(2024, 1, 15),
      );

      expect(product.description!.length, greaterThan(500));
    });

    test('✓ Product formattedPrice returns non-empty string', () {
      final product = Product(
        id: 1,
        name: 'Coffee',
        price: 50000,
        createdAt: DateTime(2024, 1, 15),
      );

      expect(product.formattedPrice, isNotEmpty);
    });
  });
}
