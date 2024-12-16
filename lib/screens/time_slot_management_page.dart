// lib/pages/time_slots/time_slot_management_page.dart
import 'package:flutter/material.dart';
import 'package:happy_deals_pro/classes/availability_rule.dart';
import 'package:happy_deals_pro/classes/service_model.dart';
import 'package:happy_deals_pro/services/availability_service.dart';
import 'package:happy_deals_pro/services/service_service.dart';
import 'package:happy_deals_pro/widgets/rule_form.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class TimeSlotManagementPage extends StatefulWidget {
  final String professionalId;

  const TimeSlotManagementPage({
    super.key,
    required this.professionalId,
  });

  @override
  _TimeSlotManagementPageState createState() => _TimeSlotManagementPageState();
}

class _TimeSlotManagementPageState extends State<TimeSlotManagementPage> {
  final AvailabilityService _availabilityService = AvailabilityService();
  final ServiceService _serviceService = ServiceService();

  ServiceModel? selectedService;
  TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 17, minute: 0);
  Set<int> selectedDays = {1, 2, 3, 4, 5};
  List<Map<String, TimeRange>> breakTimes = [];
  List<DateTime> exceptionalClosedDates = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Panneau de configuration (1/3 de l'écran)
          Expanded(
            flex: 1,
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sélection du service
                    StreamBuilder<List<ServiceModel>>(
                      stream: _serviceService.getServicesByProfessional(
                        widget.professionalId,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text('Erreur: ${snapshot.error}');
                        }

                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }

                        final services = snapshot.data!;
                        if (services.isEmpty) {
                          return const Card(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'Aucun service créé. Veuillez d\'abord créer au moins un service.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        }

                        return DropdownButtonFormField<ServiceModel>(
                          decoration: const InputDecoration(
                            labelText: 'Service',
                            border: OutlineInputBorder(),
                            filled: true,
                          ),
                          value: selectedService,
                          items: services.map((service) {
                            return DropdownMenuItem<ServiceModel>(
                              value: service,
                              child: Text(service.name),
                            );
                          }).toList(),
                          onChanged: _onServiceSelected,
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Formulaire de règle
                    Expanded(
                      child: RuleFormSection(
                        selectedService: selectedService,
                        startTime: startTime,
                        endTime: endTime,
                        selectedDays: selectedDays,
                        breakTimes: breakTimes,
                        exceptionalClosedDates: exceptionalClosedDates,
                        onStartTimeChanged: (time) =>
                            setState(() => startTime = time),
                        onEndTimeChanged: (time) =>
                            setState(() => endTime = time),
                        onDaySelected: _onDaySelected,
                        onAddBreakTime: _addBreakTime,
                        onRemoveBreakTime: _removeBreakTime,
                        onAddExceptionalDate: _addExceptionalDate,
                        onRemoveExceptionalDate: _removeExceptionalDate,
                        isLoading: _isLoading,
                        onSave: _saveAvailabilityRule,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Calendrier (2/3 de l'écran)
          Expanded(
            flex: 2,
            child: Card(
              margin: const EdgeInsets.all(16),
              child: selectedService == null
                  ? const Center(
                      child: Text(
                          'Sélectionnez un service pour voir les disponibilités'),
                    )
                  : StreamBuilder<List<AvailabilityRuleModel>>(
                      stream:
                          _availabilityService.getAvailabilityRulesByService(
                        selectedService!.id,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Erreur: ${snapshot.error}'));
                        }

                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        return SfCalendar(
                          view: CalendarView.week,
                          firstDayOfWeek: DateTime.monday,
                          timeSlotViewSettings: const TimeSlotViewSettings(
                            startHour: 8,
                            endHour: 20,
                            timeIntervalHeight: 60,
                            timeFormat: 'HH:mm',
                          ),
                          dataSource: AvailabilityDataSource(snapshot.data!),
                          onTap: _onCalendarTapped,
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _onServiceSelected(ServiceModel? service) async {
    setState(() => selectedService = service);
    if (service != null) {
      await _loadExistingRule(service.id);
    }
  }

  Future<void> _loadExistingRule(String serviceId) async {
    try {
      setState(() => _isLoading = true);
      final rules = await _availabilityService
          .getAvailabilityRulesByService(serviceId)
          .first;

      if (rules.isNotEmpty) {
        final rule = rules.first;
        setState(() {
          startTime = rule.startTime.toTimeOfDay();
          endTime = rule.endTime.toTimeOfDay();
          selectedDays = rule.workDays.toSet();
          breakTimes = rule.breakTimes;
          exceptionalClosedDates = rule.exceptionalClosedDates;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onDaySelected(int day, bool selected) {
    setState(() {
      if (selected) {
        selectedDays.add(day);
      } else {
        selectedDays.remove(day);
      }
    });
  }

  Future<void> _addBreakTime() async {
    TimeOfDay? start = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );

    if (start != null) {
      TimeOfDay? end = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: start.hour + 1, minute: start.minute),
      );

      if (end != null) {
        setState(() {
          breakTimes.add({
            'start': TimeRange.fromTimeOfDay(start),
            'end': TimeRange.fromTimeOfDay(end),
          });
        });
      }
    }
  }

  void _removeBreakTime(Map<String, TimeRange> breakTime) {
    setState(() {
      breakTimes.remove(breakTime);
    });
  }

  Future<void> _addExceptionalDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        exceptionalClosedDates.add(date);
      });
    }
  }

  void _removeExceptionalDate(DateTime date) {
    setState(() {
      exceptionalClosedDates.remove(date);
    });
  }

  Future<void> _saveAvailabilityRule() async {
    if (selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un service')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Convertir les TimeOfDay en Map pour le transport
      final Map<String, dynamic> ruleData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'professionalId': widget.professionalId,
        'serviceId': selectedService!.id,
        'workDays': selectedDays.toList(),
        'startTime': {
          'hours': startTime.hour,
          'minutes': startTime.minute,
        },
        'endTime': {
          'hours': endTime.hour,
          'minutes': endTime.minute,
        },
        'breakTimes': breakTimes
            .map((bt) => {
                  'start': {
                    'hours': bt['start']!.hours,
                    'minutes': bt['start']!.minutes,
                  },
                  'end': {
                    'hours': bt['end']!.hours,
                    'minutes': bt['end']!.minutes,
                  },
                })
            .toList(),
        'exceptionalClosedDates': exceptionalClosedDates
            .map((date) => date.toIso8601String())
            .toList(),
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await _availabilityService.createAvailabilityRule(ruleData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Règles de disponibilité enregistrées')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onCalendarTapped(CalendarTapDetails details) {
    if (details.appointments?.isEmpty ?? true) return;
    final appointment = details.appointments!.first as Appointment;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Détails de la disponibilité'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Date: ${DateFormat('dd/MM/yyyy').format(appointment.startTime)}'),
            Text(
                'Horaire: ${DateFormat('HH:mm').format(appointment.startTime)} - '
                '${DateFormat('HH:mm').format(appointment.endTime)}'),
            Text('Statut: ${appointment.subject}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}

class AvailabilityDataSource extends CalendarDataSource {
  AvailabilityDataSource(List<AvailabilityRuleModel> rules) {
    appointments = _generateAppointments(rules);
  }

  List<Appointment> _generateAppointments(List<AvailabilityRuleModel> rules) {
    List<Appointment> appointments = [];
    final now = DateTime.now();
    // Trouver le début de la semaine (lundi)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    for (final rule in rules) {
      // Générer pour cette semaine et la suivante
      for (int week = 0; week < 2; week++) {
        for (int i = 0; i < 7; i++) {
          final date = startOfWeek.add(Duration(days: i + (week * 7)));

          // Vérifier si c'est un jour travaillé et pas une date exceptionnelle
          if (rule.workDays.contains(date.weekday) &&
              !_isExceptionalClosedDate(date, rule.exceptionalClosedDates)) {
            final startDateTime = DateTime(
              date.year,
              date.month,
              date.day,
              rule.startTime.hours,
              rule.startTime.minutes,
            );

            final endDateTime = DateTime(
              date.year,
              date.month,
              date.day,
              rule.endTime.hours,
              rule.endTime.minutes,
            );

            appointments.add(Appointment(
              startTime: startDateTime,
              endTime: endDateTime,
              subject: 'Disponible',
              color: Colors.green.withOpacity(0.3),
              isAllDay: false,
            ));

            // Ajouter les pauses
            for (final breakTime in rule.breakTimes) {
              final breakStart = DateTime(
                date.year,
                date.month,
                date.day,
                breakTime['start']!.hours,
                breakTime['start']!.minutes,
              );

              final breakEnd = DateTime(
                date.year,
                date.month,
                date.day,
                breakTime['end']!.hours,
                breakTime['end']!.minutes,
              );

              appointments.add(Appointment(
                startTime: breakStart,
                endTime: breakEnd,
                subject: 'Pause',
                color: Colors.red.withOpacity(0.3),
                isAllDay: false,
              ));
            }
          }
        }
      }
    }
    return appointments;
  }

  bool _isExceptionalClosedDate(
      DateTime date, List<DateTime> exceptionalDates) {
    return exceptionalDates.any((exceptionalDate) =>
        exceptionalDate.year == date.year &&
        exceptionalDate.month == date.month &&
        exceptionalDate.day == date.day);
  }
}
