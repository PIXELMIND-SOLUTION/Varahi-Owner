import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:varahiowner/model/Staff/models/booking_model.dart';
import 'package:varahiowner/services/Staff/services/api/booking_service.dart';

class HomeBookingProvider with ChangeNotifier {
  final BookingService _bookingService = BookingService();

  List<Booking> _todayBookings = [];
  List<dynamic> _bookingStatistics = [];

  bool _isLoading = false;
  bool _isStatisticsLoading = false;
  String? _statisticsErrorMessage;

  String? _errorMessage;

  List<Booking> get todayBookings => _todayBookings;
  List<dynamic> get bookingStatistics => _bookingStatistics;
  bool get isStatisticsLoading => _isStatisticsLoading;
  String? get statisticsErrorMessage => _statisticsErrorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get completedBookings => _todayBookings
      .where(
        (b) =>
            b.paymentStatus.toLowerCase() == 'completed' ||
            b.paymentStatus.toLowerCase() == 'paid',
      )
      .length;

  int get pendingBookings => _todayBookings
      .where((b) => b.paymentStatus.toLowerCase() == 'pending')
      .length;

  double get totalRevenue => _todayBookings
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
    } catch (e) {
      _errorMessage = e.toString();
      _todayBookings = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBookingStatistics() async {
    _isStatisticsLoading = true;
    _statisticsErrorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(
          'https://varahibackend.varahiselfdrivecars.com/api/staff/staticsbookings',
        ),
        headers: {
          'Content-Type': 'application/json',
          // Add authorization headers if needed
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _bookingStatistics = data['statistics'] ?? [];
        print(
          'stsssssssssssssssssssssssssssssssssssssssssssssssss$_bookingStatistics',
        );
        _statisticsErrorMessage = null;
      } else {
        _statisticsErrorMessage = 'Failed to load booking statistics';
        _bookingStatistics = [];
      }
    } catch (e) {
      _statisticsErrorMessage = 'Network error: ${e.toString()}';
      _bookingStatistics = [];
    } finally {
      _isStatisticsLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAllData() async {
    await Future.wait([fetchTodayBookings(), fetchBookingStatistics()]);
  }

  // Clear error messages
  void clearErrors() {
    _errorMessage = null;
    _statisticsErrorMessage = null;
    notifyListeners();
  }
}
