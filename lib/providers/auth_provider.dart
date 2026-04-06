import 'package:flutter/material.dart';
import 'package:varahiowner/model/vendor_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  bool isLoading = false;
  bool isLoggedIn = false;
  String statusMessage = "";

  Future<void> login(String mobile) async {
    isLoading = true;
    notifyListeners();

    bool success = await _service.login(mobile);

    if (success) {
      isLoggedIn = true;
      statusMessage = "Login successful";
    } else {
      statusMessage = "Invalid mobile number";
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> register(VendorModel vendor) async {
    isLoading = true;
    notifyListeners();

    String result = await _service.registerVendor(vendor);

    if (result == "pending") {
      statusMessage = "Waiting for admin approval";
    }

    isLoading = false;
    notifyListeners();
  }
}
