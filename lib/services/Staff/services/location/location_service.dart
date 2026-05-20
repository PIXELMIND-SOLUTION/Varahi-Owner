// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';

// class LocationService {
//   static Future<String?> getCurrentAddress() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     // Check if location services are enabled
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return 'Location services are disabled.';
//     }

//     // Check location permission
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return 'Location permission denied.';
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       return 'Location permissions are permanently denied.';
//     }

//     // Get current position
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);

//     // Reverse geocode to get address
//     List<Placemark> placemarks = await placemarkFromCoordinates(
//         position.latitude, position.longitude);

//     if (placemarks.isNotEmpty) {
//       final place = placemarks[0];
//       return '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
//     }

//     return 'Address not found';
//   }


//   static Future<List<double>?> getCurrentCoordinates() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     // Check if location services are enabled
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       print('Location services are disabled.');
//       return null;
//     }

//     // Check location permission
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         print('Location permission denied.');
//         return null;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       print('Location permissions are permanently denied.');
//       return null;
//     }

//     // Get current position
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);

//     return [position.longitude, position.latitude]; // Return in GeoJSON format
//   }
// }
