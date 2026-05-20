class VendorModel {
  final String name;
  final String mobile;
  final String idProof;
  final String carName;
  final String modelNumber;
  final String registerNumber;
  final String fuelType;
  final String carDocument;
  final String pickupLocation;
  final double latitude;
  final double longitude;
  final bool isApproved;

  VendorModel({
    required this.name,
    required this.mobile,
    required this.idProof,
    required this.carName,
    required this.modelNumber,
    required this.registerNumber,
    required this.fuelType,
    required this.carDocument,
    required this.pickupLocation,
    required this.latitude,
    required this.longitude,
    this.isApproved = false,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "mobile": mobile,
      "id_proof": idProof,
      "car_name": carName,
      "model_number": modelNumber,
      "register_number": registerNumber,
      "fuel_type": fuelType,
      "car_document": carDocument,
      "pickup_location": pickupLocation,
      "latitude": latitude,
      "longitude": longitude,
      "is_approved": isApproved,
    };
  }
}
