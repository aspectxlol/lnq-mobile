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
import '../theme/app_theme.dart';
import '../l10n/strings.dart';

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
      MaterialPageRoute(builder: (context) => _EditOrderScreen(order: order)),
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
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteOrder,
          ),
        ],
      ),
      body: FutureBuilder<Order>(
        future: _orderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildSkeleton();
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 80,
                      color: AppColors.destructive,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppStrings.trWatch(context, 'loadingOrderFailed'),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      snapshot.error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppStrings.trWatch(context, 'goBack')),
                    ),
                  ],
                ),
              ),
            );
          }

          final order = snapshot.data!;
          return _buildContent(order);
        },
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SkeletonLoader(width: 200, height: 32),
        const SizedBox(height: 8),
        const SkeletonLoader(width: 120, height: 20),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                for (int i = 0; i < 3; i++) ...[
                  if (i > 0) const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      SkeletonLoader(width: 100, height: 16),
                      SkeletonLoader(width: 80, height: 16),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(Order order) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: FadeInSlide(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.customerName,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Order #${order.id}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.trWatch(context, 'orderInformation'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                      label: AppStrings.trWatch(context, 'status'),
                      value: order.pickupDate != null
                          ? AppStrings.trWatch(context, 'scheduled')
                          : AppStrings.trWatch(context, 'newStatus'),
                      valueColor: order.pickupDate != null
                          ? AppColors.success
                          : null,
                    ),
                    const Divider(height: 24),
                    _InfoRow(
                      label: AppStrings.trWatch(context, 'created'),
                      value: _formatDateTime(order.createdAt),
                    ),
                    if (order.notes != null && order.notes!.isNotEmpty) ...[
                      const Divider(height: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.trWatch(context, 'orderNotes'),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.mutedForeground),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.notes!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                    if (order.pickupDate != null) ...[
                      const Divider(height: 24),
                      _InfoRow(
                        label: AppStrings.trWatch(context, 'pickupDate'),
                        value: _formatDate(order.pickupDate!),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.trWatch(context, 'orderItems'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ...order.items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return Column(
                        children: [
                          if (index > 0) const Divider(height: 24),
                          _OrderItemRow(item: item),
                        ],
                      );
                    }),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.trWatch(context, 'total'),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          order.formattedTotal,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isPrinting ? null : _printOrder,
                icon: _isPrinting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryForeground,
                        ),
                      )
                    : const Icon(Icons.print),
                label: Text(_isPrinting ? AppStrings.trWatch(context, 'printing') : AppStrings.trWatch(context, 'printOrder')),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _deleteOrder,
                icon: const Icon(Icons.delete_outline),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.destructive,
                  side: const BorderSide(color: AppColors.destructive),
                ),
                label: Text(AppStrings.trWatch(context, 'deleteOrder')),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy • HH:mm').format(date);
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedForeground),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final OrderItem item;

  const _OrderItemRow({required this.item});

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
                  Text(
                    item.product?.name ?? 'Product #${item.productId}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (item.product != null)
                    Text(
                      item.product!.formattedPrice,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              'Rp ${(item.totalPrice / 1000).toStringAsFixed(0)}.000',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        if (item.notes != null && item.notes!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.note_outlined,
                  size: 16,
                  color: AppColors.mutedForeground,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.notes!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.foreground,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _EditOrderScreen extends StatefulWidget {
  final Order order;

  const _EditOrderScreen({required this.order});

  @override
  State<_EditOrderScreen> createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<_EditOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _customerNameController;
  late TextEditingController _notesController;
  final Map<int, _OrderItemData> _items = {};
  DateTime? _pickupDate;
  late Future<List<Product>> _productsFuture;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _customerNameController = TextEditingController(
      text: widget.order.customerName,
    );
    _notesController = TextEditingController(text: widget.order.notes ?? '');
    _pickupDate = widget.order.pickupDate;
    
    // Initialize items from existing order
    for (final item in widget.order.items) {
      _items[item.productId] = _OrderItemData(
        productId: item.productId,
        amount: item.amount,
        notes: item.notes,
        product: item.product,
      );
    }

    _loadProducts();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadProducts() {
    final baseUrl = context.read<SettingsProvider>().baseUrl;
    final apiService = ApiService(baseUrl);
    setState(() {
      _productsFuture = apiService.getProducts();
    });
  }

  Future<void> _selectPickupDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _pickupDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.primaryForeground,
              surface: AppColors.card,
              onSurface: AppColors.foreground,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null && mounted) {
      setState(() {
        _pickupDate = DateTime(date.year, date.month, date.day);
      });
    }
  }

  void _showAddProductDialog(List<Product> products) {
    final availableProducts = products
        .where((p) => !_items.containsKey(p.id))
        .toList();

    if (availableProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.tr(context, 'allProductsAdded')),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    Product? selectedProduct;
    int quantity = 1;
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(AppStrings.tr(context, 'addProduct')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<Product>(
                  value: selectedProduct,
                  decoration: InputDecoration(
                    labelText: AppStrings.tr(context, 'selectProduct'),
                    prefixIcon: const Icon(Icons.shopping_bag),
                  ),
                  isExpanded: true,
                  items: availableProducts
                      .map(
                        (product) => DropdownMenuItem(
                          value: product,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  product.name,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                product.formattedPrice,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (product) {
                    setDialogState(() {
                      selectedProduct = product;
                    });
                  },
                ),
                const SizedBox(height: 24),
                if (selectedProduct != null) ...[
                  Text(
                    AppStrings.tr(context, 'quantity'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: quantity > 1
                            ? () {
                                setDialogState(() {
                                  quantity--;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.remove_circle),
                        color: AppColors.destructive,
                        iconSize: 32,
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            '$quantity',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: AppColors.primaryForeground,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: () {
                          setDialogState(() {
                            quantity++;
                          });
                        },
                        icon: const Icon(Icons.add_circle),
                        color: AppColors.primary,
                        iconSize: 32,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    decoration: InputDecoration(
                      labelText: AppStrings.tr(context, 'itemNotesOptional'),
                      hintText: AppStrings.tr(context, 'itemNotesHint'),
                      prefixIcon: const Icon(Icons.note_outlined),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${AppStrings.tr(context, 'subtotal')}:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Rp ${((selectedProduct!.price * quantity) / 1000).toStringAsFixed(0)}.000',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.tr(context, 'cancel')),
            ),
            ElevatedButton(
              onPressed: selectedProduct != null
                  ? () {
                      setState(() {
                        _items[selectedProduct!.id] = _OrderItemData(
                          productId: selectedProduct!.id,
                          amount: quantity,
                          notes: notesController.text.isEmpty
                              ? null
                              : notesController.text,
                          product: selectedProduct,
                        );
                      });
                      Navigator.pop(context);
                    }
                  : null,
              child: Text(AppStrings.tr(context, 'add')),
            ),
          ],
        ),
      ),
    );
  }

  void _editItem(int productId, Product product) {
    final item = _items[productId]!;
    int quantity = item.amount;
    final notesController = TextEditingController(text: item.notes ?? '');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit ${product.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.tr(context, 'quantity'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: quantity > 1
                          ? () {
                              setDialogState(() {
                                quantity--;
                              });
                            }
                          : null,
                      icon: const Icon(Icons.remove_circle),
                      color: AppColors.destructive,
                      iconSize: 32,
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          '$quantity',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: AppColors.primaryForeground,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: () {
                        setDialogState(() {
                          quantity++;
                        });
                      },
                      icon: const Icon(Icons.add_circle),
                      color: AppColors.primary,
                      iconSize: 32,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(
                    labelText: AppStrings.tr(context, 'itemNotesOptional'),
                    hintText: AppStrings.tr(context, 'itemNotesHint'),
                    prefixIcon: const Icon(Icons.note_outlined),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${AppStrings.tr(context, 'subtotal')}:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Rp ${((product.price * quantity) / 1000).toStringAsFixed(0)}.000',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.tr(context, 'cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _items[productId] = _OrderItemData(
                    productId: productId,
                    amount: quantity,
                    notes: notesController.text.isEmpty
                        ? null
                        : notesController.text,
                    product: product,
                  );
                });
                Navigator.pop(context);
              },
              child: Text(AppStrings.tr(context, 'save')),
            ),
          ],
        ),
      ),
    );
  }

  void _removeItem(int productId) {
    setState(() {
      _items.remove(productId);
    });
  }

  int _calculateTotal() {
    int total = 0;
    for (final item in _items.values) {
      if (item.product != null) {
        total += item.product!.price * item.amount;
      }
    }
    return total;
  }

  Future<void> _saveOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.tr(context, 'pleaseAddAtLeastOneItem')),
          backgroundColor: AppColors.destructive,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final items = _items.values
          .map(
            (item) => CreateOrderItem(
              productId: item.productId,
              amount: item.amount,
              notes: item.notes,
            ),
          )
          .toList();

      Navigator.pop(context, {
        'customerName': _customerNameController.text,
        'pickupDate': _pickupDate,
        'notes': _notesController.text.isEmpty ? null : _notesController.text,
        'items': items,
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<SettingsProvider>();
    
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.trWatch(context, 'editOrder')),
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 80,
                      color: AppColors.destructive,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppStrings.trWatch(context, 'failedToLoadProducts'),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      snapshot.error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _loadProducts,
                      child: Text(AppStrings.trWatch(context, 'retry')),
                    ),
                  ],
                ),
              ),
            );
          }

          final products = snapshot.data ?? [];

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _customerNameController,
                          decoration: InputDecoration(
                            labelText: AppStrings.trWatch(context, 'customerName'),
                            hintText: AppStrings.trWatch(context, 'enterCustomerName'),
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.trWatch(context, 'pleaseEnterCustomerName');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        InkWell(
                          onTap: _selectPickupDate,
                          borderRadius: BorderRadius.circular(8),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: AppStrings.trWatch(context, 'pickupDateOptional'),
                              prefixIcon: const Icon(Icons.calendar_today),
                              suffixIcon: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                            ),
                            child: Text(
                              _pickupDate != null
                                  ? DateFormat(
                                      'MMM dd, yyyy',
                                    ).format(_pickupDate!)
                                  : AppStrings.trWatch(context, 'noPickupDateSet'),
                              style: TextStyle(
                                color: _pickupDate != null
                                    ? AppColors.foreground
                                    : AppColors.mutedForeground,
                              ),
                            ),
                          ),
                        ),
                        if (_pickupDate != null) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _pickupDate = null;
                                });
                              },
                              child: Text(AppStrings.trWatch(context, 'clearPickupDate')),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        TextField(
                          controller: _notesController,
                          decoration: InputDecoration(
                            labelText: AppStrings.trWatch(context, 'orderNotesOptional'),
                            hintText: AppStrings.trWatch(context, 'orderNotesHint'),
                            prefixIcon: const Icon(Icons.note_outlined),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppStrings.trWatch(context, 'orderItems'),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            TextButton.icon(
                              onPressed: () => _showAddProductDialog(products),
                              icon: const Icon(Icons.add),
                              label: Text(AppStrings.trWatch(context, 'addItem')),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_items.isEmpty)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.shopping_cart_outlined,
                                      size: 48,
                                      color: AppColors.mutedForeground,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      AppStrings.trWatch(context, 'noItemsAdded'),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: AppColors.mutedForeground,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      AppStrings.trWatch(context, 'tapAddItem'),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.mutedForeground,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          ..._items.entries.map((entry) {
                            final item = entry.value;
                            final product =
                                item.product ??
                                products.firstWhere(
                                  (p) => p.id == item.productId,
                                  orElse: () => Product(
                                    id: item.productId,
                                    name: 'Product #${item.productId}',
                                    price: 0,
                                    createdAt: DateTime.now(),
                                  ),
                                );

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: AppColors.accent,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.shopping_bag,
                                            color: AppColors.mutedForeground,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product.name,
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.titleMedium,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${product.formattedPrice} × ${item.amount}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: AppColors.primary,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () =>
                                              _editItem(entry.key, product),
                                          icon: const Icon(Icons.edit_outlined),
                                          color: AppColors.primary,
                                        ),
                                        IconButton(
                                          onPressed: () =>
                                              _removeItem(entry.key),
                                          icon: const Icon(
                                            Icons.delete_outline,
                                          ),
                                          color: AppColors.destructive,
                                        ),
                                      ],
                                    ),
                                    if (item.notes != null &&
                                        item.notes!.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.accent,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.note_outlined,
                                              size: 16,
                                              color: AppColors.mutedForeground,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                item.notes!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color:
                                                          AppColors.foreground,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
              ),
              if (_items.isNotEmpty)
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.card,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.trWatch(context, 'total'),
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppColors.mutedForeground,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rp ${(_calculateTotal() / 1000).toStringAsFixed(0)}.000',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: _isSaving ? null : _saveOrder,
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primaryForeground,
                                      ),
                                    )
                                  : const Icon(Icons.check),
                              label: Text(
                                _isSaving ? AppStrings.trWatch(context, 'saving') : AppStrings.trWatch(context, 'saveChanges'),
                              ),
                            ),
                          ],
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

class _OrderItemData {
  final int productId;
  final int amount;
  final String? notes;
  final Product? product;

  _OrderItemData({
    required this.productId,
    required this.amount,
    this.notes,
    this.product,
  });
}
