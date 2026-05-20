import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeHelper {
  static bool isSameDate(DateTime? d1, DateTime? d2) {
    if (d1 == null || d2 == null) return false;
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  static String formatTime(TimeOfDay? time) {
    if (time == null) return '--:--';
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt); // e.g., '10:00 AM'
  }

  static bool isEndAfterStart(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    return endMinutes > startMinutes;
  }

  static Future<DateTime?> selectFromCalendar({
    required BuildContext context,
    required bool isStartDate,
    DateTime? selectedStartDate,
    DateTime? selectedEndDate,
  }) async {
    final DateTime today = DateTime.now();
    return await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (selectedStartDate ?? today)
          : (selectedEndDate ?? selectedStartDate ?? today),
      firstDate: isStartDate ? today : (selectedStartDate ?? today),
      lastDate: DateTime(today.year + 1),
    );
  }

  static Future<TimeOfDay?> pickTime({
    required BuildContext context,
    required bool isStart,
    TimeOfDay? currentTime,
  }) async {
    return await showTimePicker(
      context: context,
      initialTime: currentTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
  }
}
