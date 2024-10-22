import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:happy_deals_pro/classes/event.dart';
import 'package:happy_deals_pro/widgets/normalize_text.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';

class FormEvent extends StatefulWidget {
  final Event? event;

  const FormEvent({super.key, this.event});

  @override
  State<FormEvent> createState() => _FormEventState();
}

class _FormEventState extends State<FormEvent> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _eventDateController = TextEditingController();
  final _cityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _productsController = TextEditingController();
  final _photoController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool get isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null).then((_) {
      setState(() {
        if (isEditing) {
          _titleController.text = widget.event!.title;
          _categoryController.text = widget.event!.category;
          _selectedDate = widget.event!.eventDate;
          _cityController.text = widget.event!.city;
          _descriptionController.text = widget.event!.description;
          _productsController.text = widget.event!.products.join(', ');
          _photoController.text = widget.event!.photo;
        }
        _eventDateController.text =
            DateFormat.yMd('fr_FR').format(_selectedDate);
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _eventDateController.dispose();
    _cityController.dispose();
    _descriptionController.dispose();
    _productsController.dispose();
    _photoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isEditing
          ? AppBar(
              title: const Text('Modifier l\'évènement'),
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
                  Row(
                    children: [
                      Expanded(
                          child: _buildTextField('Titre', _titleController)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildTextField(
                              'Catégorie', _categoryController)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _eventDateController,
                          decoration: InputDecoration(
                            labelText: 'Date de l\'évènement',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5)),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () => _selectDate(context),
                            ),
                          ),
                          readOnly: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildTextField('Ville', _cityController)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField('Description', _descriptionController,
                      maxLines: 3),
                  const SizedBox(height: 16),
                  _buildTextField('Produits (séparés par des virgules)',
                      _productsController),
                  const SizedBox(height: 16),
                  _buildTextField('URL de la photo', _photoController),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _saveEvent,
                      child: Text(
                        isEditing
                            ? 'Modifier l\'évènement'
                            : 'Ajouter l\'évènement',
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

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        User? userId = FirebaseAuth.instance.currentUser;
        String userUid = userId?.uid ?? "";
        String eventId = isEditing
            ? widget.event!.id
            : FirebaseFirestore.instance.collection('posts').doc().id;

        Event newEvent = Event(
          id: eventId,
          timestamp: DateTime.now(),
          title: _titleController.text,
          searchText: normalizeText(_titleController.text),
          category: _categoryController.text,
          eventDate: _selectedDate,
          city: _cityController.text,
          description: _descriptionController.text,
          companyId: userUid,
          products:
              _productsController.text.split(',').map((e) => e.trim()).toList(),
          photo: _photoController.text,
        );

        if (isEditing) {
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(eventId)
              .update(newEvent.toEditableMap());
        } else {
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(eventId)
              .set(newEvent.toMap());
        }

        Navigator.of(context).pop();

        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 10),
          title: Text(
            isEditing
                ? 'Évènement modifié avec succès!'
                : 'Évènement ajouté avec succès!',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        );

        if (isEditing && mounted) {
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
        _eventDateController.text = DateFormat.yMd('fr_FR').format(picked);
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
