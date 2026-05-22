
// // single_booking_model.dart

// // ================== HELPERS ==================

// DateTime? _parseDate(dynamic value) {
//   if (value == null) return null;
//   try {
//     return DateTime.parse(value.toString());
//   } catch (_) {
//     return null;
//   }
// }

// int _parseInt(dynamic value, {int defaultValue = 0}) {
//   if (value == null) return defaultValue;
//   if (value is int) return value;
//   if (value is double) return value.toInt();
//   if (value is String) return int.tryParse(value) ?? defaultValue;
//   return defaultValue;
// }

// // ================== USER ==================

// class User {
//   final String id;
//   final String name;
//   final String email;
//   final String mobile;
//   final UserDocuments? documents;

//   User({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.mobile,
//     this.documents,
//   });

//   factory User.fromJson(dynamic json) {
//     if (json is! Map) {
//       return User(id: '', name: '', email: '', mobile: '');
//     }

//     return User(
//       id: json['_id']?.toString() ?? '',
//       name: json['name']?.toString() ?? '',
//       email: json['email']?.toString() ?? '',
//       mobile: json['mobile']?.toString() ?? '',
//       documents: json['documents'] is Map
//           ? UserDocuments.fromJson(json['documents'])
//           : null,
//     );
//   }
// }

// class UserDocuments {
//   final Document? aadharCard;
//   final Document? drivingLicense;

//   UserDocuments({this.aadharCard, this.drivingLicense});

//   factory UserDocuments.fromJson(Map<String, dynamic> json) {
//     return UserDocuments(
//       aadharCard:
//           json['aadharCard'] is Map ? Document.fromJson(json['aadharCard']) : null,
//       drivingLicense: json['drivingLicense'] is Map
//           ? Document.fromJson(json['drivingLicense'])
//           : null,
//     );
//   }
// }

// class Document {
//   final String? url;
//   final DateTime? uploadedAt;
//   final String status;

//   Document({
//     this.url,
//     this.uploadedAt,
//     required this.status,
//   });

//   factory Document.fromJson(Map<String, dynamic> json) {
//     return Document(
//       url: json['url']?.toString(),
//       uploadedAt: _parseDate(json['uploadedAt']),
//       status: json['status']?.toString() ?? 'pending',
//     );
//   }
// }

// // ================== MEDIA ==================

// class DepositProof {
//   final String? id;
//   final String? url;
//   final String? label;

//   DepositProof({this.id, this.url, this.label});

//   factory DepositProof.fromJson(dynamic json) {
//     if (json is! Map) return DepositProof();
//     return DepositProof(
//       id: json['_id']?.toString(),
//       url: json['url']?.toString(),
//       label: json['label']?.toString(),
//     );
//   }
// }

// class CarImageBeforePickup {
//   final String? id;
//   final String? url;
//   final DateTime? uploadedAt;

//   CarImageBeforePickup({this.id, this.url, this.uploadedAt});

//   factory CarImageBeforePickup.fromJson(dynamic json) {
//     if (json is! Map) return CarImageBeforePickup();
//     return CarImageBeforePickup(
//       id: json['_id']?.toString(),
//       url: json['url']?.toString(),
//       uploadedAt: _parseDate(json['uploadedAt']),
//     );
//   }
// }

// class CarReturnImage {
//   final String? id;
//   final String? url;
//   final DateTime? uploadedAt;

//   CarReturnImage({this.id, this.url, this.uploadedAt});

//   factory CarReturnImage.fromJson(dynamic json) {
//     if (json is! Map) return CarReturnImage();
//     return CarReturnImage(
//       id: json['_id']?.toString(),
//       url: json['url']?.toString(),
//       uploadedAt: _parseDate(json['uploadedAt']),
//     );
//   }
// }

// // ================== CAR ==================

// class Car {
//   final String id;
//   final String carName;
//   final String model;
//   final int pricePerHour;
//   final String location;
//   final String type;
//   final int seats;
//   final List<String> carImage;
//   final String vehicleNumber;
//   final int delayPerHour;
//   final int delayPerDay;

//   Car({
//     required this.id,
//     required this.carName,
//     required this.model,
//     required this.pricePerHour,
//     required this.location,
//     required this.type,
//     required this.seats,
//     required this.carImage,
//     required this.vehicleNumber,
//     required this.delayPerHour,
//     required this.delayPerDay,
//   });

//   factory Car.fromJson(Map<String, dynamic> json) {
//     return Car(
//       id: json['_id']?.toString() ?? '',
//       carName: json['carName']?.toString() ?? '',
//       model: json['model']?.toString() ?? '',
//       pricePerHour: _parseInt(json['pricePerHour']),
//       location: json['location']?.toString() ?? '',
//       type: json['type']?.toString() ?? '',
//       seats: _parseInt(json['seats']),
//       carImage: (json['carImage'] as List? ?? []).map((e) => e.toString()).toList(),
//       vehicleNumber: json['vehicleNumber']?.toString() ?? '',
//       delayPerHour: _parseInt(json['delayPerHour']),
//       delayPerDay: _parseInt(json['delayPerDay']),
//     );
//   }
// }

// // ================== CAR REPLACEMENT ==================

// class CarReplacementHistory {
//   final bool extraPaymentRequired;
//   final int paymentAdjustment;
//   final int staffPaymentDue;
//   final String staffPaymentStatus;
//   final DateTime? replacedAt;

//   CarReplacementHistory({
//     required this.extraPaymentRequired,
//     required this.paymentAdjustment,
//     required this.staffPaymentDue,
//     required this.staffPaymentStatus,
//     this.replacedAt,
//   });

//   factory CarReplacementHistory.fromJson(dynamic json) {
//     if (json is! Map) return null as CarReplacementHistory;

//     return CarReplacementHistory(
//       extraPaymentRequired: json['extraPaymentRequired'] ?? false,
//       paymentAdjustment: _parseInt(json['paymentAdjustment']),
//       staffPaymentDue: _parseInt(json['staffPaymentDue']),
//       staffPaymentStatus: json['staffPaymentStatus']?.toString() ?? 'pending',
//       replacedAt: _parseDate(json['replacedAt']),
//     );
//   }
// }

// // ================== EXTENSION ==================

// class BookingExtension {
//   final int? hours;
//   final int amount;
//   final String transactionId;
//   final String id;
//   final DateTime extendedAt;
//   final String? extendDeliveryDate;
//   final String? extendDeliveryTime;

//   BookingExtension({
//     this.hours,
//     required this.amount,
//     required this.transactionId,
//     required this.id,
//     required this.extendedAt,
//     this.extendDeliveryDate,
//     this.extendDeliveryTime,
//   });

//   factory BookingExtension.fromJson(dynamic json) {
//     if (json is! Map) {
//       return BookingExtension(
//         amount: 0,
//         transactionId: '',
//         id: '',
//         extendedAt: DateTime.now(),
//       );
//     }

//     return BookingExtension(
//       hours: _parseInt(json['hours'], defaultValue: 0),
//       amount: _parseInt(json['amount']),
//       transactionId: json['transactionId']?.toString() ?? '',
//       id: json['_id']?.toString() ?? '',
//       extendedAt: _parseDate(json['extendedAt']) ?? DateTime.now(),
//       extendDeliveryDate: json['extendDeliveryDate']?.toString(),
//       extendDeliveryTime: json['extendDeliveryTime']?.toString(),
//     );
//   }
// }

// // ================== BOOKING ==================

// class Booking {
//   final String id;
//   final User? userId;
//   final String carId;
//   final String rentalStartDate;
//   final String rentalEndDate;
//   final String from;
//   final String to;
//   final int totalPrice;
//   final DateTime? deliveryDate;
//   final String deliveryTime;
//   final String status;
//   final String paymentStatus;
//   final int? otp;
//   final int? returnOTP;
//   final String? deposit;
//   final String pickupLocation;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//   final Car? car;
//   final List<DepositProof> depositeProof;
//   final List<CarImageBeforePickup> carImagesBeforePickup;
//   final List<CarReturnImage> carReturnImages;
//   final List<dynamic> returnDetails;
//   final String? depositPDF;
//   final String? finalBookingPDF;
//   final List<BookingExtension> extensions;
//   final CarReplacementHistory? carReplacementHistory;

//   Booking({
//     required this.id,
//     this.userId,
//     required this.carId,
//     required this.rentalStartDate,
//     required this.rentalEndDate,
//     required this.from,
//     required this.to,
//     required this.totalPrice,
//     required this.deliveryDate,
//     required this.deliveryTime,
//     required this.status,
//     required this.paymentStatus,
//     this.otp,
//     this.returnOTP,
//     this.deposit,
//     required this.pickupLocation,
//     required this.createdAt,
//     required this.updatedAt,
//     this.car,
//     this.depositeProof = const [],
//     this.carImagesBeforePickup = const [],
//     this.carReturnImages = const [],
//     this.returnDetails = const [],
//     this.depositPDF,
//     this.finalBookingPDF,
//     this.extensions = const [],
//     this.carReplacementHistory,
//   });

//   factory Booking.fromJson(Map<String, dynamic> json) {
//     return Booking(
//       id: json['_id']?.toString() ?? '',
//       userId: json['userId'] is Map ? User.fromJson(json['userId']) : null,
//       carId: json['carId']?.toString() ?? '',
//       rentalStartDate: json['rentalStartDate']?.toString() ?? '',
//       rentalEndDate: json['rentalEndDate']?.toString() ?? '',
//       from: json['from']?.toString() ?? '',
//       to: json['to']?.toString() ?? '',
//       totalPrice: _parseInt(json['totalPrice']),
//       deliveryDate: _parseDate(json['deliveryDate']),
//       deliveryTime: json['deliveryTime']?.toString() ?? '',
//       status: json['status']?.toString() ?? '',
//       paymentStatus: json['paymentStatus']?.toString() ?? '',
//       otp: json['otp'] is int ? json['otp'] : null,
//       returnOTP: json['returnOTP'] is int ? json['returnOTP'] : null,
//       deposit: json['deposit'] == "null" ? null : json['deposit']?.toString(),
//       pickupLocation: json['pickupLocation']?.toString() ?? '',
//       createdAt: _parseDate(json['createdAt']),
//       updatedAt: _parseDate(json['updatedAt']),
//       car: json['car'] is Map ? Car.fromJson(json['car']) : null,
//       depositeProof: (json['depositeProof'] as List? ?? [])
//           .map((e) => DepositProof.fromJson(e))
//           .toList(),
//       carImagesBeforePickup: (json['carImagesBeforePickup'] as List? ?? [])
//           .map((e) => CarImageBeforePickup.fromJson(e))
//           .toList(),
//       carReturnImages: (json['carReturnImages'] as List? ?? [])
//           .map((e) => CarReturnImage.fromJson(e))
//           .toList(),
//       returnDetails: json['returnDetails'] as List? ?? [],
//       depositPDF: json['depositPDF']?.toString(),
//       finalBookingPDF: json['finalBookingPDF']?.toString(),
//       extensions: (json['extensions'] as List? ?? [])
//           .map((e) => BookingExtension.fromJson(e))
//           .toList(),
//       carReplacementHistory:
//           json['carReplacementHistory'] is Map
//               ? CarReplacementHistory.fromJson(json['carReplacementHistory'])
//               : null,
//     );
//   }
// }

// // ================== RESPONSE ==================

// class BookingResponse {
//   final String message;
//   final Booking booking;

//   BookingResponse({
//     required this.message,
//     required this.booking,
//   });

//   factory BookingResponse.fromJson(Map<String, dynamic> json) {
//     return BookingResponse(
//       message: json['message']?.toString() ?? '',
//       booking: Booking.fromJson(json['booking'] ?? {}),
//     );
//   }
// }












// single_booking_model.dart

// ================== HELPERS ==================

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  try {
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    return DateTime.parse(value.toString());
  } catch (_) {
    return null;
  }
}

int _parseInt(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
}

// Helper to convert dynamic Map to Map<String, dynamic>
Map<String, dynamic> _toMapString(Map<dynamic, dynamic> map) {
  return map.map((key, value) => MapEntry(key.toString(), value));
}

// ================== USER ==================

class User {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final UserDocuments? documents;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    this.documents,
  });

  factory User.fromJson(dynamic json) {
    if (json == null) {
      return User(id: '', name: '', email: '', mobile: '');
    }
    
    // Handle Map<dynamic, dynamic>
    Map<String, dynamic> map;
    if (json is Map<String, dynamic>) {
      map = json;
    } else if (json is Map<dynamic, dynamic>) {
      map = _toMapString(json);
    } else {
      return User(id: '', name: '', email: '', mobile: '');
    }

    // Parse documents
    UserDocuments? docs;
    final documentsData = map['documents'];
    if (documentsData != null) {
      if (documentsData is Map<String, dynamic>) {
        docs = UserDocuments.fromJson(documentsData);
      } else if (documentsData is Map<dynamic, dynamic>) {
        docs = UserDocuments.fromJson(_toMapString(documentsData));
      }
    }

    return User(
      id: map['_id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      mobile: map['mobile']?.toString() ?? '',
      documents: docs,
    );
  }
}

class UserDocuments {
  final Document? aadharCard;
  final Document? drivingLicense;

  UserDocuments({this.aadharCard, this.drivingLicense});

  factory UserDocuments.fromJson(Map<String, dynamic> json) {
    Document? aadhar;
    Document? license;
    
    // Parse Aadhar Card
    final aadharData = json['aadharCard'];
    if (aadharData != null) {
      if (aadharData is Map<String, dynamic>) {
        aadhar = Document.fromJson(aadharData);
      } else if (aadharData is Map<dynamic, dynamic>) {
        aadhar = Document.fromJson(_toMapString(aadharData));
      }
    }
    
    // Parse Driving License
    final licenseData = json['drivingLicense'];
    if (licenseData != null) {
      if (licenseData is Map<String, dynamic>) {
        license = Document.fromJson(licenseData);
      } else if (licenseData is Map<dynamic, dynamic>) {
        license = Document.fromJson(_toMapString(licenseData));
      }
    }
    
    return UserDocuments(
      aadharCard: aadhar,
      drivingLicense: license,
    );
  }
}

class Document {
  final String? url;
  final DateTime? uploadedAt;
  final String status;

  Document({
    this.url,
    this.uploadedAt,
    required this.status,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      url: json['url']?.toString(),
      uploadedAt: _parseDate(json['uploadedAt']),
      status: json['status']?.toString() ?? 'pending',
    );
  }
}

// ================== MEDIA ==================

class DepositProof {
  final String? id;
  final String? url;
  final String? label;

  DepositProof({this.id, this.url, this.label});

  factory DepositProof.fromJson(dynamic json) {
    if (json == null) return DepositProof();
    
    Map<String, dynamic> map;
    if (json is Map<String, dynamic>) {
      map = json;
    } else if (json is Map<dynamic, dynamic>) {
      map = _toMapString(json);
    } else {
      return DepositProof();
    }
    
    return DepositProof(
      id: map['_id']?.toString(),
      url: map['url']?.toString(),
      label: map['label']?.toString(),
    );
  }
}

class CarImageBeforePickup {
  final String? id;
  final String? url;
  final DateTime? uploadedAt;

  CarImageBeforePickup({this.id, this.url, this.uploadedAt});

  factory CarImageBeforePickup.fromJson(dynamic json) {
    if (json == null) return CarImageBeforePickup();
    
    Map<String, dynamic> map;
    if (json is Map<String, dynamic>) {
      map = json;
    } else if (json is Map<dynamic, dynamic>) {
      map = _toMapString(json);
    } else {
      return CarImageBeforePickup();
    }
    
    return CarImageBeforePickup(
      id: map['_id']?.toString(),
      url: map['url']?.toString(),
      uploadedAt: _parseDate(map['uploadedAt']),
    );
  }
}

class CarReturnImage {
  final String? id;
  final String? url;
  final DateTime? uploadedAt;

  CarReturnImage({this.id, this.url, this.uploadedAt});

  factory CarReturnImage.fromJson(dynamic json) {
    if (json == null) return CarReturnImage();
    
    Map<String, dynamic> map;
    if (json is Map<String, dynamic>) {
      map = json;
    } else if (json is Map<dynamic, dynamic>) {
      map = _toMapString(json);
    } else {
      return CarReturnImage();
    }
    
    return CarReturnImage(
      id: map['_id']?.toString(),
      url: map['url']?.toString(),
      uploadedAt: _parseDate(map['uploadedAt']),
    );
  }
}

// ================== CAR ==================

class Car {
  final String id;
  final String carName;
  final String model;
  final int pricePerHour;
  final String location;
  final String type;
  final int seats;
  final List<String> carImage;
  final String vehicleNumber;
  final int delayPerHour;
  final int delayPerDay;

  Car({
    required this.id,
    required this.carName,
    required this.model,
    required this.pricePerHour,
    required this.location,
    required this.type,
    required this.seats,
    required this.carImage,
    required this.vehicleNumber,
    required this.delayPerHour,
    required this.delayPerDay,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['_id']?.toString() ?? '',
      carName: json['carName']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      pricePerHour: _parseInt(json['pricePerHour']),
      location: json['location']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      seats: _parseInt(json['seats']),
      carImage: (json['carImage'] as List? ?? []).map((e) => e.toString()).toList(),
      vehicleNumber: json['vehicleNumber']?.toString() ?? '',
      delayPerHour: _parseInt(json['delayPerHour']),
      delayPerDay: _parseInt(json['delayPerDay']),
    );
  }
}

// ================== CAR REPLACEMENT ==================

class CarReplacementHistory {
  final bool extraPaymentRequired;
  final int paymentAdjustment;
  final int staffPaymentDue;
  final String staffPaymentStatus;
  final DateTime? replacedAt;

  CarReplacementHistory({
    required this.extraPaymentRequired,
    required this.paymentAdjustment,
    required this.staffPaymentDue,
    required this.staffPaymentStatus,
    this.replacedAt,
  });

  factory CarReplacementHistory.fromJson(dynamic json) {
    if (json == null) {
      return CarReplacementHistory(
        extraPaymentRequired: false,
        paymentAdjustment: 0,
        staffPaymentDue: 0,
        staffPaymentStatus: 'pending',
        replacedAt: null,
      );
    }
    
    Map<String, dynamic> map;
    if (json is Map<String, dynamic>) {
      map = json;
    } else if (json is Map<dynamic, dynamic>) {
      map = _toMapString(json);
    } else {
      return CarReplacementHistory(
        extraPaymentRequired: false,
        paymentAdjustment: 0,
        staffPaymentDue: 0,
        staffPaymentStatus: 'pending',
        replacedAt: null,
      );
    }

    return CarReplacementHistory(
      extraPaymentRequired: map['extraPaymentRequired'] ?? false,
      paymentAdjustment: _parseInt(map['paymentAdjustment']),
      staffPaymentDue: _parseInt(map['staffPaymentDue']),
      staffPaymentStatus: map['staffPaymentStatus']?.toString() ?? 'pending',
      replacedAt: _parseDate(map['replacedAt']),
    );
  }
}

// ================== EXTENSION ==================

class BookingExtension {
  final int? hours;
  final int amount;
  final String transactionId;
  final String id;
  final DateTime extendedAt;
  final String? extendDeliveryDate;
  final String? extendDeliveryTime;

  BookingExtension({
    this.hours,
    required this.amount,
    required this.transactionId,
    required this.id,
    required this.extendedAt,
    this.extendDeliveryDate,
    this.extendDeliveryTime,
  });

  factory BookingExtension.fromJson(dynamic json) {
    if (json == null) {
      return BookingExtension(
        amount: 0,
        transactionId: '',
        id: '',
        extendedAt: DateTime.now(),
      );
    }
    
    Map<String, dynamic> map;
    if (json is Map<String, dynamic>) {
      map = json;
    } else if (json is Map<dynamic, dynamic>) {
      map = _toMapString(json);
    } else {
      return BookingExtension(
        amount: 0,
        transactionId: '',
        id: '',
        extendedAt: DateTime.now(),
      );
    }

    return BookingExtension(
      hours: _parseInt(map['hours'], defaultValue: 0),
      amount: _parseInt(map['amount']),
      transactionId: map['transactionId']?.toString() ?? '',
      id: map['_id']?.toString() ?? '',
      extendedAt: _parseDate(map['extendedAt']) ?? DateTime.now(),
      extendDeliveryDate: map['extendDeliveryDate']?.toString(),
      extendDeliveryTime: map['extendDeliveryTime']?.toString(),
    );
  }
}

// ================== BOOKING ==================

class Booking {
  final String id;
  final User? userId;
  final String carId;
  final String rentalStartDate;
  final String rentalEndDate;
  final String from;
  final String to;
  final int totalPrice;
  final DateTime? deliveryDate;
  final String deliveryTime;
  final String status;
  final String paymentStatus;
  final int? otp;
  final int? returnOTP;
  final String? deposit;
  final String pickupLocation;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Car? car;
  final List<DepositProof> depositeProof;
  final List<CarImageBeforePickup> carImagesBeforePickup;
  final List<CarReturnImage> carReturnImages;
  final List<dynamic> returnDetails;
  final String? depositPDF;
  final String? finalBookingPDF;
  final List<BookingExtension> extensions;
  final CarReplacementHistory? carReplacementHistory;

  Booking({
    required this.id,
    this.userId,
    required this.carId,
    required this.rentalStartDate,
    required this.rentalEndDate,
    required this.from,
    required this.to,
    required this.totalPrice,
    required this.deliveryDate,
    required this.deliveryTime,
    required this.status,
    required this.paymentStatus,
    this.otp,
    this.returnOTP,
    this.deposit,
    required this.pickupLocation,
    required this.createdAt,
    required this.updatedAt,
    this.car,
    this.depositeProof = const [],
    this.carImagesBeforePickup = const [],
    this.carReturnImages = const [],
    this.returnDetails = const [],
    this.depositPDF,
    this.finalBookingPDF,
    this.extensions = const [],
    this.carReplacementHistory,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    // Parse userId
    User? user;
    final userIdData = json['userId'];
    if (userIdData != null) {
      user = User.fromJson(userIdData);
    }
    
    // Parse car
    Car? carObj;
    final carData = json['car'];
    if (carData != null) {
      if (carData is Map<String, dynamic>) {
        carObj = Car.fromJson(carData);
      } else if (carData is Map<dynamic, dynamic>) {
        carObj = Car.fromJson(_toMapString(carData));
      }
    }
    
    // Parse depositeProof list
    List<DepositProof> depositeProofList = [];
    final depositeProofData = json['depositeProof'];
    if (depositeProofData is List) {
      depositeProofList = depositeProofData
          .map((e) => DepositProof.fromJson(e))
          .toList();
    }
    
    // Parse carImagesBeforePickup list
    List<CarImageBeforePickup> carImagesBeforeList = [];
    final carImagesBeforeData = json['carImagesBeforePickup'];
    if (carImagesBeforeData is List) {
      carImagesBeforeList = carImagesBeforeData
          .map((e) => CarImageBeforePickup.fromJson(e))
          .toList();
    }
    
    // Parse carReturnImages list
    List<CarReturnImage> carReturnImagesList = [];
    final carReturnImagesData = json['carReturnImages'];
    if (carReturnImagesData is List) {
      carReturnImagesList = carReturnImagesData
          .map((e) => CarReturnImage.fromJson(e))
          .toList();
    }
    
    // Parse extensions list
    List<BookingExtension> extensionsList = [];
    final extensionsData = json['extensions'];
    if (extensionsData is List) {
      extensionsList = extensionsData
          .map((e) => BookingExtension.fromJson(e))
          .toList();
    }
    
    // Parse carReplacementHistory
    CarReplacementHistory? replacementHistory;
    final replacementData = json['carReplacementHistory'];
    if (replacementData != null) {
      replacementHistory = CarReplacementHistory.fromJson(replacementData);
    }
    
    // ========== FIXED DEPOSIT PARSING - HANDLES ALL CASES ==========
    String? depositValue;
    final depositData = json['deposit'];
    
    if (depositData != null && depositData != "null") {
      // Handle different possible types
      if (depositData is int) {
        depositValue = "₹${depositData.toString()}";
      } else if (depositData is double) {
        depositValue = "₹${depositData.toStringAsFixed(0)}";
      } else if (depositData is String) {
        // Check if it already has ₹ symbol
        if (depositData.startsWith('₹')) {
          depositValue = depositData;
        } else if (depositData.isNotEmpty && depositData != "null") {
          depositValue = "₹$depositData";
        }
      } else {
        depositValue = "₹${depositData.toString()}";
      }
    } 
    
    // Fallback: if deposit is null or empty, try to get from car or set default
    if (depositValue == null || 
        depositValue == "₹null" || 
        depositValue == "₹" || 
        depositValue.isEmpty) {
      
      if (carObj != null && carObj.pricePerHour > 0) {
        // Calculate deposit as 24 hours of rent (standard deposit)
        final calculatedDeposit = carObj.pricePerHour * 24;
        depositValue = "₹$calculatedDeposit";
      } else {
        // Default fallback value
        depositValue = "₹5000";
      }
    }
    
    // Handle deposit value from other sources if still not set
    if (depositValue == "₹0" || depositValue == "₹") {
      depositValue = "₹5000"; // Default deposit
    }
    
    print("=== PARSED DEPOSIT VALUE: $depositValue ==="); // Debug log
    
    return Booking(
      id: json['_id']?.toString() ?? '',
      userId: user,
      carId: json['carId']?.toString() ?? '',
      rentalStartDate: json['rentalStartDate']?.toString() ?? '',
      rentalEndDate: json['rentalEndDate']?.toString() ?? '',
      from: json['from']?.toString() ?? '',
      to: json['to']?.toString() ?? '',
      totalPrice: _parseInt(json['totalPrice']),
      deliveryDate: _parseDate(json['deliveryDate']),
      deliveryTime: json['deliveryTime']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      otp: json['otp'] is int ? json['otp'] : null,
      returnOTP: json['returnOTP'] is int ? json['returnOTP'] : null,
      deposit: depositValue,
      pickupLocation: json['pickupLocation']?.toString() ?? '',
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      car: carObj,
      depositeProof: depositeProofList,
      carImagesBeforePickup: carImagesBeforeList,
      carReturnImages: carReturnImagesList,
      returnDetails: json['returnDetails'] as List? ?? [],
      depositPDF: json['depositPDF']?.toString(),
      finalBookingPDF: json['finalBookingPDF']?.toString(),
      extensions: extensionsList,
      carReplacementHistory: replacementHistory,
    );
  }
}

// ================== RESPONSE ==================

class BookingResponse {
  final String message;
  final Booking booking;

  BookingResponse({
    required this.message,
    required this.booking,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      message: json['message']?.toString() ?? '',
      booking: Booking.fromJson(json['booking'] ?? {}),
    );
  }
}