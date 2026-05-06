// import 'dart:convert';

// import 'package:varahiowner/models/user_model.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class StorageHelper {
//   static const String _userIdKey = 'userId';
//   static const String _userName = 'userName';
//   static const String _email = 'email';
//   static const String _mobile = 'mobile';
//   static const String _profileImage = 'profileImage';

//   // Updated to include profileImage parameter
//   static Future<void> saveUserId(
//       String userId, String userName, String mobile, String email, [String? profileImage]) async {
//         print('ooooooooooooooooooooooooooooooooooooooooooooooooooooo$userId');
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_userIdKey, userId);
//     await prefs.setString(_userName, userName);
//     await prefs.setString(_mobile, mobile);
//     await prefs.setString(_email, email);

//     // Save profile image if provided
//     if (profileImage != null && profileImage.isNotEmpty) {
//       await prefs.setString(_profileImage, profileImage);
//     }

//             print('ooooooooooooooooooooooooooooooooooooooooooooooooooooo$userId');

//     print("✅ Data saved to SharedPreferences:");
//     print("UserId: $userId");
//     print("UserName: $userName");
//     print("Mobile: $mobile");
//     print("Email: $email");
//     print("ProfileImage: $profileImage");
//   }

//   static Future<void> updateProfileImage(
//     String userId,
//     String userName,
//     String mobile,
//     String profileImage,
//   ) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_userIdKey, userId);
//     await prefs.setString(_userName, userName);
//     await prefs.setString(_mobile, mobile);
//     await prefs.setString(_profileImage, profileImage);

//     print("✅ Profile updated in SharedPreferences");
//   }

//   static Future<String?> getUserId() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_userIdKey);
//   }

//   static Future<String?> getUserName() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_userName);
//   }

//   static Future<String?> getEmail() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_email);
//   }

//   static Future<String?> getMobile() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_mobile);
//   }

//   static Future<String?> getProfileImage() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_profileImage);
//   }

//   // Get all user data as a Map
//   static Future<Map<String, String?>> getAllUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     return {
//       'userId': prefs.getString(_userIdKey),
//       'userName': prefs.getString(_userName),
//       'email': prefs.getString(_email),
//       'mobile': prefs.getString(_mobile),
//       'profileImage': prefs.getString(_profileImage),
//     };
//   }

//   static Future<void> clearUserId() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_userIdKey);
//     await prefs.remove(_userName);
//     await prefs.remove(_mobile);
//     await prefs.remove(_email);
//     await prefs.remove(_profileImage);

//     print("✅ All user data cleared from SharedPreferences");
//   }

//   // Debug method to check what's stored
//   static Future<void> debugPrintAllData() async {
//     final data = await getAllUserData();
//     print("📱 Current SharedPreferences data:");
//     data.forEach((key, value) {
//       print("$key: $value");
//     });
//   }
// }

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:varahiowner/model/Staff/models/user_model.dart';

class StorageHelper {
  static const String _userIdKey = 'userId';
  static const String _userName = 'userName';
  static const String _email = 'email';
  static const String _mobile = 'mobile';
  static const String _profileImage = 'profileImage';

  // New keys for additional functionality
  static const String _authToken = 'auth_token';
  static const String _tempMobile = 'temp_mobile';

  // Updated to include profileImage parameter
  static Future<void> saveUserId(
    String userId,
    String userName,
    String mobile,
    String email, [
    String? profileImage,
  ]) async {
    print('ooooooooooooooooooooooooooooooooooooooooooooooooooooo$userId');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userName, userName);
    await prefs.setString(_mobile, mobile);
    await prefs.setString(_email, email);

    // Save profile image if provided
    if (profileImage != null && profileImage.isNotEmpty) {
      await prefs.setString(_profileImage, profileImage);
    }

    print('ooooooooooooooooooooooooooooooooooooooooooooooooooooo$userId');

    print("✅ Data saved to SharedPreferences:");
    print("UserId: $userId");
    print("UserName: $userName");
    print("Mobile: $mobile");
    print("Email: $email");
    print("ProfileImage: $profileImage");
  }

  static Future<void> updateProfileImage(
    String userId,
    String userName,
    String mobile,
    String profileImage,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userName, userName);
    await prefs.setString(_mobile, mobile);
    await prefs.setString(_profileImage, profileImage);

    print("✅ Profile updated in SharedPreferences");
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userName);
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_email);
  }

  static Future<String?> getMobile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_mobile);
  }

  static Future<String?> getProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profileImage);
  }

  // Get all user data as a Map
  static Future<Map<String, String?>> getAllUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getString(_userIdKey),
      'userName': prefs.getString(_userName),
      'email': prefs.getString(_email),
      'mobile': prefs.getString(_mobile),
      'profileImage': prefs.getString(_profileImage),
    };
  }

  static Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userName);
    await prefs.remove(_mobile);
    await prefs.remove(_email);
    await prefs.remove(_profileImage);

    print("✅ All user data cleared from SharedPreferences");
  }

  // Debug method to check what's stored
  static Future<void> debugPrintAllData() async {
    final data = await getAllUserData();
    print("📱 Current SharedPreferences data:");
    data.forEach((key, value) {
      print("$key: $value");
    });
  }

  // ==================== NEW METHODS FOR OTP FUNCTIONALITY ====================

  // Token management
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authToken, token);
    print("✅ Token saved to SharedPreferences");
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authToken);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authToken);
    print("✅ Token cleared from SharedPreferences");
  }

  // Temporary mobile number storage (for OTP process)
  static Future<void> saveTempMobile(String mobile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tempMobile, mobile);
    print("✅ Temporary mobile saved: $mobile");
  }

  static Future<String?> getTempMobile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tempMobile);
  }

  static Future<void> clearTempMobile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tempMobile);
    print("✅ Temporary mobile cleared from SharedPreferences");
  }

  // Get complete user data as UserModel
  static Future<UserModel?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userIdKey);
    final userName = prefs.getString(_userName);
    final userMobile = prefs.getString(_mobile);
    final userEmail = prefs.getString(_email);
    final profileImage = prefs.getString(_profileImage);

    if (userId != null && userName != null && userMobile != null) {
      return UserModel(
        id: userId,
        name: userName,
        mobile: userMobile,
        email: userEmail ?? '',
        profileImage: profileImage!,
      );
    }
    return null;
  }

  // Enhanced clear method that clears everything including new fields
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userName);
    await prefs.remove(_mobile);
    await prefs.remove(_email);
    await prefs.remove(_profileImage);
    await prefs.remove(_authToken);
    await prefs.remove(_tempMobile);

    print(
      "✅ All data cleared from SharedPreferences (including token and temp mobile)",
    );
  }

  // Enhanced debug method to include all new fields
  static Future<void> debugPrintAllDataEnhanced() async {
    final prefs = await SharedPreferences.getInstance();
    print("📱 Complete SharedPreferences data:");
    print("UserId: ${prefs.getString(_userIdKey)}");
    print("UserName: ${prefs.getString(_userName)}");
    print("Email: ${prefs.getString(_email)}");
    print("Mobile: ${prefs.getString(_mobile)}");
    print("ProfileImage: ${prefs.getString(_profileImage)}");
    print("AuthToken: ${prefs.getString(_authToken)}");
    print("TempMobile: ${prefs.getString(_tempMobile)}");
  }
}
