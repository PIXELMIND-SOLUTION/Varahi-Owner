import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

import 'package:varahiowner/helpers/shared_pref_helper.dart';

class ApiService {
  static const String baseUrl = 'https://varahibackend.varahiselfdrivecars.com/api';
  
  // Headers
  static Future<Map<String, String>> _getHeaders({bool isMultipart = false}) async {
    final headers = <String, String>{};
    
    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }
    
    // Add auth token if available
    final token = await SharedPrefHelper.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
  
  // POST request for register-with-car (Multipart)
  static Future<Map<String, dynamic>> registerWithCar({
    required Map<String, String> fields,
    required List<File> carImages,
    required List<File> carDocs,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/owner/register-with-car');
      final request = http.MultipartRequest('POST', uri);
      
      // Add fields
      fields.forEach((key, value) {
        request.fields[key] = value;
      });
      
      // Add car images
      for (int i = 0; i < carImages.length; i++) {
        final file = carImages[i];
        final stream = http.ByteStream(file.openRead());
        final length = await file.length();
        final multipartFile = http.MultipartFile(
          i == 0 ? 'carImage' : 'carImage_$i',
          stream,
          length,
          filename: file.path.split('/').last,
        );
        request.files.add(multipartFile);
      }
      
      // Add car documents
      for (int i = 0; i < carDocs.length; i++) {
        final file = carDocs[i];
        final stream = http.ByteStream(file.openRead());
        final length = await file.length();
        final multipartFile = http.MultipartFile(
          i == 0 ? 'carDocs' : 'carDocs_$i',
          stream,
          length,
          filename: file.path.split('/').last,
        );
        request.files.add(multipartFile);
      }
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final decoded = json.decode(responseBody);

      print("ooooooooooo${decoded}");
      
      return {
        'statusCode': response.statusCode,
        'body': decoded,
      };
    } catch (e) {
      return {
        'statusCode': 500,
        'body': {'success': false, 'message': 'Network error: $e'},
      };
    }
  }


    static Future<Map<String, dynamic>> addCar({
    required Map<String, String> fields,
    required List<File> carImages,
    required List<File> carDocs,
    required String ownerId
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/owner/add-car/$ownerId');
      final request = http.MultipartRequest('POST', uri);
      
      // Add headers with token
      final token = await SharedPrefHelper.getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      // Add fields
      fields.forEach((key, value) {
        request.fields[key] = value;
      });
      
      // Add car images
      for (int i = 0; i < carImages.length; i++) {
        final file = carImages[i];
        final stream = http.ByteStream(file.openRead());
        final length = await file.length();
        final multipartFile = http.MultipartFile(
          'carImage',
          stream,
          length,
          filename: file.path.split('/').last,
        );
        request.files.add(multipartFile);
      }
      
      // Add car documents
      for (int i = 0; i < carDocs.length; i++) {
        final file = carDocs[i];
        final stream = http.ByteStream(file.openRead());
        final length = await file.length();
        final multipartFile = http.MultipartFile(
          'carDocs',
          stream,
          length,
          filename: file.path.split('/').last,
        );
        request.files.add(multipartFile);
      }
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final decoded = json.decode(responseBody);
      
      return {
        'statusCode': response.statusCode,
        'body': decoded,
      };
    } catch (e) {
      return {
        'statusCode': 500,
        'body': {'success': false, 'message': 'Network error: $e'},
      };
    }
  }
  
  // POST request (JSON)
  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders();
      
      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(data),
      );
      
      return {
        'statusCode': response.statusCode,
        'body': json.decode(response.body),
      };
    } catch (e) {
      return {
        'statusCode': 500,
        'body': {'success': false, 'message': 'Network error: $e'},
      };
    }
  }
  
  // GET request
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders();
      
      final response = await http.get(uri, headers: headers);
      
      return {
        'statusCode': response.statusCode,
        'body': json.decode(response.body),
      };
    } catch (e) {
      return {
        'statusCode': 500,
        'body': {'success': false, 'message': 'Network error: $e'},
      };
    }
  }

  // Add to existing ApiService class

// Update car (Multipart)
static Future<Map<String, dynamic>> updateCar({
  required String ownerId,
  required String carId,
  required Map<String, String> fields,
  required List<File> carImages,
  required List<File> carDocs,
}) async {
  try {
    final uri = Uri.parse('$baseUrl/owner/updatecar/$ownerId/$carId');
    final request = http.MultipartRequest('PUT', uri);
    
    // Add fields
    fields.forEach((key, value) {
      request.fields[key] = value;
    });
    
    // Add car images
    for (int i = 0; i < carImages.length; i++) {
      final file = carImages[i];
      final stream = http.ByteStream(file.openRead());
      final length = await file.length();
      final multipartFile = http.MultipartFile(
        i == 0 ? 'carImage' : 'carImage_$i',
        stream,
        length,
        filename: file.path.split('/').last,
      );
      request.files.add(multipartFile);
    }
    
    // Add car documents
    for (int i = 0; i < carDocs.length; i++) {
      final file = carDocs[i];
      final stream = http.ByteStream(file.openRead());
      final length = await file.length();
      final multipartFile = http.MultipartFile(
        i == 0 ? 'carDocs' : 'carDocs_$i',
        stream,
        length,
        filename: file.path.split('/').last,
      );
      request.files.add(multipartFile);
    }
    
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final decoded = json.decode(responseBody);

    print("pppppppppp${decoded}");
    
    return {
      'statusCode': response.statusCode,
      'body': decoded,
    };
  } catch (e) {
    return {
      'statusCode': 500,
      'body': {'success': false, 'message': 'Network error: $e'},
    };
  }
}

// DELETE request
static Future<Map<String, dynamic>> delete(String endpoint) async {
  try {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    
    final response = await http.delete(uri, headers: headers);
    
    return {
      'statusCode': response.statusCode,
      'body': json.decode(response.body),
    };
  } catch (e) {
    return {
      'statusCode': 500,
      'body': {'success': false, 'message': 'Network error: $e'},
    };
  }
}
}