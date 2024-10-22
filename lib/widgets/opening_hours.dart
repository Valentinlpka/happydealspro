import 'package:flutter/material.dart';

class OpeningHoursWidget extends StatefulWidget {
  final String day;
  final Function(String) onHoursChanged;
  final String initialHours;

  const OpeningHoursWidget({
    super.key,
    required this.day,
    required this.onHoursChanged,
    required this.initialHours,
  });

  @override
  _OpeningHoursWidgetState createState() => _OpeningHoursWidgetState();
}

class _OpeningHoursWidgetState extends State<OpeningHoursWidget> {
  bool isOpen = true;
  String openingTime = '09:00';
  String closingTime = '18:00';

  @override
  void initState() {
    super.initState();
    if (widget.initialHours.isNotEmpty) {
      if (widget.initialHours.toLowerCase() == 'fermé') {
        isOpen = false;
      } else {
        final times = widget.initialHours.split(' - ');
        if (times.length == 2) {
          openingTime = times[0];
          closingTime = times[1];
        }
      }
    }
  }

  List<String> _generateTimeOptions() {
    List<String> times = [];
    for (int hour = 5; hour <= 22; hour++) {
      times.add('${hour.toString().padLeft(2, '0')}:00');
      times.add('${hour.toString().padLeft(2, '0')}:30');
    }
    return times;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.day,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Switch(
                  value: isOpen,
                  onChanged: (value) {
                    setState(() {
                      isOpen = value;
                      if (isOpen) {
                        widget.onHoursChanged('$openingTime - $closingTime');
                      } else {
                        widget.onHoursChanged('Fermé');
                      }
                    });
                  },
                ),
                Text(isOpen ? 'Ouvert' : 'Fermé'),
              ],
            ),
            if (isOpen)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<String>(
                    value: openingTime,
                    items: _generateTimeOptions()
                        .map((time) =>
                            DropdownMenuItem(value: time, child: Text(time)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        openingTime = value!;
                        widget.onHoursChanged('$openingTime - $closingTime');
                      });
                    },
                  ),
                  const Text(' - '),
                  DropdownButton<String>(
                    value: closingTime,
                    items: _generateTimeOptions()
                        .map((time) =>
                            DropdownMenuItem(value: time, child: Text(time)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        closingTime = value!;
                        widget.onHoursChanged('$openingTime - $closingTime');
                      });
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
