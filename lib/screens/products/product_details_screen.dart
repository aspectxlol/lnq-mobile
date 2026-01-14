import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../utils/currency_utils.dart';
import '../../l10n/strings.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../providers/settings_provider.dart';
import 'package:provider/provider.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.tr(context, 'deleteProduct')),
        content: Text(AppStrings.tr(context, 'deleteProductConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.tr(context, 'cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final baseUrl = context.read<SettingsProvider>().baseUrl;
                final apiService = ApiService(baseUrl);
                await apiService.deleteProduct(product.id);
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text(AppStrings.tr(context, 'productDeletedSuccessfully')),
                    backgroundColor: Colors.green,
                  ),
                );

                Navigator.pop(context, true);
              } catch (e) {
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${AppStrings.tr(context, 'failedToDeleteProduct')}: $e',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppStrings.tr(context, 'delete')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(product.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context,
                  '/edit_product',
                  arguments: product,
                );
                if (result != null && context.mounted) {
                  Navigator.pop(context, result);
                }
              },
              tooltip: AppStrings.tr(context, 'edit'),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteConfirmDialog(context),
              tooltip: AppStrings.tr(context, 'delete'),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Image
              Container(
                height: 300,
                color: Colors.grey[300],
                child: product.imageId != null
                    ? Image.network(
                        product.getImageUrl(
                          context.read<SettingsProvider>().baseUrl,
                        )!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, trace) {
                          return Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 80,
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
                      )
                    : Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 80,
                          color: Colors.grey[600],
                        ),
                      ),
              ),

              // Product Info
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Price Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.tr(context, 'price'),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            formatIdr(product.price),
                            style:
                                Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Description Section
                    Text(
                      AppStrings.tr(context, 'description'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    if (product.description != null &&
                        product.description!.isNotEmpty)
                      Text(
                        product.description!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      )
                    else
                      Text(
                        AppStrings.tr(context, 'noDescription'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                      ),

                    const SizedBox(height: 24),

                    // Product Meta Info
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.tr(context, 'productDetails'),
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              context,
                              AppStrings.tr(context, 'productId'),
                              product.id.toString(),
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              context,
                              AppStrings.tr(context, 'created'),
                              product.createdAt.toString().split('.')[0],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.pushNamed(
                                context,
                                '/edit_product',
                                arguments: product,
                              );
                              if (result != null && context.mounted) {
                                Navigator.pop(context, result);
                              }
                            },
                            icon: const Icon(Icons.edit),
                            label: Text(AppStrings.tr(context, 'edit')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showDeleteConfirmDialog(context),
                            icon: const Icon(Icons.delete),
                            label: Text(AppStrings.tr(context, 'delete')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
