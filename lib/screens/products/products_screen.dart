import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/empty_state.dart';
import '../../utils/currency_utils.dart';
import '../../theme/app_theme.dart';
import '../../l10n/strings.dart';
import '../../utils/data_loader_extension.dart';
import '../../components/dialogs/sort_filter_dialog.dart';
import 'create_product_screen.dart';

enum ProductView { cards, list }

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late Future<List<Product>> _productsFuture;
  ProductView _currentView = ProductView.cards;
  String _searchQuery = '';
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  String _sortBy = 'name';
  bool _sortAsc = true;
  String? _filterCategory; // Example filter, adjust as needed

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with a pending future that will be resolved when settings are loaded
    _productsFuture = _initializeAndLoadProducts();
  }

  Future<List<Product>> _initializeAndLoadProducts() async {
    final settings = context.read<SettingsProvider>();
    // Wait for settings to be initialized before loading products
    await settings.ensureInitialized();
    return _loadProductsData();
  }

  Future<List<Product>> _loadProductsData() async {
    final products = await getApiService().getProducts();
    if (mounted) {
      setState(() {
        _allProducts = products;
        _applyFilters();
      });
    }
    return products;
  }

  void _loadProducts() {
    if (mounted) {
      setState(() {
        _productsFuture = _loadProductsData();
      });
    }
  }

  void _applyFilters() {
    List<Product> products = List.from(_allProducts);
    if (_searchQuery.isNotEmpty) {
      products = products.where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    // Example: filter by category if you have it
    if (_filterCategory != null && _filterCategory!.isNotEmpty) {
      // products = products.where((p) => p.category == _filterCategory).toList();
    }
    // Sort
    products.sort((a, b) {
      int cmp;
      if (_sortBy == 'name') {
        cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      } else {
        cmp = a.price.compareTo(b.price);
      }
      return _sortAsc ? cmp : -cmp;
    });
    _filteredProducts = products;
  }

  void _openSortFilterDialog() async {
    await showDialog(
      context: context,
      builder: (context) => SortFilterDialog(
        initialSortField: _sortBy,
        initialSortAscending: _sortAsc,
        sortOptions: [
          {'value': 'name', 'label': 'name'},
          {'value': 'price', 'label': 'price'},
        ],
        onApply: (sortField, sortAscending) {
          setState(() {
            _sortBy = sortField;
            _sortAsc = sortAscending;
          });
          _applyFilters();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<SettingsProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.trWatch(context, 'products')),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openSortFilterDialog,
            tooltip: AppStrings.trWatch(context, 'sortAndFilter'),
          ),
          IconButton(
            icon: Icon(
              _currentView == ProductView.cards
                  ? Icons.view_list
                  : Icons.grid_view,
            ),
            onPressed: () {
              setState(() {
                _currentView = _currentView == ProductView.cards
                    ? ProductView.list
                    : ProductView.cards;
              });
            },
            tooltip: _currentView == ProductView.cards
                ? AppStrings.trWatch(context, 'switchToListView')
                : AppStrings.trWatch(context, 'switchToCardView'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateProductScreen(),
            ),
          );
          if (result != null) {
            _loadProducts();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: AppStrings.tr(context, 'searchByName'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                            _applyFilters();
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                  _applyFilters();
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListSkeleton(
                    itemCount: 6,
                    itemBuilder: (context, index) => const ProductCardSkeleton(),
                  );
                }
                if (snapshot.hasError) {
                  return ErrorState(
                    message: snapshot.error.toString(),
                    onRetry: _loadProducts,
                  );
                }
                if (_filteredProducts.isEmpty) {
                  return EmptyState(
                    icon: Icons.shopping_bag_outlined,
                    title: AppStrings.trWatch(context, 'noProducts'),
                    message: AppStrings.trWatch(context, 'noProductsAvailable'),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    _loadProducts();
                    await _productsFuture;
                  },
                  color: AppColors.primary,
                  backgroundColor: AppColors.card,
                  child: _currentView == ProductView.cards
                      ? _buildCardView(_filteredProducts)
                      : _buildListView(_filteredProducts),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardView(List<Product> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/product_details', arguments: product);
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Section
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      color: Colors.grey[300],
                    ),
                    child: product.imageId != null
                        ? ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            child: Image.network(
                              product.getImageUrl(getApiService().baseUrl)!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, trace) {
                                return Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 40,
                                    color: Colors.grey[600],
                                  ),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 40,
                              color: Colors.grey[600],
                            ),
                          ),
                  ),
                  // Edit/Delete buttons
                  Positioned(
                    top: 4,
                    right: 4,
                    child: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Row(
                            children: [
                              const Icon(Icons.edit, size: 20),
                              const SizedBox(width: 8),
                              Text(AppStrings.tr(context, 'edit')),
                            ],
                          ),
                          onTap: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              '/edit_product',
                              arguments: product,
                            );
                            if (result != null) {
                              _loadProducts();
                            }
                          },
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: [
                              const Icon(Icons.delete, size: 20, color: Colors.red),
                              const SizedBox(width: 8),
                              Text(
                                AppStrings.tr(context, 'delete'),
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                          onTap: () {
                            _showDeleteConfirmDialog(product);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Info Section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if (product.description != null &&
                        product.description!.isNotEmpty)
                      Text(
                        product.description!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      const SizedBox.shrink(),
                    const Spacer(),
                    Text(
                      formatIdr(product.price),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(List<Product> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/product_details', arguments: product);
          },
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[300],
                ),
                child: product.imageId != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.getImageUrl(getApiService().baseUrl)!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, trace) {
                            return Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[600],
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.image_outlined,
                        color: Colors.grey[600],
                      ),
              ),
              title: Text(
                product.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: product.description != null &&
                      product.description!.isNotEmpty
                  ? Text(
                      product.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Row(
                      children: [
                        const Icon(Icons.edit, size: 20),
                        const SizedBox(width: 8),
                        Text(AppStrings.tr(context, 'edit')),
                      ],
                    ),
                    onTap: () async {
                      final result = await Navigator.pushNamed(
                        context,
                        '/edit_product',
                        arguments: product,
                      );
                      if (result != null) {
                        _loadProducts();
                      }
                    },
                  ),
                  PopupMenuItem(
                    child: Row(
                      children: [
                        const Icon(Icons.delete, size: 20, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.tr(context, 'delete'),
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                    onTap: () {
                      _showDeleteConfirmDialog(product);
                    },
                  ),
                ],
              ),
              onLongPress: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Text(product.name),
                          subtitle: Text(formatIdr(product.price)),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.edit),
                          title: Text(AppStrings.tr(context, 'edit')),
                          onTap: () async {
                            Navigator.pop(context);
                            final result = await Navigator.pushNamed(
                              context,
                              '/edit_product',
                              arguments: product,
                            );
                            if (result != null) {
                              _loadProducts();
                            }
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.delete, color: Colors.red),
                          title: Text(
                            AppStrings.tr(context, 'delete'),
                            style: const TextStyle(color: Colors.red),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _showDeleteConfirmDialog(product);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmDialog(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.tr(context, 'deleteProduct')),
        content: Text(
          AppStrings.tr(context, 'deleteProductConfirm'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.tr(context, 'cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteProduct(product);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(AppStrings.tr(context, 'delete')),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(Product product) async {
    try {
      await getApiService().deleteProduct(product.id);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.tr(context, 'productDeletedSuccessfully')),
          backgroundColor: Colors.green,
        ),
      );

      _loadProducts();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppStrings.tr(context, 'failedToDeleteProduct')}: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
