import 'dart:html' as html;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:happy_deals_pro/classes/news.dart';
import 'package:happy_deals_pro/widgets/normalize_text.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:uuid/uuid.dart';

class FormNews extends StatefulWidget {
  const FormNews({super.key});

  @override
  _FormNewsState createState() => _FormNewsState();
}

class _FormNewsState extends State<FormNews> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final uuid = const Uuid();

  QuillController _quillController = QuillController.basic();
  late TextEditingController _titleController;

  final List<html.File> _images = [];
  List<String> _existingImageUrls = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _quillController = QuillController.basic();

    _titleController = TextEditingController();
    _existingImageUrls = [];
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
                  'Nouveau post',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ).animate().fadeIn(duration: 300.ms),
                const SizedBox(height: 24),
                _buildTextField(
                    _titleController, 'Titre', Icons.title_outlined),
                const SizedBox(height: 16),
                const Text(
                  'Contenu',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
                const SizedBox(height: 8),
                QuillToolbar.simple(controller: _quillController),
                const SizedBox(height: 8),
                SizedBox(
                  height: 300,
                  child: QuillEditor.basic(
                    controller: _quillController,
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
                const SizedBox(height: 16),
                const Text(
                  'Images du post',
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
                        child: const Text('Créer le post'),
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
        User? userId = FirebaseAuth.instance.currentUser;
        String userUid = userId?.uid ?? "";
        final List<String> imageUrls = await _uploadImages();
        String eventId =
            FirebaseFirestore.instance.collection('posts').doc().id;
        final String content = _quillController.document.toPlainText();

        // Création du produit
        News news = News(
          id: '',
          title: _titleController.text,
          content: content,
          timestamp: DateTime.now(),
          searchText: normalizeText(_titleController.text),
          companyId: userUid,
          photos: [..._existingImageUrls, ...imageUrls],
        );

        await FirebaseFirestore.instance
            .collection('posts')
            .doc(eventId)
            .set(news.toMap());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post créer')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur lors de l\'enregistrement du post: $e')),
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
      final Reference ref = _storage.ref().child('post_image/$fileName');
      final UploadTask uploadTask = ref.putBlob(image);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      uploadedUrls.add(downloadUrl);
    }
    return uploadedUrls;
  }
}
