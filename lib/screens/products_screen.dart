import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/settings_provider.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/empty_state.dart';
import '../components/product_list_item.dart';
import '../components/product_card.dart';
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
  Widget build(BuildContext context) {
    context.watch<SettingsProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.trWatch(context, 'products')),
        actions: [
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
      body: FutureBuilder<List<Product>>(
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

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
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
                ? _buildCardView(products)
                : _buildListView(products),
          );
        },
      ),
    );
  }

  Widget _buildCardView(List<Product> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(product: product);
      },
    );
  }

  Widget _buildListView(List<Product> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductListItem(product: product);
      },
    );
  }
}

