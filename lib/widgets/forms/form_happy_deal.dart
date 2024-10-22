import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:happy_deals_pro/classes/happy_deal.dart';
import 'package:happy_deals_pro/classes/product.dart';
import 'package:happy_deals_pro/screens/happy_deals_page.dart';
import 'package:happy_deals_pro/widgets/normalize_text.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';

class HappyDealForm extends StatefulWidget {
  final HappyDeal? happyDeal;

  const HappyDealForm({super.key, this.happyDeal});

  @override
  _HappyDealFormState createState() => _HappyDealFormState();
}

class _HappyDealFormState extends State<HappyDealForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _discountController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _currentPriceController = TextEditingController();
  final _newPriceController = TextEditingController();

  String? _selectedProductId;
  String _selectedProductImageUrl = '';
  String _selectedProductName = '';
  List<Product> _products = [];
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  bool _isLoading = false;
  bool _isPercentageDiscount = true;

  bool get isEditing => widget.happyDeal != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _titleController.text = widget.happyDeal!.title;
      _descriptionController.text = widget.happyDeal!.description;
      _discountController.text =
          widget.happyDeal!.discountPercentage.toString();
      _selectedProductId = widget.happyDeal!.productId;
      _selectedProductImageUrl = widget.happyDeal!.photo;
      _startDate = widget.happyDeal!.startDate;
      _endDate = widget.happyDeal!.endDate;
      _currentPriceController.text =
          widget.happyDeal!.oldPrice.toStringAsFixed(2);
      _newPriceController.text = widget.happyDeal!.newPrice.toStringAsFixed(2);
    }
    _updateDateFields();
    _loadProducts();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _discountController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _currentPriceController.dispose();
    _newPriceController.dispose();
    super.dispose();
  }

  void _updateDateFields() {
    _startDateController.text = DateFormat('dd/MM/yyyy').format(_startDate);
    _endDateController.text = DateFormat('dd/MM/yyyy').format(_endDate);
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final sellerId = FirebaseAuth.instance.currentUser!.uid;
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('sellerId', isEqualTo: sellerId)
          .get();

      setState(() {
        _products =
            snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des produits: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          isEditing ? AppBar(title: const Text('Modifier Happy Deal')) : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        _buildProductDropdown(),
                        const SizedBox(height: 5),
                        if (_selectedProductImageUrl.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Image.network(
                              _selectedProductImageUrl,
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                                child: _buildTextField(
                                    'Prix actuel', _currentPriceController,
                                    readOnly: true)),
                            const SizedBox(width: 16),
                            Expanded(
                                child: _buildTextField(
                                    'Nouveau prix', _newPriceController,
                                    readOnly: true)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                _isPercentageDiscount
                                    ? 'Réduction (%)'
                                    : 'Réduction (€)',
                                _discountController,
                                onChanged: (_) => _calculateNewPrice(),
                                keyboardType: TextInputType.number,
                                validator: _validateDiscount,
                              ),
                            ),
                            Switch(
                              value: _isPercentageDiscount,
                              onChanged: (value) {
                                setState(() {
                                  _isPercentageDiscount = value;
                                  _calculateNewPrice();
                                });
                              },
                            ),
                            Text(_isPercentageDiscount ? '%' : '€'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                            'Titre du Happy Deal', _titleController),
                        const SizedBox(height: 16),
                        _buildTextField('Description', _descriptionController,
                            maxLines: 3),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                                child: _buildDateField(
                                    'Date de début', _startDateController,
                                    isStartDate: true)),
                            const SizedBox(width: 16),
                            Expanded(
                                child: _buildDateField(
                                    'Date de fin', _endDateController,
                                    isStartDate: false)),
                          ],
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
                            onPressed: _saveHappyDeal,
                            child: Text(
                              isEditing
                                  ? 'Modifier Happy Deal'
                                  : 'Créer Happy Deal',
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.white),
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

  Widget _buildProductDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedProductId,
      decoration: InputDecoration(
        labelText: 'Produit',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
      ),
      items: _products.map((product) {
        return DropdownMenuItem(
          value: product.id,
          child: Text(product.name),
        );
      }).toList(),
      onChanged: (String? productId) {
        setState(() {
          _selectedProductId = productId;
          if (productId != null) {
            final selectedProduct =
                _products.firstWhere((product) => product.id == productId);
            _currentPriceController.text =
                selectedProduct.price.toStringAsFixed(2);
            _selectedProductName = selectedProduct.name;
            _selectedProductImageUrl = selectedProduct.images.isNotEmpty
                ? selectedProduct.images[0]
                : '';
            _calculateNewPrice();
          }
        });
      },
      validator: (value) =>
          value == null ? 'Veuillez sélectionner un produit' : null,
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    bool readOnly = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          fillColor: Colors.white,
        ),
        validator: validator ??
            (value) => value!.isEmpty ? 'Ce champ ne peut pas être vide' : null,
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller,
      {required bool isStartDate}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () => _selectDate(context, isStartDate),
        ),
      ),
      readOnly: true,
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          _startDateController.text =
              DateFormat('dd/MM/yyyy').format(_startDate);
        } else {
          _endDate = picked;
          _endDateController.text = DateFormat('dd/MM/yyyy').format(_endDate);
        }
      });
    }
  }

  void _calculateNewPrice() {
    if (_currentPriceController.text.isNotEmpty &&
        _discountController.text.isNotEmpty) {
      final currentPrice = double.parse(_currentPriceController.text);
      final discount = double.parse(_discountController.text);
      double newPrice;
      if (_isPercentageDiscount) {
        newPrice = currentPrice * (1 - discount / 100);
      } else {
        newPrice = currentPrice - discount;
      }
      _newPriceController.text = newPrice.toStringAsFixed(2);
    }
  }

  String? _validateDiscount(String? value) {
    if (value!.isEmpty) {
      return 'Veuillez entrer une réduction';
    }
    final discount = num.tryParse(value);
    if (discount == null || discount <= 0) {
      return 'Veuillez entrer une réduction valide';
    }
    if (_isPercentageDiscount && discount > 100) {
      return 'La réduction ne peut pas dépasser 100%';
    }
    return null;
  }

  Future<void> _saveHappyDeal() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final happyDeal = HappyDeal(
          id: widget.happyDeal?.id ??
              FirebaseFirestore.instance.collection('posts').doc().id,
          timestamp: DateTime.now(),
          title: _titleController.text,
          searchText: normalizeText(_titleController.text),
          description: _descriptionController.text,
          productId: _selectedProductId!,
          productName: _selectedProductName,
          discountPercentage: _isPercentageDiscount
              ? num.parse(_discountController.text)
              : (num.parse(_discountController.text) /
                  num.parse(_currentPriceController.text) *
                  100),
          startDate: _startDate,
          endDate: _endDate,
          companyId: FirebaseAuth.instance.currentUser!.uid,
          photo:
              _selectedProductImageUrl, // Utilisez l'URL de l'image du produit sélectionné
          newPrice: num.parse(_newPriceController.text),
          oldPrice: num.parse(_currentPriceController.text),
        );

        if (isEditing) {
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(happyDeal.id)
              .update(happyDeal.toEditableMap());
        } else {
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(happyDeal.id)
              .set(happyDeal.toMap());
        }
        // Mise à jour du produit
        await FirebaseFirestore.instance
            .collection('products')
            .doc(_selectedProductId)
            .update({
          'hasActiveHappyDeal': true,
          'discountedPrice': happyDeal.newPrice,
          'discountPercentage': happyDeal.discountPercentage,
          'happyDealStartDate': Timestamp.fromDate(happyDeal.startDate),
          'happyDealEndDate': Timestamp.fromDate(happyDeal.endDate),
        });

        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 10),
          title: Text(
            isEditing
                ? 'Happy Deal modifié avec succès!'
                : 'Happy Deal ajouté avec succès!',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HappyDealsPage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sauvegarde: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }
}
