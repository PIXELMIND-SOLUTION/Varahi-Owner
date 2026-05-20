import 'package:flutter/foundation.dart';
import 'package:varahiowner/services/Staff/services/api/single_booking_service.dart';

import '../../../model/Staff/models/single_booking_model.dart';

class SingleBookingProvider extends ChangeNotifier {
  final SingleBookingService _bookingService = SingleBookingService();

  Booking? _currentBooking;
  List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  Booking? get currentBooking => _currentBooking;
  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Methods
  Future<void> fetchSingleBooking(String bookingId) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _bookingService.getSingleBooking(bookingId);
      if (response != null) {
        _currentBooking = response.booking;
        print(
          "uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu${_currentBooking?.userId?.documents?.aadharCard?.url}",
        );
        print(
          "uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu${_currentBooking?.userId?.documents?.drivingLicense?.url}",
        );

        notifyListeners();
      } else {
        print("helooooooooooooooooooo");
        _currentBooking = null;

        _error = 'Failed to fetch booking';
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> fetchAllBookings() async {
    _setLoading(true);
    _error = null;

    try {
      final bookings = await _bookingService.getAllBookings();
      if (bookings != null) {
        _bookings = bookings;
      } else {
        _error = 'Failed to fetch bookings';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // New method for fetching bookings with status and optional date
  Future<void> fetchBookingsWithStatusAndDate(
    String status, {
    String? date,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final bookings = await _bookingService.getBookingsWithStatusAndDate(
        status,
        date: date,
      );
      if (bookings != null) {
        _bookings = bookings;
      } else {
        _error = 'Failed to fetch bookings';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Future<bool> updateBookingStatus(String bookingId, String status) async {
  //   _setLoading(true);
  //   _error = null;

  //   try {
  //     final success = await _bookingService.updateBookingStatus(bookingId, status);
  //     if (success) {
  //       // Update local booking if it exists
  //       if (_currentBooking?.id == bookingId) {
  //         _currentBooking = Booking(
  //           id: _currentBooking!.id,
  //           userId: _currentBooking!.userId,
  //           carId: _currentBooking!.carId,
  //           rentalStartDate: _currentBooking!.rentalStartDate,
  //           rentalEndDate: _currentBooking!.rentalEndDate,
  //           from: _currentBooking!.from,
  //           to: _currentBooking!.to,
  //           totalPrice: _currentBooking!.totalPrice,
  //           status: status,
  //           paymentStatus: _currentBooking!.paymentStatus,
  //           otp: _currentBooking!.otp,
  //           deposit: _currentBooking!.deposit,
  //           pickupLocation: _currentBooking!.pickupLocation,
  //           createdAt: _currentBooking!.createdAt,
  //           updatedAt: DateTime.now(),
  //           car: _currentBooking!.car,
  //         );
  //       }

  //       // Update in bookings list
  //       final index = _bookings.indexWhere((booking) => booking.id == bookingId);
  //       if (index != -1) {
  //         _bookings[index] = Booking(
  //           id: _bookings[index].id,
  //           userId: _bookings[index].userId,
  //           carId: _bookings[index].carId,
  //           rentalStartDate: _bookings[index].rentalStartDate,
  //           rentalEndDate: _bookings[index].rentalEndDate,
  //           from: _bookings[index].from,
  //           to: _bookings[index].to,
  //           totalPrice: _bookings[index].totalPrice,
  //           status: status,
  //           paymentStatus: _bookings[index].paymentStatus,
  //           otp: _bookings[index].otp,
  //           deposit: _bookings[index].deposit,
  //           pickupLocation: _bookings[index].pickupLocation,
  //           createdAt: _bookings[index].createdAt,
  //           updatedAt: DateTime.now(),
  //           car: _bookings[index].car,
  //         );
  //       }
  //     } else {
  //       _error = 'Failed to update booking status';
  //     }
  //     return success;
  //   } catch (e) {
  //     _error = e.toString();
  //     return false;
  //   } finally {
  //     _setLoading(false);
  //   }
  // }

  void clearCurrentBooking() {
    _currentBooking = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
