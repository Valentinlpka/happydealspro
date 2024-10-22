import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:happy_deals_pro/classes/order.dart';
import 'package:happy_deals_pro/screens/order_detail_page.dart';
import 'package:happy_deals_pro/services/order_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';

class EcranListeCommandes extends StatefulWidget {
  const EcranListeCommandes({super.key});

  @override
  _EcranListeCommandesState createState() => _EcranListeCommandesState();
}

class _EcranListeCommandesState extends State<EcranListeCommandes> {
  final OrderService _serviceCommandes = OrderService();
  List<Orders> _commandes = [];
  bool _estEnChargement = false;
  String _colonneTri = 'date';
  bool _triAscendant = false;
  final TextEditingController _controleurRecherche = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null).then((_) => _chargerCommandes());
  }

  Future<void> _chargerCommandes() async {
    setState(() {
      _estEnChargement = true;
    });

    List<Orders> nouvellesCommandes = await _serviceCommandes.getOrders();

    setState(() {
      _commandes = nouvellesCommandes;
      _estEnChargement = false;
    });
  }

  void _trierCommandes(String colonne, bool ascending) {
    setState(() {
      _colonneTri = colonne;
      _triAscendant = ascending;
      _commandes.sort((a, b) {
        var valeurA = _getValeurPourColonne(a, colonne);
        var valeurB = _getValeurPourColonne(b, colonne);
        return ascending
            ? Comparable.compare(valeurA, valeurB)
            : Comparable.compare(valeurB, valeurA);
      });
    });
  }

  dynamic _getValeurPourColonne(Orders commande, String colonne) {
    switch (colonne) {
      case 'id':
        return commande.id;
      case 'date':
        return commande.createdAt;
      case 'client':
        return commande.userId;
      case 'valeur':
        return commande.totalAmount;
      case 'statut':
        return commande.status;
      default:
        return '';
    }
  }

  Widget _construireEtiquetteStatut(Orders commande) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getCouleurStatut(commande.status),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        _getTexteStatut(commande.status),
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  String _getTexteStatut(String statut) {
    switch (statut.toLowerCase()) {
      case 'paid':
        return 'Payée';
      case 'en préparation':
        return 'En préparation';
      case 'prête à être retirée':
        return 'En attente';
      case 'completed':
        return 'Terminée';
      default:
        return 'Inconnue';
    }
  }

  Color _getCouleurStatut(String statut) {
    switch (statut.toLowerCase()) {
      case 'paid':
        return Colors.purple;
      case 'en préparation':
        return Colors.orange;
      case 'prête à être retirée':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _mettreAJourStatut(Orders commande, String nouveauStatut) async {
    try {
      Map<String, dynamic> result =
          await _serviceCommandes.updateOrderStatus(commande.id, nouveauStatut);
      if (result['success']) {
        setState(() {
          commande.status = nouveauStatut;
        });
        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.flat,
          autoCloseDuration: const Duration(seconds: 3),
          title: const Text('Statut mis à jour avec succès'),
          description: const Text('Le statut de la commande a été modifié.'),
        );
      }
    } catch (e) {
      toastification.show(
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        autoCloseDuration: const Duration(seconds: 3),
        title: const Text('Erreur'),
        description:
            Text('Erreur lors de la mise à jour du statut: ${e.toString()}'),
      );
    }
  }

  void _rechercherCommandes(String query) {
    setState(() {
      if (query.isEmpty) {
        _chargerCommandes();
      } else {
        _commandes = _commandes
            .where((commande) =>
                commande.id.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _showOrderDetail(BuildContext context, Orders order) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderDetailScreen(order: order),
      ),
    );
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
                "Mes commandes",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.black),
                onPressed: _chargerCommandes,
              ),
            ],
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controleurRecherche,
              decoration: const InputDecoration(
                hintText: 'Rechercher par numéro de commande...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _rechercherCommandes,
            ),
          ),
          Expanded(
            child: _estEnChargement
                ? const Center(child: CircularProgressIndicator())
                : DataTable2(
                    columnSpacing: 10,
                    columns: [
                      DataColumn2(
                        label: const Text('Numéro'),
                        size: ColumnSize.M,
                        onSort: (columnIndex, ascending) =>
                            _trierCommandes('id', ascending),
                      ),
                      DataColumn2(
                        label: const Text('Date'),
                        size: ColumnSize.M,
                        onSort: (columnIndex, ascending) =>
                            _trierCommandes('date', ascending),
                      ),
                      DataColumn2(
                        label: const Text('Client'),
                        size: ColumnSize.L,
                        onSort: (columnIndex, ascending) =>
                            _trierCommandes('client', ascending),
                      ),
                      DataColumn2(
                        label: const Text('Statut'),
                        size: ColumnSize.M,
                        onSort: (columnIndex, ascending) =>
                            _trierCommandes('statut', ascending),
                      ),
                      DataColumn2(
                        label: const Text('Valeur'),
                        size: ColumnSize.S,
                        numeric: true,
                        onSort: (columnIndex, ascending) =>
                            _trierCommandes('valeur', ascending),
                      ),
                      const DataColumn2(
                        label: Text('Actions'),
                        size: ColumnSize.L,
                      ),
                    ],
                    rows: _commandes
                        .map((commande) => DataRow2(
                              cells: [
                                DataCell(Text(commande.id)),
                                DataCell(Text(DateFormat('d MMMM yyyy', 'fr_FR')
                                    .format(commande.createdAt))),
                                DataCell(Text(commande.userId)),
                                DataCell(_construireEtiquetteStatut(commande)),
                                DataCell(Text(
                                    '${commande.totalAmount.toStringAsFixed(2)}€')),
                                DataCell(IconButton(
                                  icon: const Icon(Icons.more_vert),
                                  onPressed: () =>
                                      _showOrderDetail(context, commande),
                                )),
                              ],
                            ))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
