import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:happy_deals_pro/classes/referral.dart';
import 'package:happy_deals_pro/widgets/image_picker.dart';
import 'package:happy_deals_pro/widgets/normalize_text.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';

class FormReferral extends StatefulWidget {
  final Referral? referral;

  const FormReferral({super.key, this.referral});

  @override
  State<FormReferral> createState() => _FormReferralState();
}

class _FormReferralState extends State<FormReferral> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sponsorBenefitController = TextEditingController();
  final _refereeBenefitController = TextEditingController();
  final _dateFinalController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool get isEditing => widget.referral != null;
  dynamic _selectedImage;
  bool _imageRemoved = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null).then((_) {
      setState(() {
        if (isEditing) {
          _titleController.text = widget.referral!.title;
          _descriptionController.text = widget.referral!.description;
          _sponsorBenefitController.text = widget.referral!.sponsorBenefit;
          _refereeBenefitController.text = widget.referral!.refereeBenefit;
          _selectedDate = widget.referral!.dateFinal;
        }
        _dateFinalController.text =
            DateFormat.yMd('fr_FR').format(_selectedDate);
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _sponsorBenefitController.dispose();
    _refereeBenefitController.dispose();
    _dateFinalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isEditing
          ? AppBar(
              title: const Text('Modifier le parrainage'),
            )
          : null,
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  _buildTextField('Titre', _titleController),
                  const SizedBox(height: 16),
                  _buildTextField('Description', _descriptionController,
                      maxLines: 3),
                  const SizedBox(height: 16),
                  _buildTextField(
                      'Avantage du parrain', _sponsorBenefitController),
                  const SizedBox(height: 16),
                  _buildTextField(
                      'Avantage du filleul', _refereeBenefitController),
                  const SizedBox(height: 16),
                  ImagePickerWidget(
                    onImageSelected: (dynamic image) {
                      setState(() {
                        _selectedImage = image;
                        _imageRemoved = false;
                      });
                    },
                    onImageRemoved: () {
                      setState(() {
                        _selectedImage = null;
                        _imageRemoved = true;
                      });
                    },
                    initialImageUrl: isEditing && !_imageRemoved
                        ? widget.referral!.image
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dateFinalController,
                    decoration: InputDecoration(
                      labelText: 'Date de fin',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5)),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context),
                      ),
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _saveReferral,
                      child: Text(
                        isEditing
                            ? 'Modifier le parrainage'
                            : 'Ajouter le parrainage',
                        style:
                            const TextStyle(fontSize: 18, color: Colors.white),
                      ),
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

  Future<void> _saveReferral() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        User? userId = FirebaseAuth.instance.currentUser;
        String userUid = userId?.uid ?? "";
        String referralId = isEditing
            ? widget.referral!.id
            : FirebaseFirestore.instance.collection('posts').doc().id;

        String imageUrl = '';
        final storage = FirebaseStorage.instance;
        final imageRef =
            storage.ref().child('referral_images').child('$referralId.jpg');

        if (_selectedImage != null) {
          if (isEditing && widget.referral!.image.isNotEmpty) {
            await storage.refFromURL(widget.referral!.image).delete();
          }
          if (kIsWeb) {
            // Pour le web, _selectedImage est une URL de données
            await imageRef.putString(_selectedImage,
                format: PutStringFormat.dataUrl);
          } else {
            // Pour mobile, _selectedImage est un File
            await imageRef.putFile(_selectedImage);
          }
          imageUrl = await imageRef.getDownloadURL();
        } else if (isEditing && !_imageRemoved) {
          imageUrl = widget.referral!.image;
        } else if (isEditing && _imageRemoved) {
          if (widget.referral!.image.isNotEmpty) {
            await storage.refFromURL(widget.referral!.image).delete();
          }
          imageUrl = '';
        }

        Referral newReferral = Referral(
          id: referralId,
          timestamp: DateTime.now(),
          title: _titleController.text,
          searchText: normalizeText(_titleController.text),
          description: _descriptionController.text,
          sponsorBenefit: _sponsorBenefitController.text,
          refereeBenefit: _refereeBenefitController.text,
          companyId: userUid,
          image: imageUrl,
          dateFinal: _selectedDate,
        );

        if (isEditing) {
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(referralId)
              .update(newReferral.toMap());
        } else {
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(referralId)
              .set(newReferral.toMap());
        }

        Navigator.of(context).pop(); // Ferme le dialog de chargement

        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 10),
          title: Text(
            isEditing
                ? 'Parrainage modifié avec succès!'
                : 'Parrainage ajouté avec succès!',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        );

        if (isEditing && mounted) {
          Navigator.of(context).pop(); // Retourne à l'écran précédent
        }
      } catch (e) {
        Navigator.of(context).pop(); // Ferme le dialog de chargement
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'opération: $e')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2021),
      lastDate: DateTime(2101),
      locale: const Locale('fr', 'FR'),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue[700],
            colorScheme: ColorScheme.light(primary: Colors.blue[700]!),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateFinalController.text = DateFormat.yMd('fr_FR').format(picked);
      });
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
}
