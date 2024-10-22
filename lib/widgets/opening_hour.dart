import 'package:flutter/material.dart';

class OpeningHourData {
  bool isOpen;
  String openTime;
  String closeTime;

  OpeningHourData({
    this.isOpen = false,
    this.openTime = '09:00',
    this.closeTime = '17:00',
  });
}

class OpeningHourWidget extends StatefulWidget {
  final String day;
  final OpeningHourData data;
  final Function(OpeningHourData) onChanged;

  const OpeningHourWidget({
    super.key,
    required this.day,
    required this.data,
    required this.onChanged,
  });

  @override
  _OpeningHourWidgetState createState() => _OpeningHourWidgetState();
}

class _OpeningHourWidgetState extends State<OpeningHourWidget> {
  late OpeningHourData _data;

  @override
  void initState() {
    super.initState();
    _data = widget.data;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(widget.day)),
          Switch(
            value: _data.isOpen,
            onChanged: (value) {
              setState(() {
                _data.isOpen = value;
                widget.onChanged(_data);
              });
            },
          ),
          Text(_data.isOpen ? 'Ouvert' : 'Fermé'),
          if (_data.isOpen) ...[
            const SizedBox(width: 10),
            _buildTimeField(_data.openTime, (newTime) {
              setState(() {
                _data.openTime = newTime;
                widget.onChanged(_data);
              });
            }),
            const SizedBox(width: 10),
            const Text('à'),
            const SizedBox(width: 10),
            _buildTimeField(_data.closeTime, (newTime) {
              setState(() {
                _data.closeTime = newTime;
                widget.onChanged(_data);
              });
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeField(String initialTime, Function(String) onChanged) {
    return GestureDetector(
      onTap: () async {
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(
            hour: int.parse(initialTime.split(':')[0]),
            minute: int.parse(initialTime.split(':')[1]),
          ),
          builder: (BuildContext context, Widget? child) {
            return MediaQuery(
              data:
                  MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child!,
            );
          },
        );

        if (pickedTime != null) {
          String formattedTime =
              '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
          onChanged(formattedTime);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(initialTime),
      ),
    );
  }
}
