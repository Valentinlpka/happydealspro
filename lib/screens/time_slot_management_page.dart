// lib/pages/time_slots/time_slot_management_page.dart
import 'package:flutter/material.dart';
import 'package:happy_deals_pro/classes/service_model.dart';
import 'package:happy_deals_pro/classes/time_slot.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../services/service_service.dart';
import '../../services/time_slot_service.dart';

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
  final TimeSlotService _timeSlotService = TimeSlotService();
  final ServiceService _serviceService = ServiceService();
  ServiceModel? selectedService;
  DateTime selectedDate = DateTime.now();
  TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 17, minute: 0);
  final Set<int> selectedDays = {1, 2, 3, 4, 5}; // Lun-Ven par défaut
  int slotDuration = 30;
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Panneau de contrôle (1/3 de l'écran)
          Expanded(
            flex: 1,
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gestion des créneaux',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 24),

                    // Sélection du service
                    StreamBuilder<List<ServiceModel>>(
                      stream: _serviceService
                          .getServicesByProfessional(widget.professionalId),
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
                                'Aucun service créé. Veuillez d\'abord créer au moins un service avant de gérer les créneaux.',
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
                          onChanged: (value) {
                            setState(() {
                              selectedService = value;
                              slotDuration = value?.duration ?? 30;
                            });
                          },
                          isExpanded: true,
                          selectedItemBuilder: (BuildContext context) {
                            return services.map<Widget>((ServiceModel item) {
                              return Text(item.name);
                            }).toList();
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Plage horaire
                    Text(
                      'Plage horaire',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: startTime,
                              );
                              if (time != null) {
                                setState(() => startTime = time);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Début',
                                border: OutlineInputBorder(),
                                filled: true,
                              ),
                              child: Text(startTime.format(context)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: endTime,
                              );
                              if (time != null) {
                                setState(() => endTime = time);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Fin',
                                border: OutlineInputBorder(),
                                filled: true,
                              ),
                              child: Text(endTime.format(context)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Jours de travail
                    Text(
                      'Jours de travail',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (var i = 1; i <= 7; i++)
                          FilterChip(
                            label: Text(_getDayName(i)),
                            selected: selectedDays.contains(i),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedDays.add(i);
                                } else {
                                  selectedDays.remove(i);
                                }
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Période de génération
                    Text(
                      'Période de génération',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                              );
                              if (date != null) {
                                setState(() => selectedDate = date);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Date de début',
                                border: OutlineInputBorder(),
                                filled: true,
                              ),
                              child: Text(DateFormat('dd/MM/yyyy')
                                  .format(selectedDate)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),

                    // Bouton de génération
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: selectedService == null || _isGenerating
                            ? null
                            : _generateTimeSlots,
                        child: _isGenerating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text('Générer les créneaux'),
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
              child: StreamBuilder<List<TimeSlotModel>>(
                stream: _timeSlotService.getTimeSlotsByProfessional(
                  widget.professionalId,
                  selectedDate,
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print(snapshot.error);

                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final timeSlots = snapshot.data!;
                  if (timeSlots.isEmpty && selectedService != null) {
                    return const Center(
                      child: Text(
                        'Aucun créneau disponible pour cette période.\nUtilisez le panneau de gauche pour en générer.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
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
                    dataSource: TimeSlotDataSource(timeSlots),
                    onTap: (CalendarTapDetails details) {
                      if (details.appointments?.isNotEmpty ?? false) {
                        _showTimeSlotDetails(context,
                            details.appointments!.first as TimeSlotModel);
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDayName(int day) {
    switch (day) {
      case 1:
        return 'Lun';
      case 2:
        return 'Mar';
      case 3:
        return 'Mer';
      case 4:
        return 'Jeu';
      case 5:
        return 'Ven';
      case 6:
        return 'Sam';
      case 7:
        return 'Dim';
      default:
        return '';
    }
  }

  Future<void> _generateTimeSlots() async {
    if (selectedService == null) return;

    setState(() => _isGenerating = true);
    try {
      await _timeSlotService.generateTimeSlots(
        serviceId: selectedService!.id,
        professionalId: widget.professionalId,
        startDate: selectedDate,
        endDate:
            selectedDate.add(const Duration(days: 30)), // Génère pour 30 jours
        workDayStart: startTime,
        workDayEnd: endTime,
        slotDuration: selectedService!.duration,
        workDays: selectedDays.toList(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Créneaux générés avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la génération: $e')),
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  void _showTimeSlotDetails(BuildContext context, TimeSlotModel timeSlot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Détails du créneau'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${DateFormat('dd/MM/yyyy').format(timeSlot.date)}'),
            Text('Horaire: ${DateFormat('HH:mm').format(timeSlot.startTime)} - '
                '${DateFormat('HH:mm').format(timeSlot.endTime)}'),
            Text('Statut: ${timeSlot.isAvailable ? 'Disponible' : 'Réservé'}'),
            if (!timeSlot.isAvailable && timeSlot.bookedByUserId != null)
              Text('Réservé par: ${timeSlot.bookedByUserId}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Fermer'),
          ),
          if (timeSlot.isAvailable)
            TextButton(
              onPressed: () async {
                await _timeSlotService.deleteTimeSlot(timeSlot.id);
                Navigator.pop(context);
              },
              child: const Text('Supprimer'),
            ),
        ],
      ),
    );
  }
}

class TimeSlotDataSource extends CalendarDataSource {
  TimeSlotDataSource(List<TimeSlotModel> timeSlots) {
    appointments = timeSlots;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].startTime;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].endTime;
  }

  @override
  String getSubject(int index) {
    final slot = appointments![index] as TimeSlotModel;
    return slot.isAvailable ? 'Disponible' : 'Réservé';
  }

  @override
  Color getColor(int index) {
    final slot = appointments![index] as TimeSlotModel;
    return slot.isAvailable ? Colors.green : Colors.red;
  }
}
