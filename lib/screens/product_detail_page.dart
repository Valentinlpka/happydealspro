import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:happy_deals_pro/classes/product.dart';
import 'package:happy_deals_pro/screens/product_form_page.dart';
import 'package:happy_deals_pro/services/product_service.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  final ProductService _productService = ProductService();

  ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du produit'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        actions: [
          TextButton.icon(
            icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
            label: Text('Modifier',
                style: TextStyle(color: Theme.of(context).primaryColor)),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProductFormScreen(product: product)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations du produit',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: 24),
            _buildInfoField('Nom du produit', product.name, Icons.shopping_bag),
            const SizedBox(height: 16),
            _buildInfoField(
                'Description', product.description, Icons.description,
                maxLines: 3),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _buildInfoField('Prix',
                        '${product.price.toStringAsFixed(2)}€', Icons.euro)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildInfoField(
                        'Stock', product.stock.toString(), Icons.inventory)),
              ],
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Produit actif',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              value: product.isActive,
              onChanged: null,
              activeColor: Theme.of(context).primaryColor,
            ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
            const SizedBox(height: 24),
            const Text(
              'Images du produit',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ).animate().fadeIn(duration: 300.ms, delay: 300.ms),
            const SizedBox(height: 16),
            _buildImageGrid(),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _showDeleteConfirmation(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Supprimer le produit'),
            ).animate().scale(duration: 300.ms, delay: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, String value, IconData icon,
      {int maxLines = 1}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(icon, color: Colors.grey[600], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms);
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: product.images.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              product.images[index],
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms);
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce produit ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _productService.deleteProduct(product.id);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
