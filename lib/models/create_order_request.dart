class CreateOrderRequest {
  final String customerName;
  final DateTime? pickupDate;
  final String? notes;
  final List<CreateOrderItem> items;

  CreateOrderRequest({
    required this.customerName,
    this.pickupDate,
    this.notes,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'pickupDate': pickupDate == null
          ? null
          : '${pickupDate!.year.toString().padLeft(4, '0')}-${pickupDate!.month.toString().padLeft(2, '0')}-${pickupDate!.day.toString().padLeft(2, '0')}',
      'notes': notes ?? '',
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

abstract class CreateOrderItem {
  String get itemType;
  Map<String, dynamic> toJson();
}

class ProductOrderItem extends CreateOrderItem {
  @override
  String get itemType => 'product';
  final int productId;
  final int amount;
  final String? notes;
  final int? priceAtSale;

  ProductOrderItem({
    required this.productId,
    required this.amount,
    this.notes,
    this.priceAtSale,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'itemType': itemType,
      'productId': productId,
      'amount': amount,
    };
    if (notes != null) json['notes'] = notes;
    if (priceAtSale != null) json['priceAtSale'] = priceAtSale;
    return json;
  }
}

class CustomOrderItem extends CreateOrderItem {
  @override
  String get itemType => 'custom';
  final String customName;
  final int customPrice;
  final String? notes;

  CustomOrderItem({
    required this.customName,
    required this.customPrice,
    this.notes,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'itemType': itemType,
      'customName': customName,
      'customPrice': customPrice,
    };
    if (notes != null) json['notes'] = notes;
    return json;
  }
}
