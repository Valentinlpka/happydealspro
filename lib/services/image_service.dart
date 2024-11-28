// lib/services/image_service.dart
import 'dart:html' as html;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class ImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final uuid = const Uuid();

  Future<List<String>> uploadImages(List<html.File> images) async {
    List<String> uploadedUrls = [];

    for (var image in images) {
      final String fileName = '${uuid.v4()}.jpg';
      final Reference ref = _storage.ref().child('service_images/$fileName');
      final UploadTask uploadTask = ref.putBlob(image);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      uploadedUrls.add(downloadUrl);
    }

    return uploadedUrls;
  }

  Future<void> deleteImages(List<String> imageUrls) async {
    for (var url in imageUrls) {
      try {
        final ref = FirebaseStorage.instance.refFromURL(url);
        await ref.delete();
      } catch (e) {
        print('Erreur lors de la suppression de l\'image: $e');
      }
    }
  }
}
