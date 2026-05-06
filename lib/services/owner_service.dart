// lib/services/owner_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:varahiowner/model/Profile/owner_model.dart';

class OwnerService {
  static const String baseUrl =
      'https://varahibackend.varahiselfdrivecars.com/api';

  // Get owner profile
  Future<Owner> getOwnerProfile(String ownerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/owner/ownerprofile/$ownerId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['message'] == 'Owner profile fetched successfully') {
          return Owner.fromJson(responseData['owner']);
        } else {
          throw Exception(
            'Failed to fetch owner profile: ${responseData['message']}',
          );
        }
      } else {
        throw Exception(
          'Failed to load owner profile. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching owner profile: $e');
    }
  }

  // Update owner profile
  Future<Owner> updateOwnerProfile(
    String ownerId,
    UpdateOwnerRequest request,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/owner/updateownerprofile/$ownerId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['message'] == 'Owner updated successfully') {
          return Owner.fromJson(responseData['owner']);
        } else {
          throw Exception('Failed to update owner: ${responseData['message']}');
        }
      } else {
        throw Exception(
          'Failed to update owner profile. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error updating owner profile: $e');
    }
  }
}
