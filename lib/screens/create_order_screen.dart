import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../models/create_order_request.dart';
import '../services/api_service.dart';
import '../providers/settings_provider.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/empty_state.dart';
import '../widgets/animated_widgets.dart';
import '../theme/app_theme.dart';
import '../l10n/strings.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  late Future<List<Product>> _productsFuture;

  DateTime? _pickupDate;
  final Map<int, int> _selectedProducts = {};
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
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
      _selectedProducts[productId] = (_selectedProducts[productId] ?? 0) + 1;
    });
  }

  void _decrementProduct(int productId) {
    setState(() {
      final current = _selectedProducts[productId] ?? 0;
      if (current > 1) {
        _selectedProducts[productId] = current - 1;
      } else {
        _selectedProducts.remove(productId);
      }
    });
  }

  Future<void> _createOrder(List<Product> products) async {
    if (!_formKey.currentState!.validate()) return;
    final settings = context.read<SettingsProvider>();
    final l10n = LocalizationHelper(settings.locale);
    
    if (_selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseSelectAtLeastOneProduct),
          backgroundColor: AppColors.destructive,
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final baseUrl = context.read<SettingsProvider>().baseUrl;
      final apiService = ApiService(baseUrl);

      final request = CreateOrderRequest(
        customerName: _customerNameController.text,
        pickupDate: _pickupDate,
        items: _selectedProducts.entries
            .map(
              (entry) =>
                  CreateOrderItem(productId: entry.key, amount: entry.value),
            )
            .toList(),
      );

      await apiService.createOrder(request);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        final settings = context.read<SettingsProvider>();
        final l10n = LocalizationHelper(settings.locale);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.orderCreationFailed}: $e'),
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
    for (final entry in _selectedProducts.entries) {
      final product = products.firstWhere((p) => p.id == entry.key);
      total += product.price * entry.value;
    }
    return total;
  }

  void _showAddProductDialog(List<Product> products) {
    Product? selectedProduct;
    int quantity = 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<Product>(
                value: selectedProduct,
                decoration: const InputDecoration(
                  labelText: 'Select Product',
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                isExpanded: true,
                items: products
                    .where((p) => !_selectedProducts.containsKey(p.id))
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
                  'Quantity',
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
                        'Subtotal:',
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedProduct != null
                  ? () {
                      setState(() {
                        _selectedProducts[selectedProduct!.id] = quantity;
                      });
                      Navigator.pop(context);
                    }
                  : null,
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Order')),
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
            return const EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: 'No Products',
              message: 'Add products before creating orders.',
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
                            decoration: const InputDecoration(
                              labelText: 'Customer Name',
                              hintText: 'Enter customer name',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter customer name';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        FadeInSlide(
                          delay: const Duration(milliseconds: 100),
                          child: InkWell(
                            onTap: _selectPickupDate,
                            borderRadius: BorderRadius.circular(8),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Pickup Date (Optional)',
                                prefixIcon: Icon(Icons.calendar_today),
                                suffixIcon: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                              ),
                              child: Text(
                                _pickupDate != null
                                    ? DateFormat(
                                        'MMM dd, yyyy',
                                      ).format(_pickupDate!)
                                    : 'No pickup date set',
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
                                'Order Items',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              TextButton.icon(
                                onPressed: () =>
                                    _showAddProductDialog(products),
                                icon: const Icon(Icons.add),
                                label: const Text('Add Item'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_selectedProducts.isEmpty)
                          FadeInSlide(
                            delay: const Duration(milliseconds: 300),
                            child: Card(
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
                                        'No items added',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: AppColors.mutedForeground,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tap "Add Item" to select products',
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
                            ),
                          )
                        else
                          ..._selectedProducts.entries.map((entry) {
                            final product = products.firstWhere(
                              (p) => p.id == entry.key,
                            );
                            final quantity = entry.value;

                            return FadeInSlide(
                              delay: const Duration(milliseconds: 300),
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
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
                                              '${product.formattedPrice} × $quantity',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: AppColors.primary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: () =>
                                                _decrementProduct(product.id),
                                            icon: const Icon(
                                              Icons.remove_circle,
                                            ),
                                            color: AppColors.destructive,
                                          ),
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '$quantity',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      color: AppColors
                                                          .primaryForeground,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () =>
                                                _incrementProduct(product.id),
                                            icon: const Icon(Icons.add_circle),
                                            color: AppColors.primary,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
              ),
              if (_selectedProducts.isNotEmpty)
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
                                  'Total',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppColors.mutedForeground,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rp ${(_calculateTotal(products) / 1000).toStringAsFixed(0)}.000',
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
                              onPressed: _isCreating
                                  ? null
                                  : () => _createOrder(products),
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
                                _isCreating ? 'Creating...' : 'Create Order',
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
