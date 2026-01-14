import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../l10n/strings.dart';
import '../utils/state_extension.dart';
import '../utils/error_handler.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/screen_scaffold.dart';
import '../components/price_input.dart';
import '../utils/currency_utils.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  late Future<List<Product>> _productsFuture;

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

  Future<void> _deleteProduct(Product product) async {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: AppStrings.tr(context, 'deleteProduct'),
        message: '${AppStrings.tr(context, 'confirmDelete')} "${product.name}"?',
        confirmLabel: AppStrings.tr(context, 'delete'),
        cancelLabel: AppStrings.tr(context, 'cancel'),
        isDestructive: true,
        onConfirm: () async {
          ifMounted(() => setState(() {}));

          try {
            await getApiService().deleteProduct(product.id);
            ifMounted(() {
              ErrorHandler.showSuccess(
                context,
                '${product.name} ${AppStrings.tr(context, 'deletedSuccessfully')}',
              );
              _loadProducts();
            });
          } catch (e) {
            ifMounted(() {
              ErrorHandler.showError(context, e);
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<SettingsProvider>();

    return ScreenScaffold(
      title: AppStrings.trWatch(context, 'productManagement'),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateProductScreen(),
            ),
          );
          if (result == true) {
            _loadProducts();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListSkeleton(
              itemCount: 5,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.destructive,
                  ),
                  const SizedBox(height: 16),
                  Text(snapshot.error.toString()),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadProducts,
                    child: Text(AppStrings.tr(context, 'retry')),
                  ),
                ],
              ),
            );
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.shopping_bag_outlined,
              title: AppStrings.trWatch(context, 'noProducts'),
              message: AppStrings.trWatch(context, 'noProductsAvailable'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListItemCard(
                title: product.name,
                subtitle: '${AppStrings.tr(context, 'price')}: ${formatIdr(product.price)}',
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Row(
                        children: [
                          const Icon(Icons.edit),
                          const SizedBox(width: 8),
                          Text(AppStrings.tr(context, 'edit')),
                        ],
                      ),
                      onTap: () async {
                        await Future.delayed(const Duration(milliseconds: 100));
                        ifMounted(() async {
                          final result = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditProductScreen(product: product),
                            ),
                          );
                          if (result == true) {
                            _loadProducts();
                          }
                        });
                      },
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          const Icon(Icons.delete, color: AppColors.destructive),
                          const SizedBox(width: 8),
                          Text(
                            AppStrings.tr(context, 'delete'),
                            style:
                                const TextStyle(color: AppColors.destructive),
                          ),
                        ],
                      ),
                      onTap: () async {
                        await Future.delayed(const Duration(milliseconds: 100));
                        ifMounted(() => _deleteProduct(product));
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({super.key});

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createProduct() async {
    if (!_formKey.currentState!.validate()) return;

    ifMounted(() => setState(() => _isLoading = true));

    try {
      final price = int.parse(_priceController.text.trim());
      
      await getApiService().createProduct(
        name: _nameController.text.trim(),
        price: price,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      ifMounted(() {
        ErrorHandler.showSuccess(
          context,
          AppStrings.tr(context, 'productCreatedSuccessfully'),
        );
        Navigator.pop(context, true);
      });
    } catch (e) {
      ifMounted(() {
        ErrorHandler.showError(context, e);
      });
    } finally {
      ifMounted(() => setState(() => _isLoading = false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: AppStrings.trWatch(context, 'createProduct'),
      body: FormContainer(
        scrollable: true,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: AppStrings.tr(context, 'productName'),
              prefixIcon: const Icon(Icons.shopping_bag),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppStrings.tr(context, 'enterProductName');
              }
              if (value.length > 100) {
                return AppStrings.tr(context, 'productNameTooLong');
              }
              return null;
            },
          ),
          const FormFieldSpacing(),
          PriceInput(
            controller: _priceController,
            labelText: AppStrings.tr(context, 'price'),
            prefixText: 'Rp ',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.tr(context, 'enterPrice');
              }
              final price = int.tryParse(value);
              if (price == null || price < 0) {
                return AppStrings.tr(context, 'enterValidPrice');
              }
              return null;
            },
          ),
          const FormFieldSpacing(),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: AppStrings.tr(context, 'description'),
              prefixIcon: const Icon(Icons.description),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FormActionButton(
              label: AppStrings.tr(context, 'create'),
              isLoading: _isLoading,
              onPressed: _createProduct,
            ),
          ),
        ],
      ),
    );
  }
}

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late final _formKey = GlobalKey<FormState>();
  late final _nameController =
      TextEditingController(text: widget.product.name);
  late final _priceController =
      TextEditingController(text: widget.product.price.toString());
  late final _descriptionController =
      TextEditingController(text: widget.product.description ?? '');
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    ifMounted(() => setState(() => _isLoading = true));

    try {
      final price = int.parse(_priceController.text.trim());
      
      await getApiService().updateProduct(
        widget.product.id,
        name: _nameController.text.trim(),
        price: price,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      ifMounted(() {
        ErrorHandler.showSuccess(
          context,
          AppStrings.tr(context, 'productUpdatedSuccessfully'),
        );
        Navigator.pop(context, true);
      });
    } catch (e) {
      ifMounted(() {
        ErrorHandler.showError(context, e);
      });
    } finally {
      ifMounted(() => setState(() => _isLoading = false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: AppStrings.trWatch(context, 'editProduct'),
      body: FormContainer(
        scrollable: true,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: AppStrings.tr(context, 'productName'),
              prefixIcon: const Icon(Icons.shopping_bag),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppStrings.tr(context, 'enterProductName');
              }
              if (value.length > 100) {
                return AppStrings.tr(context, 'productNameTooLong');
              }
              return null;
            },
          ),
          const FormFieldSpacing(),
          PriceInput(
            controller: _priceController,
            labelText: AppStrings.tr(context, 'price'),
            prefixText: 'Rp ',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.tr(context, 'enterPrice');
              }
              final price = int.tryParse(value);
              if (price == null || price < 0) {
                return AppStrings.tr(context, 'enterValidPrice');
              }
              return null;
            },
          ),
          const FormFieldSpacing(),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: AppStrings.tr(context, 'description'),
              prefixIcon: const Icon(Icons.description),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FormActionButton(
              label: AppStrings.tr(context, 'update'),
              isLoading: _isLoading,
              onPressed: _updateProduct,
            ),
          ),
        ],
      ),
    );
  }
}
