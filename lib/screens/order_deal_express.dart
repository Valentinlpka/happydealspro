import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:happy_deals_pro/screens/order_details_deal_express.dart';
import 'package:intl/intl.dart';

class DealExpressOrdersPage extends StatefulWidget {
  const DealExpressOrdersPage({super.key});

  @override
  _DealExpressOrdersPageState createState() => _DealExpressOrdersPageState();
}

class _DealExpressOrdersPageState extends State<DealExpressOrdersPage> {
  final StreamController<List<DocumentSnapshot>> _ordersController =
      StreamController<List<DocumentSnapshot>>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription? _ordersSubscription;
  String _sortColumn = 'pickupDate';
  bool _sortAscending = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initOrdersStream();
  }

  void _initOrdersStream() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final ordersQuery = FirebaseFirestore.instance
            .collection('reservations')
            .where('companyId', isEqualTo: user.uid)
            .orderBy('pickupDate', descending: true);

        _ordersSubscription = ordersQuery.snapshots().listen((snapshot) {
          _ordersController.add(snapshot.docs);
        }, onError: (error) {
          _ordersController
              .addError('Erreur lors de la récupération des commandes: $error');
        });
      } catch (e) {
        _ordersController.addError(
            'Erreur lors de l\'initialisation du flux de données: $e');
      }
    } else {
      _ordersController.addError('Utilisateur non connecté');
    }
  }

  void _sortOrders(
      List<DocumentSnapshot> orders, String column, bool ascending) {
    orders.sort((a, b) {
      var aValue = _getValueForColumn(a, column);
      var bValue = _getValueForColumn(b, column);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
  }

  dynamic _getValueForColumn(DocumentSnapshot order, String column) {
    final data = order.data() as Map<String, dynamic>;
    switch (column) {
      case 'id':
        return order.id;
      case 'pickupDate':
        return data['pickupDate'] as Timestamp;
      case 'price':
        return data['price'];
      case 'status':
        return data['isValidated'];
      default:
        return '';
    }
  }

  List<DocumentSnapshot> _filterOrders(
      List<DocumentSnapshot> orders, String query) {
    if (query.isEmpty) {
      return orders;
    } else {
      return orders
          .where(
              (order) => order.id.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void _showOrderDetail(BuildContext context, DocumentSnapshot order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.9,
            padding: const EdgeInsets.all(16),
            child: OrderDetailsPage(orderId: order.id),
          ),
        );
      },
    );
  }

  void _confirmOrder(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String enteredCode = '';
        return AlertDialog(
          title: const Text('Confirmer la commande'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Entrez le code de validation:'),
              TextField(
                onChanged: (value) {
                  enteredCode = value;
                },
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(hintText: 'Code à 6 chiffres'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirmer'),
              onPressed: () {
                _validateOrder(context, orderId, enteredCode);
              },
            ),
          ],
        );
      },
    );
  }

  void _validateOrder(
      BuildContext context, String orderId, String enteredCode) {
    FirebaseFirestore.instance
        .collection('reservations')
        .doc(orderId)
        .get()
        .then((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['validationCode'] == enteredCode) {
          doc.reference.update({'isValidated': true}).then((_) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Commande confirmée avec succès')),
            );
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Code de validation incorrect')),
          );
        }
      }
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
                "Commandes Deal Express",
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Rechercher par numéro de commande...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {}); // Trigger rebuild to apply filter
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<DocumentSnapshot>>(
              stream: _ordersController.stream,
              builder: (BuildContext context,
                  AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child:
                          Text('Une erreur est survenue: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Aucune commande trouvée'));
                }

                var filteredOrders =
                    _filterOrders(snapshot.data!, _searchController.text);
                _sortOrders(filteredOrders, _sortColumn, _sortAscending);

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: constraints.maxWidth,
                        child: PaginatedDataTable2(
                          columns: [
                            DataColumn2(
                              label: const Text('Numéro'),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {
                                setState(() {
                                  _sortColumn = 'id';
                                  _sortAscending = ascending;
                                });
                              },
                            ),
                            DataColumn2(
                              label: const Text('Date de retrait'),
                              size: ColumnSize.M,
                              onSort: (columnIndex, ascending) {
                                setState(() {
                                  _sortColumn = 'pickupDate';
                                  _sortAscending = ascending;
                                });
                              },
                            ),
                            DataColumn2(
                              label: const Text('Prix'),
                              size: ColumnSize.S,
                              numeric: true,
                              onSort: (columnIndex, ascending) {
                                setState(() {
                                  _sortColumn = 'price';
                                  _sortAscending = ascending;
                                });
                              },
                            ),
                            DataColumn2(
                              label: const Text('Statut'),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {
                                setState(() {
                                  _sortColumn = 'status';
                                  _sortAscending = ascending;
                                });
                              },
                            ),
                            const DataColumn2(
                              label: Text('Actions'),
                              size: ColumnSize.M,
                            ),
                          ],
                          source: _DealExpressDataSource(filteredOrders,
                              context, _showOrderDetail, _confirmOrder),
                          rowsPerPage: 10,
                          autoRowsToHeight: true,
                          minWidth: constraints.maxWidth,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    _ordersController.close();
    _searchController.dispose();
    super.dispose();
  }
}

class _DealExpressDataSource extends DataTableSource {
  final List<DocumentSnapshot> _orders;
  final BuildContext context;
  final Function(BuildContext, DocumentSnapshot) showOrderDetail;
  final Function(BuildContext, String) confirmOrder;

  _DealExpressDataSource(
      this._orders, this.context, this.showOrderDetail, this.confirmOrder);

  @override
  DataRow? getRow(int index) {
    if (index >= _orders.length) return null;
    final order = _orders[index];
    final orderData = order.data() as Map<String, dynamic>;
    return DataRow2(
      cells: [
        DataCell(Text(order.id.substring(0, 6))),
        DataCell(Text(DateFormat('dd/MM/yyyy HH:mm')
            .format((orderData['pickupDate'] as Timestamp).toDate()))),
        DataCell(Text('${orderData['price']} €')),
        DataCell(Text(orderData['isValidated'] ? 'Confirmé' : 'En attente')),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, color: Colors.blue),
                onPressed: () => showOrderDetail(context, order),
                tooltip: 'Voir les détails',
              ),
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                onPressed: orderData['isValidated']
                    ? null
                    : () => confirmOrder(context, order.id),
                tooltip: 'Confirmer la commande',
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _orders.length;

  @override
  int get selectedRowCount => 0;
}
