// lib/screens/product_list_screen.dart
import 'package:flutter/material.dart';
import 'package:happy_deals_pro/classes/product.dart';
import 'package:happy_deals_pro/screens/product_card.dart';
import 'package:happy_deals_pro/screens/product_form_page.dart';
import 'package:happy_deals_pro/services/product_service.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ProductService _productService = ProductService();
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _productService.getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun produit trouvé'));
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ProductCard(product: snapshot.data![index]);
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProductFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
