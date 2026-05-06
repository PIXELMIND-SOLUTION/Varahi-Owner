// import 'dart:convert';
// import 'package:varahiowner/models/user_model.dart';
// import 'package:http/http.dart' as http;

// class AuthService {
//   final String baseUrl = 'https://varahibackend.varahiselfdrivecars.com/api';

//   Future<UserModel?> login(String mobile) async {
//     try {
//       print("Mobile Number: $mobile");

//       final response = await http.post(
//         Uri.parse('$baseUrl/staff/login'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'mobile': mobile}),
//       );

//       print('Status Code: ${response.statusCode}');
//       print('Response Body: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         print("Full Response Data: $data");

//         // Check if the response has the expected structure
//         if (data != null && data['staff'] != null) {
//           print("Using data['staff'] structure");
//           return UserModel.fromJson(data['staff']);
//         } else {
//           print("Unexpected response structure: $data");
//           throw Exception("Staff data not found in response");
//         }
//       } else {
//         print('Login failed with status: ${response.statusCode}');
//         print('Error response: ${response.body}');
//         throw Exception("Login Failed: ${response.statusCode}");
//       }
//     } catch (e) {
//       print('Login Error: $e');
//       rethrow; // Re-throw to let the calling code handle the error
//     }
//   }
// }

import 'dart:convert';
import 'package:varahiowner/utils/storage_helper.dart';
import 'package:http/http.dart' as http;

import '../../../../model/Staff/models/user_model.dart';

class AuthService {
  final String baseUrl = 'https://varahibackend.varahiselfdrivecars.com/api';

  Future<UserModel?> login(String mobile) async {
    try {
      print("Mobile Number: $mobile");

      final response = await http.post(
        Uri.parse('$baseUrl/staff/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobile': mobile}),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Full Response Data: $data");

        // Store mobile number for OTP verification
        await StorageHelper.saveTempMobile(mobile);

        // Check if the response has the expected structure
        if (data != null && data['staff'] != null) {
          print("Using data['staff'] structure");
          return UserModel.fromJson(data['staff']);
        } else {
          print("Login successful, OTP sent");
          return null; // Login successful, but user data comes after OTP verification
        }
      } else {
        print('Login failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        throw Exception("Login Failed: ${response.statusCode}");
      }
    } catch (e) {
      print('Login Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String otp) async {
    try {
      print('🔄 Starting OTP verification...');
      print('📱 OTP Code: $otp');

      final response = await http
          .post(
            Uri.parse('$baseUrl/staff/verify-staff-otp'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'otp': otp}),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timeout - Server took too long to respond',
              );
            },
          );

      print('📊 Response Status Code: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.body.isEmpty) {
        throw Exception('Empty response from server');
      }

      final responseData = jsonDecode(response.body);
      print('✅ Parsed Response Data: $responseData');

      if (response.statusCode == 200) {
        final staffData = responseData['staff'];
        final token = responseData['token'];

        if (staffData != null) {
          final userModel = UserModel.fromJson(staffData);

          // Save token if available
          if (token != null) {
            await StorageHelper.saveToken(token);
          }

          // Clear temporary mobile number
          await StorageHelper.clearTempMobile();

          return {
            'success': true,
            'user': userModel,
            'token': token,
            'message': 'OTP verified successfully',
          };
        } else {
          return {
            'success': false,
            'message': 'Invalid response: No user data received',
          };
        }
      } else {
        final errorMessage =
            responseData['message'] ?? responseData['error'] ?? 'Invalid OTP';
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      print('OTP Verification Error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> resendOtp(String? mobile) async {
    try {
      // Get mobile from storage if not provided
      mobile ??= await StorageHelper.getTempMobile();

      if (mobile == null) {
        return {
          'success': false,
          'message': 'Mobile number not found. Please login again.',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/staff/resend-staff-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobile': mobile}),
      );

      print('Resend OTP Status Code: ${response.statusCode}');
      print('Resend OTP Response: ${response.body}');

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'OTP sent successfully'};
      } else {
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to resend OTP',
        };
      }
    } catch (e) {
      print('Resend OTP Error: $e');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }
}
