// lib/pages/professional/planning_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:happy_deals_pro/classes/pro_booking.dart';
import 'package:happy_deals_pro/classes/pro_booking_service.dart';
import 'package:happy_deals_pro/classes/service_model.dart';
import 'package:happy_deals_pro/widgets/probookingdatasource.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../services/service_service.dart';

class PlanningDashboardPage extends StatefulWidget {
  final String professionalId;

  const PlanningDashboardPage({
    super.key,
    required this.professionalId,
  });

  @override
  _PlanningDashboardPageState createState() => _PlanningDashboardPageState();
}

class _PlanningDashboardPageState extends State<PlanningDashboardPage> {
  final ProBookingService _bookingService = ProBookingService();
  final ServiceService _serviceService = ServiceService();

  // État du calendrier
  CalendarView _currentView = CalendarView.week;
  DateTime _selectedDate = DateTime.now();
  final List<String> _viewOptions = ['Jour', 'Semaine', 'Mois'];
  String _currentViewOption = 'Semaine';

  // Filtres et sélections
  ServiceModel? _selectedService;
  ProBookingModel? _selectedBooking;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Panneau latéral gauche
          Container(
            width: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: _buildSidePanel(),
          ),

          // Contenu principal
          Expanded(
            child: Column(
              children: [
                _buildCalendarHeader(),
                Expanded(child: _buildCalendar()),
              ],
            ),
          ),

          // Panneau de détails
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _selectedBooking != null ? 300 : 0,
            child: _selectedBooking != null
                ? _buildDetailsPanel()
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsPanel() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Détails du rendez-vous',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[100],
                child: Text(
                  _selectedBooking!.userName[0].toUpperCase(),
                  style: TextStyle(color: Colors.grey[800]),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedBooking!.userName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(_selectedBooking!.userEmail),
                    const SizedBox(height: 4),
                    Text(_selectedBooking!.userPhone),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _selectedBooking!.serviceName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('EEEE d MMMM y HH:mm', 'fr_FR')
                .format(_selectedBooking!.bookingDate),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          if (_selectedBooking!.notes != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notes',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(_selectedBooking!.notes!),
              ],
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Mettre à jour le statut de la réservation
                },
                child: Text(_selectedBooking!.status.toUpperCase()),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  // Ajouter une note à la réservation
                },
                child: const Text('Ajouter une note'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  // Reprogrammer la réservation
                },
                child: const Text('Reprogrammer'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Construction du panneau latéral
  Widget _buildSidePanel() {
    return Column(
      children: [
        // En-tête avec le nom du professionnel
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Planning',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                DateFormat.yMMMMEEEEd('fr_FR').format(DateTime.now()),
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        // Statistiques du jour
        _buildDailyStats(),

        const Divider(),

        // Liste des prochains rendez-vous
        Expanded(child: _buildUpcomingAppointments()),

        const Divider(),

        // Filtres par service
        _buildFilters(),
      ],
    );
  }

  // Construction des statistiques journalières
  Widget _buildDailyStats() {
    return StreamBuilder<List<ProBookingModel>>(
      stream: _bookingService.getTodayBookings(widget.professionalId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final bookings = snapshot.data!;
        final totalBookings = bookings.length;
        final completedBookings =
            bookings.where((b) => b.status == 'completed').length;
        final revenue =
            bookings.fold(0.0, (sum, booking) => sum + booking.price);

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Aujourd'hui",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                'Rendez-vous',
                '$completedBookings/$totalBookings',
                Icons.event,
                Colors.blue,
              ),
              const SizedBox(height: 8),
              _buildStatCard(
                'Chiffre du jour',
                '${revenue.toStringAsFixed(2)} €',
                Icons.euro,
                Colors.green,
              ),
            ],
          ),
        );
      },
    );
  }

  // Construction d'une carte de statistique
  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Construction de la liste des prochains rendez-vous
  Widget _buildUpcomingAppointments() {
    return StreamBuilder<List<ProBookingModel>>(
      stream: _bookingService.getUpcomingBookings(widget.professionalId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final bookings = snapshot.data!;

        if (bookings.isEmpty) {
          return const Center(
            child: Text('Aucun rendez-vous à venir'),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: bookings.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) =>
              _buildAppointmentTile(bookings[index]),
        );
      },
    );
  }

  // Construction d'une tuile de rendez-vous
  Widget _buildAppointmentTile(ProBookingModel booking) {
    Color statusColor;
    switch (booking.status) {
      case 'confirmed':
        statusColor = Colors.green;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      case 'completed':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey[100],
        child: Text(
          booking.userName[0].toUpperCase(),
          style: TextStyle(color: Colors.grey[800]),
        ),
      ),
      title: Text(booking.userName),
      subtitle: Text(booking.serviceName),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          DateFormat('HH:mm').format(booking.bookingDate),
          style: TextStyle(color: statusColor),
        ),
      ),
      onTap: () => setState(() => _selectedBooking = booking),
      selected: _selectedBooking?.id == booking.id,
    );
  }

  // Construction des filtres
  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtrer par service',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          StreamBuilder<List<ServiceModel>>(
            stream: _serviceService
                .getServicesByProfessional(widget.professionalId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const LinearProgressIndicator();
              }

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Tous'),
                    selected: _selectedService == null,
                    onSelected: (selected) {
                      setState(() => _selectedService = null);
                    },
                  ),
                  ...snapshot.data!.map((service) {
                    return FilterChip(
                      label: Text(service.name),
                      selected: _selectedService?.id == service.id,
                      onSelected: (selected) {
                        setState(() {
                          _selectedService = selected ? service : null;
                        });
                      },
                    );
                  }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DropdownButton<String>(
            value: _currentViewOption,
            items: _viewOptions
                .map((option) => DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _currentViewOption = value;
                  switch (value) {
                    case 'Jour':
                      _currentView = CalendarView.day;
                      break;
                    case 'Semaine':
                      _currentView = CalendarView.week;
                      break;
                    case 'Mois':
                      _currentView = CalendarView.month;
                      break;
                  }
                });
              }
            },
          ),
          IconButton(
            onPressed: () {
              setState(() {
                switch (_currentView) {
                  case CalendarView.day:
                    _selectedDate =
                        _selectedDate.subtract(const Duration(days: 1));
                    break;
                  case CalendarView.week:
                    _selectedDate =
                        _selectedDate.subtract(const Duration(days: 7));
                    break;
                  case CalendarView.month:
                    _selectedDate = DateTime(
                        _selectedDate.year, _selectedDate.month - 1, 1);
                    break;
                  default:
                    throw UnimplementedError();
                }
              });
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
          Text(DateFormat('MMMM yyyy', 'fr_FR').format(_selectedDate)),
          IconButton(
            onPressed: () {
              setState(() {
                switch (_currentView) {
                  case CalendarView.day:
                    _selectedDate = _selectedDate.add(const Duration(days: 1));
                    break;
                  case CalendarView.week:
                    _selectedDate = _selectedDate.add(const Duration(days: 7));
                    break;
                  case CalendarView.month:
                    _selectedDate = DateTime(_selectedDate.year,
                        _selectedDate.month + 1, _selectedDate.day);
                    break;
                  case CalendarView.workWeek:
                  // TODO: Handle this case.
                  case CalendarView.timelineDay:
                  // TODO: Handle this case.
                  case CalendarView.timelineWeek:
                  // TODO: Handle this case.
                  case CalendarView.timelineWorkWeek:
                  // TODO: Handle this case.
                  case CalendarView.timelineMonth:
                  // TODO: Handle this case.
                  case CalendarView.schedule:
                  // TODO: Handle this case.
                }
              });
            },
            icon: const Icon(Icons.arrow_forward_ios),
          ),
        ],
      ),
    );
  }

  Stream<List<ProBookingModel>> _getBookingsStream() {
    switch (_currentView) {
      case CalendarView.day:
        return _bookingService.getBookingsByDate(
          widget.professionalId,
          _selectedDate,
        );
      case CalendarView.week:
        return _bookingService.getBookingsByDateRange(
          widget.professionalId,
          _selectedDate,
          _selectedDate.add(const Duration(days: 7)),
        );
      case CalendarView.month:
        final firstDay = DateTime(_selectedDate.year, _selectedDate.month, 1);
        final lastDay =
            DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
        return _bookingService.getBookingsByDateRange(
          widget.professionalId,
          firstDay,
          lastDay,
        );
      default:
        throw UnimplementedError();
    }
  }

  Widget _buildCalendar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: StreamBuilder<List<ProBookingModel>>(
        stream: _getBookingsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data!;

          return SfCalendar(
            view: _currentView,
            dataSource: ProBookingDataSource(bookings),
            onTap: (calendarTapDetails) {
              if (calendarTapDetails.targetElement ==
                  CalendarElement.calendarCell) {
                setState(() {
                  _selectedDate = calendarTapDetails.date!;
                });
              }
              if (calendarTapDetails.appointments != null &&
                  calendarTapDetails.appointments!.isNotEmpty) {
                setState(() {
                  _selectedBooking = calendarTapDetails.appointments!.first;
                });
              } else {
                setState(() {
                  _selectedBooking = null;
                });
              }
            },
            onViewChanged: (ViewChangedDetails details) {
              setState(() {
                _selectedDate = details.visibleDates[0];
              });
            },
            initialDisplayDate: _selectedDate, // Ajoutez cette ligne
            monthViewSettings: const MonthViewSettings(
              appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
            ),
          );
        },
      ),
    );
  }

  Widget buildDetailsPanel() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Détails du rendez-vous',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[100],
                child: Text(
                  _selectedBooking!.userName[0].toUpperCase(),
                  style: TextStyle(color: Colors.grey[800]),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedBooking!.userName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(_selectedBooking!.userEmail),
                    const SizedBox(height: 4),
                    Text(_selectedBooking!.userPhone),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _selectedBooking!.serviceName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('EEEE d MMMM y HH:mm', 'fr_FR')
                .format(_selectedBooking!.bookingDate),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          if (_selectedBooking!.notes != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notes',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(_selectedBooking!.notes!),
              ],
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Mettre à jour le statut de la réservation
                },
                child: Text(_selectedBooking!.status.toUpperCase()),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  // Ajouter une note à la réservation
                },
                child: const Text('Ajouter une note'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  // Reprogrammer la réservation
                },
                child: const Text('Reprogrammer'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
