// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:varahiowner/helpers/toast_helper.dart';
// import 'package:varahiowner/helpers/shared_pref_helper.dart';
// import 'package:varahiowner/providers/auth_provider.dart';
// import 'package:varahiowner/views/navbar_screen.dart';
// import 'signup_screen.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _mobileController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _obscurePassword = true;
//   String _mobileError = '';

//   static const _brand = Color(0xFF1D9E75);
//   static const _brandLight = Color(0xFFE1F5EE);
//   static const _brandDark = Color(0xFF0F6E56);
//   static const _errorRed = Color(0xFFE53935);

//   @override
//   void dispose() {
//     _mobileController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _launchURL(String url) async {
//     final Uri uri = Uri.parse(url);
//     try {
//       if (await canLaunchUrl(uri)) {
//         await launchUrl(uri, mode: LaunchMode.externalApplication);
//       } else {
//         ToastHelper.showError(context, 'Could not launch URL');
//       }
//     } catch (e) {
//       ToastHelper.showError(context, 'Error: $e');
//     }
//   }

//   // Mobile number validation
//   void _validateMobileNumber(String value) {
//     setState(() {
//       if (value.isEmpty) {
//         _mobileError = '';
//       } else if (value.length != 10) {
//         _mobileError = 'Mobile number must be exactly 10 digits';
//       } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
//         _mobileError = 'Please enter valid numbers only';
//       } else {
//         _mobileError = '';
//       }
//     });
//   }

//   Future<void> _handleLogin() async {
//     final mobile = _mobileController.text.trim();
//     final password = _passwordController.text.trim();

//     // Validate mobile number
//     if (mobile.isEmpty) {
//       ToastHelper.showError(context, 'Please enter mobile number');
//       return;
//     }

//     if (mobile.length != 10) {
//       ToastHelper.showError(context, 'Mobile number must be exactly 10 digits');
//       return;
//     }

//     if (!RegExp(r'^[0-9]{10}$').hasMatch(mobile)) {
//       ToastHelper.showError(context, 'Please enter valid numbers only');
//       return;
//     }

//     if (password.isEmpty) {
//       ToastHelper.showError(context, 'Please enter your password');
//       return;
//     }

//     final provider = Provider.of<AuthProvider>(context, listen: false);
//     final success = await provider.login(mobile, password);

//     if (success) {
//       ToastHelper.showSuccess(context, 'Login successful!');
//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const MainShell()),
//         );
//       }
//     } else {
//       ToastHelper.showError(context, provider.errorMessage);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<AuthProvider>(context);
//     final size = MediaQuery.of(context).size;
//     final isSmallScreen = size.height < 700;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F7F5),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           child: ConstrainedBox(
//             constraints: BoxConstraints(
//               minHeight:
//                   size.height -
//                   MediaQuery.of(context).padding.top -
//                   MediaQuery.of(context).padding.bottom,
//             ),
//             child: IntrinsicHeight(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Logo
//                     Center(
//                       child: Container(
//                         width: isSmallScreen ? 70 : 90,
//                         height: isSmallScreen ? 70 : 90,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           boxShadow: [
//                             BoxShadow(
//                               color: _brand.withOpacity(0.2),
//                               blurRadius: 20,
//                               offset: const Offset(0, 8),
//                             ),
//                           ],
//                         ),
//                         child: ClipOval(
//                           child: Image.asset(
//                             'assets/ic_launcher.png',
//                             fit: BoxFit.contain,
//                           ),
//                         ),
//                       ),
//                     ),

//                     SizedBox(height: isSmallScreen ? 16 : 24),

//                     // Headline
//                     const Center(
//                       child: Text(
//                         'Welcome Back',
//                         style: TextStyle(
//                           fontSize: 28,
//                           fontWeight: FontWeight.w800,
//                           color: Colors.black87,
//                           letterSpacing: -0.5,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     const Center(
//                       child: Text(
//                         'Sign in to your vendor account',
//                         style: TextStyle(
//                           fontSize: 15,
//                           color: Colors.black45,
//                           height: 1.4,
//                         ),
//                       ),
//                     ),

//                     SizedBox(height: isSmallScreen ? 24 : 32),

//                     // Login Card
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.05),
//                             blurRadius: 20,
//                             offset: const Offset(0, 8),
//                           ),
//                         ],
//                       ),
//                       padding: const EdgeInsets.all(24),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Mobile field
//                           const Text(
//                             'MOBILE NUMBER',
//                             style: TextStyle(
//                               fontSize: 11,
//                               fontWeight: FontWeight.w700,
//                               color: Colors.black45,
//                               letterSpacing: 0.8,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           TextField(
//                             controller: _mobileController,
//                             keyboardType: TextInputType.phone,
//                             maxLength: 10, // Limit to 10 characters
//                             style: const TextStyle(
//                               fontSize: 15,
//                               color: Colors.black87,
//                             ),
//                             onChanged: _validateMobileNumber,
//                             decoration: InputDecoration(
//                               hintText: 'Enter 10 digit mobile number',
//                               hintStyle: const TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.black26,
//                               ),
//                               counterText: '', // Hide counter text
//                               errorText: _mobileError.isNotEmpty
//                                   ? _mobileError
//                                   : null,
//                               errorStyle: const TextStyle(
//                                 fontSize: 11,
//                                 color: _errorRed,
//                               ),
//                               prefixIcon: const Padding(
//                                 padding: EdgeInsets.only(left: 12, right: 8),
//                                 child: Icon(
//                                   Icons.phone_outlined,
//                                   size: 18,
//                                   color: Colors.black38,
//                                 ),
//                               ),
//                               prefixIconConstraints: const BoxConstraints(
//                                 minWidth: 0,
//                                 minHeight: 0,
//                               ),
//                               contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 12,
//                                 vertical: 13,
//                               ),
//                               filled: true,
//                               fillColor: const Color(0xFFF7F7F5),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: const BorderSide(
//                                   color: Colors.black12,
//                                   width: 0.5,
//                                 ),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: const BorderSide(
//                                   color: Colors.black12,
//                                   width: 0.5,
//                                 ),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: BorderSide(
//                                   color: _brand,
//                                   width: 1.5,
//                                 ),
//                               ),
//                             ),
//                             inputFormatters: [
//                               FilteringTextInputFormatter
//                                   .digitsOnly, // Only allow digits
//                             ],
//                           ),

//                           const SizedBox(height: 16),

//                           // Password field
//                           const Text(
//                             'PASSWORD',
//                             style: TextStyle(
//                               fontSize: 11,
//                               fontWeight: FontWeight.w700,
//                               color: Colors.black45,
//                               letterSpacing: 0.8,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           TextField(
//                             controller: _passwordController,
//                             obscureText: _obscurePassword,
//                             style: const TextStyle(
//                               fontSize: 15,
//                               color: Colors.black87,
//                             ),
//                             onSubmitted: (_) => _handleLogin(),
//                             decoration: InputDecoration(
//                               hintText: 'Enter your password',
//                               hintStyle: const TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.black26,
//                               ),
//                               prefixIcon: const Padding(
//                                 padding: EdgeInsets.only(left: 12, right: 8),
//                                 child: Icon(
//                                   Icons.lock_outline_rounded,
//                                   size: 18,
//                                   color: Colors.black38,
//                                 ),
//                               ),
//                               prefixIconConstraints: const BoxConstraints(
//                                 minWidth: 0,
//                                 minHeight: 0,
//                               ),
//                               suffixIcon: GestureDetector(
//                                 onTap: () => setState(
//                                   () => _obscurePassword = !_obscurePassword,
//                                 ),
//                                 child: Padding(
//                                   padding: const EdgeInsets.only(right: 12),
//                                   child: Icon(
//                                     _obscurePassword
//                                         ? Icons.visibility_off_outlined
//                                         : Icons.visibility_outlined,
//                                     size: 18,
//                                     color: Colors.black38,
//                                   ),
//                                 ),
//                               ),
//                               suffixIconConstraints: const BoxConstraints(
//                                 minWidth: 0,
//                                 minHeight: 0,
//                               ),
//                               contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 12,
//                                 vertical: 13,
//                               ),
//                               filled: true,
//                               fillColor: const Color(0xFFF7F7F5),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: const BorderSide(
//                                   color: Colors.black12,
//                                   width: 0.5,
//                                 ),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: const BorderSide(
//                                   color: Colors.black12,
//                                   width: 0.5,
//                                 ),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: BorderSide(
//                                   color: _brand,
//                                   width: 1.5,
//                                 ),
//                               ),
//                             ),
//                           ),

//                           const SizedBox(height: 24),

//                           // Login button
//                           SizedBox(
//                             width: double.infinity,
//                             height: 50,
//                             child: provider.isLoading
//                                 ? const Center(
//                                     child: CircularProgressIndicator(
//                                       color: _brand,
//                                       strokeWidth: 2.5,
//                                     ),
//                                   )
//                                 : ElevatedButton(
//                                     onPressed: _handleLogin,
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: _brand,
//                                       foregroundColor: Colors.white,
//                                       elevation: 0,
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                     ),
//                                     child: const Text(
//                                       'Sign In',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 24),

//                     // Divider
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Divider(
//                             color: Colors.black.withOpacity(0.1),
//                             thickness: 0.5,
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 12),
//                           child: Text(
//                             'New to Varahi?',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.black38,
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           child: Divider(
//                             color: Colors.black.withOpacity(0.1),
//                             thickness: 0.5,
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 16),

//                     // Register button
//                     SizedBox(
//                       width: double.infinity,
//                       height: 48,
//                       child: OutlinedButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => const SignupScreen(),
//                             ),
//                           );
//                         },
//                         style: OutlinedButton.styleFrom(
//                           foregroundColor: _brandDark,
//                           side: BorderSide(
//                             color: _brand.withOpacity(0.4),
//                             width: 0.8,
//                           ),
//                           backgroundColor: _brandLight.withOpacity(0.5),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: const Text(
//                           'Register as Vendor',
//                           style: TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 24),

//                     // Help Section
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.03),
//                             blurRadius: 10,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         children: [
//                           // Vehicle Verification
//                           Material(
//                             color: Colors.transparent,
//                             child: InkWell(
//                               onTap: () => _launchURL(
//                                 'https://varahiselfdrivecars.com/owner/vehicle-verification',
//                               ),
//                               borderRadius: BorderRadius.circular(12),
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 12,
//                                   horizontal: 8,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     Container(
//                                       padding: const EdgeInsets.all(10),
//                                       decoration: BoxDecoration(
//                                         color: _brandLight,
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       child: Icon(
//                                         Icons.verified_outlined,
//                                         color: _brand,
//                                         size: 22,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 14),
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             'Vehicle Verification',
//                                             style: TextStyle(
//                                               fontSize: 15,
//                                               fontWeight: FontWeight.w700,
//                                               color: Colors.black87,
//                                             ),
//                                           ),
//                                           const SizedBox(height: 2),
//                                           Text(
//                                             'Vehicle verification details',
//                                             style: TextStyle(
//                                               fontSize: 12,
//                                               color: Colors.black45,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     Icon(
//                                       Icons.arrow_forward_ios,
//                                       size: 14,
//                                       color: Colors.black38,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),

//                           const Divider(height: 8, thickness: 0.5),

//                           // Support
//                           Material(
//                             color: Colors.transparent,
//                             child: InkWell(
//                               onTap: () => _launchURL(
//                                 'https://varahiselfdrivecars.com/owner/support',
//                               ),
//                               borderRadius: BorderRadius.circular(12),
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 12,
//                                   horizontal: 8,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     Container(
//                                       padding: const EdgeInsets.all(10),
//                                       decoration: BoxDecoration(
//                                         color: _brandLight,
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       child: Icon(
//                                         Icons.support_agent_outlined,
//                                         color: _brand,
//                                         size: 22,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 14),
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             'Support Center',
//                                             style: TextStyle(
//                                               fontSize: 15,
//                                               fontWeight: FontWeight.w700,
//                                               color: Colors.black87,
//                                             ),
//                                           ),
//                                           const SizedBox(height: 2),
//                                           Text(
//                                             'Get help and support',
//                                             style: TextStyle(
//                                               fontSize: 12,
//                                               color: Colors.black45,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     Icon(
//                                       Icons.arrow_forward_ios,
//                                       size: 14,
//                                       color: Colors.black38,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 24),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:varahiowner/helpers/toast_helper.dart';
import 'package:varahiowner/helpers/shared_pref_helper.dart';
import 'package:varahiowner/providers/auth_provider.dart';
import 'package:varahiowner/views/navbar_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _mobileError = '';

  static const _brand = Color(0xFF1D9E75);
  static const _brandLight = Color(0xFFE1F5EE);
  static const _brandDark = Color(0xFF0F6E56);
  static const _errorRed = Color(0xFFE53935);

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ToastHelper.showError(context, 'Could not launch URL');
      }
    } catch (e) {
      ToastHelper.showError(context, 'Error: $e');
    }
  }

  // Mobile number validation
  void _validateMobileNumber(String value) {
    setState(() {
      if (value.isEmpty) {
        _mobileError = '';
      } else if (value.length != 10) {
        _mobileError = 'Mobile number must be exactly 10 digits';
      } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
        _mobileError = 'Please enter valid numbers only';
      } else {
        _mobileError = '';
      }
    });
  }

  Future<void> _handleLogin() async {
    final mobile = _mobileController.text.trim();
    final password = _passwordController.text.trim();

    // Validate mobile number
    if (mobile.isEmpty) {
      ToastHelper.showError(context, 'Please enter mobile number');
      return;
    }

    if (mobile.length != 10) {
      ToastHelper.showError(context, 'Mobile number must be exactly 10 digits');
      return;
    }

    if (!RegExp(r'^[0-9]{10}$').hasMatch(mobile)) {
      ToastHelper.showError(context, 'Please enter valid numbers only');
      return;
    }

    if (password.isEmpty) {
      ToastHelper.showError(context, 'Please enter your password');
      return;
    }

    final provider = Provider.of<AuthProvider>(context, listen: false);
    final success = await provider.login(mobile, password);

    if (success) {
      ToastHelper.showSuccess(context, 'Login successful!');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
      }
    } else {
      ToastHelper.showError(context, provider.errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F5),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo
                    Center(
                      child: Container(
                        width: isSmallScreen ? 70 : 90,
                        height: isSmallScreen ? 70 : 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _brand.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/ic_launcher.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: isSmallScreen ? 16 : 24),

                    // Headline
                    const Center(
                      child: Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Sign in to your vendor account',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black45,
                          height: 1.4,
                        ),
                      ),
                    ),

                    SizedBox(height: isSmallScreen ? 24 : 32),

                    // Login Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Mobile field
                          const Text(
                            'MOBILE NUMBER',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.black45,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _mobileController,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                            onChanged: _validateMobileNumber,
                            decoration: InputDecoration(
                              hintText: 'Enter 10 digit mobile number',
                              hintStyle: const TextStyle(
                                fontSize: 14,
                                color: Colors.black26,
                              ),
                              counterText: '',
                              errorText: _mobileError.isNotEmpty
                                  ? _mobileError
                                  : null,
                              errorStyle: const TextStyle(
                                fontSize: 11,
                                color: _errorRed,
                              ),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(left: 12, right: 8),
                                child: Icon(
                                  Icons.phone_outlined,
                                  size: 18,
                                  color: Colors.black38,
                                ),
                              ),
                              prefixIconConstraints: const BoxConstraints(
                                minWidth: 0,
                                minHeight: 0,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 13,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF7F7F5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.black12,
                                  width: 0.5,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.black12,
                                  width: 0.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _brand,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Password field
                          const Text(
                            'PASSWORD',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.black45,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                            onSubmitted: (_) => _handleLogin(),
                            decoration: InputDecoration(
                              hintText: 'Enter your password',
                              hintStyle: const TextStyle(
                                fontSize: 14,
                                color: Colors.black26,
                              ),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(left: 12, right: 8),
                                child: Icon(
                                  Icons.lock_outline_rounded,
                                  size: 18,
                                  color: Colors.black38,
                                ),
                              ),
                              prefixIconConstraints: const BoxConstraints(
                                minWidth: 0,
                                minHeight: 0,
                              ),
                              suffixIcon: GestureDetector(
                                onTap: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 18,
                                    color: Colors.black38,
                                  ),
                                ),
                              ),
                              suffixIconConstraints: const BoxConstraints(
                                minWidth: 0,
                                minHeight: 0,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 13,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF7F7F5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.black12,
                                  width: 0.5,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.black12,
                                  width: 0.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _brand,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),

                          // Forgot Password Button
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: _brand,
                                  decoration: TextDecoration.underline,
                                  decorationColor: _brand,
                                  decorationThickness: 1,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Login button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: provider.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: _brand,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed: _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _brand,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.black.withOpacity(0.1),
                            thickness: 0.5,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'New to Varahi?',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black38,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.black.withOpacity(0.1),
                            thickness: 0.5,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Register button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignupScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _brandDark,
                          side: BorderSide(
                            color: _brand.withOpacity(0.4),
                            width: 0.8,
                          ),
                          backgroundColor: _brandLight.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Register as Vendor',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Help Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Vehicle Verification
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _launchURL(
                                'https://varahiselfdrivecars.com/owner/vehicle-verification',
                              ),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: _brandLight,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.verified_outlined,
                                        color: _brand,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Vehicle Verification',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Vehicle verification details',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black45,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 14,
                                      color: Colors.black38,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const Divider(height: 8, thickness: 0.5),

                          // Support
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _launchURL(
                                'https://varahiselfdrivecars.com/owner/support',
                              ),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: _brandLight,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.support_agent_outlined,
                                        color: _brand,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Support Center',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Get help and support',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black45,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 14,
                                      color: Colors.black38,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
