import 'package:flutter/material.dart';
import '../models/order.dart';
import '../theme/app_theme.dart';
import '../utils/currency_utils.dart';
import '../widgets/note_container.dart';

class OrderItemRow extends StatelessWidget {
  final OrderItem item;

  const OrderItemRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${item.amount}x',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Builder(
                      builder: (context) {
                        if (item is ProductOrderItem) {
                          final productItem = item as ProductOrderItem;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productItem.product?.name != null
                                    ? productItem.product!.name
                                    : 'Product #${productItem.productId}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                '${formatIdr(productItem.priceAtSale ?? productItem.product?.price ?? 0)} x ${productItem.amount}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.mutedForeground,
                                ),
                              ),
                            ],
                          );
                        } else if (item is CustomOrderItem) {
                          final customItem = item as CustomOrderItem;
                          return Text(
                            customItem.customName,
                            style: Theme.of(context).textTheme.titleMedium,
                          );
                        } else {
                          return Text(
                            'Unknown Item',
                            style: Theme.of(context).textTheme.titleMedium,
                          );
                        }
                      },
                    ),
                ],
              ),
            ),
            Text(
              formatIdr(item.totalPrice),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        if (item.notes != null && item.notes!.isNotEmpty) ...[
          const SizedBox(height: 8),
          NoteContainer(note: item.notes!),
        ],
      ],
    );
  }
}
