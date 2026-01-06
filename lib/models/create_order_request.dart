class CreateOrderRequest {
  final String customerName;
  final DateTime? pickupDate;
  final List<CreateOrderItem> items;

  CreateOrderRequest({
    required this.customerName,
    this.pickupDate,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'pickupDate': pickupDate != null
          ? '${pickupDate!.year.toString().padLeft(4, '0')}-${pickupDate!.month.toString().padLeft(2, '0')}-${pickupDate!.day.toString().padLeft(2, '0')}'
          : null,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class CreateOrderItem {
  final int productId;
  final int amount;

  CreateOrderItem({required this.productId, required this.amount});

  Map<String, dynamic> toJson() {
    return {'productId': productId, 'amount': amount};
  }
}
