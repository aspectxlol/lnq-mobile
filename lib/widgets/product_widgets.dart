import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final double iconSize;
  final BorderRadius borderRadius;

  const ProductImage({
    Key? key,
    required this.imageUrl,
    required this.width,
    required this.height,
    required this.iconSize,
    required this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: imageUrl != null
          ? Image.network(
              imageUrl!,
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: width,
                  height: height,
                  color: AppColors.accent,
                  child: Icon(
                    Icons.shopping_bag,
                    size: iconSize,
                    color: AppColors.mutedForeground,
                  ),
                );
              },
            )
          : Container(
              width: width,
              height: height,
              color: AppColors.accent,
              child: Icon(
                Icons.shopping_bag,
                size: iconSize,
                color: AppColors.mutedForeground,
              ),
            ),
    );
  }
}

class ProductDescriptionColumn extends StatelessWidget {
  final String name;
  final String? description;
  final String price;
  final TextStyle? nameStyle;
  final TextStyle? descriptionStyle;
  final TextStyle? priceStyle;
  final int nameMaxLines;
  final int descriptionMaxLines;
  final int priceMaxLines;
  final double? spacing;

  const ProductDescriptionColumn({
    Key? key,
    required this.name,
    this.description,
    required this.price,
    this.nameStyle,
    this.descriptionStyle,
    this.priceStyle,
    this.nameMaxLines = 2,
    this.descriptionMaxLines = 2,
    this.priceMaxLines = 1,
    this.spacing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: nameStyle,
          maxLines: nameMaxLines,
          overflow: TextOverflow.ellipsis,
        ),
        if (description != null) ...[
          SizedBox(height: spacing ?? 4),
          Text(
            description!,
            style: descriptionStyle,
            maxLines: descriptionMaxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        SizedBox(height: spacing ?? 8),
        Text(
          price,
          style: priceStyle,
          maxLines: priceMaxLines,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
