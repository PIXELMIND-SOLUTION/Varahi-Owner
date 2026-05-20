class CarModel {
  final String? id;
  final String carName;
  final String model;
  final String year;
  final double pricePerHour;
  final double pricePerDay;
  final double delayPerHour;
  final double delayPerDay;
  final Map<String, dynamic> extendedPrice;
  final String type;
  final String description;
  final String location;
  final String carType;
  final String fuel;
  final int seats;
  final String vehicleNumber;
  final String branchName;
  final double branchLat;
  final double branchLng;
  final bool isPremium;
  final List<Map<String, dynamic>> availability;
  final String? carImage;
  final String? carDocs;
  
  CarModel({
    this.id,
    required this.carName,
    required this.model,
    required this.year,
    required this.pricePerHour,
    required this.pricePerDay,
    required this.delayPerHour,
    required this.delayPerDay,
    required this.extendedPrice,
    required this.type,
    required this.description,
    required this.location,
    required this.carType,
    required this.fuel,
    required this.seats,
    required this.vehicleNumber,
    required this.branchName,
    required this.branchLat,
    required this.branchLng,
    required this.isPremium,
    required this.availability,
    this.carImage,
    this.carDocs,
  });
  
  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: json['_id'] ?? json['id'],
      carName: json['carName'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? '',
      pricePerHour: (json['pricePerHour'] ?? 0).toDouble(),
      pricePerDay: (json['pricePerDay'] ?? 0).toDouble(),
      delayPerHour: (json['delayPerHour'] ?? 0).toDouble(),
      delayPerDay: (json['delayPerDay'] ?? 0).toDouble(),
      extendedPrice: json['extendedPrice'] ?? {},
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      carType: json['carType'] ?? '',
      fuel: json['fuel'] ?? '',
      seats: json['seats'] ?? 0,
      vehicleNumber: json['vehicleNumber'] ?? '',
      branchName: json['branchName'] ?? '',
      branchLat: (json['branchLat'] ?? 0).toDouble(),
      branchLng: (json['branchLng'] ?? 0).toDouble(),
      isPremium: json['isPremium'] ?? false,
      availability: json['availability'] != null 
          ? List<Map<String, dynamic>>.from(json['availability']) 
          : [],
      carImage: json['carImage'],
      carDocs: json['carDocs'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'carName': carName,
      'model': model,
      'year': year,
      'pricePerHour': pricePerHour,
      'pricePerDay': pricePerDay,
      'delayPerHour': delayPerHour,
      'delayPerDay': delayPerDay,
      'extendedPrice': extendedPrice,
      'type': type,
      'description': description,
      'location': location,
      'carType': carType,
      'fuel': fuel,
      'seats': seats,
      'vehicleNumber': vehicleNumber,
      'branchName': branchName,
      'branchLat': branchLat,
      'branchLng': branchLng,
      'isPremium': isPremium,
      'availability': availability,
    };
  }
}