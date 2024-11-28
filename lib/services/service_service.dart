import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:happy_deals_pro/classes/service_model.dart';

class ServiceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final String _collection = 'services';

  // Créer un nouveau service
  Future<ServiceModel> createService(ServiceModel service) async {
    try {
      final callable = _functions.httpsCallable('createService');
      final result = await callable.call({
        'name': service.name,
        'description': service.description,
        'price': service.price,
        'duration': service.duration,
        'images': service.images,
      });

      return await getServiceById(result.data['serviceId']);
    } catch (e) {
      throw Exception('Erreur lors de la création du service: $e');
    }
  }

  // Mettre à jour un service
  Future<void> updateService(ServiceModel service) async {
    try {
      final callable = _functions.httpsCallable('updateService');
      await callable.call({
        'serviceId': service.id,
        'name': service.name,
        'description': service.description,
        'price': service.price,
        'images': service.images,
        'isActive': service.isActive,
      });
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du service: $e');
    }
  }

  // Supprimer un service
  Future<void> deleteService(String serviceId) async {
    try {
      final callable = _functions.httpsCallable('deleteService');
      await callable.call({
        'serviceId': serviceId,
      });
    } catch (e) {
      throw Exception('Erreur lors de la suppression du service: $e');
    }
  }

  // Récupérer un service par ID
  Future<ServiceModel> getServiceById(String serviceId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(serviceId).get();
      if (!doc.exists) {
        throw Exception('Service non trouvé');
      }
      return ServiceModel.fromMap(doc.data()!);
    } catch (e) {
      throw Exception('Erreur lors de la récupération du service: $e');
    }
  }

  // Récupérer tous les services d'un professionnel
  Stream<List<ServiceModel>> getServicesByProfessional(String professionalId) {
    try {
      return _firestore
          .collection(_collection)
          .where('professionalId', isEqualTo: professionalId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ServiceModel.fromMap(doc.data()))
              .toList());
    } catch (e) {
      throw Exception('Erreur lors de la récupération des services: $e');
    }
  }

  // Activer/désactiver un service
  Future<void> toggleServiceStatus(String serviceId, bool isActive) async {
    try {
      final callable = _functions.httpsCallable('toggleServiceStatus');
      await callable.call({
        'serviceId': serviceId,
        'isActive': isActive,
      });
    } catch (e) {
      throw Exception('Erreur lors du changement de statut du service: $e');
    }
  }
}
