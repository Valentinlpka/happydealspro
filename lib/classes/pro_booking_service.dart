import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:happy_deals_pro/classes/pro_booking.dart';

class ProBookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtenir toutes les réservations d'un professionnel
  Stream<List<ProBookingModel>> getProfessionalBookings(String professionalId) {
    return _firestore
        .collection('bookings')
        .where('professionalId', isEqualTo: professionalId)
        .orderBy('bookingDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProBookingModel.fromMap(doc.data()))
            .toList());
  }

  // Obtenir les réservations pour une période donnée
  Stream<List<ProBookingModel>> getBookingsByDateRange(
    String professionalId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _firestore
        .collection('bookings')
        .where('professionalId', isEqualTo: professionalId)
        .where('bookingDate', isGreaterThanOrEqualTo: startDate)
        .where('bookingDate', isLessThan: endDate)
        .orderBy('bookingDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProBookingModel.fromMap(doc.data()))
            .toList());
  }

  // Obtenir les réservations pour une date spécifique
  Stream<List<ProBookingModel>> getBookingsByDate(
    String professionalId,
    DateTime date,
  ) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection('bookings')
        .where('professionalId', isEqualTo: professionalId)
        .where('bookingDate', isGreaterThanOrEqualTo: startOfDay)
        .where('bookingDate', isLessThan: endOfDay)
        .orderBy('bookingDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProBookingModel.fromMap(doc.data()))
            .toList());
  }

  // Obtenir les réservations du jour
  Stream<List<ProBookingModel>> getTodayBookings(String professionalId) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return getBookingsByDateRange(professionalId, startOfDay, endOfDay);
  }

  // Mettre à jour le statut d'une réservation
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du statut: $e');
    }
  }

  // Ajouter une note à une réservation
  Future<void> addBookingNote(String bookingId, String note) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'notes': note,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de la note: $e');
    }
  }

  // Obtenir les statistiques des réservations
  Future<Map<String, dynamic>> getBookingStats(
    String professionalId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final bookings = await _firestore
          .collection('bookings')
          .where('professionalId', isEqualTo: professionalId)
          .where('bookingDate', isGreaterThanOrEqualTo: startDate)
          .where('bookingDate', isLessThan: endDate)
          .get();

      int totalBookings = 0;
      int completedBookings = 0;
      int cancelledBookings = 0;
      double totalRevenue = 0;

      for (var doc in bookings.docs) {
        final booking = ProBookingModel.fromMap(doc.data());
        totalBookings++;

        switch (booking.status) {
          case 'completed':
            completedBookings++;
            totalRevenue += booking.price;
            break;
          case 'cancelled':
            cancelledBookings++;
            break;
        }
      }

      return {
        'totalBookings': totalBookings,
        'completedBookings': completedBookings,
        'cancelledBookings': cancelledBookings,
        'totalRevenue': totalRevenue,
        'completionRate': totalBookings > 0
            ? (completedBookings / totalBookings * 100).toStringAsFixed(1)
            : '0',
      };
    } catch (e) {
      throw Exception('Erreur lors de la récupération des statistiques: $e');
    }
  }

  // Obtenir les prochaines réservations
  Stream<List<ProBookingModel>> getUpcomingBookings(String professionalId) {
    return _firestore
        .collection('bookings')
        .where('professionalId', isEqualTo: professionalId)
        .where('bookingDate', isGreaterThanOrEqualTo: DateTime.now())
        .where('status', isEqualTo: 'confirmed')
        .orderBy('bookingDate')
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProBookingModel.fromMap(doc.data()))
            .toList());
  }

  // Reprogrammer une réservation
  Future<void> rescheduleBooking(
    String bookingId,
    String newTimeSlotId,
    DateTime newBookingDate,
  ) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Vérifier que le nouveau créneau est disponible
        final timeSlotDoc = await transaction
            .get(_firestore.collection('timeSlots').doc(newTimeSlotId));

        if (!timeSlotDoc.exists || !timeSlotDoc.data()!['isAvailable']) {
          throw Exception('Ce créneau n\'est plus disponible');
        }

        // Récupérer l'ancienne réservation
        final bookingDoc = await transaction
            .get(_firestore.collection('bookings').doc(bookingId));
        final oldTimeSlotId = bookingDoc.data()!['timeSlotId'];

        // Libérer l'ancien créneau
        transaction.update(
          _firestore.collection('timeSlots').doc(oldTimeSlotId),
          {
            'isAvailable': true,
            'bookedByUserId': null,
          },
        );

        // Réserver le nouveau créneau
        transaction.update(
          _firestore.collection('timeSlots').doc(newTimeSlotId),
          {
            'isAvailable': false,
            'bookedByUserId': bookingDoc.data()!['userId'],
          },
        );

        // Mettre à jour la réservation
        transaction.update(
          _firestore.collection('bookings').doc(bookingId),
          {
            'timeSlotId': newTimeSlotId,
            'bookingDate': newBookingDate,
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );
      });
    } catch (e) {
      throw Exception('Erreur lors de la reprogrammation: $e');
    }
  }
}
