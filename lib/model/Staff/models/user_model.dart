
// class UserModel {
//   final String id;
//   final String mobile;
//   final String email;
//   final String name;
//   final List<String> myBookings;
//   final String profileImage;

//   UserModel({
//     required this.id,
//     required this.mobile,
//     required this.email,
//     required this.name,
//     required this.myBookings,
//     required this.profileImage,
//   });

//   factory UserModel.fromJson(Map<String, dynamic> json) {
//     return UserModel(
//       id: json['_id'],
//       mobile: json['mobile'],
//       email: json['email'],
//       name: json['name'],
//       myBookings: List<String>.from(json['myBookings']),
//       profileImage: json['profileImage'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     final data = {
//       '_id': id,
//       'mobile': mobile,
//       'email': email,
//       'name': name,
//       'myBookings': myBookings,
//     };

//     if (profileImage != null && profileImage!.isNotEmpty) {
//       data['profileImage'] = profileImage!;
//     }

//     return data;
//   }

//   // ✅ Add this copyWith method
//   UserModel copyWith({
//     String? id,
//     String? mobile,
//     String? email,
//     String? name,
//     List<String>? myBookings,
//     String? profileImage,
//   }) {
//     return UserModel(
//       id: id ?? this.id,
//       mobile: mobile ?? this.mobile,
//       email: email ?? this.email,
//       name: name ?? this.name,
//       myBookings: myBookings ?? this.myBookings,
//       profileImage: profileImage ?? this.profileImage,
//     );
//   }
// }




class UserModel {
  final String id;
  final String mobile;
  final String email;
  final String name;
  // final List<String> myBookings;
  final String profileImage;

  UserModel({
    required this.id,
    required this.mobile,
    required this.email,
    required this.name,
    // required this.myBookings,
    required this.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    print("Parsing JSON: $json"); // Debug print
    
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      // myBookings: json['myBookings'] != null 
      //     ? List<String>.from(json['myBookings']) 
      //     : <String>[], // Default empty list since API doesn't return this field
      profileImage: json['profileImage'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      '_id': id,
      'mobile': mobile,
      'email': email,
      'name': name,
      // 'myBookings': myBookings,
    };

    if (profileImage.isNotEmpty) {
      data['profileImage'] = profileImage;
    }

    return data;
  }

  UserModel copyWith({
    String? id,
    String? mobile,
    String? email,
    String? name,
    // List<String>? myBookings,
    String? profileImage,
  }) {
    return UserModel(
      id: id ?? this.id,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      name: name ?? this.name,
      // myBookings: myBookings ?? this.myBookings,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}