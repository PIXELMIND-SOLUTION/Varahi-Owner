import 'package:flutter/foundation.dart';
import 'package:varahiowner/model/BannerModel/banner_model.dart';
import 'package:varahiowner/services/BannerService/banner_servicce.dart';

class BannerProvider extends ChangeNotifier {
  final BannerService _bannerService = BannerService();

  List<Banner> _banners = [];
  bool _isLoading = false;
  String _error = '';

  // Getters
  List<Banner> get banners => _banners;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get hasError => _error.isNotEmpty;

  // Fetch all banners
  Future<void> fetchBanners() async {
    _setLoading(true);
    _setError('');

    try {
      final bannerResponse = await _bannerService.getAllBanners();
      _banners = bannerResponse.banners;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Refresh banners
  Future<void> refreshBanners() async {
    await fetchBanners();
  }

  // Get banner by ID
  Banner? getBannerById(String id) {
    try {
      return _banners.firstWhere((banner) => banner.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get all images from all banners
  List<String> getAllImages() {
    List<String> allImages = [];
    for (var banner in _banners) {
      allImages.addAll(banner.images);
    }
    return allImages;
  }

  // Private methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }
}
