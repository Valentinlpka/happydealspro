import 'package:flutter/material.dart';
import 'package:happy_deals_pro/classes/dealexpress.dart';
import 'package:intl/intl.dart';

class DealsExpressCard extends StatelessWidget {
  final ExpressDeal deal;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const DealsExpressCard({
    super.key,
    required this.deal,
    this.onEdit,
    this.onDelete,
  });

  String formatDateTime(DateTime dateTime) {
    final DateTime now = DateTime.now();
    final DateFormat timeFormat = DateFormat('HH:mm');
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return 'aujourd\'hui à ${timeFormat.format(dateTime)}';
    } else if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day + 1) {
      return 'demain à ${timeFormat.format(dateTime)}';
    } else {
      return '${dateFormat.format(dateTime)} à ${timeFormat.format(dateTime)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(Icons.shopping_bag_outlined),
              const SizedBox(
                width: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deal.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const SizedBox(width: 30),
              Text(
                '${deal.basketCount} paniers disponibles',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 14,
                ),
              ),
              const SizedBox(
                width: 30,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Horaires de récupération :',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  ...deal.pickupTimes.map((time) => Text(
                        formatDateTime(time),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      )),
                ],
              ),
              const SizedBox(
                width: 30,
              ),
              Text(
                '${deal.price.toStringAsFixed(2)} €',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
