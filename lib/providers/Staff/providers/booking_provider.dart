import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:varahiowner/model/Staff/models/booking_model.dart';
import 'package:varahiowner/services/Staff/services/api/booking_service.dart';

class BookingProvider with ChangeNotifier {
  final BookingService _bookingService = BookingService();

  List<Booking> _todayBookings = [];
  List<Booking> _currentBookings = []; // For storing filtered bookings

  bool _isLoading = false;
  bool _isStatisticsLoading = false;
  String? _statisticsErrorMessage;
  String? _errorMessage;

  DateTime? _selectedDate; // Track selected date
  bool _isDateFiltered = false; // Track if date filter is applied

  List<Booking> get todayBookings => _todayBookings;
  List<Booking> get currentBookings =>
      _currentBookings; // Current displayed bookings
  bool get isStatisticsLoading => _isStatisticsLoading;
  String? get statisticsErrorMessage => _statisticsErrorMessage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get selectedDate => _selectedDate;
  bool get isDateFiltered => _isDateFiltered;

  int get completedBookings => _currentBookings
      .where(
        (b) =>
            b.paymentStatus.toLowerCase() == 'completed' ||
            b.paymentStatus.toLowerCase() == 'paid',
      )
      .length;

  int get pendingBookings => _currentBookings
      .where((b) => b.paymentStatus.toLowerCase() == 'pending')
      .length;

  double get totalRevenue => _currentBookings
      .where(
        (b) =>
            b.paymentStatus.toLowerCase() == 'completed' ||
            b.paymentStatus.toLowerCase() == 'paid',
      )
      .fold(0.0, (sum, b) => sum + b.totalPrice);

  Future<void> fetchTodayBookings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _todayBookings = await _bookingService.fetchTodayBookings();
      if (!_isDateFiltered) {
        _currentBookings = _todayBookings; // Show today's bookings by default
      }
    } catch (e) {
      _errorMessage = e.toString();
      _todayBookings = [];
      _currentBookings = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBookingsByDate(DateTime date) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedDate = date;
    _isDateFiltered = true;
    notifyListeners();

    try {
      _currentBookings = await _bookingService.fetchBookingsByDate(date);
    } catch (e) {
      _errorMessage = e.toString();
      _currentBookings = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearDateFilter() {
    _selectedDate = null;
    _isDateFiltered = false;
    _currentBookings = _todayBookings; // Reset to today's bookings
    notifyListeners();
  }

  Future<void> refreshAllData() async {
    await Future.wait([fetchTodayBookings()]);
  }

  // Clear error messages
  void clearErrors() {
    _errorMessage = null;
    _statisticsErrorMessage = null;
    notifyListeners();
  }
}
