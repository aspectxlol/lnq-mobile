import 'product.dart';

class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final int amount;
  final String? notes;
  final Product? product;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.amount,
    this.notes,
    this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int,
      orderId: json['orderId'] as int,
      productId: json['productId'] as int,
      amount: json['amount'] as int,
      notes: json['notes'] as String?,
      product: json['product'] != null
          ? Product.fromJson(json['product'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
      'amount': amount,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      if (product != null) 'product': product!.toJson(),
    };
  }

  int get totalPrice => (product?.price ?? 0) * amount;
}

class Order {
  final int id;
  final String customerName;
  final DateTime? pickupDate;
  final String? notes;
  final DateTime createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.customerName,
    this.pickupDate,
    this.notes,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      customerName: json['customerName'] as String,
      pickupDate: json['pickupDate'] != null
          ? DateTime.parse(json['pickupDate'] as String)
          : null,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      if (pickupDate != null)
        'pickupDate':
            '${pickupDate!.year.toString().padLeft(4, '0')}-${pickupDate!.month.toString().padLeft(2, '0')}-${pickupDate!.day.toString().padLeft(2, '0')}',
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  int get totalAmount => items.fold(0, (sum, item) => sum + item.totalPrice);

  String get formattedTotal {
    return 'Rp ${(totalAmount / 1000).toStringAsFixed(0)}.000';
  }

  int get itemCount => items.fold(0, (sum, item) => sum + item.amount);
}
