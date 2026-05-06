import 'package:varahiowner/utils/storage_helper.dart';
import 'package:flutter/material.dart';

import '../../../model/Staff/models/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  // Method to update user and notify listeners
  Future<void> updateUser(UserModel updatedUser) async {
    print("🔄 UserProvider: updateUser called");
    print("   Old user: ${_user?.toJson()}");
    print("   New user: ${updatedUser.toJson()}");

    _user = updatedUser;

    print("🔄 UserProvider: User updated, calling notifyListeners()");
    notifyListeners();

    print("✅ UserProvider: notifyListeners() completed");
    print("   Current user after update: ${_user?.toJson()}");
  }

  // Method to set user (for login)
  void setUser(UserModel user) {
    print("🔄 UserProvider: setUser called with: ${user.toJson()}");
    _user = user;
    notifyListeners();
    print("✅ UserProvider: setUser completed");
  }

  // Method to clear user (for logout)
  void clearUser() {
    print("🔄 UserProvider: clearUser called");
    _user = null;
    notifyListeners();
    print("✅ UserProvider: clearUser completed");
  }

  // Check if user is logged in
  bool get isLoggedIn => _user != null;

  // Load user from SharedPreferences on app start
  // Future<void> loadUserFromStorage() async {
  //   print("🔄 UserProvider: loadUserFromStorage called");

  //   final userData = await StorageHelper.getAllUserData();
  //   print("   Loaded data from storage: $userData");

  //   if (userData['userId'] != null && userData['userId']!.isNotEmpty) {
  //     final user = UserModel(
  //       id: userData['userId'],
  //       name: userData['userName'],
  //       email: userData['email'],
  //       mobile: userData['mobile'],
  //       profileImage: userData['profileImage'],
  //       myBookings: [], // You might need to load this separately
  //     );

  //     print("   Created user model: ${user.toJson()}");
  //     _user = user;
  //     notifyListeners();
  //     print("✅ UserProvider: User loaded from storage and listeners notified");
  //   } else {
  //     print("❌ UserProvider: No user data found in storage");
  //   }
  // }

  // Debug method to check current state
  void debugCurrentState() {
    print("🔍 UserProvider Debug State:");
    print("   _user: ${_user?.toJson()}");
    print("   isLoggedIn: $isLoggedIn");
    print("   hasListeners: $hasListeners");
  }
}
