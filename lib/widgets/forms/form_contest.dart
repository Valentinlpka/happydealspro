import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:happy_deals_pro/classes/contest.dart';
import 'package:happy_deals_pro/widgets/normalize_text.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';

class FormContest extends StatefulWidget {
  final Contest? contest;
  const FormContest({super.key, this.contest});

  @override
  State<FormContest> createState() => _FormContestState();
}

class _FormContestState extends State<FormContest> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _howToParticipateController = TextEditingController();
  final _conditionsController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _giftPhotoController = TextEditingController();
  final _giftNameController = TextEditingController();
  final _giftImageUrlController = TextEditingController();

  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now();
  List<Gift> _gifts = [];
  bool get isEditing => widget.contest != null;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null).then((_) {
      setState(() {
        if (isEditing) {
          _titleController.text = widget.contest!.title;
          _descriptionController.text = widget.contest!.description;
          _howToParticipateController.text = widget.contest!.howToParticipate;
          _conditionsController.text = widget.contest!.conditions;
          _selectedStartDate = widget.contest!.startDate;
          _selectedEndDate = widget.contest!.endDate;
          _gifts = widget.contest!.gifts;
          _giftPhotoController.text = widget.contest!.giftPhoto;
        }
        _startDateController.text =
            DateFormat.yMd('fr_FR').add_Hm().format(_selectedStartDate);
        _endDateController.text =
            DateFormat.yMd('fr_FR').add_Hm().format(_selectedEndDate);
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _howToParticipateController.dispose();
    _conditionsController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _giftPhotoController.dispose();
    _giftNameController.dispose();
    _giftImageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isEditing
          ? AppBar(
              title: Text(
                  isEditing ? 'Modifier le Concours' : 'Ajouter un Concours'),
            )
          : null,
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField('Titre du concours', _titleController),
                  const SizedBox(height: 16),
                  _buildTextField('Description', _descriptionController,
                      maxLines: 3),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _startDateController,
                    decoration: InputDecoration(
                      labelText: 'Date de début',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5)),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () =>
                            _selectDate(context, _startDateController, true),
                      ),
                    ),
                    readOnly: false,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _endDateController,
                    decoration: InputDecoration(
                      labelText: 'Date de fin',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5)),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () =>
                            _selectDate(context, _endDateController, false),
                      ),
                    ),
                    readOnly: false,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                      'Comment participer', _howToParticipateController,
                      maxLines: 3),
                  const SizedBox(height: 16),
                  _buildTextField('Conditions', _conditionsController,
                      maxLines: 3),
                  const SizedBox(height: 16),
                  _buildTextField('Photo du cadeau', _giftPhotoController),
                  const SizedBox(height: 16),
                  Text(
                    'Cadeaux',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _gifts.map((gift) {
                      return Chip(
                        label: Text(gift.name),
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () {
                          setState(() {
                            _gifts.remove(gift);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField('Nom du cadeau', _giftNameController),
                  const SizedBox(height: 16),
                  _buildTextField(
                      'URL de l\'image du cadeau', _giftImageUrlController),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addGift,
                    child: const Text('Ajouter le cadeau'),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _saveContest,
                    child: Text(
                      isEditing
                          ? 'Modifier le Concours'
                          : 'Ajouter le Concours',
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

  Future<void> _saveContest() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        User? userId = FirebaseAuth.instance.currentUser;
        String userUid = userId?.uid ?? "";
        String contestId = isEditing
            ? widget.contest!.id
            : FirebaseFirestore.instance.collection('posts').doc().id;

        Contest contest = Contest(
          id: contestId,
          timestamp: DateTime.now(),
          title: _titleController.text,
          searchText: normalizeText(_titleController.text),
          description: _descriptionController.text,
          gifts: _gifts,
          companyId: userUid,
          howToParticipate: _howToParticipateController.text,
          conditions: _conditionsController.text,
          startDate: _selectedStartDate,
          endDate: _selectedEndDate,
          giftPhoto: _giftPhotoController.text,
        );

        if (isEditing) {
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(contestId)
              .update(contest.toEditableMap());
        } else {
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(contestId)
              .set(contest.toMap());
        }

        Navigator.of(context).pop(); // Ferme le dialogue de chargement

        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 10),
          title: Text(
            isEditing
                ? 'Concours modifié avec succès!'
                : 'Concours ajouté avec succès!',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        );

        if (isEditing) {
          Navigator.of(context).pop(); // Retourner à la page précédente
        }
      } catch (e) {
        Navigator.of(context).pop(); // Ferme le dialogue de chargement
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'opération: $e')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context,
      TextEditingController controller, bool isStart) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? _selectedStartDate : _selectedEndDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      locale: const Locale('fr', 'FR'),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
            isStart ? _selectedStartDate : _selectedEndDate),
      );
      if (pickedTime != null) {
        setState(() {
          final selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          if (isStart) {
            _selectedStartDate = selectedDateTime;
            controller.text =
                DateFormat.yMd('fr_FR').add_Hm().format(_selectedStartDate);
          } else {
            _selectedEndDate = selectedDateTime;
            controller.text =
                DateFormat.yMd('fr_FR').add_Hm().format(_selectedEndDate);
          }
        });
      }
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
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

  void _addGift() {
    if (_giftNameController.text.isNotEmpty &&
        _giftImageUrlController.text.isNotEmpty) {
      setState(() {
        _gifts.add(Gift(
          name: _giftNameController.text,
          imageUrl: _giftImageUrlController.text,
        ));
        _giftNameController.clear();
        _giftImageUrlController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Veuillez remplir tous les champs du cadeau')),
      );
    }
  }
}
