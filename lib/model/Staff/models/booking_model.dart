import 'package:varahiowner/model/Staff/models/single_booking_model.dart';

class BookingResponse {
  final String message;
  final List<Booking> bookings;

  BookingResponse({required this.message, required this.bookings});

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      message: json['message'] ?? '',
      bookings: json['bookings'] != null
          ? List<Booking>.from(
              json['bookings']
                  .where((x) => x != null)
                  .map((x) => Booking.fromJson(x)),
            )
          : [],
    );
  }
}

class Booking {
  final String id;
  final User? user; // Make nullable
  final String carId;
  final String rentalStartDate;
  final String rentalEndDate;
  final String from;
  final String to;
  final int totalPrice;
  final DateTime deliveryDate;
  final String deliveryTime;
  final String status;
  final String paymentStatus;
  final int otp;
  final String pickupLocation;
  final String createdAt;
  final String updatedAt;
  final Car? car; // Make nullable
  final List<BookingExtension> extensions;

  Booking({
    required this.id,
    this.user, // Remove required
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
    required this.otp,
    required this.pickupLocation,
    required this.createdAt,
    required this.updatedAt,
    this.car, // Remove required
    required this.extensions,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id'] ?? '',
      user: json['userId'] != null ? User.fromJson(json['userId']) : null,
      carId: json['carId'] ?? '',
      rentalStartDate: json['rentalStartDate'] ?? '',
      rentalEndDate: json['rentalEndDate'] ?? '',
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      totalPrice: json['totalPrice'] ?? 0,
      deliveryDate: DateTime.parse(json['deliveryDate']),
      deliveryTime: json['deliveryTime'] ?? '',
      status: json['status'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      otp: json['otp'] ?? 0,
      pickupLocation: json['pickupLocation'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      car: json['car'] != null ? Car.fromJson(json['car']) : null,
      extensions:
          (json['extensions'] as List<dynamic>?)
              ?.map((e) => BookingExtension.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class User {
  final String id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class Car {
  final String id;
  final String carName;
  final String model;
  final int pricePerHour;
  final String location;
  final List<String> carImage;

  Car({
    required this.id,
    required this.carName,
    required this.model,
    required this.pricePerHour,
    required this.location,
    required this.carImage,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['_id'] ?? '',
      carName: json['carName'] ?? '',
      model: json['model'] ?? '',
      pricePerHour: json['pricePerHour'] ?? 0,
      location: json['location'] ?? '',
      carImage: json['carImage'] != null
          ? List<String>.from(json['carImage'])
          : [],
    );
  }
}
