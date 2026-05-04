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
  final List<String> carImage;
  final List<String> carDocs;
  final String runningStatus;
  final String status;
  final bool isLive;
  final String? ownerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Branch? branch;
  final List<String> depositOptions;
  final bool availabilityStatus;

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
    required this.carImage,
    required this.carDocs,
    required this.runningStatus,
    required this.status,
    required this.isLive,
    this.ownerId,
    this.createdAt,
    this.updatedAt,
    this.branch,
    this.depositOptions = const [],
    this.availabilityStatus = true,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: json['_id'] ?? json['id'],
      carName: json['carName'] ?? '',
      model: json['model'] ?? '',
      year: json['year']?.toString() ?? '',
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
      branchName: json['branch']?['name'] ?? json['branchName'] ?? '',
      branchLat: (json['branch']?['location']?['coordinates']?[1] ?? 
                  json['branchLat'] ?? 0).toDouble(),
      branchLng: (json['branch']?['location']?['coordinates']?[0] ?? 
                  json['branchLng'] ?? 0).toDouble(),
      isPremium: json['isPremium'] ?? false,
      availability: json['availability'] != null 
          ? List<Map<String, dynamic>>.from(json['availability']) 
          : [],
      carImage: json['carImage'] != null 
          ? List<String>.from(json['carImage']) 
          : [],
      carDocs: json['carDocs'] != null 
          ? List<String>.from(json['carDocs']) 
          : [],
      runningStatus: json['runningStatus'] ?? 'Available',
      status: json['status'] ?? 'active',
      isLive: json['isLive'] ?? true,
      ownerId: json['ownerId'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      branch: json['branch'] != null ? Branch.fromJson(json['branch']) : null,
      depositOptions: json['depositOptions'] != null 
          ? List<String>.from(json['depositOptions']) 
          : [],
      availabilityStatus: json['availabilityStatus'] ?? true,
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

class Branch {
  final String? name;
  final Location? location;

  Branch({this.name, this.location});

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      name: json['name'],
      location: json['location'] != null 
          ? Location.fromJson(json['location']) 
          : null,
    );
  }
}

class Location {
  final String type;
  final List<double> coordinates;

  Location({required this.type, required this.coordinates});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type'] ?? 'Point',
      coordinates: json['coordinates'] != null 
          ? List<double>.from(json['coordinates']) 
          : [0.0, 0.0],
    );
  }
}