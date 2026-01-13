import 'package:flutter/material.dart';
import '../models/product.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../screens/product_detail_screen.dart';
import 'package:provider/provider.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/product_widgets.dart';

class ProductListItem extends StatelessWidget {
  final Product product;
  const ProductListItem({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final baseUrl = context.watch<SettingsProvider>().baseUrl;
    final imageUrl = product.imageId != null
        ? '$baseUrl/api/images/${product.imageId}'
        : null;
    return AnimatedCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: product.id),
          ),
        );
      },
      child: Row(
        children: [
          ProductImage(
            imageUrl: imageUrl,
            width: 80,
            height: 80,
            iconSize: 32,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ProductDescriptionColumn(
              name: product.name,
              description: product.description,
              price: product.formattedPrice,
              nameStyle: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              descriptionStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mutedForeground),
              priceStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
              nameMaxLines: 2,
              descriptionMaxLines: 2,
              priceMaxLines: 1,
              spacing: 4,
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.mutedForeground),
        ],
      ),
    );
  }
}
