import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  static const String _tokenKey = 'auth_token';
  static const String _ownerIdKey = 'owner_id';
  static const String _mobileKey = 'mobile_number';
  static const String _isLoggedInKey = 'is_logged_in';
  
  static late SharedPreferences _prefs;
  
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  static void _checkInitialized() {
    // This will throw if init() wasn't called
    if (_prefs.toString() == 'null') {
      throw Exception('SharedPrefHelper not initialized. Call SharedPrefHelper.init() in main.dart');
    }
  }
  
  // Token methods
  static Future<void> saveToken(String token) async {
    _checkInitialized();
    await _prefs.setString(_tokenKey, token);
  }
  
  static String? getToken() {
    _checkInitialized();
    return _prefs.getString(_tokenKey);
  }
  
  static Future<void> removeToken() async {
    _checkInitialized();
    await _prefs.remove(_tokenKey);
  }
  
  // Owner ID methods
  static Future<void> saveOwnerId(String ownerId) async {
    _checkInitialized();
    await _prefs.setString(_ownerIdKey, ownerId);
  }
  
  static String? getOwnerId() {
    _checkInitialized();
    return _prefs.getString(_ownerIdKey);
  }
  
  // Mobile number methods
  static Future<void> saveMobileNumber(String mobile) async {
    _checkInitialized();
    await _prefs.setString(_mobileKey, mobile);
  }
  
  static String? getMobileNumber() {
    _checkInitialized();
    return _prefs.getString(_mobileKey);
  }
  
  // Login state methods
  static Future<void> setLoggedIn(bool value) async {
    _checkInitialized();
    await _prefs.setBool(_isLoggedInKey, value);
  }
  
  static bool isLoggedIn() {
    _checkInitialized();
    return _prefs.getBool(_isLoggedInKey) ?? false;
  }
  
  // Clear all user data
  static Future<void> logout() async {
    _checkInitialized();
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_ownerIdKey);
    await _prefs.remove(_mobileKey);
    await _prefs.setBool(_isLoggedInKey, false);
  }
}