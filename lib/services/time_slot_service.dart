import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:happy_deals_pro/classes/time_slot.dart';

class TimeSlotService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'timeSlots';

  // Créer un nouveau créneau
  Future<TimeSlotModel> createTimeSlot(TimeSlotModel timeSlot) async {
    try {
      final docRef = _firestore.collection(_collection).doc();
      final newTimeSlot = TimeSlotModel(
        id: docRef.id,
        serviceId: timeSlot.serviceId,
        professionalId: timeSlot.professionalId,
        date: timeSlot.date,
        startTime: timeSlot.startTime,
        endTime: timeSlot.endTime,
        isAvailable: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await docRef.set(newTimeSlot.toMap());
      return newTimeSlot;
    } catch (e) {
      throw Exception('Erreur lors de la création du créneau: $e');
    }
  }

  // Dans la classe TimeSlotService, ajoutez cette méthode
  // Récupérer les créneaux pour un professionnel
  Stream<List<TimeSlotModel>> getTimeSlotsByProfessional(
      String professionalId, DateTime startDate) {
    try {
      final startOfWeek =
          startDate.subtract(Duration(days: startDate.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 7));

      return _firestore
          .collection(_collection)
          .where('professionalId', isEqualTo: professionalId)
          .where('date', isGreaterThanOrEqualTo: startOfWeek)
          .where('date', isLessThan: endOfWeek)
          .orderBy('date')
          .orderBy('startTime')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => TimeSlotModel.fromMap(doc.data()))
              .toList());
    } catch (e) {
      throw Exception('Erreur lors de la récupération des créneaux: $e');
    }
  }

  // Récupérer les créneaux pour une période donnée
  Stream<List<TimeSlotModel>> getTimeSlotsByDateRange(
      String professionalId, DateTime startDate, DateTime endDate) {
    try {
      return _firestore
          .collection(_collection)
          .where('professionalId', isEqualTo: professionalId)
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThan: endDate)
          .orderBy('date')
          .orderBy('startTime')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => TimeSlotModel.fromMap(doc.data()))
              .toList());
    } catch (e) {
      throw Exception('Erreur lors de la récupération des créneaux: $e');
    }
  }

  // Générer plusieurs créneaux
  Future<List<TimeSlotModel>> generateTimeSlots({
    required String serviceId,
    required String professionalId,
    required DateTime startDate,
    required DateTime endDate,
    required TimeOfDay workDayStart,
    required TimeOfDay workDayEnd,
    required int slotDuration,
    List<int> workDays = const [1, 2, 3, 4, 5], // Lun-Ven par défaut
  }) async {
    try {
      List<TimeSlotModel> generatedSlots = [];
      DateTime currentDate = startDate;

      while (currentDate.isBefore(endDate) ||
          currentDate.isAtSameMomentAs(endDate)) {
        // Vérifier si c'est un jour travaillé
        if (workDays.contains(currentDate.weekday)) {
          DateTime slotStart = DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
            workDayStart.hour,
            workDayStart.minute,
          );

          DateTime dayEnd = DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
            workDayEnd.hour,
            workDayEnd.minute,
          );

          while (slotStart.isBefore(dayEnd)) {
            DateTime slotEnd = slotStart.add(Duration(minutes: slotDuration));

            if (slotEnd.isAfter(dayEnd)) break;

            TimeSlotModel newSlot = TimeSlotModel(
              id: '',
              serviceId: serviceId,
              professionalId: professionalId,
              date: currentDate,
              startTime: slotStart,
              endTime: slotEnd,
              isAvailable: true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

            final createdSlot = await createTimeSlot(newSlot);
            generatedSlots.add(createdSlot);

            slotStart = slotEnd;
          }
        }
        currentDate = currentDate.add(const Duration(days: 1));
      }

      return generatedSlots;
    } catch (e) {
      throw Exception('Erreur lors de la génération des créneaux: $e');
    }
  }

  // Supprimer un créneau
  Future<void> deleteTimeSlot(String timeSlotId) async {
    try {
      await _firestore.collection(_collection).doc(timeSlotId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression du créneau: $e');
    }
  }

  // Récupérer les créneaux pour une date donnée
  Stream<List<TimeSlotModel>> getTimeSlotsByDate(
      String professionalId, DateTime date) {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      return _firestore
          .collection(_collection)
          .where('professionalId', isEqualTo: professionalId)
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThan: endOfDay)
          .orderBy('date')
          .orderBy('startTime')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => TimeSlotModel.fromMap(doc.data()))
              .toList());
    } catch (e) {
      throw Exception('Erreur lors de la récupération des créneaux: $e');
    }
  }

  // Mettre à jour la disponibilité d'un créneau
  Future<void> updateTimeSlotAvailability(
      String timeSlotId, bool isAvailable) async {
    try {
      await _firestore.collection(_collection).doc(timeSlotId).update({
        'isAvailable': isAvailable,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la disponibilité: $e');
    }
  }
}
