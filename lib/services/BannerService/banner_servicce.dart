import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:varahiowner/model/BannerModel/banner_model.dart';

class BannerService {
  Future<BannerModel> getAllBanners() async {
    try {
      String url =
          'https://varahibackend.varahiselfdrivecars.com/api/car/allbanner';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return BannerModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load banners: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching banners: $e');
    }
  }
}
