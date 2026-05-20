// class JsonHelper {
//   static double toDouble(dynamic value) {
//     if (value == null) return 0.0;

//     if (value is double) return value;

//     if (value is int) return value.toDouble();

//     if (value is String) {
//       return double.tryParse(value) ?? 0.0;
//     }

//     return 0.0;
//   }

//   static int toInt(dynamic value) {
//     if (value == null) return 0;

//     if (value is int) return value;

//     if (value is double) return value.toInt();

//     if (value is String) {
//       return int.tryParse(value) ?? 0;
//     }

//     return 0;
//   }

//   static String toStringValue(dynamic value) {
//     if (value == null) return '';
//     return value.toString();
//   }

//   static bool toBool(dynamic value) {
//     if (value == null) return false;

//     if (value is bool) return value;

//     if (value is String) {
//       return value.toLowerCase() == 'true' || value == '1';
//     }

//     if (value is int) {
//       return value == 1;
//     }

//     return false;
//   }

//   static List<String> toStringList(dynamic value) {
//     if (value == null) return [];

//     if (value is List) {
//       return value.map((e) => e.toString()).toList();
//     }

//     return [];
//   }

//   static DateTime toDateTime(dynamic value) {
//     if (value == null) return DateTime.now();

//     return DateTime.tryParse(value.toString()) ?? DateTime.now();
//   }
// }

// class BookingModel {
//   final String id;
//   final UserModel user;
//   final String carId;
//   final CarBookingInfo car;
//   final String rentalStartDate;
//   final String rentalEndDate;
//   final String from;
//   final String to;
//   final double totalPrice;
//   final String status;
//   final String paymentStatus;
//   final int otp;
//   final int? returnOTP;
//   final String? depositPDF;
//   final String? finalBookingPDF;
//   final bool advancePaidStatus;
//   final String deposit;
//   final List<dynamic> returnDetails;
//   final List<String> carImagesBeforePickup;
//   final List<String> carReturnImages;
//   final bool isAdvancePayment;
//   final bool completePayment;
//   final double advancePayment;
//   final double remainingAmount;
//   final double depositAmount;
//   final double totalRemainingPayment;
//   final bool isCarWash;
//   final double carWashAmount;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//   final List<dynamic> extensions;
//   final List<dynamic> carReplacementHistory;

//   BookingModel({
//     required this.id,
//     required this.user,
//     required this.carId,
//     required this.car,
//     required this.rentalStartDate,
//     required this.rentalEndDate,
//     required this.from,
//     required this.to,
//     required this.totalPrice,
//     required this.status,
//     required this.paymentStatus,
//     required this.otp,
//     this.returnOTP,
//     this.depositPDF,
//     this.finalBookingPDF,
//     required this.advancePaidStatus,
//     required this.deposit,
//     required this.returnDetails,
//     required this.carImagesBeforePickup,
//     required this.carReturnImages,
//     required this.isAdvancePayment,
//     required this.completePayment,
//     required this.advancePayment,
//     required this.remainingAmount,
//     required this.depositAmount,
//     required this.totalRemainingPayment,
//     required this.isCarWash,
//     required this.carWashAmount,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.extensions,
//     required this.carReplacementHistory,
//   });

//   factory BookingModel.fromJson(Map<String, dynamic> json) {
//     return BookingModel(
//       id: JsonHelper.toStringValue(json['_id']),
//       user: UserModel.fromJson(json['userId'] ?? {}),
//       carId: JsonHelper.toStringValue(json['carId']),
//       car: CarBookingInfo.fromJson(json['car'] ?? {}),
//       rentalStartDate: JsonHelper.toStringValue(json['rentalStartDate']),
//       rentalEndDate: JsonHelper.toStringValue(json['rentalEndDate']),
//       from: JsonHelper.toStringValue(json['from']),
//       to: JsonHelper.toStringValue(json['to']),
//       totalPrice: JsonHelper.toDouble(json['totalPrice']),
//       status: JsonHelper.toStringValue(json['status']),
//       paymentStatus: JsonHelper.toStringValue(json['paymentStatus']),
//       otp: JsonHelper.toInt(json['otp']),
//       returnOTP: json['returnOTP'] != null
//           ? JsonHelper.toInt(json['returnOTP'])
//           : null,
//       depositPDF: json['depositPDF']?.toString(),
//       finalBookingPDF: json['finalBookingPDF']?.toString(),
//       advancePaidStatus: JsonHelper.toBool(json['advancePaidStatus']),
//       deposit: JsonHelper.toStringValue(json['deposit']),
//       returnDetails: json['returnDetails'] ?? [],
//       carImagesBeforePickup: JsonHelper.toStringList(
//         json['carImagesBeforePickup'],
//       ),
//       carReturnImages: JsonHelper.toStringList(json['carReturnImages']),
//       isAdvancePayment: JsonHelper.toBool(json['isAdvancePayment']),
//       completePayment: JsonHelper.toBool(json['completePayment']),
//       advancePayment: JsonHelper.toDouble(json['advancePayment']),
//       remainingAmount: JsonHelper.toDouble(json['remainingAmount']),
//       depositAmount: JsonHelper.toDouble(json['depositAmount']),
//       totalRemainingPayment: JsonHelper.toDouble(json['totalRemainingPayment']),
//       isCarWash: JsonHelper.toBool(json['isCarWash']),
//       carWashAmount: JsonHelper.toDouble(json['carWashAmount']),
//       createdAt: JsonHelper.toDateTime(json['createdAt']),
//       updatedAt: JsonHelper.toDateTime(json['updatedAt']),
//       extensions: json['extensions'] ?? [],
//       carReplacementHistory: json['carReplacementHistory'] ?? [],
//     );
//   }
// }

// class UserModel {
//   final String id;
//   final String name;
//   final String email;

//   UserModel({required this.id, required this.name, required this.email});

//   factory UserModel.fromJson(Map<String, dynamic> json) {
//     return UserModel(
//       id: JsonHelper.toStringValue(json['_id']),
//       name: JsonHelper.toStringValue(json['name']),
//       email: JsonHelper.toStringValue(json['email']),
//     );
//   }
// }

// class CarBookingInfo {
//   final String id;
//   final String carName;
//   final String model;
//   final int year;
//   final double pricePerHour;
//   final double pricePerDay;
//   final Map<String, dynamic> extendedPrice;
//   final String description;
//   final double delayPerHour;
//   final double delayPerDay;
//   final String vehicleNumber;
//   final String location;
//   final String carType;
//   final String fuel;
//   final BranchInfo? branch;
//   final int seats;
//   final String type;
//   final String status;
//   final List<String> carImage;
//   final List<String> carDocs;
//   final String runningStatus;

//   CarBookingInfo({
//     required this.id,
//     required this.carName,
//     required this.model,
//     required this.year,
//     required this.pricePerHour,
//     required this.pricePerDay,
//     required this.extendedPrice,
//     required this.description,
//     required this.delayPerHour,
//     required this.delayPerDay,
//     required this.vehicleNumber,
//     required this.location,
//     required this.carType,
//     required this.fuel,
//     this.branch,
//     required this.seats,
//     required this.type,
//     required this.status,
//     required this.carImage,
//     required this.carDocs,
//     required this.runningStatus,
//   });

//   factory CarBookingInfo.fromJson(Map<String, dynamic> json) {
//     return CarBookingInfo(
//       id: JsonHelper.toStringValue(json['_id']),
//       carName: JsonHelper.toStringValue(json['carName']),
//       model: JsonHelper.toStringValue(json['model']),
//       year: JsonHelper.toInt(json['year']),
//       pricePerHour: JsonHelper.toDouble(json['pricePerHour']),
//       pricePerDay: JsonHelper.toDouble(json['pricePerDay']),
//       extendedPrice: json['extendedPrice'] is Map<String, dynamic>
//           ? json['extendedPrice']
//           : {},
//       description: JsonHelper.toStringValue(json['description']),
//       delayPerHour: JsonHelper.toDouble(json['delayPerHour']),
//       delayPerDay: JsonHelper.toDouble(json['delayPerDay']),
//       vehicleNumber: JsonHelper.toStringValue(json['vehicleNumber']),
//       location: JsonHelper.toStringValue(json['location']),
//       carType: JsonHelper.toStringValue(json['carType']),
//       fuel: JsonHelper.toStringValue(json['fuel']),
//       branch: json['branch'] != null
//           ? BranchInfo.fromJson(json['branch'])
//           : null,
//       seats: JsonHelper.toInt(json['seats']),
//       type: JsonHelper.toStringValue(json['type']),
//       status: JsonHelper.toStringValue(json['status']),
//       carImage: JsonHelper.toStringList(json['carImage']),
//       carDocs: JsonHelper.toStringList(json['carDocs']),
//       runningStatus: JsonHelper.toStringValue(json['runningStatus']),
//     );
//   }
// }

// class BranchInfo {
//   final String name;
//   final LocationInfo? location;

//   BranchInfo({required this.name, this.location});

//   factory BranchInfo.fromJson(Map<String, dynamic> json) {
//     return BranchInfo(
//       name: JsonHelper.toStringValue(json['name']),
//       location: json['location'] != null
//           ? LocationInfo.fromJson(json['location'])
//           : null,
//     );
//   }
// }

// class LocationInfo {
//   final String type;
//   final List<double> coordinates;

//   LocationInfo({required this.type, required this.coordinates});

//   factory LocationInfo.fromJson(Map<String, dynamic> json) {
//     return LocationInfo(
//       type: JsonHelper.toStringValue(json['type']),
//       coordinates: json['coordinates'] is List
//           ? (json['coordinates'] as List)
//                 .map((e) => JsonHelper.toDouble(e))
//                 .toList()
//           : [],
//     );
//   }
// }








// NO SEPARATE JsonHelper class - everything inline

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
    // Inline helpers - NO external JsonHelper class
    String _toString(dynamic v) => v?.toString() ?? '';
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }
    int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }
    bool _toBool(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      if (v is String) return v.toLowerCase() == 'true' || v == '1';
      if (v is int) return v == 1;
      return false;
    }
    List<String> _toStringList(dynamic v) {
      if (v == null) return [];
      if (v is List) return v.map((e) => e.toString()).toList();
      return [];
    }
    DateTime _toDateTime(dynamic v) {
      if (v == null) return DateTime.now();
      return DateTime.tryParse(v.toString()) ?? DateTime.now();
    }

    return BookingModel(
      id: _toString(json['_id']),
      user: UserModel.fromJson(json['userId'] ?? {}),
      carId: _toString(json['carId']),
      car: CarBookingInfo.fromJson(json['car'] ?? {}),
      rentalStartDate: _toString(json['rentalStartDate']),
      rentalEndDate: _toString(json['rentalEndDate']),
      from: _toString(json['from']),
      to: _toString(json['to']),
      totalPrice: _toDouble(json['totalPrice']),
      status: _toString(json['status']),
      paymentStatus: _toString(json['paymentStatus']),
      otp: _toInt(json['otp']),
      returnOTP: json['returnOTP'] != null ? _toInt(json['returnOTP']) : null,
      depositPDF: json['depositPDF']?.toString(),
      finalBookingPDF: json['finalBookingPDF']?.toString(),
      advancePaidStatus: _toBool(json['advancePaidStatus']),
      deposit: _toString(json['deposit']),
      returnDetails: json['returnDetails'] ?? [],
      carImagesBeforePickup: _toStringList(json['carImagesBeforePickup']),
      carReturnImages: _toStringList(json['carReturnImages']),
      isAdvancePayment: _toBool(json['isAdvancePayment']),
      completePayment: _toBool(json['completePayment']),
      advancePayment: _toDouble(json['advancePayment']),
      remainingAmount: _toDouble(json['remainingAmount']),
      depositAmount: _toDouble(json['depositAmount']),
      totalRemainingPayment: _toDouble(json['totalRemainingPayment']),
      isCarWash: _toBool(json['isCarWash']),
      carWashAmount: _toDouble(json['carWashAmount']),
      createdAt: _toDateTime(json['createdAt']),
      updatedAt: _toDateTime(json['updatedAt']),
      extensions: json['extensions'] ?? [],
      carReplacementHistory: json['carReplacementHistory'] ?? [],
    );
  }

  // ADDED toJson method
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': user.toJson(),
      'carId': carId,
      'car': car.toJson(),
      'rentalStartDate': rentalStartDate,
      'rentalEndDate': rentalEndDate,
      'from': from,
      'to': to,
      'totalPrice': totalPrice,
      'status': status,
      'paymentStatus': paymentStatus,
      'otp': otp,
      'returnOTP': returnOTP,
      'depositPDF': depositPDF,
      'finalBookingPDF': finalBookingPDF,
      'advancePaidStatus': advancePaidStatus,
      'deposit': deposit,
      'returnDetails': returnDetails,
      'carImagesBeforePickup': carImagesBeforePickup,
      'carReturnImages': carReturnImages,
      'isAdvancePayment': isAdvancePayment,
      'completePayment': completePayment,
      'advancePayment': advancePayment,
      'remainingAmount': remainingAmount,
      'depositAmount': depositAmount,
      'totalRemainingPayment': totalRemainingPayment,
      'isCarWash': isCarWash,
      'carWashAmount': carWashAmount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'extensions': extensions,
      'carReplacementHistory': carReplacementHistory,
    };
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;

  UserModel({required this.id, required this.name, required this.email});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String _toString(dynamic v) => v?.toString() ?? '';
    
    return UserModel(
      id: _toString(json['_id']),
      name: _toString(json['name']),
      email: _toString(json['email']),
    );
  }

  // ADDED toJson method
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
    };
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
    String _toString(dynamic v) => v?.toString() ?? '';
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }
    int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }
    List<String> _toStringList(dynamic v) {
      if (v == null) return [];
      if (v is List) return v.map((e) => e.toString()).toList();
      return [];
    }

    return CarBookingInfo(
      id: _toString(json['_id']),
      carName: _toString(json['carName']),
      model: _toString(json['model']),
      year: _toInt(json['year']),
      pricePerHour: _toDouble(json['pricePerHour']),
      pricePerDay: _toDouble(json['pricePerDay']),
      extendedPrice: json['extendedPrice'] is Map<String, dynamic>
          ? json['extendedPrice']
          : {},
      description: _toString(json['description']),
      delayPerHour: _toDouble(json['delayPerHour']),
      delayPerDay: _toDouble(json['delayPerDay']),
      vehicleNumber: _toString(json['vehicleNumber']),
      location: _toString(json['location']),
      carType: _toString(json['carType']),
      fuel: _toString(json['fuel']),
      branch: json['branch'] != null
          ? BranchInfo.fromJson(json['branch'])
          : null,
      seats: _toInt(json['seats']),
      type: _toString(json['type']),
      status: _toString(json['status']),
      carImage: _toStringList(json['carImage']),
      carDocs: _toStringList(json['carDocs']),
      runningStatus: _toString(json['runningStatus']),
    );
  }

  // ADDED toJson method
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'carName': carName,
      'model': model,
      'year': year,
      'pricePerHour': pricePerHour,
      'pricePerDay': pricePerDay,
      'extendedPrice': extendedPrice,
      'description': description,
      'delayPerHour': delayPerHour,
      'delayPerDay': delayPerDay,
      'vehicleNumber': vehicleNumber,
      'location': location,
      'carType': carType,
      'fuel': fuel,
      'branch': branch?.toJson(),
      'seats': seats,
      'type': type,
      'status': status,
      'carImage': carImage,
      'carDocs': carDocs,
      'runningStatus': runningStatus,
    };
  }
}

class BranchInfo {
  final String name;
  final LocationInfo? location;

  BranchInfo({required this.name, this.location});

  factory BranchInfo.fromJson(Map<String, dynamic> json) {
    String _toString(dynamic v) => v?.toString() ?? '';
    
    return BranchInfo(
      name: _toString(json['name']),
      location: json['location'] != null
          ? LocationInfo.fromJson(json['location'])
          : null,
    );
  }

  // ADDED toJson method
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location?.toJson(),
    };
  }
}

class LocationInfo {
  final String type;
  final List<double> coordinates;

  LocationInfo({required this.type, required this.coordinates});

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    String _toString(dynamic v) => v?.toString() ?? '';
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }
    
    return LocationInfo(
      type: _toString(json['type']),
      coordinates: json['coordinates'] is List
          ? (json['coordinates'] as List)
                .map((e) => _toDouble(e))
                .toList()
          : [],
    );
  }

  // ADDED toJson method
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}