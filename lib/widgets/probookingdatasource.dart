import 'dart:ui';

import 'package:happy_deals_pro/classes/pro_booking.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class ProBookingDataSource extends CalendarDataSource {
  ProBookingDataSource(List<ProBookingModel> appointments) {
    this.appointments = appointments;
  }

  @override
  DateTime getStartTime(int index) => appointments![index].bookingDate;

  @override
  DateTime getEndTime(int index) => appointments![index]
      .bookingDate
      .add(Duration(minutes: appointments![index].duration));

  @override
  bool isAllDay(int index) => false;

  @override
  String getSubject(int index) => appointments![index].serviceName;

  @override
  String? getNotes(int index) => appointments![index].notes;

  @override
  Color getColor(int index) {
    switch (appointments![index].status) {
      case 'confirmed':
        return const Color(0xFF4CAF50); // Green
      case 'cancelled':
        return const Color(0xFFE53935); // Red
      case 'completed':
        return const Color(0xFF2196F3); // Blue
      default:
        return const Color(0xFF9E9E9E); // Gray
    }
  }
}
