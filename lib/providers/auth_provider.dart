import 'dart:io';
import 'package:flutter/material.dart';
import 'package:varahiowner/model/car_model.dart';
import 'package:varahiowner/model/owner_model.dart';
import 'package:varahiowner/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isLoggedIn = false;
  String _errorMessage = '';
  OwnerModel? _currentOwner;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String get errorMessage => _errorMessage;
  OwnerModel? get currentOwner => _currentOwner;

  AuthProvider() {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    _isLoggedIn = await _authService.isLoggedIn();
    notifyListeners();
  }

  Future<bool> login(String mobileNumber, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    print("ooooooooooo$mobileNumber");
    print("ooooooooooo$password");

    final result = await _authService.login(mobileNumber, password);

    _isLoading = false;

    if (result['success'] == true) {
      _isLoggedIn = true;
      _currentOwner = OwnerModel.fromJson(result['data']);
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerWithCar({
    required OwnerModel owner,
    required CarModel car,
    required List<File> carImages,
    required List<File> carDocs,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final result = await _authService.registerWithCar(
      owner: owner,
      car: car,
      carImages: carImages,
      carDocs: carDocs,
    );

    _isLoading = false;

    if (result['success'] == true) {
      _isLoggedIn = true;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _isLoggedIn = false;
    _currentOwner = null;
    _errorMessage = '';
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
