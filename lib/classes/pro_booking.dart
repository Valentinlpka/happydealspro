// lib/models/pro_booking_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ProBookingModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String serviceId;
  final String serviceName;
  final String professionalId;
  final String timeSlotId;
  final DateTime bookingDate;
  final double price;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? stripeSessionId;
  final int duration;

  ProBookingModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.serviceId,
    required this.serviceName,
    required this.professionalId,
    required this.timeSlotId,
    required this.bookingDate,
    required this.price,
    required this.status,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.stripeSessionId,
    required this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'professionalId': professionalId,
      'timeSlotId': timeSlotId,
      'bookingDate': bookingDate,
      'price': price,
      'status': status,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'stripeSessionId': stripeSessionId,
      'duration': duration,
    };
  }

  factory ProBookingModel.fromMap(Map<String, dynamic> map) {
    return ProBookingModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      userPhone: map['userPhone'] ?? '',
      serviceId: map['serviceId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      professionalId: map['professionalId'] ?? '',
      timeSlotId: map['timeSlotId'] ?? '',
      bookingDate: (map['bookingDate'] as Timestamp).toDate(),
      price: (map['price'] ?? 0).toDouble(),
      status: map['status'] ?? '',
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      stripeSessionId: map['stripeSessionId'],
      duration: map['duration'] ?? 30,
    );
  }

  ProBookingModel copyWith({
    String? status,
    String? notes,
    DateTime? updatedAt,
  }) {
    return ProBookingModel(
      id: id,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
      serviceId: serviceId,
      serviceName: serviceName,
      professionalId: professionalId,
      timeSlotId: timeSlotId,
      bookingDate: bookingDate,
      price: price,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      stripeSessionId: stripeSessionId,
      duration: duration,
    );
  }
}
