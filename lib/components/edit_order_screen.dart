import '../screens/order_detail_screen.dart';
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
import 'dart:ui';

// Move _OrderItemData definition to the top so it is available for type checks
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
  String? _errorMessage;

  Future<_OrderItemData?> _showEditItemDialog(
    BuildContext context, {
    required List<Product> products,
    _OrderItemData? item,
  }) async {
    final isCustom = item?.isCustom ?? false;
    final TextEditingController nameController = TextEditingController(
      text: isCustom ? item?.customName : null,
    );
    final TextEditingController priceController = TextEditingController(
      text: isCustom ? (item?.customPrice?.toString() ?? '') : null,
    );
    final TextEditingController notesController = TextEditingController(
      text: item?.notes ?? '',
    );
    int? selectedProductId = !isCustom ? item?.productId : null;
    int amount = !isCustom ? (item?.amount ?? 1) : 1;
    final TextEditingController priceAtSaleController = TextEditingController(
      text: !isCustom && (item?.priceAtSale != null)
        ? item!.priceAtSale.toString()
        : '',
    );
    String formattedPriceAtSale = priceAtSaleController.text.isNotEmpty
      ? formatIdr(int.tryParse(priceAtSaleController.text) ?? 0)
      : '';
    return await showDialog<_OrderItemData>(
      context: context,
      builder: (context) {
        bool custom = isCustom;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                custom
                    ? AppStrings.trWatch(context, 'editCustomItem')
                    : AppStrings.trWatch(context, 'editProductItem'),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        ChoiceChip(
                          label: Text(AppStrings.trWatch(context, 'product')),
                          selected: !custom,
                          onSelected: (v) => setState(() => custom = !v),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text(AppStrings.trWatch(context, 'custom')),
                          selected: custom,
                          onSelected: (v) => setState(() => custom = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (!custom) ...[
                      DropdownButtonFormField<int>(
                        value: selectedProductId,
                        items: products
                            .map(
                              (p) => DropdownMenuItem(
                                value: p.id,
                                child: Text(p.name),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => selectedProductId = v),
                        decoration: InputDecoration(
                          labelText: AppStrings.trWatch(context, 'product'),
                        ),
                        validator: (v) => v == null ? AppStrings.trWatch(context, 'selectProduct') : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: amount.toString(),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: AppStrings.trWatch(context, 'amount'),
                        ),
                        onChanged: (v) => amount = int.tryParse(v) ?? 1,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: priceAtSaleController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: AppStrings.trWatch(context, 'priceAtSaleOptional'),
                          prefixText: 'Rp ',
                          helperText: formattedPriceAtSale.isNotEmpty ? formattedPriceAtSale : null,
                        ),
                        onChanged: (v) {
                          setState(() {
                            final value = int.tryParse(v) ?? 0;
                            formattedPriceAtSale = v.isNotEmpty ? formatIdr(value) : '';
                          });
                        },
                      ),
                    ] else ...[
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: AppStrings.trWatch(context, 'customName'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: AppStrings.trWatch(context, 'customPrice'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: notesController,
                      decoration: InputDecoration(
                        labelText: AppStrings.trWatch(context, 'notes'),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppStrings.trWatch(context, 'cancel')),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (custom) {
                      final name = nameController.text.trim();
                      final price = int.tryParse(
                        priceController.text.trim() ?? '',
                      );
                      if (name.isEmpty || price == null) return;
                      Navigator.pop(
                        context,
                        _OrderItemData.custom(
                          customName: name,
                          customPrice: price,
                          notes: notesController.text.trim(),
                        ),
                      );
                    } else {
                      if (selectedProductId == null) return;
                      final product = products.firstWhere(
                        (p) => p.id == selectedProductId,
                      );
                      final priceAtSale = int.tryParse(
                        priceAtSaleController.text.trim(),
                      );
                      Navigator.pop(
                        context,
                        _OrderItemData.product(
                          productId: selectedProductId!,
                          amount: amount,
                          notes: notesController.text.trim(),
                          product: product,
                          priceAtSale: priceAtSale ?? product.price,
                        ),
                      );
                    }
                  },
                  child: Text(AppStrings.trWatch(context, 'save')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _customerNameController = TextEditingController(
      text: widget.order.customerName,
    );
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
      appBar: AppBar(title: Text(AppStrings.tr(context, 'editOrderTitle'))),
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
                      AppStrings.tr(context, 'failedToLoadProducts'),
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
                      child: Text(AppStrings.tr(context, 'retry')),
                    ),
                  ],
                ),
              ),
            );
          }
          final products = snapshot.data ?? [];
          final total = _items.values.fold(
            0,
            (sum, item) =>
                sum +
                ((item.priceAtSale ??
                        item.product?.priceAtSale ??
                        item.product?.price ??
                        0) *
                    item.amount),
          );
          return Form(
            key: _formKey,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          // Glassmorphism background
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withOpacity(0.10),
                                  AppColors.primary.withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.18),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                              child: Container(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.sticky_note_2_outlined, color: AppColors.primary, size: 28),
                                    const SizedBox(width: 8),
                                    Text(AppStrings.get('editOrderTitle'), style: Theme.of(context).textTheme.titleLarge),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                TextFormField(
                                  controller: _customerNameController,
                                  decoration: InputDecoration(
                                    labelText: AppStrings.tr(context, 'customerName'),
                                  ),
                                  validator: (v) => v == null || v.trim().isEmpty ? AppStrings.tr(context, 'enterCustomerName') : null,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _notesController,
                                  decoration: InputDecoration(
                                    labelText: AppStrings.tr(context, 'notes'),
                                  ),
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 16),
                                Text(AppStrings.tr(context, 'orderItems'), style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 8),
                                ..._items.entries.map((entry) {
                                  final item = entry.value;
                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    child: ListTile(
                                      title: Text(item.isCustom ? item.customName ?? '' : item.product?.name ?? ''),
                                      subtitle: Text(item.isCustom
                                          ? '${AppStrings.tr(context, 'customPrice')}: ${formatIdr(item.customPrice ?? 0)}'
                                          : '${AppStrings.tr(context, 'amount')}: ${item.amount}  |  ${AppStrings.tr(context, 'priceAtSaleOptional')}: ${formatIdr(item.priceAtSale ?? item.product?.price ?? 0)}'),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () async {
                                              final edited = await _showEditItemDialog(context, products: products, item: item);
                                              if (edited != null) {
                                                setState(() {
                                                  _items[entry.key] = edited;
                                                });
                                              }
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () {
                                              setState(() {
                                                _items.remove(entry.key);
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.add),
                                      label: Text(AppStrings.tr(context, 'addItem')),
                                      onPressed: () async {
                                        final newItem = await _showEditItemDialog(context, products: products);
                                        if (newItem != null) {
                                          setState(() {
                                            // Use a unique key for custom items
                                            final key = newItem.isCustom ? DateTime.now().millisecondsSinceEpoch * -1 : newItem.productId!;
                                            _items[key] = newItem;
                                          });
                                        }
                                      },
                                    ),
                                    const Spacer(),
                                    Text('${AppStrings.tr(context, 'total')}: ${formatIdr(total)}', style: Theme.of(context).textTheme.titleMedium),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isSaving
                                        ? null
                                        : () async {
                                            if (!_formKey.currentState!.validate()) return;
                                            setState(() => _isSaving = true);
                                            // TODO: Implement save logic here
                                            setState(() => _isSaving = false);
                                          },
                                    child: _isSaving
                                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                        : Text(AppStrings.tr(context, 'save')),
                                  ),
                                ),
                                if (_errorMessage != null) ...[
                                  const SizedBox(height: 12),
                                  Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
