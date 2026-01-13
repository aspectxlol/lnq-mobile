import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/create_order_request.dart';
import '../services/api_service.dart';
import '../providers/settings_provider.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/animated_widgets.dart';
import '../components/edit_order_screen.dart';
import '../components/info_row.dart';
import '../components/order_item_row.dart';
import '../theme/app_theme.dart';
import '../l10n/strings.dart';
import '../utils/currency_utils.dart';

// Removed local formatIdr, using centralized version from utils/currency_utils.dart

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
    final baseUrl = context.read<SettingsProvider>().baseUrl;
    final apiService = ApiService(baseUrl);
    setState(() {
      _orderFuture = apiService.getOrder(widget.orderId);
    });
  }

  Future<void> _printOrder() async {
    final settings = context.read<SettingsProvider>();
    
    setState(() {
      _isPrinting = true;
    });

    try {
      final baseUrl = settings.baseUrl;
      final apiService = ApiService(baseUrl);
      await apiService.printOrder(widget.orderId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.tr(context, 'orderSentToPrinter')),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.tr(context, 'failedToPrint')}: $e'),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPrinting = false;
        });
      }
    }
  }

  Future<void> _deleteOrder() async {
    final settings = context.read<SettingsProvider>();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.tr(context, 'deleteOrder')),
        content: Text(AppStrings.tr(context, 'deleteOrderConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.tr(context, 'cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.destructive,
            ),
            child: Text(AppStrings.tr(context, 'delete')),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final baseUrl = settings.baseUrl;
      final apiService = ApiService(baseUrl);
      await apiService.deleteOrder(widget.orderId);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.tr(context, 'failedToDelete')}: $e'),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    }
  }

  Future<void> _editOrder(Order order) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => EditOrderScreen(order: order)),
    );

    if (result != null && mounted) {
      final settings = context.read<SettingsProvider>();
      
      try {
        final baseUrl = settings.baseUrl;
        final apiService = ApiService(baseUrl);

        await apiService.updateOrder(
          widget.orderId,
          customerName: result['customerName'],
          pickupDate: result['pickupDate'],
          notes: result['notes'],
          items: result['items'],
        );

        _loadOrder();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.tr(context, 'orderUpdatedSuccessfully')),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${AppStrings.tr(context, 'failedToUpdateOrder')}: $e',
              ),
              backgroundColor: AppColors.destructive,
            ),
          );
        }
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
            onPressed: () async {
              final order = await _orderFuture;
              _editOrder(order);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Add your main content here. For example:
          // Order details, list of items, etc.
          // The following is an example placeholder:
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              AppStrings.trWatch(context, 'tapAddItem'),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderItemData {
  final int productId;
  final int amount;
  final String? notes;
  final Product? product;
  final int? priceAtSale;

  _OrderItemData({
    required this.productId,
    required this.amount,
    this.notes,
    this.product,
    this.priceAtSale,
  });
}
