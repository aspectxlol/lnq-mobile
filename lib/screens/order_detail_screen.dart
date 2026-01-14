
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../providers/settings_provider.dart';
import '../components/edit_order_screen.dart';
import '../components/order_item_row.dart';
import '../theme/app_theme.dart';
import '../l10n/strings.dart';
import '../utils/currency_utils.dart';
import '../utils/state_extension.dart';
import '../utils/error_handler.dart';
import '../widgets/confirmation_dialog.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  const OrderDetailScreen({super.key, required this.orderId});
  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Future<Order> _orderFuture;
  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  void _loadOrder() {
    setState(() {
      _orderFuture = getApiService().getOrder(widget.orderId);
    });
  }

  Future<void> _printOrder() async {
    setState(() => _isPrinting = true);
    try {
      await getApiService().printOrder(widget.orderId);
      ifMounted(() {
        ErrorHandler.showSuccess(
          context,
          AppStrings.tr(context, 'orderSentToPrinter'),
        );
      });
    } catch (e) {
      ifMounted(() {
        ErrorHandler.showError(context, e);
      });
    } finally {
      ifMounted(() => setState(() => _isPrinting = false));
    }
  }

  Future<void> _deleteOrder() async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: AppStrings.tr(context, 'deleteOrder'),
      content: AppStrings.tr(context, 'deleteOrderConfirm'),
      confirmLabel: AppStrings.tr(context, 'delete'),
      cancelLabel: AppStrings.tr(context, 'cancel'),
      isDestructive: true,
    );
    if (confirmed != true) return;
    try {
      await getApiService().deleteOrder(widget.orderId);
      ifMounted(() => Navigator.pop(context, true));
    } catch (e) {
      ifMounted(() {
        ErrorHandler.showError(context, e);
      });
    }
  }

  Future<void> _editOrder(Order order) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => EditOrderScreen(order: order)),
    );
    if (result != null && mounted) {
      try {
        await getApiService().updateOrder(
          widget.orderId,
          customerName: result['customerName'],
          pickupDate: result['pickupDate'],
          notes: result['notes'],
          items: result['items'],
        );
        _loadOrder();
        ifMounted(() {
          ErrorHandler.showSuccess(
            context,
            AppStrings.tr(context, 'orderUpdatedSuccessfully'),
          );
        });
      } catch (e) {
        ifMounted(() {
          ErrorHandler.showError(context, e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<SettingsProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.trWatch(context, 'orderDetails')),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: AppStrings.trWatch(context, 'editOrder'),
            onPressed: () async {
              final order = await _orderFuture;
              _editOrder(order);
            },
          ),
        ],
      ),
      body: FutureBuilder<Order>(
        future: _orderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text(AppStrings.trWatch(context, 'loadingOrderFailed')));
          } else if (!snapshot.hasData) {
            return Center(child: Text(AppStrings.trWatch(context, 'noOrders')));
          }
          final order = snapshot.data!;
          final total = order.items.fold(0, (sum, item) => sum + item.totalPrice);
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primary.withOpacity(0.1),
                                child: Icon(Icons.person, color: AppColors.primary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(order.customerName,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Icon(Icons.event, color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                order.pickupDate != null
                                    ? DateFormat('MMM d, yyyy').format(order.pickupDate!)
                                    : AppStrings.trWatch(context, 'noPickupDateSet'),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                          if (order.notes != null && order.notes!.isNotEmpty) ...[
                            const SizedBox(height: 18),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.sticky_note_2_outlined, color: AppColors.primary, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(order.notes!,
                                      style: Theme.of(context).textTheme.bodyLarge),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
                  child: Row(
                    children: [
                      Icon(Icons.shopping_cart_outlined, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(AppStrings.trWatch(context, 'orderItems'),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              order.items.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.shopping_cart_outlined, size: 64, color: AppColors.mutedForeground),
                              const SizedBox(height: 16),
                              Text(AppStrings.trWatch(context, 'noItemsAdded'),
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.mutedForeground)),
                              const SizedBox(height: 8),
                              Text(AppStrings.trWatch(context, 'tapAddItem'),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mutedForeground)),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: OrderItemRow(item: order.items[index]),
                        ),
                        childCount: order.items.length,
                      ),
                    ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
                  child: Card(
                    color: AppColors.primary.withOpacity(0.08),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(AppStrings.trWatch(context, 'totalAmount'),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                          Text(formatIdr(total),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.print),
                          label: Text(_isPrinting
                              ? AppStrings.trWatch(context, 'printing')
                              : AppStrings.trWatch(context, 'printOrder')),
                          onPressed: _isPrinting ? null : _printOrder,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            textStyle: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.delete_outline),
                          label: Text(AppStrings.trWatch(context, 'deleteOrder')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.destructive,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            textStyle: Theme.of(context).textTheme.titleMedium,
                          ),
                          onPressed: _deleteOrder,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
