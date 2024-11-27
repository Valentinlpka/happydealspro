import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:happy_deals_pro/classes/product.dart';
import 'package:happy_deals_pro/classes/promo_code.dart';
import 'package:happy_deals_pro/services/user_service.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';

class PromoCodeForm extends StatefulWidget {
  final PromoCodePost? promoCode;
  const PromoCodeForm({super.key, this.promoCode});

  @override
  _PromoCodeFormState createState() => _PromoCodeFormState();
}

class _PromoCodeFormState extends State<PromoCodeForm> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _valueController = TextEditingController();
  final _maxUsesController = TextEditingController();
  final _endDateController = TextEditingController();

  final UserService _userService = UserService();
  String? _sellerId;

  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  bool _isLoading = false;
  bool _isPercentageDiscount = true;
  bool _isStoreWide = true;
  List<Product> _products = [];
  List<String> _selectedProductIds = [];

  bool get isEditing => widget.promoCode != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _initializeEditingValues();
    }
    _updateDateField();
    _loadProducts();
    _loadSellerId(); // Ajoutez cette ligne
  }

  Future<void> _loadSellerId() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    _sellerId = await _userService.getStripeAccountId(userId);
    if (_sellerId == null) {
      _showError('Erreur: Impossible de récupérer l\'ID du vendeur');
    }
  }

  void _initializeEditingValues() {
    final promo = widget.promoCode!;
    _codeController.text = promo.code;
    _descriptionController.text = promo.description;
    _valueController.text = promo.value.toString();
    _maxUsesController.text = promo.maxUses?.toString() ?? '';
    _endDate = promo.expiresAt;
    _isPercentageDiscount = promo.isPercentage;
    _isStoreWide = promo.isStoreWide;
    _selectedProductIds = promo.applicableProductIds;
  }

  void _updateDateField() {
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
      _showError('Erreur lors du chargement des produits: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier Code Promo' : 'Créer Code Promo'),
      ),
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
                        _buildTextField('Code Promo', _codeController),
                        const SizedBox(height: 16),
                        _buildTextField('Description', _descriptionController,
                            maxLines: 3),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                _isPercentageDiscount
                                    ? 'Réduction (%)'
                                    : 'Réduction (€)',
                                _valueController,
                                keyboardType: TextInputType.number,
                                validator: _validateDiscount,
                              ),
                            ),
                            Switch(
                              value: _isPercentageDiscount,
                              onChanged: (value) =>
                                  setState(() => _isPercentageDiscount = value),
                            ),
                            Text(_isPercentageDiscount ? '%' : '€'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          'Nombre maximum d\'utilisations',
                          _maxUsesController,
                          keyboardType: TextInputType.number,
                          required: false,
                        ),
                        const SizedBox(height: 16),
                        _buildDateField(),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Applicable à toute la boutique'),
                          value: _isStoreWide,
                          onChanged: (value) =>
                              setState(() => _isStoreWide = value),
                        ),
                        if (!_isStoreWide) _buildProductsSelection(),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _savePromoCode,
                            child: Text(
                              isEditing
                                  ? 'Modifier Code Promo'
                                  : 'Créer Code Promo',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    bool readOnly = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
      ),
      validator: validator ??
          (value) => required && value!.isEmpty
              ? 'Ce champ ne peut pas être vide'
              : null,
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _endDateController,
      decoration: InputDecoration(
        labelText: 'Date d\'expiration',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () => _selectDate(context),
        ),
      ),
      readOnly: true,
    );
  }

  Widget _buildProductsSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sélectionner les produits applicables:'),
        const SizedBox(height: 8),
        ...List.generate(_products.length, (index) {
          final product = _products[index];
          return CheckboxListTile(
            title: Text(product.name),
            value: _selectedProductIds.contains(product.id),
            onChanged: (bool? value) {
              setState(() {
                if (value ?? false) {
                  _selectedProductIds.add(product.id);
                } else {
                  _selectedProductIds.remove(product.id);
                }
              });
            },
          );
        }),
      ],
    );
  }

  String? _validateDiscount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer une réduction';
    }
    final discount = double.tryParse(value);
    if (discount == null || discount <= 0) {
      return 'Veuillez entrer une réduction valide';
    }
    if (_isPercentageDiscount && discount > 100) {
      return 'La réduction ne peut pas dépasser 100%';
    }
    return null;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
        _endDateController.text = DateFormat('dd/MM/yyyy').format(_endDate);
      });
    }
  }

  Future<void> _savePromoCode() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isStoreWide && _selectedProductIds.isEmpty) {
      _showError('Veuillez sélectionner au moins un produit');
      return;
    }
    if (_sellerId == null) {
      _showError('Erreur: ID du vendeur non disponible');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      final promoCode = PromoCodePost(
        timestamp: DateTime.now(),
        code: _codeController.text,
        companyId: userId,
        sellerId: _sellerId!, // ID du vendeur Stripe

        value: double.parse(_valueController.text),
        isPercentage: _isPercentageDiscount,
        description: _descriptionController.text,
        expiresAt: _endDate,
        maxUses: _maxUsesController.text.isNotEmpty
            ? int.parse(_maxUsesController.text)
            : null,
        currentUses: widget.promoCode?.currentUses ?? 0,
        isStoreWide: _isStoreWide,
        applicableProductIds: _isStoreWide ? [] : _selectedProductIds,
      );

      final docRef = FirebaseFirestore.instance.collection('posts').doc();
      await docRef.set(promoCode.toMap());

      toastification.show(
        context: context,
        type: ToastificationType.success,
        title: Text(
          isEditing
              ? 'Code promo modifié avec succès!'
              : 'Code promo créé avec succès!',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        autoCloseDuration: const Duration(seconds: 5),
      );

      Navigator.of(context).pop();
    } catch (e) {
      _showError('Erreur lors de la sauvegarde: $e');
    }
    setState(() => _isLoading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _descriptionController.dispose();
    _valueController.dispose();
    _maxUsesController.dispose();
    _endDateController.dispose();
    super.dispose();
  }
}
