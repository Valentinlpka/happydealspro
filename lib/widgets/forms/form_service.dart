// lib/pages/services/service_form_screen.dart
import 'dart:html' as html;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:happy_deals_pro/classes/service_model.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:uuid/uuid.dart';

import '../../services/service_service.dart';

class ServiceFormScreen extends StatefulWidget {
  final ServiceModel? service;
  final String professionalId;
  final VoidCallback onServiceSaved;

  const ServiceFormScreen(
      {super.key,
      this.service,
      required this.professionalId,
      required this.onServiceSaved});

  @override
  _ServiceFormScreenState createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ServiceService _serviceService = ServiceService();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final uuid = const Uuid();

  // Initialiser les contrôleurs directement
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _durationController =
      TextEditingController(text: '30');
  bool _isActive = true;
  final List<html.File> _images = [];
  List<String> _existingImageUrls = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadServiceData();
  }

  @override
  void didUpdateWidget(ServiceFormScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.service != oldWidget.service) {
      _loadServiceData();
    }
  }

  void _loadServiceData() {
    if (widget.service != null) {
      _nameController.text = widget.service!.name;
      _descriptionController.text = widget.service!.description;
      _priceController.text = widget.service!.price.toString();
      _durationController.text = widget.service!.duration.toString();
      _isActive = widget.service!.isActive;
      _existingImageUrls = widget.service!.images;
    } else {
      _nameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _durationController.text = '30';
      _isActive = true;
      _existingImageUrls = [];
    }
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
        childAspectRatio: 1,
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
              : Image.network(html.Url.createObjectUrlFromBlob(image),
                  fit: BoxFit.cover),
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

  Future<List<String>> _uploadImages() async {
    List<String> uploadedUrls = [];
    for (var image in _images) {
      final String fileName = '${uuid.v4()}.jpg';
      final Reference ref = _storage.ref().child('service_images/$fileName');
      final UploadTask uploadTask = ref.putBlob(image);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      uploadedUrls.add(downloadUrl);
    }
    return uploadedUrls;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final List<String> imageUrls = await _uploadImages();

        final service = ServiceModel(
          id: widget.service?.id ?? '',
          name: _nameController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          duration: int.parse(_durationController.text),
          professionalId: FirebaseAuth.instance.currentUser!.uid,
          images: [..._existingImageUrls, ...imageUrls],
          isActive: _isActive,
          createdAt: widget.service?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        if (widget.service == null) {
          await _serviceService.createService(service);
        } else {
          await _serviceService.updateService(service);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Service ${widget.service == null ? 'créé' : 'mis à jour'} avec succès')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur lors de l\'enregistrement du service: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
                  'Informations du service',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ).animate().fadeIn(duration: 300.ms),
                const SizedBox(height: 24),
                _buildTextField(_nameController, 'Nom du service', Icons.spa),
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
                          keyboardType: TextInputType.number),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                          _durationController, 'Durée (minutes)', Icons.timer,
                          keyboardType: TextInputType.number),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SwitchListTile(
                  title: const Text('Service actif',
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
                  'Images du service',
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
                        child: Text(widget.service == null
                            ? 'Créer le service'
                            : 'Mettre à jour le service'),
                      ).animate().scale(duration: 300.ms, delay: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }
}
