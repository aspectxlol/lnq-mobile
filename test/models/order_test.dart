import 'package:flutter_test/flutter_test.dart';
import 'package:lnq/models/order.dart';

void main() {
  group('Order Model Tests', () {
    test('✓ Order initialization with all fields', () {
      final items = [
        ProductOrderItem(productId: 1, amount: 2),
      ];

      final order = Order(
        id: 100,
        customerName: 'John Doe',
        pickupDate: DateTime(2024, 1, 20),
        notes: 'ASAP',
        createdAt: DateTime(2024, 1, 15),
        items: items,
      );

      expect(order.id, equals(100));
      expect(order.customerName, equals('John Doe'));
      expect(order.pickupDate, equals(DateTime(2024, 1, 20)));
      expect(order.notes, equals('ASAP'));
      expect(order.items.length, equals(1));
    });

    test('✓ Order initialization with minimal fields', () {
      final order = Order(
        id: 100,
        customerName: 'John',
        createdAt: DateTime(2024, 1, 15),
        items: [],
      );

      expect(order.id, equals(100));
      expect(order.customerName, equals('John'));
      expect(order.pickupDate, isNull);
      expect(order.notes, isNull);
      expect(order.items.isEmpty, isTrue);
    });

    test('✓ Order toJson serialization', () {
      final items = [
        ProductOrderItem(productId: 1, amount: 2, priceAtSale: 50000),
      ];

      final order = Order(
        id: 100,
        customerName: 'John',
        pickupDate: DateTime(2024, 1, 20),
        notes: 'Fast',
        createdAt: DateTime(2024, 1, 15),
        items: items,
      );

      final json = order.toJson();
      expect(json['id'], equals(100));
      expect(json['customerName'], equals('John'));
      expect(json['items'], isList);
    });

    test('✓ Order fromJson deserialization', () {
      final json = {
        'id': 100,
        'customerName': 'John',
        'createdAt': '2024-01-15T10:30:00.000Z',
        'items': [],
      };

      final order = Order.fromJson(json);
      expect(order.id, equals(100));
      expect(order.customerName, equals('John'));
      expect(order.items.isEmpty, isTrue);
    });

    test('✓ Order round-trip JSON with items', () {
      final items = [
        ProductOrderItem(
          id: 1,
          productId: 1,
          amount: 2,
          priceAtSale: 50000,
        ),
        CustomOrderItem(
          id: 2,
          customName: 'Special',
          customPrice: 75000,
        ),
      ];

      final original = Order(
        id: 100,
        customerName: 'John',
        pickupDate: DateTime(2024, 1, 20),
        notes: 'Test',
        createdAt: DateTime(2024, 1, 15),
        items: items,
      );

      final json = original.toJson();
      final reconstructed = Order.fromJson(json);

      expect(reconstructed.id, equals(original.id));
      expect(reconstructed.customerName, equals(original.customerName));
      expect(reconstructed.items.length, equals(2));
    });

    test('✓ Order with null optional fields', () {
      final order = Order(
        id: 100,
        customerName: 'John',
        createdAt: DateTime(2024, 1, 15),
        items: [],
      );

      expect(order.pickupDate, isNull);
      expect(order.notes, isNull);
    });

    test('✓ Order calculates itemCount correctly', () {
      final items = [
        ProductOrderItem(productId: 1, amount: 2),
        ProductOrderItem(productId: 2, amount: 3),
        CustomOrderItem(customName: 'Custom', customPrice: 1000),
      ];

      final order = Order(
        id: 100,
        customerName: 'John',
        createdAt: DateTime(2024, 1, 15),
        items: items,
      );

      expect(order.itemCount, equals(6)); // 2 + 3 + 1
    });

    test('✓ Order calculates totalAmount correctly', () {
      final items = [
        ProductOrderItem(productId: 1, amount: 2, priceAtSale: 50000),
        ProductOrderItem(productId: 2, amount: 1, priceAtSale: 30000),
        CustomOrderItem(customName: 'Custom', customPrice: 20000),
      ];

      final order = Order(
        id: 100,
        customerName: 'John',
        createdAt: DateTime(2024, 1, 15),
        items: items,
      );

      expect(order.totalAmount, equals(150000)); // (2*50000) + (1*30000) + 20000
    });

    test('✓ Order with many items', () {
      final items = List.generate(
        100,
        (i) => ProductOrderItem(productId: i, amount: i + 1),
      );

      final order = Order(
        id: 100,
        customerName: 'Bulk',
        createdAt: DateTime(2024, 1, 15),
        items: items,
      );

      expect(order.items.length, equals(100));
    });

    test('✓ Order with Unicode customer name', () {
      final order = Order(
        id: 100,
        customerName: 'José García 中文',
        createdAt: DateTime(2024, 1, 15),
        items: [],
      );

      expect(order.customerName, contains('José'));
      expect(order.customerName, contains('中'));
    });

    test('✓ Order with very long customer name', () {
      final longName = 'A' * 200;
      final order = Order(
        id: 100,
        customerName: longName,
        createdAt: DateTime(2024, 1, 15),
        items: [],
      );

      expect(order.customerName.length, equals(200));
    });

    test('✓ Order with special notes', () {
      final order = Order(
        id: 100,
        customerName: 'John',
        notes: 'Notes with @#\$% & special chars',
        createdAt: DateTime(2024, 1, 15),
        items: [],
      );

      expect(order.notes, contains('@'));
      expect(order.notes, contains('\$'));
    });

    test('✓ Order formattedTotal returns non-empty string', () {
      final items = [
        ProductOrderItem(productId: 1, amount: 2, priceAtSale: 50000),
      ];

      final order = Order(
        id: 100,
        customerName: 'John',
        createdAt: DateTime(2024, 1, 15),
        items: items,
      );

      expect(order.formattedTotal, isNotEmpty);
    });

    test('✓ ProductOrderItem with minimal fields', () {
      final item = ProductOrderItem(
        productId: 1,
        amount: 1,
      );

      expect(item.productId, equals(1));
      expect(item.amount, equals(1));
      expect(item.itemType, equals('product'));
    });

    test('✓ ProductOrderItem calculates totalPrice', () {
      final item = ProductOrderItem(
        productId: 1,
        amount: 3,
        priceAtSale: 50000,
      );

      expect(item.totalPrice, equals(150000));
    });

    test('✓ CustomOrderItem totalPrice equals customPrice', () {
      final item = CustomOrderItem(
        customName: 'Special',
        customPrice: 100000,
      );

      expect(item.totalPrice, equals(100000));
      expect(item.amount, equals(1));
    });

    test('✓ CustomOrderItem serialization', () {
      final item = CustomOrderItem(
        id: 1,
        customName: 'Custom',
        customPrice: 50000,
        notes: 'Special',
      );

      final json = item.toJson();
      expect(json['itemType'], equals('custom'));
      expect(json['customName'], equals('Custom'));
      expect(json['customPrice'], equals(50000));
    });

    test('✓ OrderItem factory creates correct type', () {
      final productJson = {
        'itemType': 'product',
        'productId': 1,
        'amount': 2,
      };

      final customJson = {
        'itemType': 'custom',
        'customName': 'Item',
        'customPrice': 50000,
      };

      final productItem = OrderItem.fromJson(productJson);
      final customItem = OrderItem.fromJson(customJson);

      expect(productItem is ProductOrderItem, isTrue);
      expect(customItem is CustomOrderItem, isTrue);
    });
  });
}
