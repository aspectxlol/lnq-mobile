import 'package:flutter/material.dart';

class LabeledValueRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final int? labelMaxLines;
  final int? valueMaxLines;
  final bool expandLabel;

  const LabeledValueRow({
    super.key,
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueStyle,
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.labelMaxLines,
    this.valueMaxLines,
    this.expandLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final labelWidget = Text(
      label,
      style: labelStyle,
      maxLines: labelMaxLines,
      overflow: TextOverflow.ellipsis,
    );
    final valueWidget = Text(
      value,
      style: valueStyle,
      maxLines: valueMaxLines,
      overflow: TextOverflow.ellipsis,
    );
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        if (expandLabel)
          Expanded(child: labelWidget)
        else
          labelWidget,
        valueWidget,
      ],
    );
  }
}
