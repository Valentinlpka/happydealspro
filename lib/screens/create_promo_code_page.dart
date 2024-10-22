// lib/screens/create_promo_code_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:happy_deals_pro/classes/product.dart';
import 'package:happy_deals_pro/services/user_service.dart';

import '../services/product_service.dart';

class CreatePromoCodeScreen extends StatefulWidget {
  const CreatePromoCodeScreen({super.key});

  @override
  _CreatePromoCodeScreenState createState() => _CreatePromoCodeScreenState();
}

class _CreatePromoCodeScreenState extends State<CreatePromoCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();
  final UserService _userService = UserService();

  String _code = '';
  double _discountPercent = 0;
  DateTime _expirationDate = DateTime.now().add(const Duration(days: 30));
  List<Product> _products = [];
  final List<String> _selectedProductIds = [];
  String? _sellerId;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _initializeSellerId();
  }

  void _initializeSellerId() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final stripeAccountId = await _userService.getStripeAccountId(userId);
    setState(() {
      _sellerId = stripeAccountId;
    });
    print(_sellerId);
    _loadProducts();
  }

  void _loadProducts() async {
    final sellerId = _sellerId;

    final products = await _productService.getProductsForSeller(
        (sellerId != null) ? sellerId : 'acct_1PabJvREQk4uQV6x');
    setState(() {
      _products = products;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 50),
        child: Container(
          padding: const EdgeInsets.only(left: 10, bottom: 50),
          child: AppBar(
            title: Container(
              alignment: Alignment.centerLeft,
              child: const Text(
                "Créer un code promo",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Code promo'),
              validator: (value) =>
                  value!.isEmpty ? 'Veuillez entrer un code' : null,
              onSaved: (value) => _code = value!,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Réduction (%)'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value!.isEmpty) return 'Veuillez entrer un pourcentage';
                final discount = double.tryParse(value);
                if (discount == null || discount <= 0 || discount > 100) {
                  return 'Entrez un pourcentage valide entre 0 et 100';
                }
                return null;
              },
              onSaved: (value) => _discountPercent = double.parse(value!),
            ),
            ListTile(
              title: const Text('Date d\'expiration'),
              subtitle: Text('${_expirationDate.toLocal()}'.split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _expirationDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null && picked != _expirationDate) {
                  setState(() {
                    _expirationDate = picked;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            const Text('Sélectionnez les produits applicables :'),
            ..._products.map((product) => CheckboxListTile(
                  title: Text(product.name),
                  value: _selectedProductIds.contains(product.id),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value!) {
                        _selectedProductIds.add(product.id);
                      } else {
                        _selectedProductIds.remove(product.id);
                      }
                    });
                  },
                )),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Créer le code promo'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await FirebaseFirestore.instance
            .collection('promoCodes')
            .doc(_code)
            .set({
          'code': _code,
          'discountPercent': _discountPercent,
          'expirationDate': Timestamp.fromDate(_expirationDate),
          'applicableProductIds': _selectedProductIds,
          'sellerId': FirebaseAuth.instance.currentUser!.uid,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Code promo créé avec succès')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur lors de la création du code promo: $e')),
        );
      }
    }
  }
}
