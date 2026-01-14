import 'package:flutter/material.dart';
import 'dart:io';
import '../theme/app_theme.dart';
import '../l10n/strings.dart';

/// Reusable image picker widget for product creation/editing
class ImagePickerWidget extends StatelessWidget {
  final File? selectedImage;
  final String? networkImageUrl;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;
  final double height;
  final String? editButtonLabel;
  final bool showEditButton;

  const ImagePickerWidget({
    super.key,
    this.selectedImage,
    this.networkImageUrl,
    required this.onPickImage,
    required this.onRemoveImage,
    this.height = 250,
    this.editButtonLabel,
    this.showEditButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPickImage,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          color: AppColors.card,
        ),
        child: selectedImage != null
            ? _buildSelectedImagePreview(context)
            : networkImageUrl != null
                ? _buildNetworkImagePreview(context)
                : _buildEmptyImagePlaceholder(context),
      ),
    );
  }

  Widget _buildSelectedImagePreview(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Image.file(
            selectedImage!,
            height: height,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.red,
            onPressed: onRemoveImage,
            child: const Icon(Icons.close),
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkImagePreview(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Image.network(
            networkImageUrl!,
            height: height,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, trace) {
              return Container(
                height: height,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image),
              );
            },
          ),
        ),
        if (showEditButton)
          Positioned(
            top: 8,
            right: 8,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.orange,
              onPressed: onPickImage,
              child: const Icon(Icons.edit),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyImagePlaceholder(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: height / 3),
        Icon(
          Icons.image_outlined,
          size: 64,
          color: Colors.grey[600],
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.tr(context, 'noImageSelected'),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: onPickImage,
          icon: const Icon(Icons.add_photo_alternate),
          label: Text(
            editButtonLabel ?? AppStrings.tr(context, 'uploadImage'),
          ),
        ),
        SizedBox(height: height / 3),
      ],
    );
  }
}
