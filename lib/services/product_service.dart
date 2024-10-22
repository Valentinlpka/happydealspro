// lib/services/product_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:happy_deals_pro/classes/product.dart';

class ProductService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? userId = FirebaseAuth.instance.currentUser;
  late String? userUid = userId?.uid;

  Future<List<Product>> getProductsForSeller(String sellerId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('merchantId', isEqualTo: sellerId)
          .get();

      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    } catch (e) {
      print('Erreur lors de la récupération des produits: $e');
      return [];
    }
  }

  Future<List<Product>> getProducts() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: userUid)
          .get();
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching products: $e');
      rethrow;
    }
  }

  Future<void> createProduct(Product product) async {
    try {
      await _functions.httpsCallable('createProduct').call(product.toMap());
    } catch (e) {
      print('Error creating product: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _functions.httpsCallable('updateProduct').call(product.toMap());
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _functions
          .httpsCallable('deleteProduct')
          .call({'productId': productId});
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }

  Future<void> updateStock(String productId, int newStock) async {
    try {
      await _functions.httpsCallable('updateStock').call({
        'productId': productId,
        'newStock': newStock,
      });
    } catch (e) {
      print('Error updating stock: $e');
      rethrow;
    }
  }
}
