import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/labeled_value_row.dart';

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const InfoRow({super.key, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return LabeledValueRow(
      label: label,
      value: value,
      labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mutedForeground),
      valueStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: valueColor,
      ),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    );
  }
}
