import 'dart:async';

import 'package:varahiowner/model/vendor_model.dart';

class AuthService {
  Future<bool> login(String mobile) async {
    await Future.delayed(Duration(seconds: 1));

    if (mobile == "9999999999") {
      return true;
    }
    return false;
  }

  Future<String> registerVendor(VendorModel vendor) async {
    await Future.delayed(Duration(seconds: 2));

    // Simulate admin approval pending
    return "pending"; // approved / rejected later
  }
}
