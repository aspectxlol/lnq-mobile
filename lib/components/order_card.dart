import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../l10n/strings.dart';
import 'package:provider/provider.dart';
import '../widgets/animated_widgets.dart';
import 'info_row.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;
  const OrderCard({Key? key, required this.order, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.watch<SettingsProvider>();
    return AnimatedCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order.customerName, style: Theme.of(context).textTheme.titleLarge),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: order.pickupDate != null ? AppColors.success.withOpacity(0.2) : AppColors.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: order.pickupDate != null ? AppColors.success : AppColors.secondary,
                  ),
                ),
                child: Text(
                  order.pickupDate != null ? AppStrings.trWatch(context, 'scheduled') : AppStrings.trWatch(context, 'new'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: order.pickupDate != null ? AppColors.success : AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.receipt, size: 16, color: AppColors.mutedForeground),
              const SizedBox(width: 8),
              Text('Order #${order.id}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mutedForeground)),
            ],
          ),
          if (order.pickupDate != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.event, size: 16, color: AppColors.mutedForeground),
                const SizedBox(width: 8),
                Text(
                  '${AppStrings.trWatch(context, 'pickup')}: ${_formatDate(order.pickupDate!)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mutedForeground),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          InfoRow(
            label: '${order.itemCount} ${AppStrings.trWatch(context, 'items')}',
            value: order.formattedTotal,
            valueColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}
