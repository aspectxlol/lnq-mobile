import 'info_row.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/create_order_request.dart' as create_order;
import '../services/api_service.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/currency_utils.dart';
import '../l10n/strings.dart';
import '../widgets/note_container.dart';

class EditOrderScreen extends StatefulWidget {
  final Order order;
  const EditOrderScreen({Key? key, required this.order}) : super(key: key);

  @override
  State<EditOrderScreen> createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen> {
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
    _customerNameController = TextEditingController(text: widget.order.customerName);
    _notesController = TextEditingController(text: widget.order.notes ?? '');
    _pickupDate = widget.order.pickupDate;
    for (final item in widget.order.items) {
      if (item is ProductOrderItem) {
        _items[item.productId] = _OrderItemData.product(
          productId: item.productId,
          amount: item.amount,
          notes: item.notes,
          product: item.product,
          priceAtSale: item.priceAtSale,
        );
      } else if (item is CustomOrderItem) {
        // Use a unique negative key for custom items
        final customId = -item.hashCode;
        _items[customId] = _OrderItemData.custom(
          customName: item.customName,
          customPrice: item.customPrice,
          notes: item.notes,
        );
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('editOrderTitle')),
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
                    const Icon(Icons.error_outline, size: 80, color: AppColors.destructive),
                    const SizedBox(height: 24),
                    Text(AppStrings.get('failedToLoadProducts'), style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 12),
                    Text(
                      snapshot.error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mutedForeground),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _loadProducts,
                      child: Text(AppStrings.get('retry')),
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
                            labelText: AppStrings.get('customerName'),
                            hintText: AppStrings.get('enterCustomerName'),
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.get('pleaseEnterCustomerName');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _pickupDate ?? DateTime.now().add(const Duration(days: 1)),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
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
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: AppStrings.get('pickupDateOptional'),
                              prefixIcon: const Icon(Icons.calendar_today),
                              suffixIcon: const Icon(Icons.arrow_forward_ios, size: 16),
                            ),
                            child: Text(
                              _pickupDate != null
                                  ? DateFormat('MMM dd, yyyy').format(_pickupDate!)
                                  : AppStrings.get('noPickupDateSet'),
                              style: TextStyle(
                                color: _pickupDate != null ? AppColors.foreground : AppColors.mutedForeground,
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
                              child: Text(AppStrings.get('clearPickupDate')),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        TextField(
                          controller: _notesController,
                          decoration: InputDecoration(
                            labelText: AppStrings.get('orderNotesOptional'),
                            hintText: AppStrings.get('orderNotesHint'),
                            prefixIcon: const Icon(Icons.note_outlined),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppStrings.get('orderItems'), style: Theme.of(context).textTheme.titleLarge),
                            TextButton.icon(
                              onPressed: () {
                                // TODO: Implement add item dialog
                              },
                              icon: const Icon(Icons.add),
                              label: Text(AppStrings.get('addItem')),
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
                                    Icon(Icons.shopping_cart_outlined, size: 48, color: AppColors.mutedForeground),
                                    const SizedBox(height: 16),
                                    Text(AppStrings.get('noItemsAdded'), style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.mutedForeground)),
                                    const SizedBox(height: 8),
                                    Text(AppStrings.get('tapAddItem'), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mutedForeground)),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          ..._items.entries.map((entry) {
                            final item = entry.value;
                            final product = item.product ?? products.firstWhere(
                              (p) => p.id == item.productId,
                              orElse: () => Product(
                                id: item.productId ?? 0,
                                name: 'Product #${item.productId ?? 0}',
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
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.shopping_bag, color: AppColors.mutedForeground),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(product.name, style: Theme.of(context).textTheme.titleMedium),
                                              const SizedBox(height: 4),
                                              Text(
                                                formatIdr(item.priceAtSale ?? 0) + ' × ${item.amount}',
                                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            // TODO: Implement edit item dialog
                                          },
                                          icon: const Icon(Icons.edit_outlined),
                                          color: AppColors.primary,
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _items.remove(entry.key);
                                            });
                                          },
                                          icon: const Icon(Icons.delete_outline),
                                          color: AppColors.destructive,
                                        ),
                                      ],
                                    ),
                                    if (item.notes != null && item.notes!.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      NoteContainer(note: item.notes!),
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
                            InfoRow(
                              label: AppStrings.get('total'),
                              value: formatIdr(_items.values.fold(0, (sum, item) => sum + ((item.priceAtSale ?? item.product?.priceAtSale ?? item.product?.price ?? 0) * item.amount))),
                              valueColor: AppColors.primary,
                            ),
                            ElevatedButton.icon(
                              onPressed: _isSaving ? null : () {
                                if (!_formKey.currentState!.validate()) return;
                                if (_items.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(AppStrings.get('pleaseAddAtLeastOneItem')),
                                      backgroundColor: AppColors.destructive,
                                    ),
                                  );
                                  return;
                                }
                                setState(() {
                                  _isSaving = true;
                                });
                                try {
                                  final items = _items.values.map((item) {
                                    if (item.isCustom) {
                                      return create_order.CustomOrderItem(
                                        customName: item.customName ?? '',
                                        customPrice: item.customPrice ?? 0,
                                        notes: item.notes,
                                      );
                                    } else {
                                      return create_order.ProductOrderItem(
                                        productId: item.productId!,
                                        amount: item.amount,
                                        notes: item.notes,
                                        priceAtSale: item.priceAtSale ?? item.product?.priceAtSale ?? item.product?.price,
                                      );
                                    }
                                  }).toList();
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
                              },
                              icon: _isSaving
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryForeground))
                                  : const Icon(Icons.check),
                              label: Text(_isSaving ? AppStrings.get('saving') : AppStrings.get('saveChanges')),
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
  final bool isCustom;
  final int? productId;
  final int amount;
  final String? notes;
  final Product? product;
  final int? priceAtSale;
  final String? customName;
  final int? customPrice;
  _OrderItemData.product({
    required this.productId,
    required this.amount,
    this.notes,
    this.product,
    this.priceAtSale,
  })  : isCustom = false,
        customName = null,
        customPrice = null;

  _OrderItemData.custom({
    required this.customName,
    required this.customPrice,
    this.notes,
  })  : isCustom = true,
        productId = null,
        amount = 1,
        product = null,
        priceAtSale = null;
}
