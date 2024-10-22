import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:happy_deals_pro/providers/company_provider.dart';
import 'package:happy_deals_pro/screens/home_page.dart';
import 'package:happy_deals_pro/widgets/logo_upload_widget.dart';
import 'package:happy_deals_pro/widgets/normalize_text.dart';
import 'package:happy_deals_pro/widgets/opening_hour.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

class CompanyFormPage extends StatefulWidget {
  final bool isNewUser;
  const CompanyFormPage({super.key, this.isNewUser = false});

  @override
  State<CompanyFormPage> createState() => _CompanyFormPageState();
}

class _CompanyFormPageState extends State<CompanyFormPage> {
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'FR');
  final _formKey = GlobalKey<FormState>();
  double? _latitude;
  double? _longitude;
  Timer? _debounce;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();

  Map<String, OpeningHourData> openingHours = {
    'Lundi': OpeningHourData(),
    'Mardi': OpeningHourData(),
    'Mercredi': OpeningHourData(),
    'Jeudi': OpeningHourData(),
    'Vendredi': OpeningHourData(),
    'Samedi': OpeningHourData(),
    'Dimanche': OpeningHourData(),
  };

  List<dynamic> _placeList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CompanyProvider>(context, listen: false);
      provider.loadCompanyData().then((_) {
        if (provider.companyData != null) {
          setState(() {
            _nameController.text = provider.companyData!['name'] ?? '';
            _addressController.text =
                provider.companyData!['adress']?['adresse'] ?? '';
            _postalCodeController.text =
                provider.companyData!['adress']?['code_postal'] ?? '';
            _cityController.text =
                provider.companyData!['adress']?['ville'] ?? '';
            _categoryController.text = provider.companyData!['categorie'] ?? '';
            _descriptionController.text =
                provider.companyData!['description'] ?? '';
            _emailController.text = provider.companyData!['email'] ?? '';
            _phoneNumber = PhoneNumber(
              phoneNumber: provider.companyData!['phone'] ?? '',
              isoCode: 'FR',
            );
            _websiteController.text = provider.companyData!['website'] ?? '';
            final Map<String, dynamic>? openingHoursData =
                provider.companyData!['openingHours'];
            if (openingHoursData != null) {
              openingHoursData.forEach((key, value) {
                String frenchDay = CompanyProvider.dayTranslations.entries
                    .firstWhere((entry) => entry.value == key)
                    .key;
                if (value is String) {
                  if (value == "Fermé") {
                    openingHours[frenchDay] = OpeningHourData(isOpen: false);
                  } else {
                    List<String> times = value.split('-');
                    if (times.length == 2) {
                      openingHours[frenchDay] = OpeningHourData(
                        isOpen: true,
                        openTime: times[0].trim(),
                        closeTime: times[1].trim(),
                      );
                    }
                  }
                }
              });
            }
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CompanyProvider>(context);
    final bool isEditing = provider.companyData != null;

    return Scaffold(
      appBar: widget.isNewUser
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.black),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushReplacementNamed(
                        '/login'); // Assurez-vous d'avoir défini cette route
                  },
                ),
              ],
            )
          : AppBar(
              title: Text(
                isEditing
                    ? 'Modifier l\'entreprise'
                    : 'Ajouter votre entreprise',
              ),
            ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(height: 100, 'assets/images/logo.png'),
                  const SizedBox(height: 20),
                  Text(
                    isEditing
                        ? 'Modifier l\'entreprise'
                        : 'Ajouter votre entreprise',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                          child: _buildTextField(
                              'Nom de l\'entreprise', _nameController)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _buildTextField(
                              'Catégorie', _categoryController)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildAddressField(),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: _buildTextField(
                              'Code postal', _postalCodeController)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _buildTextField('Ville', _cityController)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildTextField('Description', _descriptionController,
                      maxLines: 3),
                  const SizedBox(height: 10),
                  _buildTextField('Email', _emailController),
                  const SizedBox(width: 10),
                  _buildPhoneInput(),
                  const SizedBox(height: 10),
                  _buildTextField('Site web', _websiteController),
                  const SizedBox(height: 20),
                  _buildImageWidgets(),
                  const SizedBox(height: 20),
                  _buildOpeningHours(),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _submitForm,
                    child: Text(
                      isEditing
                          ? 'Modifier l\'entreprise'
                          : 'Ajouter l\'entreprise',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressField() {
    return Column(
      children: [
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Adresse',
            border: OutlineInputBorder(),
          ),
          onChanged: _searchPlaces,
        ),
        if (_placeList.isNotEmpty)
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: _placeList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_placeList[index]['description']),
                  onTap: () => _getPlaceDetails(_placeList[index]['place_id']),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildPhoneInput() {
    return InternationalPhoneNumberInput(
      onInputChanged: (PhoneNumber number) {
        _phoneNumber = number;
      },
      selectorConfig: const SelectorConfig(
          selectorType: PhoneInputSelectorType.BOTTOM_SHEET),
      initialValue: _phoneNumber,
      textFieldController: _phoneController,
      inputDecoration: const InputDecoration(
        labelText: 'Téléphone',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildOpeningHours() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Horaires d\'ouverture',
        ),
        const SizedBox(height: 10),
        ...openingHours.entries.map((entry) => OpeningHourWidget(
              day: entry.key,
              data: entry.value,
              onChanged: (newData) {
                setState(() {
                  openingHours[entry.key] = newData;
                });
              },
            )),
      ],
    );
  }

  Future<void> _searchPlaces(String input) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final provider = Provider.of<CompanyProvider>(context, listen: false);
      final places = await provider.searchPlaces(input);
      setState(() {
        _placeList = places;
      });
    });
  }

  Future<void> _getPlaceDetails(String placeId) async {
    final provider = Provider.of<CompanyProvider>(context, listen: false);
    final details = await provider.getPlaceDetails(placeId);
    setState(() {
      _addressController.text = details['address'] ?? '';
      _postalCodeController.text = details['postalCode'] ?? '';
      _cityController.text = details['city'] ?? '';
      _latitude = double.tryParse(details['latitude']?.toString() ?? '');

      _longitude = double.tryParse(details['longitude']?.toString() ?? '');
      _placeList = [];
    });
  }

  Map<String, dynamic> _getModifiedFields(
      Map<String, dynamic> currentData, Map<String, dynamic> newData) {
    Map<String, dynamic> modifiedFields = {};

    newData.forEach((key, value) {
      if (key == 'adress') {
        Map<String, dynamic> currentAddress = currentData['adress'] ?? {};
        Map<String, dynamic> newAddress = value;
        Map<String, dynamic> modifiedAddress = {};

        newAddress.forEach((addressKey, addressValue) {
          if (currentAddress[addressKey] != addressValue &&
              addressValue != null) {
            modifiedAddress[addressKey] = addressValue;
          }
        });

        if (modifiedAddress.isNotEmpty) {
          modifiedFields['adress'] = modifiedAddress;
        }
      } else if (currentData[key] != value && value != null) {
        modifiedFields[key] = value;
      }
    });

    return modifiedFields;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<CompanyProvider>(context, listen: false);
      try {
        String? logoUrl;
        String? coverUrl;

        if (provider.logoImage != null || provider.webLogoImage != null) {
          logoUrl = await provider.uploadImage(
              provider.logoImage, provider.webLogoImage, 'logo');
        } else if (provider.existingLogoUrl != null) {
          logoUrl = provider.existingLogoUrl;
        }

        if (provider.coverImage != null || provider.webCoverImage != null) {
          coverUrl = await provider.uploadImage(
              provider.coverImage, provider.webCoverImage, 'cover');
        } else if (provider.existingCoverUrl != null) {
          coverUrl = provider.existingCoverUrl;
        }

        Map<String, String> translatedOpeningHours = {};
        openingHours.forEach((key, value) {
          if (value.isOpen) {
            translatedOpeningHours[CompanyProvider.dayTranslations[key]!] =
                "${value.openTime}-${value.closeTime}";
          } else {
            translatedOpeningHours[CompanyProvider.dayTranslations[key]!] =
                "Fermé";
          }
        });

        Map<String, dynamic> newCompanyData = {
          'name': _nameController.text,
          'searchText': normalizeText(_nameController.text),
          'adress': {
            'adresse': _addressController.text,
            'code_postal': _postalCodeController.text,
            'ville': _cityController.text,
            'pays': 'france',
            'latitude': _latitude, // Ajout de la latitude
            'longitude': _longitude, // Ajout de la longitude
          },
          'categorie': _categoryController.text,
          'description': _descriptionController.text,
          'email': _emailController.text,
          'phone': _phoneNumber.phoneNumber,
          'website': _websiteController.text,
          'logo': logoUrl,
          'cover': coverUrl,
          'openingHours': translatedOpeningHours,
        };

        String companyId;
        if (provider.companyData != null) {
          Map<String, dynamic> modifiedFields =
              _getModifiedFields(provider.companyData!, newCompanyData);
          await provider.updateCompany(modifiedFields);

          companyId = FirebaseAuth.instance.currentUser!.uid;
        } else {
          companyId = await provider.createCompany(newCompanyData);
        }

        // Mise à jour du document utilisateur
        final userRef = FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid);

        await userRef.update({
          'status': 'complete',
          'companyName': _nameController.text,
          'companyId': companyId,
        });

        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 10),
          title: Text(
            'Entreprise ${provider.companyData != null ? "modifiée" : "ajoutée"} avec succès !',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        );
        if (widget.isNewUser) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        } else {
          Navigator.of(context).pop();
        }
      } catch (e) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 10),
          title: Text(
            'Erreur lors de l\'opération: $e',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          fillColor: Colors.white,
        ),
        validator: (value) =>
            value!.isEmpty ? 'Ce champ ne peut pas être vide' : null,
      ),
    );
  }

  Widget _buildImageWidgets() {
    return Consumer<CompanyProvider>(
      builder: (context, provider, child) {
        return Row(
          children: [
            Expanded(
              child: ImageUploadWidget(
                label: "Logo de l'entreprise",
                onPickImage: () => provider.pickLogoImage(),
                onRemoveImage: () => provider.removeLogoImage(),
                imageWidget: _buildImageWidget(
                  provider.logoImage,
                  provider.webLogoImage,
                  provider.existingLogoUrl,
                ),
                isUploaded: provider.logoImage != null ||
                    provider.webLogoImage != null ||
                    (provider.existingLogoUrl?.isNotEmpty ?? false),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ImageUploadWidget(
                label: "Photo de couverture",
                onPickImage: () => provider.pickCoverImage(),
                onRemoveImage: () => provider.removeCoverImage(),
                imageWidget: _buildImageWidget(
                  provider.coverImage,
                  provider.webCoverImage,
                  provider.existingCoverUrl,
                ),
                isUploaded: provider.coverImage != null ||
                    provider.webCoverImage != null ||
                    (provider.existingCoverUrl?.isNotEmpty ?? false),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageWidget(
      File? image, Uint8List? webImage, String? existingUrl) {
    if (image != null && !kIsWeb) {
      return Image.file(image, fit: BoxFit.cover);
    } else if (webImage != null && kIsWeb) {
      return Image.memory(webImage, fit: BoxFit.cover);
    } else if (existingUrl != null && existingUrl.isNotEmpty) {
      return Image.network(existingUrl, fit: BoxFit.cover);
    } else {
      return Icon(Icons.add_a_photo, size: 50, color: Colors.grey[400]);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
