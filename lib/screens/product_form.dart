// import 'dart:html' as html;

// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:happy_deals_pro/classes/categorie_product.dart';
// import 'package:happy_deals_pro/classes/product.dart';
// import 'package:happy_deals_pro/services/product_service.dart';
// import 'package:image_picker_web/image_picker_web.dart';
// import 'package:uuid/uuid.dart';

// class ProductForm extends StatefulWidget {
//   final Product? product;

//   const ProductForm({super.key, this.product});

//   @override
//   _ProductFormState createState() => _ProductFormState();
// }

// class _ProductFormState extends State<ProductForm> {
//   final _formKey = GlobalKey<FormState>();
//   final ProductService _productService = ProductService();
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   final uuid = const Uuid();

//   int _currentStep = 0;
//   String? _selectedCategory;
//   Map<String, dynamic> _attributes = {};

//   late TextEditingController _nameController;
//   late TextEditingController _descriptionController;
//   late TextEditingController _priceController;
//   late TextEditingController _stockController;
//   late bool _isActive;
//   final List<html.File> _images = [];
//   List<String> _existingImageUrls = [];
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController(text: widget.product?.name ?? '');
//     _descriptionController =
//         TextEditingController(text: widget.product?.description ?? '');
//     _priceController =
//         TextEditingController(text: widget.product?.price.toString() ?? '');
//     _stockController =
//         TextEditingController(text: widget.product?.stock.toString() ?? '');
//     _isActive = widget.product?.isActive ?? true;
//     _existingImageUrls = widget.product?.images ?? [];
//     _selectedCategory = widget.product?.categoryId;
//     _attributes = widget.product?.attributes ?? {};
//   }

//   List<Step> get _formSteps => [
//         Step(
//           title: const Text('Catégorie'),
//           content: _buildCategoryDropdown(),
//           isActive: _currentStep >= 0,
//         ),
//         Step(
//           title: const Text('Informations de base'),
//           content: _buildBasicInfoFields(),
//           isActive: _currentStep >= 1,
//         ),
//         Step(
//           title: const Text('Attributs'),
//           content: _buildAttributesFields(),
//           isActive: _currentStep >= 2,
//         ),
//         Step(
//           title: const Text('Images'),
//           content: _buildImageUploader(),
//           isActive: _currentStep >= 3,
//         ),
//       ];

//   Widget _buildCategoryDropdown() {
//     return DropdownButtonFormField<String>(
//       value: _selectedCategory,
//       decoration: InputDecoration(
//         labelText: 'Catégorie',
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//       items: ecommerceCategories.map((category) {
//         return DropdownMenuItem(
//           value: category.id,
//           child: Text(category.name),
//         );
//       }).toList(),
//       onChanged: (String? newValue) {
//         setState(() {
//           _selectedCategory = newValue;
//           _attributes = {}; // Reset attributes when category changes
//         });
//       },
//     ).animate().fadeIn(duration: 300.ms);
//   }

//   Widget _buildBasicInfoFields() {
//     return Column(
//       children: [
//         _buildTextField(_nameController, 'Nom du produit', Icons.shopping_bag),
//         const SizedBox(height: 16),
//         _buildTextField(
//             _descriptionController, 'Description', Icons.description,
//             maxLines: 3),
//         const SizedBox(height: 16),
//         Row(
//           children: [
//             Expanded(
//                 child: _buildTextField(_priceController, 'Prix', Icons.euro,
//                     keyboardType: TextInputType.number)),
//             const SizedBox(width: 16),
//             Expanded(
//                 child: _buildTextField(
//                     _stockController, 'Stock', Icons.inventory,
//                     keyboardType: TextInputType.number)),
//           ],
//         ),
//         const SizedBox(height: 16),
//         SwitchListTile(
//           title: const Text('Produit actif',
//               style: TextStyle(fontWeight: FontWeight.bold)),
//           value: _isActive,
//           onChanged: (value) => setState(() => _isActive = value),
//           activeColor: Theme.of(context).primaryColor,
//         ),
//       ],
//     ).animate().fadeIn(duration: 300.ms);
//   }

//   Widget _buildAttributesFields() {
//     final category = ecommerceCategories.firstWhere(
//       (c) => c.id == _selectedCategory,
//       orElse: () => Category(id: '', name: '', allowedAttributes: []),
//     );
//     return Column(
//       children: category.allowedAttributes.map((attr) {
//         return Padding(
//           padding: const EdgeInsets.only(bottom: 16),
//           child: TextFormField(
//             decoration: InputDecoration(
//               labelText: attr,
//               border:
//                   OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//             initialValue: _attributes[attr]?.toString() ?? '',
//             onChanged: (value) {
//               setState(() {
//                 if (value.isEmpty) {
//                   _attributes.remove(attr);
//                 } else {
//                   _attributes[attr] = value;
//                 }
//               });
//             },
//           ),
//         );
//       }).toList(),
//     ).animate().fadeIn(duration: 300.ms);
//   }

//   Widget _buildImageUploader() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Images du produit',
//             style: TextStyle(fontWeight: FontWeight.bold)),
//         const SizedBox(height: 16),
//         _buildImageGrid(),
//       ],
//     ).animate().fadeIn(duration: 300.ms);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//             widget.product == null ? 'Nouveau produit' : 'Modifier le produit'),
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         foregroundColor: Colors.black,
//       ),
//       body: Form(
//         key: _formKey,
//         child: Stepper(
//           type: StepperType.horizontal,
//           currentStep: _currentStep,
//           onStepContinue: () {
//             if (_currentStep < _formSteps.length - 1) {
//               setState(() => _currentStep += 1);
//             } else {
//               _submitForm();
//             }
//           },
//           onStepCancel: () {
//             if (_currentStep > 0) {
//               setState(() => _currentStep -= 1);
//             }
//           },
//           steps: _formSteps,
//           controlsBuilder: (context, details) {
//             return Padding(
//               padding: const EdgeInsets.only(top: 20),
//               child: Row(
//                 children: [
//                   ElevatedButton(
//                     onPressed: details.onStepContinue,
//                     child: Text(_currentStep < _formSteps.length - 1
//                         ? 'Continuer'
//                         : 'Enregistrer'),
//                   ),
//                   if (_currentStep > 0) ...[
//                     const SizedBox(width: 12),
//                     TextButton(
//                       onPressed: details.onStepCancel,
//                       child: const Text('Retour'),
//                     ),
//                   ],
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(
//       TextEditingController controller, String label, IconData icon,
//       {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
//     return TextFormField(
//       controller: controller,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         filled: true,
//         fillColor: Colors.grey[100],
//       ),
//       maxLines: maxLines,
//       keyboardType: keyboardType,
//       validator: (value) =>
//           value!.isEmpty ? 'Ce champ ne peut pas être vide' : null,
//     ).animate().fadeIn(duration: 300.ms, delay: 100.ms);
//   }

//   Widget _buildImageGrid() {
//     final totalImages = _existingImageUrls.length + _images.length;
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 4,
//         crossAxisSpacing: 10,
//         mainAxisSpacing: 10,
//         childAspectRatio: 1, // Assure que chaque élément est carré
//       ),
//       itemCount: totalImages + 1,
//       itemBuilder: (context, index) {
//         return index == totalImages
//             ? _addImageButton()
//             : index < _existingImageUrls.length
//                 ? _imageCard(_existingImageUrls[index], index, true)
//                 : _imageCard(
//                     _images[index - _existingImageUrls.length], index, false);
//       },
//     ).animate().fadeIn(duration: 300.ms, delay: 100.ms);
//   }

//   Widget _addImageButton() {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey, width: 1),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: IconButton(
//         icon: const Icon(Icons.add_photo_alternate, size: 30),
//         onPressed: _pickImages,
//         padding: EdgeInsets.zero,
//         constraints: const BoxConstraints(),
//         color: Colors.grey,
//       ),
//     );
//   }

//   Future<void> _pickImages() async {
//     final images = await ImagePickerWeb.getMultiImagesAsFile();
//     if (images != null) {
//       setState(() {
//         _images.addAll(images);
//       });
//     }
//   }

//   Widget _imageCard(dynamic image, int index, bool isExisting) {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(8),
//           child: isExisting
//               ? Image.network(image, fit: BoxFit.cover)
//               : Image.network(
//                   html.Url.createObjectUrlFromBlob(image),
//                   fit: BoxFit.cover,
//                 ),
//         ),
//         Positioned(
//           top: 0,
//           right: 0,
//           child: IconButton(
//             icon: const Icon(Icons.close, color: Colors.white, size: 18),
//             onPressed: () => _removeImage(index),
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(),
//             style: ButtonStyle(
//               backgroundColor: WidgetStateProperty.all(Colors.black54),
//               shape: WidgetStateProperty.all(const CircleBorder()),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   void _removeImage(int index) {
//     setState(() {
//       if (index < _existingImageUrls.length) {
//         _existingImageUrls.removeAt(index);
//       } else {
//         _images.removeAt(index - _existingImageUrls.length);
//       }
//     });
//   }

//   Future<List<String>> _uploadImages() async {
//     List<String> uploadedUrls = [];
//     for (var image in _images) {
//       final String fileName = '${uuid.v4()}.jpg';
//       final Reference ref = _storage.ref().child('product_images/$fileName');
//       final UploadTask uploadTask = ref.putBlob(image);
//       final TaskSnapshot snapshot = await uploadTask;
//       final String downloadUrl = await snapshot.ref.getDownloadURL();
//       uploadedUrls.add(downloadUrl);
//     }
//     return uploadedUrls;
//   }

//   // ... (keep other methods like _buildTextField, _buildImageGrid, _pickImages, _removeImage, _uploadImages)

//   void _submitForm() async {
//     if (_formKey.currentState!.validate()) {
//       if (_selectedCategory == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Veuillez sélectionner une catégorie')),
//         );
//         return;
//       }

//       setState(() => _isLoading = true);

//       try {
//         final List<String> imageUrls = await _uploadImages();
//         final product = Product(
//           id: widget.product?.id ?? '',
//           name: _nameController.text,
//           description: _descriptionController.text,
//           price: double.parse(_priceController.text),
//           images: [..._existingImageUrls, ...imageUrls],
//           stock: int.parse(_stockController.text),
//           isActive: _isActive,
//           merchantId: widget.product?.merchantId ?? '',
//           stripeProductId: widget.product?.stripeProductId ?? '',
//           stripePriceId: widget.product?.stripePriceId ?? '',
//           categoryId: _selectedCategory!,
//           attributes: _attributes,
//         );

//         if (widget.product == null) {
//           await _productService.createProduct(product);
//         } else {
//           await _productService.updateProduct(product);
//         }

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text(
//                   'Produit ${widget.product == null ? 'créé' : 'mis à jour'} avec succès')),
//         );
//         Navigator.pop(context);
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text('Erreur lors de l\'enregistrement du produit: $e')),
//         );
//       } finally {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
// }
