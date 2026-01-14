import '../models/product.dart';

/// Data class for managing order items (both product and custom)
/// Used across order creation and editing screens
class OrderItemData {
  final bool isCustom;
  final int? productId;
  int amount; // Mutable for quantity changes in dialogs
  final String? notes;
  final Product? product;
  final int? priceAtSale;
  final String? customName;
  final int? customPrice;

  OrderItemData.product({
    required this.productId,
    required this.amount,
    this.notes,
    this.product,
    this.priceAtSale,
  })  : isCustom = false,
        customName = null,
        customPrice = null;

  OrderItemData.custom({
    required this.customName,
    required this.customPrice,
    this.notes,
    int amount = 1,
  })  : isCustom = true,
        productId = null,
        amount = amount,
        product = null,
        priceAtSale = null;
}
