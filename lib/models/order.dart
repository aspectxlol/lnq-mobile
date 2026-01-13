import 'product.dart';
import '../utils/currency_utils.dart';

abstract class OrderItem {
  String get itemType;
  int? get id;
  int? get orderId;
  String? get notes;
  int get totalPrice;
  int get amount;
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final type = json['itemType'] ?? (json['productId'] != null ? 'product' : 'custom');
    if (type == 'custom') {
      return CustomOrderItem.fromJson(json);
    } else {
      return ProductOrderItem.fromJson(json);
    }
  }
  Map<String, dynamic> toJson();
}

class ProductOrderItem implements OrderItem {
  @override
  final String itemType = 'product';
  @override
  final int? id;
  @override
  final int? orderId;
  final int productId;
  final int _amount;
  @override
  final String? notes;
  final int? priceAtSale;
  final Product? product;

  @override
  int get amount => _amount;

  ProductOrderItem({
    this.id,
    this.orderId,
    required this.productId,
    required int amount,
    this.notes,
    this.priceAtSale,
    this.product,
  }) : _amount = amount;

  factory ProductOrderItem.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic val) {
      if (val == null) return null;
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return int.tryParse(val);
      return null;
    }
    return ProductOrderItem(
      id: parseInt(json['id']),
      orderId: parseInt(json['orderId']),
      productId: parseInt(json['productId']) ?? 0,
      amount: parseInt(json['amount']) ?? 0,
      notes: json['notes'] == null ? null : json['notes'] as String,
      priceAtSale: parseInt(json['priceAtSale']),
      product: json['product'] != null
          ? Product.fromJson(json['product'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'itemType': itemType,
      if (id != null) 'id': id,
      if (orderId != null) 'orderId': orderId,
      'productId': productId,
      'amount': amount,
      'notes': notes,
      if (priceAtSale != null) 'priceAtSale': priceAtSale,
      if (product != null) 'product': product!.toJson(),
    };
  }

  @override
  int get totalPrice {
    final int price = priceAtSale ?? product?.price ?? 0;
    return price * amount;
  }
}

class CustomOrderItem implements OrderItem {
  @override
  final String itemType = 'custom';
  @override
  final int? id;
  @override
  final int? orderId;
  final String customName;
  final int customPrice;
  @override
  final String? notes;

  @override
  int get amount => 1;

  CustomOrderItem({
    this.id,
    this.orderId,
    required this.customName,
    required this.customPrice,
    this.notes,
  });

  factory CustomOrderItem.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic val) {
      if (val == null) return null;
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return int.tryParse(val);
      return null;
    }
    return CustomOrderItem(
      id: parseInt(json['id']),
      orderId: parseInt(json['orderId']),
      customName: json['customName'] ?? '',
      customPrice: parseInt(json['customPrice']) ?? 0,
      notes: json['notes'] == null ? null : json['notes'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'itemType': itemType,
      if (id != null) 'id': id,
      if (orderId != null) 'orderId': orderId,
      'customName': customName,
      'customPrice': customPrice,
      'notes': notes,
    };
  }

  @override
  int get totalPrice => customPrice;
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
      pickupDate: json['pickupDate'] == null
          ? null
          : DateTime.tryParse(json['pickupDate'] as String),
      notes: json['notes'] == null ? null : json['notes'] as String,
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
      'pickupDate': pickupDate == null
          ? null
          : '${pickupDate!.year.toString().padLeft(4, '0')}-${pickupDate!.month.toString().padLeft(2, '0')}-${pickupDate!.day.toString().padLeft(2, '0')}',
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  int get totalAmount => items.fold(0, (sum, item) => sum + item.totalPrice);

  String get formattedTotal {
    return formatIdr(totalAmount);
  }

  int get itemCount => items.fold(0, (sum, item) => sum + item.amount);
}
