// lib/providers/owner_provider.dart

import 'package:flutter/foundation.dart';
import 'package:varahiowner/model/Profile/owner_model.dart';
import '../services/owner_service.dart';

class OwnerProvider extends ChangeNotifier {
  final OwnerService _ownerService = OwnerService();

  Owner? _owner;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Owner? get owner => _owner;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isVerified => _owner?.isVerified ?? false;
  String get ownerStatus => _owner?.status ?? '';

  // Fetch owner profile
  Future<bool> fetchOwnerProfile(String ownerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _owner = await _ownerService.getOwnerProfile(ownerId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update owner profile
  Future<bool> updateOwnerProfile({
    required String ownerId,
    String? fullName,
    String? mobileNumber,
    String? email,
    String? aadharNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = UpdateOwnerRequest(
        fullName: fullName,
        mobileNumber: mobileNumber,
        email: email,
        aadharNumber: aadharNumber,
      );

      _owner = await _ownerService.updateOwnerProfile(ownerId, request);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Reset provider
  void reset() {
    _owner = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
