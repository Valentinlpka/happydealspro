import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:happy_deals_pro/classes/availability_rule.dart';

class AvailabilityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final String _collection = 'availabilityRules';

  // Créer une nouvelle règle de disponibilité
  Future<void> createAvailabilityRule(Map<String, dynamic> ruleData) async {
    try {
      final callable = _functions.httpsCallable('createAvailabilityRule');
      await callable.call(ruleData);
    } catch (e) {
      throw Exception('Erreur lors de la création de la règle: $e');
    }
  }

  // Récupérer une règle par ID
  Future<AvailabilityRuleModel> getAvailabilityRuleById(String ruleId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(ruleId).get();
      if (!doc.exists) {
        throw Exception('Règle non trouvée');
      }
      return AvailabilityRuleModel.fromMap(doc.data()!);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la règle: $e');
    }
  }

  // Récupérer les règles d'un professionnel
  Stream<List<AvailabilityRuleModel>> getAvailabilityRulesByProfessional(
      String professionalId) {
    return _firestore
        .collection(_collection)
        .where('professionalId', isEqualTo: professionalId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AvailabilityRuleModel.fromMap(doc.data()))
            .toList());
  }

  // Récupérer les règles pour un service spécifique
  Stream<List<AvailabilityRuleModel>> getAvailabilityRulesByService(
      String serviceId) {
    return _firestore
        .collection(_collection)
        .where('serviceId', isEqualTo: serviceId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AvailabilityRuleModel.fromMap(doc.data()))
            .toList());
  }

  // Mettre à jour une règle
  Future<void> updateAvailabilityRule(AvailabilityRuleModel rule) async {
    try {
      final callable = _functions.httpsCallable('updateAvailabilityRule');
      await callable.call(rule.toMap());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la règle: $e');
    }
  }

  // Supprimer une règle
  Future<void> deleteAvailabilityRule(String ruleId) async {
    try {
      final callable = _functions.httpsCallable('deleteAvailabilityRule');
      await callable.call({'ruleId': ruleId});
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la règle: $e');
    }
  }

  // Vérifier si une règle existe déjà pour un service
  Future<bool> hasExistingRule(String serviceId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('serviceId', isEqualTo: serviceId)
          .where('isActive', isEqualTo: true)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception(
          'Erreur lors de la vérification des règles existantes: $e');
    }
  }
}
