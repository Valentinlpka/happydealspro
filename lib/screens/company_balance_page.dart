import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CompanyBalancePage extends StatefulWidget {
  const CompanyBalancePage({super.key});

  @override
  _CompanyBalancePageState createState() => _CompanyBalancePageState();
}

class _CompanyBalancePageState extends State<CompanyBalancePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  String? _companyId;
  double _totalGain = 0;
  double _totalFees = 0;
  double _availableBalance = 0;
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;
  List<Map<String, dynamic>> _payouts = [];

  @override
  void initState() {
    super.initState();
    _loadCompanyData();
  }

  Future<void> _loadCompanyData() async {
    setState(() => _isLoading = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final companySnapshot =
            await _firestore.collection('companys').doc(user.uid).get();

        if (companySnapshot.exists) {
          final companyDoc = companySnapshot;
          final companyData = companyDoc.data();
          setState(() {
            _companyId = companyDoc.id;
            _totalGain = companyData?['totalGain'] ?? 0;
            _totalFees = companyData?['totalFees'] ?? 0;
            _availableBalance = companyData?['availableBalance'] ?? 0;
          });
          await Future.wait([
            _loadTransactions(),
            _loadPayouts(),
          ]);
        } else {
          _showErrorSnackBar('Aucune entreprise trouvée pour cet utilisateur');
        }
      }
    } catch (e) {
      print(e);
      _showErrorSnackBar('Erreur lors du chargement des données: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPayouts() async {
    if (_companyId != null) {
      final payoutsSnapshot = await _firestore
          .collection('payouts')
          .where('companyId', isEqualTo: _companyId)
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        _payouts = payoutsSnapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList();
      });
    }
  }

  Future<void> _loadTransactions() async {
    if (_companyId != null) {
      final transactionsSnapshot = await _firestore
          .collection('transactions')
          .where('companyId', isEqualTo: _companyId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      setState(() {
        _transactions = transactionsSnapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solde et Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCompanyData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildFinancialSummary(),
                  _buildTransactionList(),
                ],
              ),
            ),
    );
  }

  Widget _buildFinancialSummary() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Résumé Financier',
            ),
            const SizedBox(height: 16),
            _buildFinancialRow('Gains totaux', _totalGain),
            _buildFinancialRow('Frais de plateforme', _totalFees),
            const Divider(),
            _buildFinancialRow('Solde disponible', _availableBalance,
                isTotal: true),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _requestPayout,
              child: const Text('Demander un virement'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialRow(String label, double amount,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: isTotal
                  ? const TextStyle(fontWeight: FontWeight.bold)
                  : null),
          Text(
            '${amount.toStringAsFixed(2)} €',
            style:
                isTotal ? const TextStyle(fontWeight: FontWeight.bold) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    final List<Map<String, dynamic>> allTransactions = [
      ..._transactions,
      ..._payouts,
    ];

    allTransactions.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));

    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Dernières transactions et demandes de virement',
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: allTransactions.length,
            itemBuilder: (context, index) {
              final item = allTransactions[index];
              if (item.containsKey('orderId')) {
                return _buildTransactionItem(item);
              } else {
                return _buildPayoutItem(item);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    return ListTile(
      title: Text('Commande #${transaction['orderId']}'),
      subtitle: Text(DateFormat('dd/MM/yyyy HH:mm')
          .format(transaction['createdAt'].toDate())),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${transaction['totalAmount'].toStringAsFixed(2)} €',
            style: TextStyle(color: Colors.green[600]),
          ),
          Text(
            '- ${transaction['feeAmount'].toStringAsFixed(2)} €',
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutItem(Map<String, dynamic> payout) {
    return ListTile(
      title: const Text('Demande de virement'),
      subtitle: Text(
          DateFormat('dd/MM/yyyy HH:mm').format(payout['createdAt'].toDate())),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '- ${payout['amount'].toStringAsFixed(2)} €',
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  Future<void> _requestPayout() async {
    final TextEditingController amountController = TextEditingController();
    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Demander un virement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Montant (€)',
                hintText: 'Entrez le montant à virer',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Solde disponible: ${_availableBalance.toStringAsFixed(2)} €',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Annuler'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text('Confirmer'),
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0 && amount <= _availableBalance) {
                Navigator.of(context).pop(amount);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Montant invalide ou supérieur au solde disponible'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );

    if (result != null && result > 0) {
      try {
        final callable = _functions.httpsCallable('requestPayout');
        final response = await callable.call({
          'amount': result,
          'companyId': _companyId,
        });

        if (response.data['success']) {
          _showSuccessSnackBar('Demande de virement effectuée avec succès');
          _loadCompanyData();
        }
      } catch (e) {
        _showErrorSnackBar('Erreur lors de la demande de virement: $e');
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
