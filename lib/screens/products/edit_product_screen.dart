import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/product.dart';
import '../../l10n/strings.dart';
import '../../theme/app_theme.dart';
import '../../utils/data_loader_extension.dart';

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
    final priceStr = _priceController.text.trim();

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.tr(context, 'productUpdatedSuccessfully')),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, updatedProduct);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppStrings.tr(context, 'failedToUpdateProduct')}: $e',
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
        title: Text(AppStrings.tr(context, 'editProduct')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Section
            GestureDetector(
              onTap: _pickImage,
              child: Container(
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
                    : widget.product.imageId != null
                        ? Stack(
                            children: [
                              FutureBuilder<String?>(
                                future: Future.value(
                                  widget.product.getImageUrl(
                                    getApiService().baseUrl,
                                  ),
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData && snapshot.data != null) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(11),
                                      child: Image.network(
                                        snapshot.data!,
                                        height: 250,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, trace) {
                                          return Container(
                                            height: 250,
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.broken_image),
                                          );
                                        },
                                      ),
                                    );
                                  }
                                  return Container(
                                    height: 250,
                                    color: Colors.grey[300],
                                  );
                                },
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: FloatingActionButton(
                                  mini: true,
                                  backgroundColor: Colors.orange,
                                  onPressed: _pickImage,
                                  child: const Icon(Icons.edit),
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
            ),
            const SizedBox(height: 24),

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
