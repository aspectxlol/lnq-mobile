import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import 'price_input.dart';

/// Reusable product form fields for create/edit screens
class ProductFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final String? nameHint;
  final String? descriptionHint;
  final String? priceHint;
  final bool showDescription;
  final bool showPrice;
  final String? Function(String?)? nameValidator;
  final String? Function(String?)? priceValidator;

  const ProductFormFields({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.priceController,
    this.nameHint,
    this.descriptionHint,
    this.priceHint,
    this.showDescription = true,
    this.showPrice = true,
    this.nameValidator,
    this.priceValidator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Product Name
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: AppStrings.tr(context, 'name'),
            hintText: nameHint ?? AppStrings.tr(context, 'enterProductName'),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.label_outlined),
          ),
          validator: nameValidator,
        ),
        if (showDescription) ...[
          const SizedBox(height: 16),
          // Product Description
          TextFormField(
            controller: descriptionController,
            decoration: InputDecoration(
              labelText: AppStrings.tr(context, 'description'),
              hintText: descriptionHint ?? AppStrings.tr(context, 'enterProductDescription'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.description_outlined),
            ),
            maxLines: 3,
          ),
        ],
        if (showPrice) ...[
          const SizedBox(height: 16),
          // Product Price
          PriceInput(
            controller: priceController,
            labelText: AppStrings.tr(context, 'price'),
            helperText: AppStrings.tr(context, 'enterProductPrice'),
            validator: priceValidator,
          ),
        ],
      ],
    );
  }
}
