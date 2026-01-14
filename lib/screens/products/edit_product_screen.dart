import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/product.dart';
import '../../l10n/strings.dart';
import '../../theme/app_theme.dart';
import '../../utils/data_loader_extension.dart';
import '../../components/image_picker_widget.dart';
import '../../components/product_form_fields.dart';
import '../../utils/snackbar_util.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;

  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController = TextEditingController(
      text: widget.product.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.product.price.toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.tr(context, 'imageUploadFailed'))),
      );
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _updateProduct() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final priceStr = _priceController.text.replaceAll(RegExp(r'[^0-9]'), '').trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.tr(context, 'productNameRequired')),
        ),
      );
      return;
    }

    if (priceStr.isEmpty || int.tryParse(priceStr) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.tr(context, 'priceRequired')),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final price = int.parse(priceStr);

      List<int>? imageBytes;
      String? imageFilename;

      if (_selectedImage != null) {
        imageBytes = await _selectedImage!.readAsBytes();
        imageFilename = _selectedImage!.path.split('/').last;
      }

      final updatedProduct = await getApiService().updateProduct(
        widget.product.id,
        name: name,
        price: price,
        description: description.isNotEmpty ? description : null,
        imageBytes: imageBytes,
        imageFilename: imageFilename,
      );

      if (!mounted) return;

      SnackbarUtil.showSuccess(
        context,
        AppStrings.tr(context, 'productUpdatedSuccessfully'),
      );

      Navigator.pop(context, updatedProduct);
    } catch (e) {
      if (!mounted) return;

      SnackbarUtil.showError(
        context,
        '${AppStrings.tr(context, 'failedToUpdateProduct')}: $e',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.tr(context, 'editProduct')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Picker Widget
            ImagePickerWidget(
              selectedImage: _selectedImage,
              networkImageUrl: widget.product.imageId != null
                  ? widget.product.getImageUrl(getApiService().baseUrl)
                  : null,
              onPickImage: _pickImage,
              onRemoveImage: _removeImage,
              showEditButton: widget.product.imageId != null && _selectedImage == null,
            ),
            const SizedBox(height: 24),

            // Product Form Fields
            ProductFormFields(
              nameController: _nameController,
              descriptionController: _descriptionController,
              priceController: _priceController,
              nameValidator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.tr(context, 'productNameRequired');
                }
                return null;
              },
              priceValidator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.tr(context, 'priceRequired');
                }
                final unformatted = value.replaceAll(RegExp(r'[^0-9]'), '').trim();
                if (int.tryParse(unformatted) == null || unformatted == '0') {
                  return AppStrings.tr(context, 'priceRequired');
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Update Button
            ElevatedButton(
              onPressed: _isLoading ? null : _updateProduct,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: Colors.grey[400],
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      AppStrings.tr(context, 'saveChanges'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
