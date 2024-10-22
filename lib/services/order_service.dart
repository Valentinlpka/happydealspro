// lib/services/order_service.dart
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:happy_deals_pro/classes/loyalty_card.dart';
import 'package:happy_deals_pro/classes/loyalty_program.dart';
import 'package:happy_deals_pro/classes/order.dart';

class OrderService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DocumentSnapshot? _lastDocumentSnapshot;

  Future<Map<String, dynamic>> updateOrderStatus(
      String orderId, String newStatus) async {
    // Vérifier l'authentification de l'utilisateur
    if (_auth.currentUser == null) {
      throw Exception("L'utilisateur doit être authentifié.");
    }

    try {
      // Référence à la commande
      final orderRef = _firestore.collection("orders").doc(orderId);
      final order = await orderRef.get();

      if (!order.exists) {
        throw Exception("Commande non trouvée");
      }

      // Vérifier que le statut est valide
      final validStatuses = [
        "payée",
        "en préparation",
        "prête à être retirée",
        "completed"
      ];
      if (!validStatuses.contains(newStatus)) {
        throw Exception("Statut invalide");
      }

      // Si le nouveau statut est "prête à être retirée", générer un code de retrait
      String? pickupCode;
      if (newStatus == "prête à être retirée") {
        pickupCode = _generatePickupCode();
      }

      // Mise à jour du statut
      await orderRef.update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
        if (pickupCode != null) 'pickupCode': pickupCode,
      });

      print('Statut mis à jour : $newStatus');

      return {
        'success': true,
        'orderId': orderId,
        'newStatus': newStatus,
        'pickupCode': pickupCode,
      };
    } catch (error) {
      print("Erreur lors de la mise à jour du statut de la commande: $error");
      throw Exception("Impossible de mettre à jour le statut de la commande");
    }
  }

  Future<Orders> getOrder(String orderId) async {
    DocumentSnapshot orderDoc =
        await _firestore.collection('orders').doc(orderId).get();

    if (!orderDoc.exists) {
      throw Exception('Commande non trouvée');
    }

    Map<String, dynamic> data = orderDoc.data() as Map<String, dynamic>;

    return Orders(
        id: orderDoc.id,
        userId: data['userId'],
        merchantId: data['sellerId'],
        items: (data['items'] as List)
            .map((item) => OrderItem.fromMap(item))
            .toList(),
        totalAmount: data['totalPrice'].toDouble(),
        status: data['status'],
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        pickupCode: data['pickupCode'],
        entrepriseId: data['entrepriseId'],
        reference: orderDoc.reference);
  }

  Future<void> _updateLoyaltyProgram(String orderId) async {
    print('Début de la mise a jour du programme de fidelité');
    try {
      final order = await getOrder(orderId);
      final loyaltyProgramDoc = await _firestore
          .collection('LoyaltyPrograms')
          .where('companyId', isEqualTo: order.entrepriseId)
          .get();

      if (loyaltyProgramDoc.docs.isNotEmpty) {
        final loyaltyProgram =
            LoyaltyProgram.fromFirestore(loyaltyProgramDoc.docs.first);
        final loyaltyCardDoc = await _firestore
            .collection('LoyaltyCards')
            .where('customerId', isEqualTo: order.userId)
            .where('companyId', isEqualTo: order.entrepriseId)
            .get();

        if (loyaltyCardDoc.docs.isNotEmpty) {
          final loyaltyCard =
              LoyaltyCard.fromFirestore(loyaltyCardDoc.docs.first);
          int newValue;

          switch (loyaltyProgram.type) {
            case LoyaltyProgramType.visits:
              newValue = loyaltyCard.currentValue + 1;
              break;
            case LoyaltyProgramType.points:
              newValue = loyaltyCard.currentValue +
                  (order.totalAmount ~/ loyaltyProgram.targetValue);
              break;
            case LoyaltyProgramType.amount:
              newValue = loyaltyCard.currentValue + order.totalAmount.toInt();
              break;
          }

          await _firestore
              .collection('LoyaltyCards')
              .doc(loyaltyCard.id)
              .update({'currentValue': newValue});

          if (newValue >= loyaltyProgram.targetValue) {
            await _generateReward(loyaltyCard, loyaltyProgram);
          }
        }
      }
    } catch (e) {
      print('Erreur lors de la mise à jour du programme de fidélité: $e');
    }
  }

  Future<void> _generateReward(LoyaltyCard card, LoyaltyProgram program) async {
    // Générer un code promo
    String promoCode = _generatePromoCode();

    await _firestore.collection('PromoCodes').add({
      'code': promoCode,
      'customerId': card.customerId,
      'companyId': card.companyId,
      'value': program.rewardValue,
      'isPercentage': program.isPercentage,
      'usedAt': null,
      'expiresAt': DateTime.now().add(const Duration(days: 30)),
    });

    // Réinitialiser la carte de fidélité
    await _firestore
        .collection('LoyaltyCards')
        .doc(card.id)
        .update({'currentValue': 0});

    // Envoyer une notification au client (à implémenter)
    // sendNotificationToCustomer(card.customerId, promoCode, program.rewardValue);
  }

  String _generatePromoCode() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final Random random = Random();
    return String.fromCharCodes(Iterable.generate(
        8, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  String _generatePickupCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(Random().nextInt(chars.length))));
  }

  Future<List<Orders>> getOrders(
      {int limit = 20, DocumentSnapshot? startAfter}) async {
    try {
      // Obtenir l'utilisateur actuellement connecté
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Aucun utilisateur connecté');
      }

      // Récupérer le document de l'utilisateur pour obtenir le stripeAccountId
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (!userDoc.exists) {
        throw Exception('Document utilisateur non trouvé');
      }

      String? stripeAccountId = userDoc.get('stripeAccountId');
      if (stripeAccountId == null) {
        throw Exception('stripeAccountId non trouvé pour cet utilisateur');
      }

      // Construire la requête pour les commandes
      Query query = _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: stripeAccountId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      QuerySnapshot querySnapshot = await query.get();

      // Sauvegarde du dernier DocumentSnapshot
      _lastDocumentSnapshot =
          querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null;

      return querySnapshot.docs.map((doc) {
        return Orders.fromFirestore(doc);
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des commandes: $e');
      return [];
    }
  }

  DocumentSnapshot? getLastDocument() {
    return _lastDocumentSnapshot;
  }

  Future<String> getCustomerName(String userId) async {
    try {
      DocumentSnapshot customerDoc =
          await _firestore.collection('users').doc(userId).get();

      if (customerDoc.exists) {
        Map<String, dynamic> data = customerDoc.data() as Map<String, dynamic>;
        String firstName = data['firstName'] ?? '';
        String lastName = data['lastName'] ?? '';
        return '$firstName $lastName'.trim();
      } else {
        return 'Client inconnu';
      }
    } catch (e) {
      print('Erreur lors de la récupération du nom du client: $e');
      return 'Erreur de chargement';
    }
  }

  Future<void> confirmOrderPickup(String orderId, String pickupCode) async {
    try {
      await _functions.httpsCallable('confirmOrderPickup').call({
        'orderId': orderId,
        'pickupCode': pickupCode,
      });
      await _updateLoyaltyProgram(orderId);
    } catch (e) {
      print('Error confirming order pickup: $e');
      rethrow;
    }
  }
}
