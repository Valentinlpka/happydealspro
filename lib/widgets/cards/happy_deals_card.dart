import 'package:flutter/material.dart';
import 'package:happy_deals_pro/classes/happy_deal.dart';
import 'package:intl/intl.dart';

class HappyDealCard extends StatelessWidget {
  final HappyDeal happyDeal;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const HappyDealCard({
    super.key,
    required this.happyDeal,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Navigate to Happy Deal detail page if you have one
          // Otherwise, you can implement edit functionality here
          if (onEdit != null) onEdit!();
        },
        child: Row(
          children: [
            Image.network(
              happyDeal.photo,
              fit: BoxFit.cover,
              height: 100,
              width: 100,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        happyDeal.productName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Prices
                      Row(
                        children: [
                          // Old Price (crossed out)
                          Text(
                            '${happyDeal.oldPrice.toStringAsFixed(2)}€',
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // New Price
                          Text(
                            '${happyDeal.newPrice.toStringAsFixed(2)}€',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Discount
                      Text(
                        'Réduction: ${happyDeal.discountPercentage.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Date range
                      Text(
                        'Du ${DateFormat('dd/MM/yyyy').format(happyDeal.startDate)} au ${DateFormat('dd/MM/yyyy').format(happyDeal.endDate)}',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                // Edit and Delete buttons
                if (onEdit != null || onDelete != null)
                  OverflowBar(
                    alignment: MainAxisAlignment.end,
                    children: [
                      if (onEdit != null)
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: onEdit,
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: onDelete,
                        ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
