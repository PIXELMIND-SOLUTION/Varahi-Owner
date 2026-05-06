import 'package:varahiowner/model/Staff/models/user_model.dart';
import 'package:varahiowner/utils/storage_helper.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  String? _localImageUrl;
  String? _token;
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  String get localImageUrl =>
      _localImageUrl ?? 'https://avatar.iran.liara.run/public/boy?username=Ash';

  // Loading state management
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Error message management
  void setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  Future<void> loadProfileImage() async {
    final profileImage =
        _user?.profileImage ?? await StorageHelper.getProfileImage();

    print("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk$profileImage");

    if (profileImage != null) {
      _localImageUrl =
          'https://varahibackend.varahiselfdrivecars.com$profileImage';
    } else {
      _localImageUrl = 'https://avatar.iran.liara.run/public/boy?username=Ash';
    }

    notifyListeners();
  }

  void setUser(UserModel user) {
    print('Setting user: ${user.toJson()}');
    _user = user;
    StorageHelper.saveUserId(
      user.id,
      user.name,
      user.mobile,
      user.email,
      user.profileImage,
    );
    loadProfileImage(); // Load profile image after setting user
    notifyListeners();
  }

  void setToken(String token) {
    _token = token;
    StorageHelper.saveToken(token);
    notifyListeners();
  }

  Future<void> updateProfileImage(String imagePath) async {
    if (_user != null) {
      await StorageHelper.updateProfileImage(
        _user!.id,
        _user!.name,
        _user!.mobile,
        imagePath,
      );
      _user = _user!.copyWith(profileImage: imagePath);
      await loadProfileImage();
    }
  }

  Future<void> updateUser(UserModel updatedUser) async {
    _user = updatedUser;

    await StorageHelper.updateProfileImage(
      updatedUser.id,
      updatedUser.name,
      updatedUser.mobile,
      updatedUser.profileImage ?? '',
    );

    await loadProfileImage(); // updates _localImageUrl
    notifyListeners();
  }

  void logout() {
    _user = null;
    _localImageUrl = null;
    _token = null;
    _errorMessage = '';
    StorageHelper.clearUserId();
    StorageHelper.clearToken();
    StorageHelper.clearTempMobile();
    notifyListeners();
  }

  // Initialize user from storage on app start
  Future<void> initializeUser() async {
    final userData = await StorageHelper.getUserData();
    final token = await StorageHelper.getToken();

    if (userData != null) {
      _user = userData;
      await loadProfileImage();
    }

    if (token != null) {
      _token = token;
    }

    notifyListeners();
  }
}
