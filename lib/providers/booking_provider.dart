// import 'package:flutter/material.dart';
// import 'package:varahiowner/model/MyBookings/booking_model.dart';
// import 'package:varahiowner/services/booking_service.dart';

// class MainBookingProvider extends ChangeNotifier {
//   final BookingService _bookingService = BookingService();

//   bool _isLoading = false;
//   bool _isUpdating = false;
//   String _errorMessage = '';
//   List<BookingModel> _bookings = [];
//   int _totalBookings = 0;
//   String _selectedDate = '';

//   bool get isLoading => _isLoading;
//   bool get isUpdating => _isUpdating;
//   String get errorMessage => _errorMessage;
//   List<BookingModel> get bookings => _bookings;
//   int get totalBookings => _totalBookings;
//   String get selectedDate => _selectedDate;

//   // Fetch bookings
//   Future<bool> fetchBookings({String? date}) async {
//     if (_isLoading) return false;

//     _isLoading = true;
//     _errorMessage = '';
//     _selectedDate = date ?? '';
//     notifyListeners();

//     final result = await _bookingService.getOwnerBookings(date: date);

//     _isLoading = false;

//     if (result['success'] == true) {
//       _bookings = result['bookings'];
//       _totalBookings = result['total'] ?? 0;
//       notifyListeners();
//       return true;
//     } else {
//       _errorMessage = result['message'];
//       notifyListeners();
//       return false;
//     }
//   }

//   // Update booking status
//   Future<bool> updateBookingStatus(String bookingId, String status) async {
//     _isUpdating = true;
//     notifyListeners();

//     final result = await _bookingService.updateBookingStatus(
//       bookingId: bookingId,
//       status: status,
//     );

//     _isUpdating = false;

//     if (result['success'] == true) {
//       // Update local list
//       final index = _bookings.indexWhere((b) => b.id == bookingId);
//       if (index != -1) {
//         _bookings[index] = BookingModel.fromJson({
//           ..._bookings[index].toJson(),
//           'status': status,
//         });
//       }
//       notifyListeners();
//       return true;
//     } else {
//       _errorMessage = result['message'];
//       notifyListeners();
//       return false;
//     }
//   }

//   void clearError() {
//     _errorMessage = '';
//     notifyListeners();
//   }
// }

// // Extension to convert BookingModel to JSON
// extension BookingModelJson on BookingModel {
//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'userId': {'_id': user.id, 'name': user.name, 'email': user.email},
//       'carId': carId,
//       'car': {
//         '_id': car.id,
//         'carName': car.carName,
//         'model': car.model,
//         'year': car.year,
//         'pricePerHour': car.pricePerHour,
//         'pricePerDay': car.pricePerDay,
//         'extendedPrice': car.extendedPrice,
//         'description': car.description,
//         'delayPerHour': car.delayPerHour,
//         'delayPerDay': car.delayPerDay,
//         'vehicleNumber': car.vehicleNumber,
//         'location': car.location,
//         'carType': car.carType,
//         'fuel': car.fuel,
//         'seats': car.seats,
//         'type': car.type,
//         'status': car.status,
//         'carImage': car.carImage,
//         'carDocs': car.carDocs,
//         'runningStatus': car.runningStatus,
//       },
//       'rentalStartDate': rentalStartDate,
//       'rentalEndDate': rentalEndDate,
//       'from': from,
//       'to': to,
//       'totalPrice': totalPrice,
//       'status': status,
//       'paymentStatus': paymentStatus,
//       'otp': otp,
//       'deposit': deposit,
//       'createdAt': createdAt.toIso8601String(),
//       'updatedAt': updatedAt.toIso8601String(),
//     };
//   }
// }

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

  // Fetch bookings
  Future<bool> fetchBookings({String? date}) async {
    // Remove the isLoading check to allow refresh
    // if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = '';
    _selectedDate = date ?? '';
    notifyListeners();

    debugPrint('📡 Fetching bookings with date: ${date ?? "ALL"}');

    final result = await _bookingService.getOwnerBookings(date: date);

    _isLoading = false;

    if (result['success'] == true) {
      _bookings = result['bookings'];
      _totalBookings = result['total'] ?? 0;
      debugPrint(
        '✅ Bookings fetched: ${_bookings.length} bookings, Total: $_totalBookings',
      );
      notifyListeners();
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
      // Update local list
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

// Extension to convert BookingModel to JSON
extension BookingModelJson on BookingModel {
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': {'_id': user.id, 'name': user.name, 'email': user.email},
      'carId': carId,
      'car': {
        '_id': car.id,
        'carName': car.carName,
        'model': car.model,
        'year': car.year,
        'pricePerHour': car.pricePerHour,
        'pricePerDay': car.pricePerDay,
        'extendedPrice': car.extendedPrice,
        'description': car.description,
        'delayPerHour': car.delayPerHour,
        'delayPerDay': car.delayPerDay,
        'vehicleNumber': car.vehicleNumber,
        'location': car.location,
        'carType': car.carType,
        'fuel': car.fuel,
        'seats': car.seats,
        'type': car.type,
        'status': car.status,
        'carImage': car.carImage,
        'carDocs': car.carDocs,
        'runningStatus': car.runningStatus,
      },
      'rentalStartDate': rentalStartDate,
      'rentalEndDate': rentalEndDate,
      'from': from,
      'to': to,
      'totalPrice': totalPrice,
      'status': status,
      'paymentStatus': paymentStatus,
      'otp': otp,
      'deposit': deposit,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
