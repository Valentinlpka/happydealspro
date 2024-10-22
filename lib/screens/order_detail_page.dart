import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:happy_deals_pro/classes/order.dart';
import 'package:happy_deals_pro/providers/conversation_provider.dart';
import 'package:happy_deals_pro/screens/conversation.detail.dart';
import 'package:happy_deals_pro/services/order_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrderDetailScreen extends StatefulWidget {
  final Orders order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderService _orderService = OrderService();
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order.status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Commande #${widget.order.id}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              // Implémenter la fonctionnalité d'impression
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderSummary(),
              const SizedBox(height: 24),
              _buildOrderItems(),
              const SizedBox(height: 24),
              _buildOrderStatus(),
              const SizedBox(height: 24),
              _buildOrderActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Résumé de la commande',
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Date de commande:'),
                Text(DateFormat('dd/MM/yyyy HH:mm')
                    .format(widget.order.createdAt)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Montant total:'),
                Text('${widget.order.totalAmount.toStringAsFixed(2)}€',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('ID Client:'),
                Text(widget.order.userId),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Articles de la commande',
            ),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.order.items.length,
              itemBuilder: (context, index) {
                OrderItem item = widget.order.items[index];
                return ListTile(
                  leading: Image.network(item.image,
                      width: 50, height: 50, fit: BoxFit.cover),
                  title: Text(item.name),
                  subtitle: Text('Quantité: ${item.quantity}'),
                  trailing: Text(
                      '${(item.price * item.quantity).toStringAsFixed(2)}€'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatus() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statut de la commande',
            ),
            const Divider(),
            _currentStatus == 'completed'
                ? Text(_getStatusText(_currentStatus),
                    style: const TextStyle(fontWeight: FontWeight.bold))
                : DropdownButton<String>(
                    value: _currentStatus,
                    isExpanded: true,
                    items: <String>[
                      'paid',
                      'en préparation',
                      'prête à être retirée',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(_getStatusText(value)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        _updateStatus(newValue);
                      }
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderActions() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actions',
            ),
            const Divider(),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: <Widget>[
                ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Confirmer réception'),
                  onPressed: _currentStatus == 'prête à être retirée'
                      ? _confirmPickup
                      : null,
                ),
                ElevatedButton.icon(
                    icon: const Icon(Icons.message),
                    label: const Text('Contacter le client'),
                    onPressed: () => _startConversation(
                        context, widget.order.userId, currentUserId)),
                ElevatedButton.icon(
                  icon: const Icon(Icons.cancel),
                  label: const Text('Annuler la commande'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    // Implémenter la fonctionnalité d'annulation
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateStatus(String newStatus) async {
    if (_currentStatus == 'completed') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Impossible de modifier une commande terminée')),
      );
      return;
    }
    try {
      await _orderService.updateOrderStatus(widget.order.id, newStatus);
      setState(() {
        _currentStatus = newStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Statut mis à jour avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erreur lors de la mise à jour du statut')),
      );
    }
  }

  void _confirmPickup() async {
    String? code = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String? enteredCode;
        return AlertDialog(
          title: const Text('Confirmer la réception'),
          content: TextField(
            onChanged: (value) {
              enteredCode = value;
            },
            decoration:
                const InputDecoration(hintText: "Entrez le code de retrait"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Confirmer'),
              onPressed: () => Navigator.of(context).pop(enteredCode),
            ),
          ],
        );
      },
    );

    if (code != null) {
      try {
        await _orderService.confirmOrderPickup(widget.order.id, code);
        setState(() {
          _currentStatus = 'completed';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Commande confirmée comme terminée')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Erreur lors de la confirmation : code invalide ou autre problème')),
        );
      }
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'Payée';
      case 'en préparation':
        return 'En préparation';
      case 'prête à être retirée':
        return 'Prête à être retirée';
      case 'completed':
        return 'Terminée';
      default:
        return 'Inconnue';
    }
  }

  void _startConversation(
      BuildContext context, String particulierId, String currentUserId) async {
    final conversationService =
        Provider.of<ConversationService>(context, listen: false);
    final String conversationId = await conversationService
        .getOrCreateConversation(particulierId, currentUserId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationDetailScreen(
          otherUserName: 'company.name',
          conversationId: conversationId,
        ),
      ),
    );
  }
}
