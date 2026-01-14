import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/settings_provider.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/empty_state.dart';
import '../components/product_list_item.dart';
import '../components/product_card.dart';
import '../utils/currency_utils.dart';
import '../theme/app_theme.dart';
import '../l10n/strings.dart';
import '../utils/data_loader_extension.dart';

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
    _loadProducts();
  }

  void _loadProducts() {
    setState(() {
      _productsFuture = getApiService().getProducts().then((products) {
        _allProducts = products;
        _applyFilters();
        return products;
      });
    });
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
    String tempSortBy = _sortBy;
    bool tempSortAsc = _sortAsc;
    String? tempFilterCategory = _filterCategory;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppStrings.tr(context, 'sortAndFilter')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(AppStrings.tr(context, 'sortBy')),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: tempSortBy,
                    items: [
                      DropdownMenuItem(value: 'name', child: Text(AppStrings.tr(context, 'name'))),
                      DropdownMenuItem(value: 'price', child: Text(AppStrings.tr(context, 'price'))),
                    ],
                    onChanged: (v) {
                      if (v != null) tempSortBy = v;
                      setState(() {});
                    },
                  ),
                  IconButton(
                    icon: Icon(tempSortAsc ? Icons.arrow_upward : Icons.arrow_downward),
                    onPressed: () {
                      tempSortAsc = !tempSortAsc;
                      setState(() {});
                    },
                  ),
                ],
              ),
              // Example filter UI (uncomment and adjust if you have categories)
              // Row(
              //   children: [
              //     Text(AppStrings.tr(context, 'category')),
              //     const SizedBox(width: 16),
              //     DropdownButton<String>(
              //       value: tempFilterCategory,
              //       items: [DropdownMenuItem(value: null, child: Text('All'))],
              //       onChanged: (v) {
              //         tempFilterCategory = v;
              //         setState(() {});
              //       },
              //     ),
              //   ],
              // ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.tr(context, 'cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _sortBy = tempSortBy;
                  _sortAsc = tempSortAsc;
                  _filterCategory = tempFilterCategory;
                });
                _applyFilters();
                Navigator.pop(context);
              },
              child: Text(AppStrings.tr(context, 'apply')),
            ),
          ],
        );
      },
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
        childAspectRatio: 1.1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/product_details', arguments: product);
          },
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(formatIdr(product.price), style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary)),
                ],
              ),
            ),
          ),
        );
      },
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
            child: ListTile(
              title: Text(product.name),
              subtitle: Text(formatIdr(product.price)),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
        );
      },
    );
  }
}

