import 'package:flutter/material.dart';
import '../models/product.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../screens/products/product_details_screen.dart';
import 'package:provider/provider.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/product_widgets.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final baseUrl = context.watch<SettingsProvider>().baseUrl;
    final imageUrl = product.imageId != null
        ? '$baseUrl/api/images/${product.imageId}'
        : null;
    return Hero(
      tag: 'product-${product.id}',
      child: AnimatedCard(
        onTap: () {
          Navigator.push( 
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(product: product),
            ),
          );
        },
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductImage(
              imageUrl: imageUrl,
              width: double.infinity,
              height: 120,
              iconSize: 48,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: ProductDescriptionColumn(
                  name: product.name,
                  description: product.description,
                  price: product.formattedPrice,
                  nameStyle: Theme.of(context).textTheme.titleSmall,
                  descriptionStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mutedForeground),
                  priceStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                  nameMaxLines: 2,
                  descriptionMaxLines: 1,
                  priceMaxLines: 1,
                  spacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
