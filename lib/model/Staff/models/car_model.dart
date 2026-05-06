// class Car {
//   final String id;
//   final String name;
//   final String model;
//   final int year;
//   final int pricePerHour;
//   final String description;
//   final bool availabilityStatus;
//   final String image;
//   final String location;
//   final String carType;
//   final String fuel;
//   final int seats;
//   final String type;

//   Car({
//     required this.id,
//     required this.name,
//     required this.model,
//     required this.year,
//     required this.pricePerHour,
//     required this.description,
//     required this.availabilityStatus,
//     required this.image,
//     required this.location,
//     required this.carType,
//     required this.fuel,
//     required this.seats,
//     required this.type,
//   });

//   factory Car.fromJson(Map<String, dynamic> json) {
//     return Car(
//       id: json['_id'],
//       name: json['carName'],
//       model: json['model'],
//       year: json['year'],
//       pricePerHour: json['pricePerHour'],
//       description: json['description'],
//       availabilityStatus: json['availabilityStatus'],
//       image: json['carImage'],
//       location: json['location'],
//       carType: json['carType'],
//       fuel: json['fuel'],
//       seats: json['seats'],
//       type: json['type'],
//     );
//   }
// }



class Car {
  final String id;
  final String name;
  final String model;
  final int year;
  final int pricePerHour;
  final String description;
  final bool availabilityStatus;
  final String image;
  final String location;
  final String carType;
  final String fuel;
  final int seats;
  final String type;

  Car({
    required this.id,
    required this.name,
    required this.model,
    required this.year,
    required this.pricePerHour,
    required this.description,
    required this.availabilityStatus,
    required this.image,
    required this.location,
    required this.carType,
    required this.fuel,
    required this.seats,
    required this.type,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['_id'],
      name: json['carName'], // API uses 'carName' instead of 'name'
      model: json['model'],
      year: json['year'],
      pricePerHour: json['pricePerHour'],
      description: json['description'],
      availabilityStatus: json['availabilityStatus'],
      image: json['carImage'], // API uses 'carImage' instead of 'image'
      location: json['location'],
      carType: json['carType'],
      fuel: json['fuel'],
      seats: json['seats'],
      type: json['type'],
    );
  }
}