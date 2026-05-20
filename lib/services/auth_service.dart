import 'dart:convert';
import 'dart:io';
import 'package:varahiowner/helpers/shared_pref_helper.dart';
import 'package:varahiowner/model/car_model.dart';
import 'package:varahiowner/model/owner_model.dart';
import 'api_service.dart';

class AuthService {
  
  // Login owner
  Future<Map<String, dynamic>> login(String mobileNumber, String password) async {
  try {
    print("Mobile: $mobileNumber");
    print("Password: $password");

    final response = await ApiService.post('/owner/login', {
      'mobileNumber': mobileNumber,
      'password': password,
    });

    print("Response: ${response['body']}");

    if (response['statusCode'] == 200 || response['statusCode'] == 201) {
      final body = response['body'];
      
      // Check if login was successful
      if (body['message'] == 'Login successful') {
        // Extract token and owner from root level (not inside 'data')
        final token = body['token'];
        final ownerData = body['owner'];
        
        // Save to SharedPreferences
        if (token != null) {
          await SharedPrefHelper.saveToken(token);
          print("Token saved: $token");
        }
        
        if (ownerData != null) {
          final owner = OwnerModel.fromJson(ownerData);
          await SharedPrefHelper.saveOwnerId(owner.id ?? '');
          await SharedPrefHelper.saveMobileNumber(owner.mobileNumber);
          await SharedPrefHelper.setLoggedIn(true);
          print("Owner saved: ${owner.fullName}");
        }
        
        return {
          'success': true,
          'message': body['message'] ?? 'Login successful',
          'data': ownerData,
          'token': token,
        };
      } else {
        return {
          'success': false,
          'message': body['message'] ?? 'Login failed',
        };
      }
    } else {
      return {
        'success': false,
        'message': response['body']['message'] ?? 'Login failed. Please try again.',
      };
    }
  } catch (e) {
    print("Login error: $e");
    return {
      'success': false,
      'message': 'Network error: $e',
    };
  }
}
  // Register owner with car (Multipart)
  Future<Map<String, dynamic>> registerWithCar({
    required OwnerModel owner,
    required CarModel car,
    required List<File> carImages,
    required List<File> carDocs,
  }) async {
    try {
      // Prepare fields
      final fields = <String, String>{
        // Owner fields
        'fullName': owner.fullName,
        'mobileNumber': owner.mobileNumber,
        'email': owner.email,
        'password': owner.password ?? '',
        'aadharNumber': owner.aadharNumber ?? '',
        
        // Car fields
        'carName': car.carName,
        'model': car.model,
        'year': car.year,
        'pricePerHour': car.pricePerHour.toString(),
        'pricePerDay': car.pricePerDay.toString(),
        'delayPerHour': car.delayPerHour.toString(),
        'delayPerDay': car.delayPerDay.toString(),
        'extendedPrice': jsonEncode(car.extendedPrice),
        'type': car.type,
        'description': car.description,
        'location': car.location,
        'carType': car.carType,
        'fuel': car.fuel,
        'seats': car.seats.toString(),
        'vehicleNumber': car.vehicleNumber,
        'branchName': car.branchName,
        'branchLat': car.branchLat.toString(),
        'branchLng': car.branchLng.toString(),
        'isPremium': car.isPremium.toString(),
        'availability': jsonEncode(car.availability),
      };
      
      final response = await ApiService.registerWithCar(
        fields: fields,
        carImages: carImages,
        carDocs: carDocs,
      );
      
      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        final body = response['body'];
        
          // Save login info after successful registration
          final token = body['token'] ?? body['data']?['token'];
          final ownerData = body['data']?['owner'] ?? body['data'];
          
          if (token != null) {
            await SharedPrefHelper.saveToken(token);
          }
          
          if (ownerData != null) {
            final registeredOwner = OwnerModel.fromJson(ownerData);
            await SharedPrefHelper.saveOwnerId(registeredOwner.id ?? '');
            await SharedPrefHelper.saveMobileNumber(registeredOwner.mobileNumber);
            await SharedPrefHelper.setLoggedIn(true);
          }
          
          return {
            'success': true,
            'message': body['message'] ?? 'Registration successful!',
            'data': ownerData,
          };
      } else {
        return {
          'success': false,
          'message': response['body']['message'] ?? 'Registration failed. Please try again.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
  
  // Logout
  Future<void> logout() async {
    await SharedPrefHelper.logout();
  }
  
  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return SharedPrefHelper.isLoggedIn();
  }
}