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
      expect(product.createdAt, isNotNull);
      expect(product.createdAt.year, equals(2024));
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
      expect(json['name'], isNotEmpty);
      expect(json.containsKey('id'), isTrue);
      expect(json.containsKey('price'), isTrue);
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
      expect(product.id, isNotNull);
      expect(product.name, isNotEmpty);
      expect(product.price, greaterThanOrEqualTo(0));
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
      expect(reconstructed.imageId, equals(original.imageId));
      expect(reconstructed, isA<Product>());
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
      expect(product.id, isNotNull);
      expect(product.name, isNotEmpty);
    });

    test('✓ Product price zero is valid', () {
      final product = Product(
        id: 1,
        name: 'Free',
        price: 0,
        createdAt: DateTime(2024, 1, 15),
      );

      expect(product.price, equals(0));
      expect(product.price, greaterThanOrEqualTo(0));
    });

    test('✓ Product price max value', () {
      final product = Product(
        id: 1,
        name: 'Expensive',
        price: 999999999,
        createdAt: DateTime(2024, 1, 15),
      );

      expect(product.price, equals(999999999));
      expect(product.price, greaterThan(999999998));
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
      expect(url, isNotEmpty);
      expect(url, contains('abc123'));
      expect(url, startsWith('http'));
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
      expect(product.name, contains('('));
      expect(product.name, contains('@'));
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
      expect(product.name, isNotEmpty);
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
      expect(product.name, isNotEmpty);
      expect(product.name, startsWith('A'));
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
      expect(product.description, isNotEmpty);
    });

    test('✓ Product formattedPrice returns non-empty string', () {
      final product = Product(
        id: 1,
        name: 'Coffee',
        price: 50000,
        createdAt: DateTime(2024, 1, 15),
      );

      expect(product.formattedPrice, isNotEmpty);
      expect(product.formattedPrice, isA<String>());
    });

    test('✓ Product comparison - different products are not equal', () {
      final product1 = Product(
        id: 1,
        name: 'Coffee',
        price: 50000,
        createdAt: DateTime(2024, 1, 15),
      );

      final product2 = Product(
        id: 2,
        name: 'Tea',
        price: 30000,
        createdAt: DateTime(2024, 1, 15),
      );

      expect(product1.id, isNot(product2.id));
      expect(product1.name, isNot(product2.name));
    });

    test('✓ Product getImageUrl with different baseUrls', () {
      final product = Product(
        id: 1,
        name: 'Coffee',
        price: 50000,
        imageId: 'abc123',
        createdAt: DateTime(2024, 1, 15),
      );

      final url1 = product.getImageUrl('http://example.com');
      final url2 = product.getImageUrl('https://api.example.com');

      expect(url1, isNotEmpty);
      expect(url2, isNotEmpty);
      expect(url1, isNot(url2));
      expect(url2, contains('https'));
    });
  });
}
