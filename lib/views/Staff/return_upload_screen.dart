import 'dart:ui';
import 'dart:io';
import 'package:varahiowner/model/Staff/models/single_booking_model.dart';
import 'package:varahiowner/providers/Staff/providers/single_booking_provider.dart';
import 'package:varahiowner/views/navbar_screen.dart';
import 'package:varahiowner/widgect/delay.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';

// Define the mandatory return image categories with custom names
enum ReturnImageCategory {
  frontView('Front View'),
  backView('Back View'),
  rightSideView('Right Side View'),
  leftSideView('Left Side View'),
  stphniView('Stphni View'),
  speedometerView('Speedometer View'),
  bonetView('Bonet View'),
  frontMirrorView('Front Mirror View');

  const ReturnImageCategory(this.displayName);
  final String displayName;
}

class ReturnUploadScreen extends StatefulWidget {
  final String id;

  const ReturnUploadScreen({super.key, required this.id});

  @override
  State<ReturnUploadScreen> createState() => _ReturnUploadScreenState();
}

class _ReturnUploadScreenState extends State<ReturnUploadScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  bool showOtpOverlay = false;
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

  // Image picker and captured images for return upload
  final ImagePicker _picker = ImagePicker();
  Map<ReturnImageCategory, File?> _capturedReturnImages = {};
  Map<ReturnImageCategory, String?> _uploadedReturnImages =
      {}; // Store uploaded image URLs
  bool _isUploading = false;
  bool _returnImagesAlreadyUploaded = false;
  DateTime? returnDate;
  TimeOfDay? returnTime;
  bool hasReturnDetails = false;

  @override
  void initState() {
    super.initState();
    // Initialize all categories with null values
    for (ReturnImageCategory category in ReturnImageCategory.values) {
      _capturedReturnImages[category] = null;
      _uploadedReturnImages[category] = null;
    }

    // Fetch booking data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SingleBookingProvider>().fetchSingleBooking(widget.id);
      _checkUploadedReturnImages();
    });
  }

  // Check if return images are already uploaded from the booking data
  void _checkUploadedReturnImages() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingProvider = context.read<SingleBookingProvider>();
      final booking = bookingProvider.currentBooking;

      if (booking?.carReturnImages != null &&
          booking!.carReturnImages!.isNotEmpty) {
        setState(() {
          _returnImagesAlreadyUploaded = true;

          // Map uploaded images to categories in order
          for (
            int i = 0;
            i < ReturnImageCategory.values.length &&
                i < booking.carReturnImages!.length;
            i++
          ) {
            _uploadedReturnImages[ReturnImageCategory.values[i]] =
                booking.carReturnImages![i].url;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  // Add these variables to your ReturnUploadScreen state

  // Add this method to parse return date and time from booking
  void _parseReturnDateTime(Booking? booking) {
    if (booking != null) {
      // Parse return date
      if (booking.rentalEndDate != null) {
        try {
          final dateParts = booking.rentalEndDate!.split('-');
          if (dateParts.length == 3) {
            returnDate = DateTime(
              int.parse(dateParts[0]),
              int.parse(dateParts[1]),
              int.parse(dateParts[2]),
            );
          }
        } catch (e) {
          print('Error parsing return date: $e');
        }
      }

      // Parse return time
      if (booking.to != null) {
        try {
          final timeStr = booking.to!.replaceAll(RegExp(r'[AP]M'), '').trim();
          final timeParts = timeStr.split(':');
          if (timeParts.length == 2) {
            int hour = int.parse(timeParts[0]);
            int minute = int.parse(timeParts[1]);

            if (booking.to!.contains('PM') && hour != 12) {
              hour += 12;
            } else if (booking.to!.contains('AM') && hour == 12) {
              hour = 0;
            }

            returnTime = TimeOfDay(hour: hour, minute: minute);
          }
        } catch (e) {
          print('Error parsing return time: $e');
        }
      }

      // Check if return details exist
      hasReturnDetails = booking.returnDetails.isNotEmpty;
    }
  }

  // Call this method when you get booking data
  // In your Consumer builder, after getting booking data:

  // Function to check if all mandatory return images are captured or already uploaded
  bool get _allReturnImagesUploaded {
    if (_returnImagesAlreadyUploaded) {
      return _uploadedReturnImages.values.every(
        (image) => image != null && image.isNotEmpty,
      );
    }
    return _capturedReturnImages.values.every((image) => image != null);
  }

  // Show full screen image with zoom capability for pickup images
  void _showPickupImageFullScreen(String imageUrl, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImageFullScreenViewer(
          imageProvider: NetworkImage(imageUrl),
          title: title,
        ),
      ),
    );
  }

  // Show full screen image with zoom capability for return images
  void _showReturnImageFullScreen({
    File? imageFile,
    String? imageUrl,
    required String title,
  }) {
    ImageProvider? imageProvider;

    if (imageFile != null) {
      imageProvider = FileImage(imageFile);
    } else if (imageUrl != null && imageUrl.isNotEmpty) {
      imageProvider = NetworkImage(imageUrl);
    }

    if (imageProvider == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            ImageFullScreenViewer(imageProvider: imageProvider!, title: title),
      ),
    );
  }

  // Show instructions modal for return images
  void _showReturnInstructionsModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF120698),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Photography Instructions',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildReturnInstructionItem(
                        'Front View',
                        'Take a clear photo of the entire front of the car showing its condition at return. Include any new damage or wear.',
                        Icons.car_rental,
                      ),
                      _buildReturnInstructionItem(
                        'Back View',
                        'Capture the entire rear of the car including taillights, bumper, and license plate. Document any damage.',
                        Icons.directions_car,
                      ),
                      _buildReturnInstructionItem(
                        'Right Side View',
                        'Take photos of the right side of the car showing doors, windows, and any side damage.',
                        Icons.airline_seat_recline_normal,
                      ),
                      _buildReturnInstructionItem(
                        'Left Side View',
                        'Take photos of the left side of the car showing doors, windows, and any side damage.',
                        Icons.airline_seat_recline_normal,
                      ),
                      _buildReturnInstructionItem(
                        'Stphni View',
                        'Capture specific angle view as per company requirements.',
                        Icons.camera_alt,
                      ),
                      _buildReturnInstructionItem(
                        'Speedometer View',
                        'Capture the dashboard showing final mileage, fuel level, and any warning lights.',
                        Icons.speed,
                      ),
                      _buildReturnInstructionItem(
                        'Bonet View',
                        'Take a clear photo of the car bonnet/hood area showing its condition.',
                        Icons.car_repair,
                      ),
                      _buildReturnInstructionItem(
                        'Front Mirror View',
                        'Capture the front mirror and surrounding area for documentation.',
                        Icons.visibility,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.warning, color: Colors.red),
                                SizedBox(width: 5),
                                Text(
                                  'Return Documentation Tips:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text('• Document any new damage clearly'),
                            Text('• Record final mileage and fuel level'),
                            Text('• Show interior cleanliness'),
                            Text('• Capture all required angles'),
                            Text('• Ensure good lighting for evidence'),
                            Text('• All return categories are mandatory'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReturnInstructionItem(
    String title,
    String description,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF120698).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF120698), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Function to take photo for specific return category (only if images not already uploaded)
  Future<void> _takeReturnPhoto(ReturnImageCategory category) async {
    if (_returnImagesAlreadyUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Return images are already uploaded and cannot be modified',
          ),
        ),
      );
      return;
    }

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 80,
      );

      if (photo != null) {
        setState(() {
          _capturedReturnImages[category] = File(photo.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error taking photo: $e')));
    }
  }

  // Function to pick image from gallery for specific return category
  Future<void> _pickReturnImage(ReturnImageCategory category) async {
    if (_returnImagesAlreadyUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Return images are already uploaded and cannot be modified',
          ),
        ),
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _capturedReturnImages[category] = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  // Function to delete return image for specific category (only if images not already uploaded)
  void _deleteReturnImage(ReturnImageCategory category) {
    if (_returnImagesAlreadyUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Return images are already uploaded and cannot be modified',
          ),
        ),
      );
      return;
    }

    setState(() {
      _capturedReturnImages[category] = null;
    });
  }

  // Function to upload return images to API (only if not already uploaded)
  Future<bool> _uploadReturnImages() async {
    if (_returnImagesAlreadyUploaded) {
      // Images are already uploaded, no need to upload again
      return true;
    }

    if (!_allReturnImagesUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please capture all mandatory return images'),
        ),
      );
      return false;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      print("pppppppppppppppppppppppppppppppppppppppppppppppp${widget.id}");
      var uri = Uri.parse(
        'https://varahibackend.varahiselfdrivecars.com/api/staff/carreturnimages/${widget.id}',
      );
      var request = http.MultipartRequest('POST', uri);

      // Add all captured return images to the request with category names in order
      for (var category in ReturnImageCategory.values) {
        if (_capturedReturnImages[category] != null) {
          var multipartFile = await http.MultipartFile.fromPath(
            'carReturnImages',
            _capturedReturnImages[category]!.path,
            filename:
                '${category.name}_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
          request.files.add(multipartFile);
        }
      }

      // Add headers if needed
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        // Add authorization header if needed
        // 'Authorization': 'Bearer $token',
      });

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print('llllllllllllllllllllllllllllllllllll$responseBody');

      setState(() {
        _isUploading = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Return images uploaded successfully')),
        );

        // Mark images as uploaded
        setState(() {
          _returnImagesAlreadyUploaded = true;
          // Convert captured images to uploaded images
          for (var category in ReturnImageCategory.values) {
            if (_capturedReturnImages[category] != null) {
              _uploadedReturnImages[category] = _capturedReturnImages[category]!
                  .path; // This would be replaced with actual server URL
            }
          }
        });

        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to upload images. Status: ${response.statusCode}',
            ),
          ),
        );
        return false;
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error uploading images: $e')));
      return false;
    }
  }

  void _showOtpVerification() async {
    // First upload images, then show OTP dialog
    bool uploadSuccess = await _uploadReturnImages();
    if (uploadSuccess) {
      setState(() {
        showOtpOverlay = true;
      });
    }
  }

  Future<void> _verifyOtp() async {
    String enteredOtp = _otpControllers
        .map((controller) => controller.text)
        .join();

    // Validate OTP length
    if (enteredOtp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a 4-digit OTP')),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      if (enteredOtp is String) {
        print('OTP is a String: $enteredOtp');
      }

      if (enteredOtp is int) {
        print('OTP is an Integer: $enteredOtp');
      } else {
        print('OTP is not an Integer');
      }
      print('Return otp timing checking start');

      // Make API call to verify return OTP
      final response = await http.post(
        Uri.parse(
          'https://varahibackend.varahiselfdrivecars.com/api/staff/verify-return-otp/${widget.id}',
        ),
        headers: {
          'Content-Type': 'application/json',
          // Add authorization header if needed
          // 'Authorization': 'Bearer $token',
        },
        body: json.encode({'returnOTP': enteredOtp}),
      );
      print('Return otp timing checking start 1');

      Navigator.pop(context); // Close loading dialog
      print('Return OTP verification status: ${response.body}');
      print('Return otp timing checking start 2');

      if (response.statusCode == 200) {
        print('Return otp timing checking start 3');

        // OTP verification successful
        final responseData = json.decode(response.body);
        print('Return OTP verification successful: $responseData');

        String? depositPdfPath = responseData['depositPDF'];
        if (depositPdfPath != null) {
          String fullPdfUrl =
              'https://varahibackend.varahiselfdrivecars.com$depositPdfPath';
          print('PDF URL: $fullPdfUrl');

          // Download PDF before navigation
          await _downloadPdfToDownloads(fullPdfUrl, widget.id);
        }

        print('Return otp timing checking start 4');

        setState(() {
          showOtpOverlay = false;
        });

        // Navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainShell()),
        );
      } else if (response.statusCode == 400) {
        // Invalid OTP
        final errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorData['message'] ?? 'Invalid OTP')),
        );
      } else if (response.statusCode == 404) {
        // Booking not found
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Booking not found')));
      } else {
        // Other errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Verification failed. Status code: ${response.statusCode}',
            ),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      print('Return OTP verification error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: $e')));
    }
  }

  // Widget to display return image category card
  Widget _buildReturnImageCategoryCard(ReturnImageCategory category) {
    final isCaptured = _capturedReturnImages[category] != null;
    final isUploaded = _uploadedReturnImages[category] != null;
    final hasImage = isCaptured || isUploaded;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasImage
              ? (isUploaded ? Colors.blue : Colors.green)
              : Colors.grey.shade300,
          width: hasImage ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category title with status
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: hasImage
                  ? (isUploaded ? Colors.blue.shade50 : Colors.green.shade50)
                  : Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isUploaded
                      ? Icons.cloud_done
                      : hasImage
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isUploaded
                      ? Colors.blue
                      : hasImage
                      ? Colors.green
                      : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.displayName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isUploaded
                              ? Colors.blue.shade700
                              : hasImage
                              ? Colors.green.shade700
                              : Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                      if (isUploaded)
                        Text(
                          'Already uploaded',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
                if (isCaptured && !isUploaded)
                  TextButton(
                    onPressed: () => _deleteReturnImage(category),
                    child: const Text('Retake', style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
          ),
          // Image area with camera and gallery options
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Stack(
              children: [
                // Display uploaded image from server
                if (isUploaded && _uploadedReturnImages[category] != null)
                  GestureDetector(
                    onTap: () => _showReturnImageFullScreen(
                      imageUrl:
                          _uploadedReturnImages[category]!.startsWith('http')
                          ? _uploadedReturnImages[category]
                          : null,
                      imageFile:
                          !_uploadedReturnImages[category]!.startsWith('http')
                          ? File(_uploadedReturnImages[category]!)
                          : null,
                      title: category.displayName,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        image: DecorationImage(
                          image:
                              _uploadedReturnImages[category]!.startsWith(
                                'http',
                              )
                              ? NetworkImage(_uploadedReturnImages[category]!)
                              : FileImage(
                                      File(_uploadedReturnImages[category]!),
                                    )
                                    as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: const Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.fullscreen,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                // Display captured image (local file)
                else if (isCaptured && _capturedReturnImages[category] != null)
                  GestureDetector(
                    onTap: () => _showReturnImageFullScreen(
                      imageFile: _capturedReturnImages[category],
                      title: category.displayName,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        image: DecorationImage(
                          image: FileImage(_capturedReturnImages[category]!),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: const Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.fullscreen,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                // Show placeholder with camera and gallery options
                else
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _returnImagesAlreadyUploaded
                              ? null
                              : () => _takeReturnPhoto(category),
                          child: Container(
                            height: 150,
                            decoration: BoxDecoration(
                              color: _returnImagesAlreadyUploaded
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade200,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _returnImagesAlreadyUploaded
                                      ? Icons.lock
                                      : Icons.camera_alt,
                                  size: 30,
                                  color: _returnImagesAlreadyUploaded
                                      ? Colors.grey.shade500
                                      : Colors.grey.shade600,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _returnImagesAlreadyUploaded
                                      ? 'Locked'
                                      : 'Camera',
                                  style: TextStyle(
                                    color: _returnImagesAlreadyUploaded
                                        ? Colors.grey.shade500
                                        : Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 150,
                        color: Colors.grey.shade400,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: _returnImagesAlreadyUploaded
                              ? null
                              : () => _pickReturnImage(category),
                          child: Container(
                            height: 150,
                            decoration: BoxDecoration(
                              color: _returnImagesAlreadyUploaded
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade200,
                              borderRadius: const BorderRadius.only(
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _returnImagesAlreadyUploaded
                                      ? Icons.lock
                                      : Icons.file_upload_outlined,
                                  size: 30,
                                  color: _returnImagesAlreadyUploaded
                                      ? Colors.grey.shade500
                                      : Colors.grey.shade600,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _returnImagesAlreadyUploaded
                                      ? 'Locked'
                                      : 'Gallery',
                                  style: TextStyle(
                                    color: _returnImagesAlreadyUploaded
                                        ? Colors.grey.shade500
                                        : Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                // Show overlay for uploaded images to indicate they're not editable
                if (isUploaded)
                  Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      color: Colors.transparent,
                    ),
                    child: const Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.lock, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Function to download PDF and save to public Downloads folder
  Future<void> _downloadPdfToDownloads(String pdfUrl, String bookingId) async {
    try {
      // Request storage permission
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission denied. Cannot download PDF.'),
          ),
        );
        return;
      }

      // Create Dio instance for downloading
      Dio dio = Dio();

      String fileName =
          'deposit_receipt_${bookingId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      String filePath;

      if (Platform.isAndroid) {
        // For Android - save to public Downloads directory
        filePath = '/storage/emulated/0/Download/$fileName';

        // Alternative paths to try if the first one fails
        List<String> possiblePaths = [
          '/storage/emulated/0/Download/$fileName',
          '/sdcard/Download/$fileName',
          '/storage/sdcard0/Download/$fileName',
        ];

        // Try to create the Downloads directory if it doesn't exist
        for (String path in possiblePaths) {
          try {
            Directory downloadsDir = Directory(
              path.substring(0, path.lastIndexOf('/')),
            );
            if (!await downloadsDir.exists()) {
              await downloadsDir.create(recursive: true);
            }
            filePath = path;
            break;
          } catch (e) {
            print('Failed to create directory for path: $path');
            continue;
          }
        }
      } else if (Platform.isIOS) {
        // For iOS, save to app documents directory (iOS doesn't have a public Downloads folder)
        Directory appDocDir = await getApplicationDocumentsDirectory();
        filePath = '${appDocDir.path}/$fileName';
      } else {
        throw Exception('Unsupported platform');
      }

      print('Attempting to save PDF to: $filePath');

      // Show downloading progress
      // _showDownloadProgress();

      // Download the file
      // await dio.download(
      //   pdfUrl,
      //   filePath,
      //   options: Options(
      //     receiveTimeout: const Duration(minutes: 5),
      //     sendTimeout: const Duration(minutes: 5),
      //     headers: {
      //       'Accept': 'application/pdf',
      //       'User-Agent': 'Mozilla/5.0 (Android; Mobile)',
      //     },
      //   ),
      //   onReceiveProgress: (received, total) {
      //     if (total != -1) {
      //       double progress = received / total;
      //       print('Download progress: ${(progress * 100).toStringAsFixed(0)}%');
      //     }
      //   },
      // );

      // Hide download progress
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Verify the file was downloaded successfully
      // File downloadedFile = File(filePath);
      // bool fileExists = await downloadedFile.exists();

      // if (!fileExists) {
      //   throw Exception('File was not created at expected location');
      // }

      // int fileSize = await downloadedFile.length();
      // if (fileSize == 0) {
      //   throw Exception('Downloaded file is empty');
      // }

      // print('File downloaded successfully: $filePath (Size: $fileSize bytes)');

      // // For Android, add the file to MediaStore so it appears in file managers
      // if (Platform.isAndroid) {
      //   await _addToMediaStore(filePath, fileName);
      // }

      // // Show success message
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('PDF saved to Downloads'),
      //     duration: const Duration(seconds: 6),
      //     action: SnackBarAction(
      //       label: 'Show Location',
      //       onPressed: () => _showFileLocation(fileName),
      //     ),
      //   ),
      // );
    } catch (e) {
      // Hide download progress if showing
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      print('Error downloading PDF: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: ${e.toString()}'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => _downloadPdfToDownloads(pdfUrl, bookingId),
          ),
        ),
      );
    }
  }

  // Show file location instead of trying to open
  void _showFileLocation(String fileName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PDF Downloaded'),
        content: Text(
          'Your receipt has been saved to:\n\n'
          'Downloads > $fileName\n\n'
          'You can find it in your phone\'s Downloads folder using any file manager app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Add file to Android MediaStore so it appears in file managers
  Future<void> _addToMediaStore(String filePath, String fileName) async {
    try {
      if (Platform.isAndroid) {
        // Use method channel to add file to MediaStore
        const platform = MethodChannel('file_operations');
        await platform.invokeMethod('addToMediaStore', {
          'filePath': filePath,
          'fileName': fileName,
          'mimeType': 'application/pdf',
        });
      }
    } catch (e) {
      print('Error adding to MediaStore: $e');
      // This is not critical, file should still be accessible
    }
  }

  // Improved permission handling for different Android versions
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      int sdkInt = androidInfo.version.sdkInt;

      print('Android SDK version: $sdkInt');

      if (sdkInt >= 33) {
        // Android 13+ (API 33+) - Scoped storage, no special permission needed for Downloads
        return true;
      } else if (sdkInt >= 30) {
        // Android 11-12 (API 30-32) - Need MANAGE_EXTERNAL_STORAGE
        var status = await Permission.manageExternalStorage.status;
        if (status.isDenied) {
          status = await Permission.manageExternalStorage.request();
        }

        if (status.isDenied) {
          // Fallback to regular storage permission
          var storageStatus = await Permission.storage.request();
          return storageStatus.isGranted;
        }
        return status.isGranted;
      } else {
        // Android 10 and below - Use regular storage permission
        var status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    return true; // iOS or other platforms
  }

  void _showDownloadProgress() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Downloading PDF...'),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<SingleBookingProvider>(
        builder: (context, bookingProvider, child) {
          // Show loading indicator
          if (bookingProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show error message
          if (bookingProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${bookingProvider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      bookingProvider.fetchSingleBooking(widget.id);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final booking = bookingProvider.currentBooking;

          if (booking != null) {
            _parseReturnDateTime(booking);
          }

          return Stack(
            children: [
              // Main Content
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: Colors.black,
                                  size: screenWidth * 0.06,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.25),
                            Text(
                              "id: #${booking?.id != null ? booking!.id.substring(booking!.id.length - 4) : widget.id.substring(widget.id.length - 4)}",
                              style: TextStyle(
                                color: const Color.fromARGB(255, 255, 0, 0),
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Car Details Card
                      _buildCarDetailsCard(booking, screenWidth),

                      const SizedBox(height: 30),
                      const SizedBox(height: 10),
                      const Text(
                        'Pickup Photos',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Display pickup photos from booking data
                      _buildPickupPhotosGrid(booking),

                      const SizedBox(height: 30),

                      // Header with instructions button for return images
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Return Images',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _showReturnInstructionsModal,
                            icon: const Icon(Icons.help_outline, size: 18),
                            label: const Text('Instructions'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF120698),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Progress indicator for return images
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _returnImagesAlreadyUploaded
                              ? Colors.green.shade50
                              : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _returnImagesAlreadyUploaded
                                ? Colors.green.shade200
                                : Colors.blue.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _returnImagesAlreadyUploaded
                                  ? Icons.cloud_done
                                  : _allReturnImagesUploaded
                                  ? Icons.check_circle
                                  : Icons.camera_alt,
                              color: _returnImagesAlreadyUploaded
                                  ? Colors.green
                                  : _allReturnImagesUploaded
                                  ? Colors.green
                                  : Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _returnImagesAlreadyUploaded
                                    ? 'Return images already uploaded! Ready to proceed.'
                                    : _allReturnImagesUploaded
                                    ? 'All return images captured! Ready to proceed.'
                                    : 'Progress: ${_capturedReturnImages.values.where((img) => img != null).length}/${ReturnImageCategory.values.length} return images captured',
                                style: TextStyle(
                                  color: _returnImagesAlreadyUploaded
                                      ? Colors.green.shade700
                                      : _allReturnImagesUploaded
                                      ? Colors.green.shade700
                                      : Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Return image capture cards for each category
                      ...ReturnImageCategory.values.map((category) {
                        return Column(
                          children: [
                            _buildReturnImageCategoryCard(category),
                            const SizedBox(height: 15),
                          ],
                        );
                      }).toList(),

                      const SizedBox(height: 25),

                      DelayHandlingSection(
                        bookingId: widget.id,
                        delayPerHour: booking?.car?.delayPerHour,
                        delayPerDay: booking?.car?.delayPerDay,
                        returnDate: returnDate,
                        returnTime: returnTime,
                        hasReturnDetails: false,
                      ),

                      const SizedBox(height: 25),

                      // Next button - only enabled when all return images are captured or already uploaded
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (_isUploading || !_allReturnImagesUploaded)
                              ? null
                              : _showOtpVerification,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _allReturnImagesUploaded
                                ? const Color(0xFF120698)
                                : Colors.grey.shade400,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isUploading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  _returnImagesAlreadyUploaded
                                      ? 'Proceed to OTP Verification'
                                      : _allReturnImagesUploaded
                                      ? 'Proceed'
                                      : 'Capture All Return Images First',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // OTP Verification Overlay
              if (showOtpOverlay)
                buildOtpVerificationDialog(
                  context,
                  _otpControllers,
                  _focusNodes,
                  _verifyOtp,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCarDetailsCard(booking, double screenWidth) {
    return Card(
      elevation: 1,
      color: const Color(0XFFFFFFFF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  booking?.car?.vehicleNumber ?? 'TS 05 TD 4544',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking?.car?.carName ?? 'Hyundai Verna',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Automatic & Seaters Row
            Row(
              children: [
                const Icon(Icons.settings, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  booking?.car?.type ?? 'Automatic',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.airline_seat_recline_normal,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${booking?.car?.seats ?? 5} Seaters',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Date & Time Row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                const SizedBox(width: 4),
                Text(
                  booking?.rentalEndDate ?? '23-03-2025',
                  style: const TextStyle(color: Colors.black87, fontSize: 13),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16, color: Colors.blue),
                const SizedBox(width: 4),
                Text(
                  booking?.to ?? '11:00 AM',
                  style: const TextStyle(color: Colors.black87, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickupPhotosGrid(booking) {
    final pickupImages = booking?.carImagesBeforePickup ?? [];

    if (pickupImages.isEmpty) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade200,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported,
                size: 50,
                color: Colors.grey.shade500,
              ),
              const SizedBox(height: 8),
              Text(
                'No pickup photos available',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: pickupImages.length,
      itemBuilder: (context, index) {
        final image = pickupImages[index];
        return GestureDetector(
          onTap: () => _showPickupImageFullScreen(
            image.url ?? '',
            'Pickup Photo ${index + 1}',
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade200,
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    image.url ?? '',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.error, size: 40),
                    ),
                  ),
                ),
                // Full screen view icon
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.fullscreen, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildOtpVerificationDialog(
    BuildContext context,
    List<TextEditingController> otpControllers,
    List<FocusNode> otpFocusNodes,
    VoidCallback onVerify,
  ) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10,
          sigmaY: 10,
        ), // increased blur for softer effect
        child: Container(
          color: Colors.black.withOpacity(0.3), // slightly darker shade
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15), // glass effect
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 25, // stronger blur on shadow
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Return otp verification',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          4,
                          (index) => Container(
                            width: 50,
                            height: 50,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: TextField(
                                controller: _otpControllers[index],
                                focusNode: _focusNodes[index],
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(1),
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (value) {
                                  if (value.isNotEmpty && index < 3) {
                                    otpFocusNodes[index].unfocus();
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(otpFocusNodes[index + 1]);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: onVerify,
                          style:
                              ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ).copyWith(
                                backgroundColor:
                                    MaterialStateProperty.resolveWith<Color>((
                                      Set<MaterialState> states,
                                    ) {
                                      return Colors.transparent;
                                    }),
                                shadowColor: MaterialStateProperty.all(
                                  Colors.transparent,
                                ),
                                elevation: MaterialStateProperty.all(0),
                              ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF003082), Color(0xFF0071BC)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: const Text(
                                'Verify',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Full screen image viewer with zoom capability
class ImageFullScreenViewer extends StatelessWidget {
  final ImageProvider imageProvider;
  final String title;

  const ImageFullScreenViewer({
    super.key,
    required this.imageProvider,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: PhotoView(
        imageProvider: imageProvider,
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 4.0,
        initialScale: PhotoViewComputedScale.contained,
        heroAttributes: PhotoViewHeroAttributes(tag: title),
        loadingBuilder: (context, event) =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 64),
              SizedBox(height: 16),
              Text(
                'Failed to load image',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
