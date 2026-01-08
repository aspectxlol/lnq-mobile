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
      'notes': notes,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class CreateOrderItem {
  final int productId;
  final int amount;
  final String? notes;
  final int? priceAtSale;

  CreateOrderItem({
    required this.productId,
    required this.amount,
    this.notes,
    this.priceAtSale,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'productId': productId, 'amount': amount};
    if (notes != null) {
      json['notes'] = notes;
    }
    if (priceAtSale != null) {
      json['priceAtSale'] = priceAtSale;
    }
    return json;
  }
}
