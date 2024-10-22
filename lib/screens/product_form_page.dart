import 'dart:html' as html;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:happy_deals_pro/classes/product.dart';
import 'package:happy_deals_pro/services/product_service.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:uuid/uuid.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final uuid = const Uuid();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _tvaController;
  late TextEditingController _stockController;
  late bool _isActive;
  final List<html.File> _images = [];
  List<String> _existingImageUrls = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.product?.description ?? '');
    _tvaController =
        TextEditingController(text: widget.product?.tva.toString() ?? '');
    _priceController =
        TextEditingController(text: widget.product?.price.toString() ?? '');
    _stockController =
        TextEditingController(text: widget.product?.stock.toString() ?? '');
    _isActive = widget.product?.isActive ?? true;
    _existingImageUrls = widget.product?.images ?? [];
  }

  Future<void> _pickImages() async {
    final images = await ImagePickerWeb.getMultiImagesAsFile();
    if (images != null) {
      setState(() {
        _images.addAll(images);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      if (index < _existingImageUrls.length) {
        _existingImageUrls.removeAt(index);
      } else {
        _images.removeAt(index - _existingImageUrls.length);
      }
    });
  }

  Widget _buildImageGrid() {
    final totalImages = _existingImageUrls.length + _images.length;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1, // Assure que chaque élément est carré
      ),
      itemCount: totalImages + 1,
      itemBuilder: (context, index) {
        return index == totalImages
            ? _addImageButton()
            : index < _existingImageUrls.length
                ? _imageCard(_existingImageUrls[index], index, true)
                : _imageCard(
                    _images[index - _existingImageUrls.length], index, false);
      },
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms);
  }

  Widget _addImageButton() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: const Icon(Icons.add_photo_alternate, size: 30),
        onPressed: _pickImages,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        color: Colors.grey,
      ),
    );
  }

  Widget _imageCard(dynamic image, int index, bool isExisting) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: isExisting
              ? Image.network(image, fit: BoxFit.cover)
              : Image.network(
                  html.Url.createObjectUrlFromBlob(image),
                  fit: BoxFit.cover,
                ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 18),
            onPressed: () => _removeImage(index),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.black54),
              shape: WidgetStateProperty.all(const CircleBorder()),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Informations du produit',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ).animate().fadeIn(duration: 300.ms),
                const SizedBox(height: 24),
                _buildTextField(
                    _nameController, 'Nom du produit', Icons.shopping_bag),
                const SizedBox(height: 16),
                _buildTextField(
                    _descriptionController, 'Description', Icons.description,
                    maxLines: 3),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: _buildTextField(
                            _priceController, 'Prix', Icons.euro,
                            keyboardType: TextInputType.number)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildTextField(
                            _tvaController, 'TVA en %', Icons.inventory,
                            keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(_stockController, 'Stock', Icons.inventory,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 24),
                SwitchListTile(
                  title: const Text('Produit actif',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                  activeColor: Theme.of(context).primaryColor,
                ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
                const SizedBox(height: 24),
                const Text(
                  'Images du produit',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ).animate().fadeIn(duration: 300.ms, delay: 300.ms),
                const SizedBox(height: 16),
                SizedBox(child: _buildImageGrid()),
                const SizedBox(height: 32),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(widget.product == null
                            ? 'Créer le produit'
                            : 'Mettre à jour le produit'),
                      ).animate().scale(duration: 300.ms, delay: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: (value) =>
          value!.isEmpty ? 'Ce champ ne peut pas être vide' : null,
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms);
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final List<String> imageUrls = await _uploadImages();
        final product = Product(
          id: widget.product?.id ?? '',
          name: _nameController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          tva: double.parse(_tvaController.text),
          images: [..._existingImageUrls, ...imageUrls],
          stock: int.parse(_stockController.text),
          isActive: _isActive,
          sellerId: FirebaseAuth.instance.currentUser!.uid,
          merchantId: widget.product?.merchantId ?? '',
          stripeProductId: widget.product?.stripeProductId ?? '',
          stripePriceId: widget.product?.stripePriceId ?? '',
        );

        if (widget.product == null) {
          await _productService.createProduct(product);
        } else {
          await _productService.updateProduct(product);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Produit ${widget.product == null ? 'créé' : 'mis à jour'} avec succès')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur lors de l\'enregistrement du produit: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<List<String>> _uploadImages() async {
    List<String> uploadedUrls = [];
    for (var image in _images) {
      final String fileName = '${uuid.v4()}.jpg';
      final Reference ref = _storage.ref().child('product_images/$fileName');
      final UploadTask uploadTask = ref.putBlob(image);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      uploadedUrls.add(downloadUrl);
    }
    return uploadedUrls;
  }
}
