import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../l10n/strings.dart';
import '../../theme/app_theme.dart';
import '../../utils/data_loader_extension.dart';
import '../../components/image_picker_widget.dart';
import '../../components/product_form_fields.dart';
import '../../utils/snackbar_util.dart';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({super.key});

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;

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

  Future<void> _createProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      final price = int.parse(_priceController.text.trim());

      List<int>? imageBytes;
      String? imageFilename;

      if (_selectedImage != null) {
        imageBytes = await _selectedImage!.readAsBytes();
        imageFilename = _selectedImage!.path.split('/').last;
      }

      final product = await getApiService().createProduct(
        name: name,
        price: price,
        description: description.isNotEmpty ? description : null,
        imageBytes: imageBytes,
        imageFilename: imageFilename,
      );

      if (!mounted) return;

      SnackbarUtil.showSuccess(
        context,
        AppStrings.tr(context, 'productCreatedSuccessfully'),
      );

      Navigator.pop(context, product);
    } catch (e) {
      if (!mounted) return;

      SnackbarUtil.showError(
        context,
        '${AppStrings.tr(context, 'failedToCreateProduct')}: $e',
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
        title: Text(AppStrings.tr(context, 'createNewProduct')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Picker Widget
              ImagePickerWidget(
                selectedImage: _selectedImage,
                onPickImage: _pickImage,
                onRemoveImage: _removeImage,
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
                  if (int.tryParse(value.trim()) == null) {
                    return AppStrings.tr(context, 'priceRequired');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Create Button
              ElevatedButton(
                onPressed: _isLoading ? null : _createProduct,
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
                        AppStrings.tr(context, 'createNewProduct'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
