import 'package:varahiowner/helpers/shared_pref_helper.dart';
import 'package:varahiowner/model/MyBookings/booking_model.dart';
import 'api_service.dart';

class BookingService {
  
  // Get all bookings for owner
  Future<Map<String, dynamic>> getOwnerBookings({String? date}) async {
    try {
      final ownerId = SharedPrefHelper.getOwnerId();
      if (ownerId == null) {
        return {
          'success': false,
          'message': 'Owner not found',
        };
      }

      String endpoint = '/owner/owner-bookings/$ownerId';
      if (date != null && date.isNotEmpty) {
        endpoint += '?date=$date';
      }

      final response = await ApiService.get(endpoint);
      
      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        final body = response['body'];
        
        if (body['message'] == 'Owner bookings retrieved successfully') {
          final List<dynamic> bookingsData = body['bookings'] ?? [];
          final List<BookingModel> bookings = bookingsData
              .map((booking) => BookingModel.fromJson(booking))
              .toList();
          
          return {
            'success': true,
            'message': body['message'],
            'bookings': bookings,
            'total': body['total'] ?? 0,
          };
        } else {
          return {
            'success': false,
            'message': body['message'] ?? 'Failed to fetch bookings',
          };
        }
      } else {
        return {
          'success': false,
          'message': response['body']['message'] ?? 'Failed to fetch bookings',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Update booking status
  Future<Map<String, dynamic>> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    try {
      final ownerId = SharedPrefHelper.getOwnerId();
      if (ownerId == null) {
        return {
          'success': false,
          'message': 'Owner not found',
        };
      }

      final response = await ApiService.post(
        '/owner/update-booking-status/$ownerId/$bookingId',
        {'status': status},
      );
      
      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        final body = response['body'];
        
        return {
          'success': true,
          'message': body['message'] ?? 'Booking status updated',
        };
      } else {
        return {
          'success': false,
          'message': response['body']['message'] ?? 'Failed to update status',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
}