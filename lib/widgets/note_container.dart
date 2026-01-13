import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NoteContainer extends StatelessWidget {
  final String note;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;
  final BorderRadius? borderRadius;

  const NoteContainer({
    Key? key,
    required this.note,
    this.textStyle,
    this.padding,
    this.iconSize = 16,
    this.backgroundColor,
    this.iconColor,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.accent,
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(
            Icons.note_outlined,
            size: iconSize,
            color: iconColor ?? AppColors.mutedForeground,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              note,
              style: textStyle ?? Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.foreground,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
