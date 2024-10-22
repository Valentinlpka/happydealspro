// company_provider.dart
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

const kGoogleApiKey = "AIzaSyCS3N9FwFLGHDRSN7PbCSIhDrTjMPALfLc";

class CompanyProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String get companyName => _companyData?['name'] ?? '';
  String get companyCategorie => _companyData?['categorie'] ?? '';
  String get companyLogo => _companyData?['logo'] ?? '';
  String get companyCover => _companyData?['cover'] ?? '';
  String get companyVille => _companyData?['adress']['ville'] ?? '';

  Future<void> refreshCompanyData() async {
    await loadCompanyData();
  }

  Map<String, dynamic>? _companyData;
  Map<String, dynamic>? get companyData => _companyData;

  File? _coverImage;
  Uint8List? _webCoverImage;
  String? _existingCoverUrl;

  File? get coverImage => _coverImage;
  Uint8List? get webCoverImage => _webCoverImage;
  String? get existingCoverUrl => _existingCoverUrl;

  File? _logoImage;
  Uint8List? _webLogoImage;
  String? _existingLogoUrl;

  File? get logoImage => _logoImage;
  Uint8List? get webLogoImage => _webLogoImage;
  String? get existingLogoUrl => _existingLogoUrl;

  CompanyProvider() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        loadCompanyData();
      } else {
        // Réinitialiser les données si l'utilisateur est déconnecté
        _companyData = null;
        _existingLogoUrl = null;
        _existingCoverUrl = null;
        notifyListeners();
      }
    });
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  Future<void> pickCoverImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        _webCoverImage = await pickedFile.readAsBytes();
      } else {
        _coverImage = File(pickedFile.path);
      }
      _existingCoverUrl = null;
      notifyListeners();
    }
  }

  Future<void> pickLogoImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        _webLogoImage = await pickedFile.readAsBytes();
      } else {
        _logoImage = File(pickedFile.path);
      }
      _existingLogoUrl = null;
      notifyListeners();
    }
  }

  void removeLogoImage() {
    _logoImage = null;
    _webLogoImage = null;
    _existingLogoUrl = null;
    notifyListeners();
  }

  Future<void> removeCoverImage() async {
    _coverImage = null;
    _webCoverImage = null;
    _existingCoverUrl = null;
    notifyListeners();
  }

  static const Map<String, String> dayTranslations = {
    'Lundi': 'monday',
    'Mardi': 'tuesday',
    'Mercredi': 'wednesday',
    'Jeudi': 'thursday',
    'Vendredi': 'friday',
    'Samedi': 'saturday',
    'Dimanche': 'sunday',
  };

  Future<void> loadCompanyData() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('companys').doc(user.uid).get();
        if (doc.exists) {
          _companyData = doc.data();
          _existingLogoUrl = _companyData?['logo'];
          _existingCoverUrl = _companyData?['cover'];

          notifyListeners();
        } else {
          print('Aucune donnée d\'entreprise trouvée pour cet utilisateur.');
        }
      } catch (e) {
        print('Erreur lors du chargement des données de l\'entreprise: $e');
      }
    }
  }

  Future<void> updateCompany(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('companys').doc(user.uid).update(data);
      _companyData = {...?_companyData, ...data};
      notifyListeners();
    }
  }

  Future<String> createCompany(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('companys').doc(user.uid).set(data);
      _companyData = data;
      notifyListeners();
      return user.uid;
    }
    throw Exception('Utilisateur non authentifié');
  }

  Future<String> uploadLogo(File? logoFile, Uint8List? webImage) async {
    final user = _auth.currentUser;
    if (user != null) {
      final ref =
          _storage.ref().child('company_logos').child('${user.uid}.jpg');
      if (logoFile != null) {
        await ref.putFile(logoFile);
      } else if (webImage != null) {
        await ref.putData(webImage);
      } else {
        return _companyData?['logo'] ?? '';
      }
      return await ref.getDownloadURL();
    }
    throw Exception('User not logged in');
  }

  Future<String?> uploadImage(
      File? imageFile, Uint8List? webImage, String imageType) async {
    if (imageFile == null && webImage == null) {
      return null; // Retourne null au lieu de lancer une exception
    }

    try {
      final storage = FirebaseStorage.instance;
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      final ref = storage.ref().child(
          'company_images/$userId/${imageType}_${DateTime.now().millisecondsSinceEpoch}');

      UploadTask uploadTask;
      if (kIsWeb && webImage != null) {
        uploadTask = ref.putData(webImage);
      } else if (!kIsWeb && imageFile != null) {
        uploadTask = ref.putFile(imageFile);
      } else {
        return null; // Retourne null si aucune image n'est fournie
      }

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Erreur lors du téléchargement de l\'image: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> searchPlaces(String input) async {
    if (input.length < 5) {
      return []; // Ne commence la recherche qu'à partir de 5 caractères
    }

    final String request =
        'https://cors-anywhere.herokuapp.com/https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=address&components=country:fr&key=$kGoogleApiKey';
    try {
      final response = await http.get(Uri.parse(request));
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'OK') {
          return result['predictions'];
        }
      }
    } catch (e) {
      print('Error: $e');
    }
    return [];
  }

  String _sessionToken = '';
  String _getSessionToken() {
    if (_sessionToken.isEmpty) {
      _sessionToken = DateTime.now().millisecondsSinceEpoch.toString();
    }
    return _sessionToken;
  }

  // Réinitialiser le token de session
  void resetSessionToken() {
    _sessionToken = '';
  }

  Future<Map<String, String>> getPlaceDetails(String placeId) async {
    final String request =
        'https://cors-anywhere.herokuapp.com/https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$kGoogleApiKey';

    try {
      final response = await http.get(Uri.parse(request));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API Response: ${response.body}'); // Pour le débogage

        if (data['status'] == 'OK' && data['result'] != null) {
          final result = data['result'];

          // Fonction helper pour extraire en toute sécurité les composants d'adresse
          String getAddressComponent(String type) {
            final components =
                result['address_components'] as List<dynamic>? ?? [];
            for (var component in components) {
              final types = component['types'] as List<dynamic>? ?? [];
              if (types.contains(type)) {
                return component['long_name'] as String? ?? '';
              }
            }
            return '';
          }

          return {
            'address': result['name'] as String? ?? '',
            'postalCode': getAddressComponent('postal_code'),
            'city': getAddressComponent('locality'),
            'latitude':
                (result['geometry']['location']['lat'] as num?)?.toString() ??
                    '',
            'longitude':
                (result['geometry']['location']['lng'] as num?)?.toString() ??
                    '',
          };
        } else {
          print('API returned non-OK status or null result: ${data['status']}');
          return {};
        }
      } else {
        print('HTTP request failed with status: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      print('Error in getPlaceDetails: $e');
      return {};
    }
  }
}
