import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../l10n/strings.dart';
import '../../theme/app_theme.dart';
import '../../utils/data_loader_extension.dart';

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.tr(context, 'productCreatedSuccessfully')),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, product);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppStrings.tr(context, 'failedToCreateProduct')}: $e',
          ),
          backgroundColor: Colors.red,
        ),
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
              // Image Section
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                  color: AppColors.card,
                ),
                child: _selectedImage != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: Image.file(
                              _selectedImage!,
                              height: 250,
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
                              onPressed: _removeImage,
                              child: const Icon(Icons.close),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
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
                            onPressed: _pickImage,
                            icon: const Icon(Icons.add_photo_alternate),
                            label: Text(
                              AppStrings.tr(context, 'uploadImage'),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
              ),
              const SizedBox(height: 24),

              // Change Image Button
              if (_selectedImage != null)
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.edit),
                  label: Text(
                    AppStrings.tr(context, 'selectImageFromGallery'),
                  ),
                )
              else
                const SizedBox.shrink(),

              if (_selectedImage != null) const SizedBox(height: 16),

              // Product Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: AppStrings.tr(context, 'name'),
                  hintText: AppStrings.tr(context, 'enterProductName'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.label_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.tr(context, 'productNameRequired');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Product Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: AppStrings.tr(context, 'description'),
                  hintText: AppStrings.tr(context, 'enterProductDescription'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.description_outlined),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Product Price
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: AppStrings.tr(context, 'price'),
                  hintText: AppStrings.tr(context, 'enterProductPrice'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
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
