import 'package:flutter/material.dart';
import '../models/product.dart';
import '../utils/currency_utils.dart';
import '../l10n/strings.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Text(formatIdr(product.price), style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 24),
            if (product.description != null && product.description!.isNotEmpty)
              Text(product.description!, style: Theme.of(context).textTheme.bodyLarge),
            if (product.description == null || product.description!.isEmpty)
              Text(AppStrings.tr(context, 'noDescription'), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
            // Add more product details here if needed
          ],
        ),
      ),
    );
  }
}
