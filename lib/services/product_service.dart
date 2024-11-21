import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:happy_deals_pro/classes/product.dart';
import 'package:happy_deals_pro/classes/product_post.dart';

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
      // Appeler la Cloud Function pour créer le produit
      final result =
          await _functions.httpsCallable('createProduct').call(product.toMap());

      // Récupérer l'ID du produit créé
      final String productId = result.data['productId'];

      // Créer le ProductPost avec le bon ID de produit
      final productPost = ProductPost.fromProductWithId(product, productId);

      // Utiliser une transaction pour s'assurer que les deux opérations réussissent
      await _firestore.runTransaction((transaction) async {
        // Vérifier que le produit a bien été créé
        final productDoc = await transaction
            .get(_firestore.collection('products').doc(productId));

        if (!productDoc.exists) {
          throw Exception('Le produit n\'a pas été créé correctement');
        }

        // Créer le post associé
        transaction.set(
          _firestore.collection('posts').doc(productPost.id),
          productPost.toMap(),
        );
      });
    } catch (e) {
      print('Error creating product: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      // S'assurer que toutes les données requises sont présentes
      final data = {
        'productId': product.id,
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'images': product.images,
        'isActive': product.isActive,
        'stock': product.stock
      };
      if (data.values.any((value) => value == null)) {
        throw Exception("Toutes les données sont requises");
      }

      // Mettre à jour le produit via Cloud Functions
      await _functions.httpsCallable('updateProduct').call(data);

      // Mettre à jour le post associé
      await _firestore.runTransaction((transaction) async {
        // Trouver le post associé
        final postQuery = await _firestore
            .collection('posts')
            .where('type', isEqualTo: 'product')
            .where('productId', isEqualTo: product.id)
            .limit(1)
            .get();

        if (postQuery.docs.isNotEmpty) {
          final existingPost = ProductPost.fromDocument(postQuery.docs.first);

          // Mettre à jour le post avec les nouvelles informations
          final updatedPost = existingPost.copyWith(
            name: product.name,
            description: product.description,
            price: product.price,
            tva: product.tva,
            images: product.images,
            stock: product.stock,
            isActive: product.isActive,
            hasActiveHappyDeal: product.hasActiveHappyDeal,
            discountedPrice: product.discountedPrice,
            discountPercentage: product.discountPercentage,
            timestamp: DateTime.now(), // Optionnel: mettre à jour le timestamp
          );

          transaction.update(
            _firestore.collection('posts').doc(existingPost.id),
            updatedPost.toMap(),
          );
        }
      });
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      // D'abord appeler la Cloud Function de manière isolée
      await _functions
          .httpsCallable('deleteProduct')
          .call({'productId': productId});

      // Ensuite supprimer le post associé sans transaction
      final postQuery = await _firestore
          .collection('posts')
          .where('type', isEqualTo: 'product')
          .where('productId', isEqualTo: productId)
          .limit(1)
          .get();

      if (postQuery.docs.isNotEmpty) {
        await _firestore
            .collection('posts')
            .doc(postQuery.docs.first.id)
            .delete();
      }
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }

  Future<void> updateStock(String productId, int newStock) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Mettre à jour le stock via Cloud Functions
        await _functions.httpsCallable('updateStock').call({
          'productId': productId,
          'newStock': newStock,
        });

        // Mettre à jour le stock dans le post associé
        final postQuery = await _firestore
            .collection('posts')
            .where('type', isEqualTo: 'product')
            .where('productId', isEqualTo: productId)
            .limit(1)
            .get();

        if (postQuery.docs.isNotEmpty) {
          transaction.update(
            _firestore.collection('posts').doc(postQuery.docs.first.id),
            {'stock': newStock},
          );
        }
      });
    } catch (e) {
      print('Error updating stock: $e');
      rethrow;
    }
  }

  // Méthode pour synchroniser manuellement un produit avec son post
  Future<void> syncProductWithPost(String productId) async {
    try {
      final productDoc =
          await _firestore.collection('products').doc(productId).get();
      if (!productDoc.exists) return;

      final product = Product.fromFirestore(productDoc);
      final productPost = ProductPost.fromProduct(product);

      final postQuery = await _firestore
          .collection('posts')
          .where('type', isEqualTo: 'product')
          .where('productId', isEqualTo: productId)
          .limit(1)
          .get();

      if (postQuery.docs.isNotEmpty) {
        await _firestore
            .collection('posts')
            .doc(postQuery.docs.first.id)
            .update(productPost.toMap());
      } else {
        await _firestore
            .collection('posts')
            .doc(productPost.id)
            .set(productPost.toMap());
      }
    } catch (e) {
      print('Error syncing product with post: $e');
      rethrow;
    }
  }
}
