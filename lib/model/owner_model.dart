class OwnerModel {
  final String? id;
  final String fullName;
  final String mobileNumber;
  final String email;
  final String? aadharNumber;
  final String? password;
  final String? token;
  final String? status;
  
  OwnerModel({
    this.id,
    required this.fullName,
    required this.mobileNumber,
    required this.email,
    this.aadharNumber,
    this.password,
    this.token,
    this.status,
  });
  
  factory OwnerModel.fromJson(Map<String, dynamic> json) {
    return OwnerModel(
      id: json['_id'] ?? json['id'],
      fullName: json['fullName'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      email: json['email'] ?? '',
      aadharNumber: json['aadharNumber'],
      password: json['password'],
      token: json['token'],
      status: json['status'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'mobileNumber': mobileNumber,
      'email': email,
      if (aadharNumber != null) 'aadharNumber': aadharNumber,
      if (password != null) 'password': password,
    };
  }
}