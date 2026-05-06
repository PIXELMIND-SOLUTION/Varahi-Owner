import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:varahiowner/model/Staff/models/booking_model.dart';

class BookingService {
  final String baseUrl = "https://varahibackend.varahiselfdrivecars.com/api";

  // Future<List<Booking>> fetchTodayBookings() async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse("$baseUrl/staff/todaybookings"),
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //     );
  //     print('kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk${response.statusCode}');

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       final bookingsJson = data['bookings'] as List;
  //       return bookingsJson.map((json) => Booking.fromJson(json)).toList();
  //     } else {
  //       throw Exception('Failed to load bookings: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     throw Exception('Error fetching bookings: $e');
  //   }
  // }

  Future<List<Booking>> fetchTodayBookings() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/staff/todaybookings"),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Add null check for bookings array
        if (data == null || data['bookings'] == null) {
          return [];
        }

        final bookingsJson = data['bookings'] as List;
        return bookingsJson
            .where((json) => json != null) // Filter out null entries
            .map((json) => Booking.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load bookings: ${response.statusCode}');
      }
    } catch (e) {
      print('Error details: $e'); // Add this for debugging
      throw Exception('Error fetching bookings: $e');
    }
  }

  Future<List<Booking>> fetchBookingsByDate(DateTime date) async {
    try {
      // Format the date as YYYY-MM-DD
      final formattedDate = DateFormat('yyyy/MM/dd').format(date);

      print(
        "dateeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee$formattedDate",
      );

      final response = await http.get(
        Uri.parse("$baseUrl/staff/todaybookings?date=$formattedDate"),
        headers: {'Content-Type': 'application/json'},
      );

      print(
        "dateeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee${response.body}",
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final bookingsJson = data['bookings'] as List;
        return bookingsJson.map((json) => Booking.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load bookings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching bookings: $e');
    }
  }
}
