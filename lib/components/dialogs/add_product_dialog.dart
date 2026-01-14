import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../models/order_item_data.dart';
import '../../l10n/strings.dart';
import '../product_dropdown_item.dart';
import '../quantity_selector.dart';
import '../price_input.dart';

class AddProductDialog extends StatefulWidget {
  final List<Product> availableProducts;
  final List<int> selectedProductIds;
  final void Function(OrderItemData) onAddItem;

  const AddProductDialog({
    super.key,
    required this.availableProducts,
    required this.selectedProductIds,
    required this.onAddItem,
  });

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  Product? selectedProduct;
  int quantity = 1;
  int? customPrice;
  final customPriceController = TextEditingController();

  @override
  void dispose() {
    customPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final products = widget.availableProducts
        .where((p) => !widget.selectedProductIds.contains(p.id))
        .toList();

    return AlertDialog(
      title: Text(AppStrings.getString(locale, 'addProduct')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<Product>(
              initialValue: selectedProduct,
              decoration: InputDecoration(
                labelText: AppStrings.getString(locale, 'selectProduct'),
                prefixIcon: const Icon(Icons.shopping_bag),
              ),
              isExpanded: true,
              items: products
                  .map(
                    (product) => DropdownMenuItem(
                      value: product,
                      child: ProductDropdownItem(
                        name: product.name,
                        price: _formatPrice(product.price),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (product) {
                setState(() {
                  selectedProduct = product;
                  customPrice = product?.price;
                  customPriceController.text = product != null && product.price > 0
                      ? _formatPrice(product.price)
                      : '';
                });
              },
            ),
            const SizedBox(height: 24),
            if (selectedProduct != null) ...[
              Text(
                AppStrings.getString(locale, 'quantity'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              QuantitySelector(
                quantity: quantity,
                onDecrement: quantity > 1
                    ? () {
                        setState(() {
                          quantity--;
                        });
                      }
                    : null,
                onIncrement: () {
                  setState(() {
                    quantity++;
                  });
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Price at sale (optional):',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              PriceInput(
                controller: customPriceController,
                labelText: 'Price at sale (optional):',
                prefixText: 'Rp ',
                onChanged: (value) {
                  setState(() {
                    customPrice = int.tryParse(value);
                  });
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppStrings.getString(locale, 'cancel')),
        ),
        ElevatedButton(
          onPressed: selectedProduct == null
              ? null
              : () {
                  if (selectedProduct != null) {
                    widget.onAddItem(
                      OrderItemData.product(
                        productId: selectedProduct!.id,
                        product: selectedProduct!,
                        amount: quantity,
                        priceAtSale: customPrice,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
          child: Text(AppStrings.getString(locale, 'add')),
        ),
      ],
    );
  }

  String _formatPrice(int price) {
    if (price == 0) return '';
    final str = price.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) buffer.write('.');
    }
    return buffer.toString().split('').reversed.join();
  }
}
