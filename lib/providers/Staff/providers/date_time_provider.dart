
import 'package:flutter/material.dart';

class DateTimeProvider with ChangeNotifier {
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  TimeOfDay? get startTime => _startTime;
  TimeOfDay? get endTime => _endTime;

  void setStartDate(DateTime date) {
    _startDate = date;
    _endDate = null; // Reset end date when start changes
    notifyListeners();
  }

  void setEndDate(DateTime date) {
    _endDate = date;
    notifyListeners();
  }

  void setStartTime(TimeOfDay time) {
    _startTime = time;
    _endTime = null; 
    notifyListeners();
  }

  void setEndTime(TimeOfDay time) {
    _endTime = time;
    notifyListeners();
  }

  void resetAll() {
    _startDate = null;
    _endDate = null;
    _startTime = null;
    _endTime = null;
    notifyListeners();
  }
}