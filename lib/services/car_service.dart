import 'dart:io';
import 'dart:convert';
import 'package:varahiowner/helpers/shared_pref_helper.dart';
import 'package:varahiowner/model/Mycar/car_model.dart';
import 'api_service.dart';

class CarService {
  
  // Get all cars for owner
  Future<Map<String, dynamic>> getMyCars() async {
    try {
      final ownerId = SharedPrefHelper.getOwnerId();
      if (ownerId == null) {
        return {
          'success': false,
          'message': 'Owner not found',
        };
      }

      final response = await ApiService.get('/owner/mycars/$ownerId');
      
      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        final body = response['body'];
        
        if (body['message'] == 'Owner cars fetched successfully') {
          final List<dynamic> carsData = body['cars'] ?? [];
          final List<CarModel> cars = carsData
              .map((car) => CarModel.fromJson(car))
              .toList();
          
          return {
            'success': true,
            'message': body['message'],
            'cars': cars,
            'totalCars': body['totalCars'] ?? 0,
          };
        } else {
          return {
            'success': false,
            'message': body['message'] ?? 'Failed to fetch cars',
          };
        }
      } else {
        return {
          'success': false,
          'message': response['body']['message'] ?? 'Failed to fetch cars',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }


    Future<Map<String, dynamic>> addCar({
    required Map<String, String> fields,
    required List<File> carImages,
    required List<File> carDocs,
  }) async {
    try {
      
      final ownerId = SharedPrefHelper.getOwnerId();
      if (ownerId == null) {
        return {
          'success': false,
          'message': 'Owner not found. Please login again.',
        };
      }

      // Add ownerId to fields
      fields['ownerId'] = ownerId;
      
      final response = await ApiService.addCar(
        fields: fields,
        carImages: carImages,
        carDocs: carDocs,
        ownerId:ownerId
      );
      
      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        final body = response['body'];
        
        return {
          'success': true,
          'message': body['message'] ?? 'Car added successfully',
          'car': body['car'] != null ? CarModel.fromJson(body['car']) : null,
        };
      } else {
        return {
          'success': false,
          'message': response['body']['message'] ?? 'Failed to add car',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
  
  // Get single car details
  Future<Map<String, dynamic>> getCarById(String carId) async {
    try {
      final ownerId = SharedPrefHelper.getOwnerId();
      if (ownerId == null) {
        return {
          'success': false,
          'message': 'Owner not found',
        };
      }

      final response = await ApiService.get('/owner/singlecar/$ownerId/$carId');
      
      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        final body = response['body'];
        
        if (body['message'] == 'Car fetched successfully') {
          final car = CarModel.fromJson(body['car']);
          
          return {
            'success': true,
            'message': body['message'],
            'car': car,
          };
        } else {
          return {
            'success': false,
            'message': body['message'] ?? 'Failed to fetch car',
          };
        }
      } else {
        return {
          'success': false,
          'message': response['body']['message'] ?? 'Failed to fetch car',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
  
  // Update car
  Future<Map<String, dynamic>> updateCar({
    required String carId,
    required Map<String, String> fields,
    List<File>? carImages,
    List<File>? carDocs,
  }) async {
    try {
      final ownerId = SharedPrefHelper.getOwnerId();
      if (ownerId == null) {
        return {
          'success': false,
          'message': 'Owner not found',
        };
      }

      final response = await ApiService.updateCar(
        ownerId: ownerId,
        carId: carId,
        fields: fields,
        carImages: carImages ?? [],
        carDocs: carDocs ?? [],
      );
      
      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        final body = response['body'];
        
        return {
          'success': true,
          'message': body['message'] ?? 'Car updated successfully',
          'car': body['car'] != null ? CarModel.fromJson(body['car']) : null,
        };
      } else {
        return {
          'success': false,
          'message': response['body']['message'] ?? 'Failed to update car',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
  
  // Delete car (if endpoint exists)
  Future<Map<String, dynamic>> deleteCar(String carId) async {
    try {
      final ownerId = SharedPrefHelper.getOwnerId();
      if (ownerId == null) {
        return {
          'success': false,
          'message': 'Owner not found',
        };
      }

      final response = await ApiService.delete('/owner/deletecar/$ownerId/$carId');
      
      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        final body = response['body'];
        
        return {
          'success': true,
          'message': body['message'] ?? 'Car deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': response['body']['message'] ?? 'Failed to delete car',
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