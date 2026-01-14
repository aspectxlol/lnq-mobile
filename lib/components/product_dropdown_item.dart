import 'package:flutter/material.dart';
import '../widgets/labeled_value_row.dart';

class ProductDropdownItem extends StatelessWidget {
  final String name;
  final String price;
  final TextStyle? nameStyle;
  final TextStyle? priceStyle;

  const ProductDropdownItem({
    super.key,
    required this.name,
    required this.price,
    this.nameStyle,
    this.priceStyle,
  });

  @override
  Widget build(BuildContext context) {
    return LabeledValueRow(
      label: name,
      value: price,
      labelStyle: nameStyle ?? Theme.of(context).textTheme.bodyLarge,
      valueStyle: priceStyle ?? Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      expandLabel: true,
    );
  }
}
