// lib/models/owner_model.dart

class Owner {
  final String id;
  final String fullName;
  final String mobileNumber;
  final String email;
  final String aadharNumber;
  final bool isVerified;
  final String status;
  final List<String> cars;
  final DateTime createdAt;
  final DateTime updatedAt;

  Owner({
    required this.id,
    required this.fullName,
    required this.mobileNumber,
    required this.email,
    required this.aadharNumber,
    required this.isVerified,
    required this.status,
    required this.cars,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      email: json['email'] ?? '',
      aadharNumber: json['aadharNumber'] ?? '',
      isVerified: json['isVerified'] ?? false,
      status: json['status'] ?? '',
      cars: List<String>.from(json['cars'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'mobileNumber': mobileNumber,
      'email': email,
      'aadharNumber': aadharNumber,
      'isVerified': isVerified,
      'status': status,
      'cars': cars,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Owner copyWith({
    String? fullName,
    String? mobileNumber,
    String? email,
    String? aadharNumber,
    String? status,
  }) {
    return Owner(
      id: this.id,
      fullName: fullName ?? this.fullName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      email: email ?? this.email,
      aadharNumber: aadharNumber ?? this.aadharNumber,
      isVerified: this.isVerified,
      status: status ?? this.status,
      cars: this.cars,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

// Update Request Model
class UpdateOwnerRequest {
  final String? fullName;
  final String? mobileNumber;
  final String? email;
  final String? aadharNumber;

  UpdateOwnerRequest({
    this.fullName,
    this.mobileNumber,
    this.email,
    this.aadharNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      if (fullName != null) 'fullName': fullName,
      if (mobileNumber != null) 'mobileNumber': mobileNumber,
      if (email != null) 'email': email,
      if (aadharNumber != null) 'aadharNumber': aadharNumber,
    };
  }
}
