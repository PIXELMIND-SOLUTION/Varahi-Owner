import 'package:flutter/material.dart';
import 'package:varahiowner/model/MyBookings/booking_model.dart';
import 'package:varahiowner/services/booking_service.dart';

class MainBookingProvider extends ChangeNotifier {
  final BookingService _bookingService = BookingService();

  bool _isLoading = false;
  bool _isUpdating = false;
  String _errorMessage = '';
  List<BookingModel> _bookings = [];
  int _totalBookings = 0;
  String _selectedDate = '';

  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String get errorMessage => _errorMessage;
  List<BookingModel> get bookings => _bookings;
  int get totalBookings => _totalBookings;
  String get selectedDate => _selectedDate;

  // Fetch bookings - MODIFIED VERSION
  Future<bool> fetchBookings({String? date}) async {
    _isLoading = true;
    _errorMessage = '';
    _selectedDate = date ?? '';
    
    // Force UI update for loading state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    debugPrint('📡 Fetching bookings with date: ${date ?? "ALL"}');

    final result = await _bookingService.getOwnerBookings(date: date);

    _isLoading = false;

    if (result['success'] == true) {
      // CRITICAL: Create a completely new list
      final newBookings = List<BookingModel>.from(result['bookings']);
      _bookings = newBookings;
      _totalBookings = result['total'] ?? 0;
      
      debugPrint('✅ Bookings fetched: ${_bookings.length} bookings, Total: $_totalBookings');
      
      // Force multiple UI updates
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
        // Double notify to ensure UI rebuilds
        Future.delayed(Duration(milliseconds: 50), () {
          notifyListeners();
        });
      });
      
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Unknown error occurred';
      debugPrint('❌ Error fetching bookings: $_errorMessage');
      notifyListeners();
      return false;
    }
  }

  // Update booking status
  Future<bool> updateBookingStatus(String bookingId, String status) async {
    _isUpdating = true;
    notifyListeners();

    final result = await _bookingService.updateBookingStatus(
      bookingId: bookingId,
      status: status,
    );

    _isUpdating = false;

    if (result['success'] == true) {
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = BookingModel.fromJson({
          ..._bookings[index].toJson(),
          'status': status,
        });
      }
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Failed to update status';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}