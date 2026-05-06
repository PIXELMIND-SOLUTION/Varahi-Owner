class BannerModel {
  final String message;
  final List<Banner> banners;

  BannerModel({
    required this.message,
    required this.banners,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      message: json['message'] ?? '',
      banners: (json['banners'] as List<dynamic>?)
              ?.map((banner) => Banner.fromJson(banner))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'banners': banners.map((banner) => banner.toJson()).toList(),
    };
  }
}

class Banner {
  final String id;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  Banner({
    required this.id,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory Banner.fromJson(Map<String, dynamic> json) {
    return Banner(
      id: json['_id'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      version: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'images': images,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
    };
  }
}