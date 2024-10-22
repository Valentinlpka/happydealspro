// lib/widgets/product_card.dart
import 'package:flutter/material.dart';
import 'package:happy_deals_pro/classes/product.dart';
import 'package:happy_deals_pro/screens/product_detail_page.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (product.images.isNotEmpty)
              Image.network(
                product.images[0],
                fit: BoxFit.contain,
                height: 100,
                width: 100,
              ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text('${product.price}€'),
                  const SizedBox(height: 4),
                  Text('Stock: ${product.stock}'),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: product.isActive ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      product.isActive ? 'Actif' : 'Inactif',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
