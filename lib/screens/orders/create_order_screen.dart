import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/product.dart';
import '../../models/create_order_request.dart';
import '../../models/order_item_data.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/animated_widgets.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_animations.dart';
import '../../components/dialogs/add_product_dialog.dart';
import '../../components/dialogs/add_custom_item_dialog.dart';
import '../../components/quantity_selector.dart';
import '../../widgets/labeled_value_row.dart';
import '../../widgets/note_container.dart';
import '../../l10n/strings.dart';
import '../../utils/data_loader_extension.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _orderNotesController = TextEditingController();
  late Future<List<Product>> _productsFuture;

  DateTime? _pickupDate;
  final List<OrderItemData> _orderItems = [];
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    setState(() {
      _productsFuture = getApiService().getProducts();
    });
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _orderNotesController.dispose();
    super.dispose();
  }

  Future<void> _selectPickupDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
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

  void _incrementProduct(int productId) {
    setState(() {
      final item = _orderItems.firstWhere((item) => item.productId == productId);
      item.amount++;
    });
  }

  void _decrementProduct(int productId) {
    setState(() {
      final item = _orderItems.firstWhere((item) => item.productId == productId);
      if (item.amount > 1) {
        item.amount--;
      } else {
        _orderItems.removeWhere((item) => item.productId == productId);
      }
    });
  }

  Future<void> _createOrder() async {
    if (_customerNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.tr(context, 'pleaseEnterCustomerName')),
          backgroundColor: AppColors.destructive,
        ),
      );
      return;
    }
    if (_orderItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.tr(context, 'pleaseSelectAtLeastOneProduct'),
          ),
          backgroundColor: AppColors.destructive,
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final apiService = getApiService();

      final items = _orderItems.map((item) {
        if (item.isCustom) {
          return CustomOrderItem(
            customName: item.customName!,
            customPrice: item.customPrice!,
            notes: item.notes,
          );
        } else {
          return ProductOrderItem(
            productId: item.productId!,
            amount: item.amount,
            notes: item.notes,
            priceAtSale: item.priceAtSale,
          );
        }
      }).toList();

      final request = CreateOrderRequest(
        customerName: _customerNameController.text,
        pickupDate: _pickupDate,
        notes: _orderNotesController.text.trim().isEmpty
            ? null
            : _orderNotesController.text.trim(),
        items: items,
      );

      await apiService.createOrder(request);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppStrings.tr(context, 'orderCreationFailed')}: $e',
            ),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  int _calculateTotal(List<Product> products) {
    int total = 0;
    for (final item in _orderItems) {
      final product = products.firstWhere((p) => p.id == item.productId);
      final price = item.priceAtSale ?? product.price;
      total += price * item.amount;
    }
    return total;
  }

  void _showAddCustomItemDialog() {
    showDialog(
      context: context,
      builder: (context) => AddCustomItemDialog(
        onAddItem: (item) {
          setState(() {
            _orderItems.add(item);
          });
        },
      ),
    );
  }

  void _showAddProductDialog(List<Product> products) {
    final selectedProductIds = _orderItems
        .where((item) => item.productId != null)
        .map((item) => item.productId!)
        .toList();

    showDialog(
      context: context,
      builder: (context) => AddProductDialog(
        availableProducts: products,
        selectedProductIds: selectedProductIds,
        onAddItem: (item) {
          setState(() {
            _orderItems.add(item);
          });
        },
      ),
    );
  }

  String _formatIdr(int value, {bool raw = false, bool allowZero = false}) {
    if (raw) {
      return value.toString();
    }
    if (value == 0 && !allowZero) return '';
    final str = value.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) buffer.write('.');
    }
    final formatted = buffer.toString().split('').reversed.join();
    return 'Rp $formatted';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.trWatch(context, 'createOrder'))),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListSkeleton(
              itemCount: 5,
              itemBuilder: (context, index) => FadeInSlide(
                delay: Duration(milliseconds: index * 50),
                child: const ProductCardSkeleton(),
              ),
            );
          }

          if (snapshot.hasError) {
            return ErrorState(
              message: snapshot.error.toString(),
              onRetry: _loadProducts,
            );
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: AppStrings.trWatch(context, 'noProducts'),
              message: AppStrings.trWatch(context, 'addProductsBeforeOrders'),
            );
          }

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
                        FadeInSlide(
                          child: TextFormField(
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
                        ),
                        const SizedBox(height: 16),
                        FadeInSlide(
                          delay: AppAnimations.fadeInMedium,
                          child: TextFormField(
                            controller: _orderNotesController,
                            decoration: InputDecoration(
                              labelText: 'Order Notes (optional)',
                              hintText: 'Enter any notes for this order',
                              prefixIcon: const Icon(Icons.note_alt_outlined),
                            ),
                            maxLines: 2,
                          ),
                        ),
                        const SizedBox(height: 24),
                        FadeInSlide(
                          delay: AppAnimations.fadeInLong,
                          child: InkWell(
                            onTap: _selectPickupDate,
                            borderRadius: BorderRadius.circular(8),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: AppStrings.trWatch(context, 'pickupDateOptional'),
                                prefixIcon: const Icon(Icons.calendar_today),
                                suffixIcon: const Icon(Icons.arrow_forward_ios, size: 16),
                              ),
                              child: Text(
                                _pickupDate != null
                                    ? DateFormat('MMM dd, yyyy').format(_pickupDate!)
                                    : AppStrings.trWatch(context, 'noPickupDateSet'),
                                style: TextStyle(
                                  color: _pickupDate != null
                                      ? AppColors.foreground
                                      : AppColors.mutedForeground,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        FadeInSlide(
                          delay: const Duration(milliseconds: 200),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppStrings.trWatch(context, 'orderItems'),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Row(
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _showAddProductDialog(products),
                                    icon: const Icon(Icons.add),
                                    label: Text(AppStrings.trWatch(context, 'addItem')),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: _showAddCustomItemDialog,
                                    icon: const Icon(Icons.add_circle_outline),
                                    label: Text(AppStrings.tr(context, 'addCustom')),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_orderItems.isEmpty)
                          FadeInSlide(
                            delay: const Duration(milliseconds: 300),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.shopping_cart_outlined, size: 48, color: AppColors.mutedForeground),
                                      const SizedBox(height: 16),
                                      Text(
                                        AppStrings.trWatch(context, 'noItemsAdded'),
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.mutedForeground),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        AppStrings.trWatch(context, 'tapAddItem'),
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mutedForeground),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        else ...[
                          ..._orderItems.map((item) {
                            return FadeInSlide(
                              delay: const Duration(milliseconds: 300),
                              child: Card(
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
                                                Text(item.customName ?? '', style: Theme.of(context).textTheme.titleMedium),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Rp ${item.customPrice.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')} × ${item.amount}',
                                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                                                ),
                                              ],
                                            ),
                                          ),
                                          QuantitySelector(
                                            quantity: item.amount,
                                            onIncrement: () => _incrementProduct(item.productId!),
                                            onDecrement: () => _decrementProduct(item.productId!),
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
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (_orderItems.isNotEmpty)
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
                        LabeledValueRow(
                          label: AppStrings.trWatch(context, 'total'),
                          value: _formatIdr(_calculateTotal(products), allowZero: true),
                          labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mutedForeground),
                          valueStyle: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _isCreating ? null : () => _createOrder(),
                          icon: _isCreating
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
                            _isCreating
                                ? AppStrings.trWatch(context, 'creating')
                                : AppStrings.trWatch(context, 'createOrder'),
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

class ProductOrderItemCard extends StatelessWidget {
  final Product product;
  final int quantity;
  final int price;
  final String? notes;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const ProductOrderItemCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.price,
    this.notes,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
                        'Rp ${price.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')} × $quantity',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                QuantitySelector(
                  quantity: quantity,
                  onIncrement: onIncrement,
                  onDecrement: onDecrement,
                ),
              ],
            ),
            if (notes != null && notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              NoteContainer(note: notes!),
            ],
          ],
        ),
      ),
    );
  }
}
