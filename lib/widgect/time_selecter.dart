import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeSelector extends StatefulWidget {
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;

  const TimeSelector({
    super.key,
    required this.selectedStartDate,
    required this.selectedEndDate,
  });

  @override
  State<TimeSelector> createState() => _TimeSelectorState();
}

class _TimeSelectorState extends State<TimeSelector> {
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  Future<void> _pickTime({required bool isStart}) async {
    TimeOfDay initialTime = TimeOfDay.now();

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? (startTime ?? initialTime) : (endTime ?? initialTime),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
          endTime = null; // Reset end time if start changes
        } else {
          // If same date, check that end time is after start
          if (widget.selectedStartDate != null &&
              widget.selectedEndDate != null &&
              isSameDate(widget.selectedStartDate!, widget.selectedEndDate!) &&
              startTime != null &&
              !_isEndTimeAfterStart(startTime!, picked)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("End time must be after start time")),
            );
            return;
          }
          endTime = picked;
        }
      });
    }
  }

  bool isSameDate(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  bool _isEndTimeAfterStart(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    return endMinutes > startMinutes;
  }

  String formatTime(TimeOfDay? time) {
    if (time == null) return "--:--";
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => _pickTime(isStart: true),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF120698),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(formatTime(startTime), style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Duration', style: TextStyle(color: Colors.black)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(height: 2, width: 90, color: Colors.black54),
                Transform.translate(
                  offset: const Offset(-5, 0),
                  child: const Icon(Icons.arrow_forward, size: 25, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => _pickTime(isStart: false),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF120698),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(formatTime(endTime), style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
