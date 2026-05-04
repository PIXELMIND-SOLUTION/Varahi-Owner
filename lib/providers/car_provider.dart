import 'dart:io';
import 'package:flutter/material.dart';
import 'package:varahiowner/model/Mycar/car_model.dart';
import 'package:varahiowner/services/car_service.dart';

class CarProvider extends ChangeNotifier {
  final CarService _carService = CarService();
  
  bool _isLoading = false;
  bool _isUpdating = false;
  String _errorMessage = '';
  List<CarModel> _myCars = [];
  CarModel? _selectedCar;
  int _totalCars = 0;
    bool _isAdding = false;

  
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String get errorMessage => _errorMessage;
  List<CarModel> get myCars => _myCars;
  CarModel? get selectedCar => _selectedCar;
  int get totalCars => _totalCars;
    bool get isAdding => _isAdding;

  
  // Fetch all cars for the owner
  Future<bool> fetchMyCars() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    final result = await _carService.getMyCars();
    
    _isLoading = false;
    
    if (result['success'] == true) {
      _myCars = result['cars'];
      _totalCars = result['totalCars'] ?? 0;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }
  
  // Fetch single car details
  Future<bool> fetchCarById(String carId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    final result = await _carService.getCarById(carId);
    
    _isLoading = false;
    
    if (result['success'] == true) {
      _selectedCar = result['car'];
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }


  // ADD NEW CAR
  Future<bool> addCar({
    required Map<String, String> fields,
    required List<File> carImages,
    required List<File> carDocs,
  }) async {
    if (_isAdding) return false;
    
    _isAdding = true;
    _errorMessage = '';
    notifyListeners();
    
    final result = await _carService.addCar(
      fields: fields,
      carImages: carImages,
      carDocs: carDocs,
    );
    
    _isAdding = false;
    
    if (result['success'] == true) {
      // Add the new car to the list
      if (result['car'] != null) {
        _myCars.insert(0, result['car']);
        _totalCars++;
      }
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }
  
  // Update car
  Future<bool> updateCar({
    required String carId,
    required Map<String, String> fields,
    List<File>? carImages,
    List<File>? carDocs,
  }) async {
    _isUpdating = true;
    _errorMessage = '';
    notifyListeners();
    
    final result = await _carService.updateCar(
      carId: carId,
      fields: fields,
      carImages: carImages,
      carDocs: carDocs,
    );
    
    _isUpdating = false;
    
    if (result['success'] == true) {
      // Update the car in the list
      final updatedCar = result['car'];
      if (updatedCar != null) {
        final index = _myCars.indexWhere((car) => car.id == carId);
        if (index != -1) {
          _myCars[index] = updatedCar;
        }
        if (_selectedCar?.id == carId) {
          _selectedCar = updatedCar;
        }
      }
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }
  
  // Clear error
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
  
  // Clear selected car
  void clearSelectedCar() {
    _selectedCar = null;
    notifyListeners();
  }
}