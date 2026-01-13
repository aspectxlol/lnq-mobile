import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final Color? color;
  final Color? foregroundColor;
  final double iconSize;

  const QuantitySelector({
    Key? key,
    required this.quantity,
    this.onIncrement,
    this.onDecrement,
    this.color,
    this.foregroundColor,
    this.iconSize = 32,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onDecrement,
          icon: const Icon(Icons.remove_circle),
          color: AppColors.destructive,
          iconSize: iconSize,
        ),
        const SizedBox(width: 16),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color ?? AppColors.primary,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              '$quantity',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: foregroundColor ?? AppColors.primaryForeground,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: onIncrement,
          icon: const Icon(Icons.add_circle),
          color: AppColors.primary,
          iconSize: iconSize,
        ),
      ],
    );
  }
}
