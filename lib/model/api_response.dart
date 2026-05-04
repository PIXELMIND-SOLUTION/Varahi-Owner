class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;
  
  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
  });
  
  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJson) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJson(json['data']) : null,
      statusCode: json['statusCode'],
    );
  }
  
  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }
}