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
  final _orderNotesController = TextEditingController();
  late Future<List<Product>> _productsFuture;

  DateTime? _pickupDate;
  final Map<int, int> _selectedProducts = {};
  final Map<int, int> _customPrices = {}; // productId -> priceAtSale
  final Map<int, String> _itemNotes = {}; // productId -> notes
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    final baseUrl = Provider.of<SettingsProvider>(
      context,
      listen: false,
    ).baseUrl;
    final apiService = ApiService(baseUrl);
    setState(() {
      _productsFuture = apiService.getProducts();
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
    if (_customerNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.tr(context, 'pleaseEnterCustomerName')),
          backgroundColor: AppColors.destructive,
        ),
      );
      return;
    }
    if (_selectedProducts.isEmpty) {
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
      final baseUrl = Provider.of<SettingsProvider>(
        context,
        listen: false,
      ).baseUrl;
      final apiService = ApiService(baseUrl);

      final request = CreateOrderRequest(
        customerName: _customerNameController.text,
        pickupDate: _pickupDate,
        notes: _orderNotesController.text.trim().isEmpty
            ? null
            : _orderNotesController.text.trim(),
        items: _selectedProducts.entries
            .map(
              (entry) {
          int? custom = _customPrices[entry.key];
          String? notes = _itemNotes[entry.key];
          // Respect 0 as a valid price, fallback only if null
          return CreateOrderItem(
            productId: entry.key,
            amount: entry.value,
            priceAtSale: custom != null ? custom : null,
            notes: notes,
          );
        },
            )
            .toList(),
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
    for (final entry in _selectedProducts.entries) {
      final product = products.firstWhere((p) => p.id == entry.key);
      final custom = _customPrices[entry.key];
      final price = custom != null ? custom : product.price;
      total += price * entry.value;
    }
    return total;
  }

  void _showAddProductDialog(List<Product> products) {
    final locale = Provider.of<SettingsProvider>(context, listen: false).locale;
    Product? selectedProduct;
    int quantity = 1;

    int? customPrice;
    final customPriceController = TextEditingController();
    final itemNotesController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(AppStrings.getString(locale, 'addProduct')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<Product>(
                  value: selectedProduct,
                  decoration: InputDecoration(
                    labelText: AppStrings.getString(locale, 'selectProduct'),
                    prefixIcon: const Icon(Icons.shopping_bag),
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
                                _formatIdr(product.price),
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
                      customPrice = product?.price;
                      customPriceController.text =
                          product != null && product.price > 0
                          ? _formatIdr(product.price)
                          : '';
                    });
                  },
                ),
                const SizedBox(height: 24),
                if (selectedProduct != null) ...[
                  Text(
                    AppStrings.getString(locale, 'quantity'),
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
                  Text(
                    'Price at sale (optional):',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: customPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Masukkan harga custom',
                      prefixIcon: const Icon(Icons.price_change),
                    ),
                    inputFormatters: [
                      // Only allow digits, formatting handled in onChanged
                    ],
                    onChanged: (value) {
                      // Remove non-digit characters
                      String digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                      int? parsed = int.tryParse(digits);
                      setDialogState(() {
                        customPrice = parsed;
                        // Format as IDR for display, allow 0 (free)
                        String formatted = digits.isEmpty
                            ? ''
                            : _formatIdr(parsed ?? 0, allowZero: true);
                        int caret = formatted.length;
                        customPriceController.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(offset: caret),
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Item Notes (optional):',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: itemNotesController,
                    decoration: InputDecoration(
                      hintText: 'Enter notes for this item',
                      prefixIcon: const Icon(Icons.note_alt_outlined),
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
                          '${AppStrings.getString(locale, 'subtotal')}:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          _formatIdr(
                            (customPrice != null
                                    ? customPrice!
                                    : selectedProduct!.price) *
                                quantity,
                            allowZero: true,
                          ),
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
              child: Text(AppStrings.getString(locale, 'cancel')),
            ),
            ElevatedButton(
              onPressed: selectedProduct != null
                  ? () {
                      setState(() {
                        _selectedProducts[selectedProduct!.id] = quantity;
                        // Respect 0 as a valid custom price
                        if (customPrice != null && customPrice! >= 0) {
                          _customPrices[selectedProduct!.id] = customPrice!;
                        } else {
                          _customPrices.remove(selectedProduct!.id);
                        }
                        // Store item notes in a new map
                        if (itemNotesController.text.trim().isNotEmpty) {
                          _itemNotes[selectedProduct!.id] = itemNotesController
                              .text
                              .trim();
                        } else {
                          _itemNotes.remove(selectedProduct!.id);
                        }
                      });
                      Navigator.pop(context);
                    }
                  : null,
              child: Text(AppStrings.getString(locale, 'add')),
            ),
          ],
        ),
      ),
    );
  }

  String _formatIdr(int value, {bool raw = false, bool allowZero = false}) {
    if (raw) {
      // Format as plain number for input
      return value.toString();
    }
    // If allowZero is true, show 'Rp 0' for zero value
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
                              labelText: AppStrings.trWatch(
                                context,
                                'customerName',
                              ),
                              hintText: AppStrings.trWatch(
                                context,
                                'enterCustomerName',
                              ),
                              prefixIcon: const Icon(Icons.person_outline),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppStrings.trWatch(
                                  context,
                                  'pleaseEnterCustomerName',
                                );
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeInSlide(
                          delay: const Duration(milliseconds: 50),
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
                          delay: const Duration(milliseconds: 100),
                          child: InkWell(
                            onTap: _selectPickupDate,
                            borderRadius: BorderRadius.circular(8),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: AppStrings.trWatch(
                                  context,
                                  'pickupDateOptional',
                                ),
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
                                    : AppStrings.trWatch(
                                        context,
                                        'noPickupDateSet',
                                      ),
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
                              TextButton.icon(
                                onPressed: () =>
                                    _showAddProductDialog(products),
                                icon: const Icon(Icons.add),
                                label: Text(
                                  AppStrings.trWatch(context, 'addItem'),
                                ),
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
                                        AppStrings.trWatch(
                                          context,
                                          'noItemsAdded',
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: AppColors.mutedForeground,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        AppStrings.trWatch(
                                          context,
                                          'tapAddItem',
                                        ),
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
                            final custom = _customPrices[entry.key];
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
                                              '${_formatIdr(custom != null ? custom : product.price, allowZero: true)} × $quantity',
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
                                  AppStrings.trWatch(context, 'total'),
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppColors.mutedForeground,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _calculateTotal(products) == 0
                                      ? 'Rp 0'
                                      : 'Rp ${(_calculateTotal(products) / 1000).toStringAsFixed(0)}.000',
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
                                _isCreating
                                    ? AppStrings.trWatch(context, 'creating')
                                    : AppStrings.trWatch(
                                        context,
                                        'createOrder',
                                      ),
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
