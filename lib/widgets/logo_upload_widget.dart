import 'package:flutter/material.dart';

class ImageUploadWidget extends StatelessWidget {
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;
  final Widget imageWidget;
  final bool isUploaded;
  final String label;

  const ImageUploadWidget({
    super.key,
    required this.onPickImage,
    required this.onRemoveImage,
    required this.imageWidget,
    required this.isUploaded,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.topRight,
          children: [
            InkWell(
              onTap: onPickImage,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: imageWidget,
                ),
              ),
            ),
            if (isUploaded)
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle,
                      color: Colors.green, size: 24),
                ),
              ),
            if (isUploaded)
              Positioned(
                bottom: 5,
                right: 5,
                child: InkWell(
                  onTap: onRemoveImage,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(5),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
