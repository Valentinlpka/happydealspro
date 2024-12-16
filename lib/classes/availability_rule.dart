// lib/models/availability_rule_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TimeRange {
  final int hours;
  final int minutes;

  TimeRange(this.hours, this.minutes);

  factory TimeRange.fromTimeOfDay(TimeOfDay time) {
    return TimeRange(time.hour, time.minute);
  }

  Map<String, dynamic> toMap() {
    return {
      'hours': hours,
      'minutes': minutes,
    };
  }

  factory TimeRange.fromMap(Map<String, dynamic> map) {
    return TimeRange(
      map['hours'] as int,
      map['minutes'] as int,
    );
  }

  TimeOfDay toTimeOfDay() {
    return TimeOfDay(hour: hours, minute: minutes);
  }
}

class AvailabilityRuleModel {
  final String id;
  final String professionalId;
  final String serviceId;
  final List<int> workDays;
  final TimeRange startTime;
  final TimeRange endTime;
  final List<Map<String, TimeRange>> breakTimes;
  final List<DateTime> exceptionalClosedDates;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  AvailabilityRuleModel({
    required this.id,
    required this.professionalId,
    required this.serviceId,
    required this.workDays,
    required this.startTime,
    required this.endTime,
    this.breakTimes = const [],
    this.exceptionalClosedDates = const [],
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'professionalId': professionalId,
      'serviceId': serviceId,
      'workDays': workDays,
      'startTime': startTime.toMap(),
      'endTime': endTime.toMap(),
      'breakTimes': breakTimes
          .map((bt) => {
                'start': bt['start']?.toMap(),
                'end': bt['end']?.toMap(),
              })
          .toList(),
      'exceptionalClosedDates': exceptionalClosedDates
          .map((date) => Timestamp.fromDate(date))
          .toList(),
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory AvailabilityRuleModel.fromMap(Map<String, dynamic> map) {
    return AvailabilityRuleModel(
      id: map['id'] as String,
      professionalId: map['professionalId'] as String,
      serviceId: map['serviceId'] as String,
      workDays: List<int>.from(map['workDays']),
      startTime: TimeRange.fromMap(map['startTime']),
      endTime: TimeRange.fromMap(map['endTime']),
      breakTimes: (map['breakTimes'] as List)
          .map((bt) => {
                'start': TimeRange.fromMap(bt['start']),
                'end': TimeRange.fromMap(bt['end']),
              })
          .toList(),
      exceptionalClosedDates: (map['exceptionalClosedDates'] as List)
          .map((timestamp) => (timestamp as Timestamp).toDate())
          .toList(),
      isActive: map['isActive'] as bool,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
}
