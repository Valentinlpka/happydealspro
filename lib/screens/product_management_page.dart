import 'package:flutter/material.dart';
import 'package:happy_deals_pro/screens/deal_express_page.dart';
import 'package:happy_deals_pro/screens/happy_deals_page.dart';
import 'package:happy_deals_pro/screens/product_list_page.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  _ProductManagementScreenState createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  String _selectedOption = 'Produits';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildOptionButtons(),
          Expanded(
            child: _buildSelectedView(),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButtons() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildOptionButton('Produits', Icons.inventory),
          _buildOptionButton('Happy Deals', Icons.local_offer),
          _buildOptionButton('Deals Express', Icons.flash_on),
        ],
      ),
    );
  }

  Widget _buildOptionButton(String title, IconData icon) {
    bool isSelected = _selectedOption == title;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: isSelected ? Colors.white : Colors.black,
          backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          setState(() {
            _selectedOption = title;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(height: 5),
            Text(title),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedView() {
    switch (_selectedOption) {
      case 'Produits':
        return const ProductListScreen();
      case 'Happy Deals':
        return const HappyDealsPage();
      case 'Deals Express':
        return const ExpressDealPage();
      default:
        return const Center(child: Text('Sélectionnez une option'));
    }
  }
}
