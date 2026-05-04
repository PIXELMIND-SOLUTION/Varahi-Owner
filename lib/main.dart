import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:varahiowner/helpers/shared_pref_helper.dart'; // Add this import
import 'package:varahiowner/providers/auth_provider.dart';
import 'package:varahiowner/providers/booking_provider.dart';
import 'package:varahiowner/providers/car_provider.dart';
import 'package:varahiowner/views/login_screen.dart';
import 'package:varahiowner/views/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure bindings are initialized
  await SharedPrefHelper.init(); // Initialize SharedPreferences
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider()),
              ChangeNotifierProvider(create: (_) => CarProvider()),
                      ChangeNotifierProvider(create: (_) => BookingProvider()),


      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Varahi Vendor',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}