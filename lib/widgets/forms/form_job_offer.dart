import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:happy_deals_pro/classes/job_offer.dart';
import 'package:happy_deals_pro/widgets/normalize_text.dart';
import 'package:toastification/toastification.dart';

class JobOfferForm extends StatefulWidget {
  final JobOffer? jobOffer;
  final VoidCallback? onComplete;

  const JobOfferForm({super.key, this.jobOffer, this.onComplete});

  @override
  State<JobOfferForm> createState() => _JobOfferFormState();
}

class _JobOfferFormState extends State<JobOfferForm> {
  final _formKey = GlobalKey<FormState>();
  final _jobTitleController = TextEditingController();
  final _cityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _missionsController = TextEditingController();
  final _profileController = TextEditingController();
  final _benefitsController = TextEditingController();
  final _whyJoinController = TextEditingController();
  final _keywordsController = TextEditingController();
  final _salaryController = TextEditingController();

  String _selectedIndustrySector = '';
  String? _selectedContractType;
  String? _selectedWorkingHours;

  final List<String> _contractTypes = [
    'CDI',
    'CDD',
    'Intérim',
    'Stage',
    'Alternance'
  ];

  final List<String> _workingHours = [
    'Temps plein',
    'Temps partiel',
    'Flexibles'
  ];

  final kGoogleApi = 'AIzaSyCS3N9FwFLGHDRSN7PbCSIhDrTjMPALfLc';

  bool get isEditing => widget.jobOffer != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _jobTitleController.text = widget.jobOffer!.title;
      _cityController.text = widget.jobOffer!.city;
      _descriptionController.text = widget.jobOffer!.description;
      _missionsController.text = widget.jobOffer!.missions;
      _profileController.text = widget.jobOffer!.profile;
      _benefitsController.text = widget.jobOffer!.benefits;
      _whyJoinController.text = widget.jobOffer!.whyJoin;
      _keywordsController.text = widget.jobOffer!.keywords.join(', ');
      _salaryController.text = widget.jobOffer!.salary ?? '';
      _selectedContractType = widget.jobOffer!.contractType;
      _selectedWorkingHours = widget.jobOffer!.workingHours;
      _selectedIndustrySector = widget.jobOffer!.industrySector;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isEditing
          ? AppBar(title: const Text('Modifier l\'offre d\'emploi'))
          : null,
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField('Titre du poste', _jobTitleController),
                  const SizedBox(height: 16),
                  _buildCityAutocomplete(),
                  const SizedBox(height: 16),
                  _buildIndustrySectorDropdown(),
                  const SizedBox(height: 16),
                  _buildTextField('Description', _descriptionController,
                      maxLines: 5),
                  const SizedBox(height: 16),
                  _buildTextField('Missions', _missionsController, maxLines: 5),
                  const SizedBox(height: 16),
                  _buildTextField('Profil recherché', _profileController,
                      maxLines: 3),
                  const SizedBox(height: 16),
                  _buildContractTypeDropdown(),
                  const SizedBox(height: 16),
                  _buildWorkingHoursDropdown(),
                  const SizedBox(height: 16),
                  _buildTextField('Rémunération', _salaryController),
                  const SizedBox(height: 16),
                  _buildTextField('Avantages', _benefitsController,
                      maxLines: 2),
                  const SizedBox(height: 16),
                  _buildTextField('Pourquoi nous rejoindre', _whyJoinController,
                      maxLines: 2),
                  const SizedBox(height: 16),
                  _buildTextField('Mots-clés (séparés par des virgules)',
                      _keywordsController),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _saveJobOffer,
                      child: Text(
                        isEditing
                            ? 'Modifier l\'offre d\'emploi'
                            : 'Ajouter l\'offre d\'emploi',
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

  Widget _buildCityAutocomplete() {
    return TextFormField(
      controller: _cityController,
      decoration: InputDecoration(
        labelText: 'Ville',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
        suffixIcon: const Icon(Icons.search),
      ),
      onTap: () async {
        // Show the autocomplete dialog when the field is tapped
        final Prediction? p = await PlacesAutocomplete.show(
          context: context,
          apiKey: kGoogleApi,
          onError: (response) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text(response.errorMessage ?? 'Une erreur est survenue')),
            );
          },
          mode: Mode.overlay,
          language: "fr",
          components: [Component(Component.country, "fr")],
          types: ["(cities)"],
        );

        if (p != null) {
          // Extraire uniquement le nom de la ville
          String cityName = _extractCityName(p.description!);
          setState(() {
            _cityController.text = cityName;
          });
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez sélectionner une ville';
        }
        return null;
      },
    );
  }

  String _extractCityName(String fullDescription) {
    // La description complète est généralement au format "Ville, Département, France"
    // On va prendre la première partie avant la première virgule
    List<String> parts = fullDescription.split(',');
    if (parts.isNotEmpty) {
      return parts[0]
          .trim(); // Retourne la première partie (la ville) et enlève les espaces inutiles
    }
    return fullDescription; // Au cas où il n'y a pas de virgule, on retourne la description complète
  }

  Widget _buildIndustrySectorDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Secteur d\'activité',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
      ),
      value:
          _selectedIndustrySector.isNotEmpty ? _selectedIndustrySector : null,
      items: JobOffer.industrySectors.map((String sector) {
        return DropdownMenuItem<String>(
          value: sector,
          child: Text(sector),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedIndustrySector = newValue!;
        });
      },
      validator: (value) =>
          value == null ? 'Veuillez sélectionner un secteur d\'activité' : null,
    );
  }

  Widget _buildContractTypeDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Type de contrat',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
      ),
      value: _selectedContractType,
      items: _contractTypes.map((String type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(type),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedContractType = newValue;
        });
      },
      validator: (value) =>
          value == null ? 'Veuillez sélectionner un type de contrat' : null,
    );
  }

  Widget _buildWorkingHoursDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Horaires de travail',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
      ),
      value: _selectedWorkingHours,
      items: _workingHours.map((String hours) {
        return DropdownMenuItem<String>(
          value: hours,
          child: Text(hours),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedWorkingHours = newValue;
        });
      },
      validator: (value) => value == null
          ? 'Veuillez sélectionner des horaires de travail'
          : null,
    );
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

  Future<void> _saveJobOffer() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        User? userId = FirebaseAuth.instance.currentUser;
        String userUid = userId?.uid ?? "";
        String jobOfferId = isEditing
            ? widget.jobOffer!.id
            : FirebaseFirestore.instance.collection('posts').doc().id;

        JobOffer newJobOffer = JobOffer(
          id: jobOfferId,
          timestamp: DateTime.now(),
          title: _jobTitleController.text,
          searchText: normalizeText(_jobTitleController.text),
          city: _cityController.text,
          description: _descriptionController.text,
          missions: _missionsController.text,
          profile: _profileController.text,
          benefits: _benefitsController.text,
          whyJoin: _whyJoinController.text,
          keywords:
              _keywordsController.text.split(',').map((e) => e.trim()).toList(),
          companyId: userUid,
          contractType: _selectedContractType,
          workingHours: _selectedWorkingHours,
          salary: _salaryController.text,
          industrySector: _selectedIndustrySector,
        );

        if (isEditing) {
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(jobOfferId)
              .update(newJobOffer.toMap());
        } else {
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(jobOfferId)
              .set(newJobOffer.toMap());
        }

        Navigator.of(context).pop();

        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 10),
          title: Text(
            isEditing
                ? 'Offre d\'emploi modifiée avec succès!'
                : 'Offre d\'emploi ajoutée avec succès!',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        );

        widget.onComplete!(); // Appel du callback onComplete

        if (isEditing) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'opération: $e')),
        );
      }
    }
  }
}
