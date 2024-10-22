import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:universal_html/html.dart' as html;

class ImagePickerWidget extends StatefulWidget {
  final Function(dynamic) onImageSelected;
  final Function() onImageRemoved;
  final String? initialImageUrl;

  const ImagePickerWidget({
    super.key,
    required this.onImageSelected,
    required this.onImageRemoved,
    this.initialImageUrl,
  });

  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  dynamic _image;
  bool _hasImage = false;

  @override
  void initState() {
    super.initState();
    _hasImage = widget.initialImageUrl != null;
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      final html.FileUploadInputElement input = html.FileUploadInputElement()
        ..accept = 'image/*';
      input.click();

      await input.onChange.first;
      if (input.files!.isNotEmpty) {
        final file = input.files![0];
        final reader = html.FileReader();
        reader.readAsDataUrl(file);
        await reader.onLoad.first;

        setState(() {
          _image = reader.result;
          _hasImage = true;
        });
        widget.onImageSelected(_image);
      }
    } else {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _hasImage = true;
        });
        widget.onImageSelected(_image);
      }
    }
  }

  void _removeImage() {
    setState(() {
      _image = null;
      _hasImage = false;
    });
    widget.onImageRemoved();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(12),
        padding: const EdgeInsets.all(6),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          child: Container(
            height: 200,
            width: double.infinity,
            color: Colors.grey[200],
            child: _hasImage
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_image != null)
                        kIsWeb
                            ? Image.network(_image as String, fit: BoxFit.cover)
                            : Image.file(_image as File, fit: BoxFit.cover)
                      else if (widget.initialImageUrl != null)
                        Image.network(widget.initialImageUrl!,
                            fit: BoxFit.cover),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: _removeImage,
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload,
                          size: 40, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'Cliquez ou glissez une image ici',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
