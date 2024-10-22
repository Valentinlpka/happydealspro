import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:happy_deals_pro/classes/dealexpress.dart';
import 'package:happy_deals_pro/widgets/normalize_text.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';

class FormExpressDeal extends StatefulWidget {
  final ExpressDeal? expressDeal;
  const FormExpressDeal({super.key, this.expressDeal});

  @override
  State<FormExpressDeal> createState() => _FormExpressDealState();
}

class _FormExpressDealState extends State<FormExpressDeal> {
  final _formKey = GlobalKey<FormState>();
  final _basketTypeController = TextEditingController();
  final _contentController = TextEditingController();
  final _basketCountController = TextEditingController();
  final _priceController = TextEditingController();
  List<DateTime> _pickupTimes = [];

  bool get isEditing => widget.expressDeal != null;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null).then((_) {
      setState(() {
        if (isEditing) {
          _basketTypeController.text = widget.expressDeal!.title;
          _contentController.text = widget.expressDeal!.content;
          _pickupTimes = widget.expressDeal!.pickupTimes;
          _basketCountController.text =
              widget.expressDeal!.basketCount.toString();
          _priceController.text = widget.expressDeal!.price.toString();
        }
      });
    });
  }

  @override
  void dispose() {
    _basketTypeController.dispose();
    _contentController.dispose();
    _basketCountController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isEditing
          ? AppBar(
              title: Text(isEditing
                  ? 'Modifier l\'Express Deal'
                  : 'Ajouter un Express Deal'),
            )
          : null,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: isEditing ? 20.0 : 0),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextField('Titre du panier', _basketTypeController),
                    const SizedBox(height: 16),
                    _buildPickupTimesSection(),
                    const SizedBox(height: 16),
                    _buildTextField('Contenu', _contentController, maxLines: 3),
                    const SizedBox(height: 16),
                    _buildTextField('Nombre de paniers', _basketCountController,
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    _buildTextField('Prix', _priceController,
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _saveExpressDeal,
                      child: Text(
                        isEditing
                            ? 'Modifier l\'Express Deal'
                            : 'Ajouter l\'Express Deal',
                        style:
                            const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPickupTimesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Créneaux de retrait',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ..._pickupTimes.asMap().entries.map((entry) {
          int index = entry.key;
          DateTime time = entry.value;
          return ListTile(
            title: Text(DateFormat.yMd('fr_FR').add_Hm().format(time)),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _removePickupTime(index),
            ),
          );
        }),
        ElevatedButton(
          onPressed: () => _addPickupTime(context),
          child: const Text('Ajouter un créneau'),
        ),
      ],
    );
  }

  Future<void> _addPickupTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      locale: const Locale('fr', 'FR'),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          _pickupTimes.add(DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          ));
        });
      }
    }
  }

  void _removePickupTime(int index) {
    setState(() {
      _pickupTimes.removeAt(index);
    });
  }

  Future<void> _saveExpressDeal() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        User? userId = FirebaseAuth.instance.currentUser;
        if (userId == null) {
          throw Exception("Utilisateur non authentifié");
        }

        if (_pickupTimes.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Veuillez ajouter au moins un créneau de retrait')),
          );
          return;
        }

        // Récupérer l'ID Stripe de l'utilisateur
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId.uid)
            .get();

        if (!userDoc.exists) {
          throw Exception("Document utilisateur non trouvé");
        }

        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        String? stripeAccountId = userData['stripeAccountId'] as String?;

        if (stripeAccountId == null) {
          throw Exception(
              "ID de compte Stripe non trouvé pour cet utilisateur");
        }

        String expressDealId = isEditing
            ? widget.expressDeal!.id
            : FirebaseFirestore.instance.collection('posts').doc().id;

        ExpressDeal expressDeal = ExpressDeal(
          id: expressDealId,
          timestamp: DateTime.now(),
          title: _basketTypeController.text,
          searchText: normalizeText(_basketTypeController.text),
          pickupTimes: _pickupTimes,
          content: _contentController.text,
          companyId: userId.uid,
          basketCount: int.parse(_basketCountController.text),
          price: int.parse(_priceController.text),
          stripeAccountId: stripeAccountId,
        );

        if (isEditing) {
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(expressDealId)
              .update(expressDeal.toEditableMap());
        } else {
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(expressDealId)
              .set(expressDeal.toMap());
        }

        Navigator.of(context).pop();

        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 10),
          title: Text(
            isEditing
                ? 'Express Deal modifié avec succès!'
                : 'Express Deal ajouté avec succès!',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        );

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
}
