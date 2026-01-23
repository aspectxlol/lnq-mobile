import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/order_item_data.dart';
import '../models/create_order_request.dart' as create_order;
import '../theme/app_theme.dart';
import '../utils/currency_utils.dart';
import '../utils/data_loader_extension.dart';
import '../l10n/strings.dart';
import 'price_input.dart';

class EditOrderScreen extends StatefulWidget {
  final Order order;
  const EditOrderScreen({super.key, required this.order});

  @override
  State<EditOrderScreen> createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _customerNameController;
  late TextEditingController _notesController;
  final Map<int, OrderItemData> _items = {};
  // DateTime? _pickupDate; // Removed unused field
  late Future<List<Product>> _productsFuture;
  bool _isSaving = false;
  String? _errorMessage;

  Future<OrderItemData?> _showEditItemDialog(
    BuildContext context, {
    required List<Product> products,
    OrderItemData? item,
  }) async {
    final isCustom = item?.isCustom ?? false;
    final TextEditingController nameController = TextEditingController(
      text: isCustom ? item?.customName ?? '' : '',
    );
    final TextEditingController priceController = TextEditingController(
      text: isCustom ? (item?.customPrice?.toString() ?? '') : '',
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
    if (!mounted) return null;
    return await showDialog<OrderItemData>(
      context: context,
      builder: (dialogContext) {
        bool custom = isCustom;
        return StatefulBuilder(
          builder: (statefulContext, setState) {
            return AlertDialog(
              title: Text(
                custom
                    ? AppStrings.trWatch(statefulContext, 'editCustomItem')
                    : AppStrings.trWatch(statefulContext, 'editProductItem'),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        ChoiceChip(
                          label: Text(AppStrings.trWatch(statefulContext, 'product')),
                          selected: !custom,
                          onSelected: (v) => setState(() => custom = !v),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text(AppStrings.trWatch(statefulContext, 'custom')),
                          selected: custom,
                          onSelected: (v) => setState(() => custom = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (!custom) ...[
                      DropdownButtonFormField<int>(
                        initialValue: selectedProductId,
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
                          labelText: AppStrings.trWatch(statefulContext, 'product'),
                        ),
                        validator: (v) => v == null ? AppStrings.trWatch(statefulContext, 'selectProduct') : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: amount.toString(),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: AppStrings.trWatch(statefulContext, 'amount'),
                        ),
                        onChanged: (v) => amount = int.tryParse(v) ?? 1,
                      ),
                      const SizedBox(height: 8),
                      PriceInput(
                        controller: priceAtSaleController,
                        labelText: AppStrings.trWatch(statefulContext, 'priceAtSaleOptional'),
                        prefixText: 'Rp ',
                      ),
                    ] else ...[
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: AppStrings.trWatch(statefulContext, 'customName'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      PriceInput(
                        controller: priceController,
                        labelText: AppStrings.trWatch(statefulContext, 'customPrice'),
                        prefixText: 'Rp ',
                      ),
                    ],
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: notesController,
                      decoration: InputDecoration(
                        labelText: AppStrings.trWatch(statefulContext, 'notes'),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: Text(AppStrings.trWatch(statefulContext, 'cancel')),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (custom) {
                      final name = nameController.text.trim();
                      // Remove non-digit characters from formatted price
                      final priceText = priceController.text.replaceAll(RegExp(r'[^0-9]'), '');
                      final price = priceText.isEmpty ? null : int.tryParse(priceText);
                      if (name.isEmpty || price == null) return;
                      Navigator.pop(
                        dialogContext,
                        OrderItemData.custom(
                          customName: name,
                          customPrice: price,
                          notes: notesController.text.trim(),
                        ),
                      );
                    } else {
                      if (selectedProductId == null) return;
                      final product = products.firstWhereOrNull(
                        (p) => p.id == selectedProductId,
                      );
                      if (product == null) return;
                      // Remove non-digit characters from formatted price
                      final priceAtSaleText = priceAtSaleController.text.replaceAll(RegExp(r'[^0-9]'), '');
                      final priceAtSale = priceAtSaleText.isNotEmpty ? int.tryParse(priceAtSaleText) : null;
                      Navigator.pop(
                        dialogContext,
                        OrderItemData.product(
                          productId: selectedProductId!,
                          amount: amount,
                          notes: notesController.text.trim(),
                          product: product,
                          priceAtSale: priceAtSale ?? product.price,
                        ),
                      );
                    }
                  },
                  child: Text(AppStrings.trWatch(statefulContext, 'save')),
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
    for (final item in widget.order.items) {
      if (item is ProductOrderItem) {
        _items[item.productId] = OrderItemData.product(
          productId: item.productId,
          amount: item.amount,
          notes: item.notes,
          product: item.product,
          priceAtSale: item.priceAtSale,
        );
      } else if (item is create_order.CustomOrderItem) {
        // Use a unique negative key for custom items
        final customId = -item.hashCode;
        _items[customId] = OrderItemData.custom(
          customName: (item as create_order.CustomOrderItem).customName,
          customPrice: (item as create_order.CustomOrderItem).customPrice,
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
    setState(() {
      _productsFuture = getApiService().getProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.tr(context, 'editOrderTitle')),
        elevation: 0,
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
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: AppColors.border, width: 1.5),
                      ),
                      color: AppColors.card,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              children: [
                                Icon(Icons.edit_outlined, color: AppColors.primary, size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    AppStrings.tr(context, 'editOrderTitle'),
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Customer Name Field
                            TextFormField(
                              controller: _customerNameController,
                              decoration: InputDecoration(
                                labelText: AppStrings.tr(context, 'customerName'),
                                prefixIcon: const Icon(Icons.person_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.transparent,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: AppColors.border, width: 1.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                                ),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? AppStrings.tr(context, 'enterCustomerName') : null,
                            ),
                            const SizedBox(height: 16),
                            // Notes Field
                            TextFormField(
                              controller: _notesController,
                              decoration: InputDecoration(
                                labelText: AppStrings.tr(context, 'notes'),
                                prefixIcon: const Icon(Icons.note_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.transparent,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: AppColors.border, width: 1.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                                ),
                              ),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Items Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: Row(
                      children: [
                        Icon(Icons.shopping_cart_outlined, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.tr(context, 'orderItems'),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_items.length}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Items List
                _items.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 64,
                                  color: AppColors.mutedForeground,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  AppStrings.tr(context, 'noItemsAdded'),
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final entry = _items.entries.toList()[index];
                              final item = entry.value;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: AppColors.border, width: 1),
                                  ),
                                  color: AppColors.card,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    leading: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${item.amount}x',
                                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      item.isCustom ? item.customName ?? '' : item.product?.name ?? '',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    subtitle: Text(
                                      item.isCustom
                                          ? '${AppStrings.tr(context, 'customPrice')}: ${formatIdr(item.customPrice ?? 0)}'
                                          : '${AppStrings.tr(context, 'priceAtSaleOptional')}: ${formatIdr(item.priceAtSale ?? item.product?.price ?? 0)}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.mutedForeground,
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined),
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
                                          icon: const Icon(Icons.delete_outline),
                                          onPressed: () {
                                            setState(() {
                                              _items.remove(entry.key);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: _items.length,
                          ),
                        ),
                      ),
                // Add Item Button
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: Text(AppStrings.tr(context, 'addItem')),
                      onPressed: () async {
                        final newItem = await _showEditItemDialog(context, products: products);
                        if (newItem != null) {
                          setState(() {
                            final key = newItem.isCustom ? DateTime.now().millisecondsSinceEpoch * -1 : newItem.productId!;
                            _items[key] = newItem;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                // Total Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: AppColors.primary.withValues(alpha: 0.08),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppStrings.tr(context, 'totalAmount'),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              formatIdr(total),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Error Message
                if (_errorMessage != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Card(
                        elevation: 0,
                        color: AppColors.destructive.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppColors.destructive, width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: AppColors.destructive),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(color: AppColors.destructive),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                // Save Button
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : () async {
                        if (!_formKey.currentState!.validate()) return;
                        if (_items.isEmpty) {
                          setState(() {
                            _errorMessage = AppStrings.tr(context, 'pleaseAddAtLeastOneItem');
                          });
                          return;
                        }

                        setState(() {
                          _isSaving = true;
                          _errorMessage = null;
                        });

                        try {
                          final items = <create_order.CreateOrderItem>[];
                          for (final item in _items.values) {
                            if (item.isCustom) {
                              items.add(
                                create_order.CustomOrderItem(
                                  customName: item.customName ?? '',
                                  customPrice: item.customPrice ?? 0,
                                  notes: item.notes,
                                ),
                              );
                            } else {
                              items.add(
                                create_order.ProductOrderItem(
                                  productId: item.productId ?? 0,
                                  amount: item.amount,
                                  notes: item.notes,
                                  priceAtSale: item.priceAtSale,
                                ),
                              );
                            }
                          }

                          final navigator = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);
                          final successMessage = AppStrings.tr(context, 'orderUpdatedSuccessfully');

                          await getApiService().updateOrder(
                            widget.order.id,
                            customerName: _customerNameController.text.trim(),
                            notes: _notesController.text.trim().isEmpty
                                ? null
                                : _notesController.text.trim(),
                            items: items,
                          );

                          if (mounted) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(successMessage),
                                backgroundColor: AppColors.success,
                              ),
                            );
                            navigator.pop({
                              'customerName': _customerNameController.text.trim(),
                              'pickupDate': null, // Add pickup date if editing is supported
                              'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
                              'items': items,
                            });
                          }
                        } catch (e) {
                          if (mounted) {
                            setState(() {
                              _errorMessage = e.toString();
                            });
                          }
                        } finally {
                          if (mounted) {
                            setState(() => _isSaving = false);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              AppStrings.tr(context, 'save'),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                    ),
                  ),
                ),
                // Bottom Padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 16),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
