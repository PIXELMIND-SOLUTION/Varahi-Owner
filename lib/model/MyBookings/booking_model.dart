class BookingModel {
  final String id;
  final UserModel user;
  final String carId;
  final CarBookingInfo car;
  final String rentalStartDate;
  final String rentalEndDate;
  final String from;
  final String to;
  final double totalPrice;
  final String status;
  final String paymentStatus;
  final int otp;
  final int? returnOTP;
  final String? depositPDF;
  final String? finalBookingPDF;
  final bool advancePaidStatus;
  final String deposit;
  final List<dynamic> returnDetails;
  final List<String> carImagesBeforePickup;
  final List<String> carReturnImages;
  final bool isAdvancePayment;
  final bool completePayment;
  final double advancePayment;
  final double remainingAmount;
  final double depositAmount;
  final double totalRemainingPayment;
  final bool isCarWash;
  final double carWashAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<dynamic> extensions;
  final List<dynamic> carReplacementHistory;

  BookingModel({
    required this.id,
    required this.user,
    required this.carId,
    required this.car,
    required this.rentalStartDate,
    required this.rentalEndDate,
    required this.from,
    required this.to,
    required this.totalPrice,
    required this.status,
    required this.paymentStatus,
    required this.otp,
    this.returnOTP,
    this.depositPDF,
    this.finalBookingPDF,
    required this.advancePaidStatus,
    required this.deposit,
    required this.returnDetails,
    required this.carImagesBeforePickup,
    required this.carReturnImages,
    required this.isAdvancePayment,
    required this.completePayment,
    required this.advancePayment,
    required this.remainingAmount,
    required this.depositAmount,
    required this.totalRemainingPayment,
    required this.isCarWash,
    required this.carWashAmount,
    required this.createdAt,
    required this.updatedAt,
    required this.extensions,
    required this.carReplacementHistory,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['_id'] ?? '',
      user: UserModel.fromJson(json['userId'] ?? {}),
      carId: json['carId'] ?? '',
      car: CarBookingInfo.fromJson(json['car'] ?? {}),
      rentalStartDate: json['rentalStartDate'] ?? '',
      rentalEndDate: json['rentalEndDate'] ?? '',
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      paymentStatus: json['paymentStatus'] ?? 'Pending',
      otp: json['otp'] ?? 0,
      returnOTP: json['returnOTP'],
      depositPDF: json['depositPDF'],
      finalBookingPDF: json['finalBookingPDF'],
      advancePaidStatus: json['advancePaidStatus'] ?? false,
      deposit: json['deposit'] ?? '',
      returnDetails: json['returnDetails'] ?? [],
      carImagesBeforePickup: json['carImagesBeforePickup'] != null 
          ? List<String>.from(json['carImagesBeforePickup']) 
          : [],
      carReturnImages: json['carReturnImages'] != null 
          ? List<String>.from(json['carReturnImages']) 
          : [],
      isAdvancePayment: json['isAdvancePayment'] ?? false,
      completePayment: json['completePayment'] ?? true,
      advancePayment: (json['advancePayment'] ?? 0).toDouble(),
      remainingAmount: (json['remainingAmount'] ?? 0).toDouble(),
      depositAmount: (json['depositAmount'] ?? 0).toDouble(),
      totalRemainingPayment: (json['totalRemainingPayment'] ?? 0).toDouble(),
      isCarWash: json['isCarWash'] ?? false,
      carWashAmount: (json['carWashAmount'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      extensions: json['extensions'] ?? [],
      carReplacementHistory: json['carReplacementHistory'] ?? [],
    );
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class CarBookingInfo {
  final String id;
  final String carName;
  final String model;
  final int year;
  final double pricePerHour;
  final double pricePerDay;
  final Map<String, dynamic> extendedPrice;
  final String description;
  final double delayPerHour;
  final double delayPerDay;
  final String vehicleNumber;
  final String location;
  final String carType;
  final String fuel;
  final BranchInfo? branch;
  final int seats;
  final String type;
  final String status;
  final List<String> carImage;
  final List<String> carDocs;
  final String runningStatus;

  CarBookingInfo({
    required this.id,
    required this.carName,
    required this.model,
    required this.year,
    required this.pricePerHour,
    required this.pricePerDay,
    required this.extendedPrice,
    required this.description,
    required this.delayPerHour,
    required this.delayPerDay,
    required this.vehicleNumber,
    required this.location,
    required this.carType,
    required this.fuel,
    this.branch,
    required this.seats,
    required this.type,
    required this.status,
    required this.carImage,
    required this.carDocs,
    required this.runningStatus,
  });

  factory CarBookingInfo.fromJson(Map<String, dynamic> json) {
    return CarBookingInfo(
      id: json['_id'] ?? '',
      carName: json['carName'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? 0,
      pricePerHour: (json['pricePerHour'] ?? 0).toDouble(),
      pricePerDay: (json['pricePerDay'] ?? 0).toDouble(),
      extendedPrice: json['extendedPrice'] ?? {},
      description: json['description'] ?? '',
      delayPerHour: (json['delayPerHour'] ?? 0).toDouble(),
      delayPerDay: (json['delayPerDay'] ?? 0).toDouble(),
      vehicleNumber: json['vehicleNumber'] ?? '',
      location: json['location'] ?? '',
      carType: json['carType'] ?? '',
      fuel: json['fuel'] ?? '',
      branch: json['branch'] != null ? BranchInfo.fromJson(json['branch']) : null,
      seats: json['seats'] ?? 0,
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      carImage: json['carImage'] != null ? List<String>.from(json['carImage']) : [],
      carDocs: json['carDocs'] != null ? List<String>.from(json['carDocs']) : [],
      runningStatus: json['runningStatus'] ?? 'Available',
    );
  }
}

class BranchInfo {
  final String name;
  final LocationInfo? location;

  BranchInfo({required this.name, this.location});

  factory BranchInfo.fromJson(Map<String, dynamic> json) {
    return BranchInfo(
      name: json['name'] ?? '',
      location: json['location'] != null ? LocationInfo.fromJson(json['location']) : null,
    );
  }
}

class LocationInfo {
  final String type;
  final List<double> coordinates;

  LocationInfo({required this.type, required this.coordinates});

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      type: json['type'] ?? 'Point',
      coordinates: json['coordinates'] != null ? List<double>.from(json['coordinates']) : [],
    );
  }
}