// lib/pages/time_slots/widgets/rule_form.dart
import 'package:flutter/material.dart';
import 'package:happy_deals_pro/classes/availability_rule.dart';
import 'package:happy_deals_pro/classes/service_model.dart';
import 'package:intl/intl.dart';

class RuleFormSection extends StatelessWidget {
  final ServiceModel? selectedService;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Set<int> selectedDays;
  final List<Map<String, TimeRange>> breakTimes;
  final List<DateTime> exceptionalClosedDates;
  final Function(TimeOfDay) onStartTimeChanged;
  final Function(TimeOfDay) onEndTimeChanged;
  final Function(int, bool) onDaySelected;
  final Function() onAddBreakTime;
  final Function(Map<String, TimeRange>) onRemoveBreakTime;
  final Function() onAddExceptionalDate;
  final Function(DateTime) onRemoveExceptionalDate;
  final bool isLoading;
  final VoidCallback onSave;

  const RuleFormSection({
    super.key,
    required this.selectedService,
    required this.startTime,
    required this.endTime,
    required this.selectedDays,
    required this.breakTimes,
    required this.exceptionalClosedDates,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
    required this.onDaySelected,
    required this.onAddBreakTime,
    required this.onRemoveBreakTime,
    required this.onAddExceptionalDate,
    required this.onRemoveExceptionalDate,
    required this.isLoading,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuration des disponibilités',
              style: Theme.of(context).textTheme.titleLarge,
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
                  child: _buildTimeSelector(
                    context: context,
                    label: 'Début',
                    time: startTime,
                    onChanged: onStartTimeChanged,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimeSelector(
                    context: context,
                    label: 'Fin',
                    time: endTime,
                    onChanged: onEndTimeChanged,
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
                    onSelected: (selected) => onDaySelected(i, selected),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Pauses
            Text(
              'Pauses',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Column(
              children: [
                ...breakTimes.map((breakTime) => Card(
                      child: ListTile(
                        title: Text(
                          '${breakTime['start']!.toTimeOfDay().format(context)} - '
                          '${breakTime['end']!.toTimeOfDay().format(context)}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => onRemoveBreakTime(breakTime),
                        ),
                      ),
                    )),
                TextButton.icon(
                  onPressed: onAddBreakTime,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter une pause'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Dates exceptionnelles
            Text(
              'Dates de fermeture',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Column(
              children: [
                ...exceptionalClosedDates.map((date) => Card(
                      child: ListTile(
                        title: Text(DateFormat('dd/MM/yyyy').format(date)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => onRemoveExceptionalDate(date),
                        ),
                      ),
                    )),
                TextButton.icon(
                  onPressed: onAddExceptionalDate,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter une date'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: isLoading ? null : onSave,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Enregistrer les disponibilités'),
              ),
            ),
          ],
        ),
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

  Widget _buildTimeSelector({
    required BuildContext context,
    required String label,
    required TimeOfDay time,
    required Function(TimeOfDay) onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final selected = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (selected != null) {
          onChanged(selected);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
        ),
        child: Text(time.format(context)),
      ),
    );
  }
}
