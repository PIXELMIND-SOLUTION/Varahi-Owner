import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:photo_view/photo_view.dart';
import 'package:varahiowner/providers/Staff/providers/single_booking_provider.dart';
import 'package:varahiowner/views/Staff/all_bookings_screen.dart'; // Add this import

// Define the mandatory image categories
enum ImageCategory {
  frontMirror('Front View'),
  completeFront('Back View'),
  rightSideView('Right Side View'),
  backView('Left Side View'),
  leftSideView('Stephni View'),
  frontSideView('Toolkit'),
  speedometerView('Speedometer View'),
  backSeatView('Bonet View'),
  fourCornerView('Front Mirror View');

  const ImageCategory(this.displayName);
  final String displayName;
}

class CarDetails extends StatefulWidget {
  final String? bookingId;

  const CarDetails({super.key, this.bookingId});

  @override
  State<CarDetails> createState() => _CarDetailsState();
}

class _CarDetailsState extends State<CarDetails> {
  // Add controller for OTP fields
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

  // Flag to control OTP dialog visibility
  bool _showOtpDialog = false;

  // Add image picker and map to store captured images by category
  final ImagePicker _picker = ImagePicker();
  Map<ImageCategory, File?> _capturedImages = {};
  Map<ImageCategory, String?> _uploadedImages = {}; // Store uploaded image URLs
  bool _isUploading = false;
  bool _imagesAlreadyUploaded = false;

  @override
  void initState() {
    super.initState();
    // Initialize all categories with null values
    for (ImageCategory category in ImageCategory.values) {
      _capturedImages[category] = null;
      _uploadedImages[category] = null;
    }
    _checkUploadedImages();
  }

  // Check if images are already uploaded from the booking data
  void _checkUploadedImages() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingProvider = context.read<SingleBookingProvider>();
      final booking = bookingProvider.currentBooking;

      if (booking?.carImagesBeforePickup != null &&
          booking!.carImagesBeforePickup!.isNotEmpty) {
        // Check if we have all required images
        if (booking.carImagesBeforePickup!.length >=
            ImageCategory.values.length) {
          setState(() {
            _imagesAlreadyUploaded = true;

            // Map uploaded images to categories in order
            for (
              int i = 0;
              i < ImageCategory.values.length &&
                  i < booking.carImagesBeforePickup!.length;
              i++
            ) {
              _uploadedImages[ImageCategory.values[i]] =
                  booking.carImagesBeforePickup![i].url;
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    // Dispose all controllers and focus nodes when widget is disposed
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  // Function to check if all mandatory images are captured or already uploaded
  bool get _allImagesUploaded {
    if (_imagesAlreadyUploaded) {
      return _uploadedImages.values.every(
        (image) => image != null && image.isNotEmpty,
      );
    }
    return _capturedImages.values.every((image) => image != null);
  }

  // Show full screen image with zoom capability
  void _showImageFullScreen({
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

  // Function to take photo for specific category (only if images not already uploaded)
  Future<void> _takePhoto(ImageCategory category) async {
    if (_imagesAlreadyUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Images are already uploaded and cannot be modified'),
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
          _capturedImages[category] = File(photo.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error taking photo: $e')));
    }
  }

  // Function to delete image for specific category (only if images not already uploaded)
  void _deleteImage(ImageCategory category) {
    if (_imagesAlreadyUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Images are already uploaded and cannot be modified'),
        ),
      );
      return;
    }

    setState(() {
      _capturedImages[category] = null;
    });
  }

  // Show instructions modal
  void _showInstructionsModal() {
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
                          fontSize: 18,
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
                      _buildInstructionItem(
                        'Front View',
                        'Take a clear photo of the front rearview mirror showing any cracks or damage.',
                        Icons.visibility,
                      ),
                      _buildInstructionItem(
                        'Back View',
                        'Capture the entire back of the car including lights and, license plate.',
                        Icons.car_rental,
                      ),
                      _buildInstructionItem(
                        'Right Side View',
                        'Take a photo from the right side.',
                        Icons.arrow_forward,
                      ),
                      _buildInstructionItem(
                        'Left Side View',
                        'Take a photo from the left side.',
                        Icons.arrow_back,
                      ),
                      _buildInstructionItem(
                        'Stephni View',
                        'Take a photo from the Stephni side.',
                        Icons.rotate_left,
                      ),
                      _buildInstructionItem(
                        'Toolkit View',
                        'Take a photo of Toolkit.',
                        Icons.airline_seat_recline_normal,
                      ),
                      _buildInstructionItem(
                        'Speedometer View',
                        'Capture the dashboard showing the speedometer, fuel gauge, and mileage.',
                        Icons.speed,
                      ),
                      _buildInstructionItem(
                        'Bonet View',
                        'Take a photo of Bonet.',
                        Icons.crop_free,
                      ),
                      _buildInstructionItem(
                        'Front Mirror View',
                        'Take a photo of Front mirror.',
                        Icons.crop_free,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade300),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info, color: Colors.amber),
                                SizedBox(width: 8),
                                Text(
                                  'Important Tips:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text('• Ensure good lighting for clear photos'),
                            Text('• Keep the camera steady to avoid blur'),
                            Text('• Capture any existing damage clearly'),
                            Text('• Make sure all required areas are visible'),
                            Text('• All 9 categories are mandatory'),
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

  Widget _buildInstructionItem(
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

  // Function to upload images to API (only if not already uploaded)
  Future<bool> _uploadImages(String bookingId) async {
    if (_imagesAlreadyUploaded) {
      // Images are already uploaded, no need to upload again
      return true;
    }

    if (!_allImagesUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture all mandatory images')),
      );
      return false;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      var uri = Uri.parse(
        'https://varahibackend.varahiselfdrivecars.com/api/staff/carimagesbeforepickup/$bookingId',
      );
      var request = http.MultipartRequest('POST', uri);

      // Add all captured images to the request with category names in order
      for (var category in ImageCategory.values) {
        if (_capturedImages[category] != null) {
          var multipartFile = await http.MultipartFile.fromPath(
            'carImages',
            _capturedImages[category]!.path,
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

      setState(() {
        _isUploading = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Images uploaded successfully')),
        );

        // Mark images as uploaded
        setState(() {
          _imagesAlreadyUploaded = true;
          // Convert captured images to uploaded images
          for (var category in ImageCategory.values) {
            if (_capturedImages[category] != null) {
              _uploadedImages[category] = _capturedImages[category]!
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<SingleBookingProvider>(
      builder: (context, bookingProvider, child) {
        final booking = bookingProvider.currentBooking;

        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              // Main content
              SingleChildScrollView(
                child: Column(
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
                            "Car Details",
                            style: TextStyle(
                              color: const Color.fromARGB(255, 255, 0, 0),
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    Image.network(
                      '${booking?.car?.carImage[0]}',
                      fit: BoxFit.fill,
                      width: double.infinity,
                      height: 263,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade300,
                        height: 200,
                        child: Icon(Icons.error, size: screenWidth * 0.1),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Header with instructions button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Car Images (Required)",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _showInstructionsModal,
                                icon: const Icon(Icons.help_outline, size: 18),
                                label: const Text('Instructions'),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF120698),
                                ),
                              ),
                            ],
                          ),

                          // Progress indicator
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _imagesAlreadyUploaded
                                  ? Colors.green.shade50
                                  : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _imagesAlreadyUploaded
                                    ? Colors.green.shade200
                                    : Colors.blue.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _imagesAlreadyUploaded
                                      ? Icons.cloud_done
                                      : _allImagesUploaded
                                      ? Icons.check_circle
                                      : Icons.camera_alt,
                                  color: _imagesAlreadyUploaded
                                      ? Colors.green
                                      : _allImagesUploaded
                                      ? Colors.green
                                      : Colors.blue,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _imagesAlreadyUploaded
                                        ? 'Images already uploaded! Ready to proceed.'
                                        : _allImagesUploaded
                                        ? 'All images captured! Ready to proceed.'
                                        : 'Progress: ${_capturedImages.values.where((img) => img != null).length}/${ImageCategory.values.length} images captured',
                                    style: TextStyle(
                                      color: _imagesAlreadyUploaded
                                          ? Colors.green.shade700
                                          : _allImagesUploaded
                                          ? Colors.green.shade700
                                          : Colors.blue.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Image capture cards for each category
                          ...ImageCategory.values.map((category) {
                            return Column(
                              children: [
                                _buildImageCategoryCard(category),
                                const SizedBox(height: 15),
                              ],
                            );
                          }).toList(),

                          const SizedBox(height: 25),

                          // Proceed button - only enabled when all images are captured or already uploaded
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: (_isUploading || !_allImagesUploaded)
                                  ? null
                                  : () async {
                                      // First upload images (if not already uploaded), then show OTP dialog
                                      String bookingId =
                                          booking?.id.toString() ?? '';
                                      if (bookingId.isNotEmpty) {
                                        bool uploadSuccess =
                                            await _uploadImages(bookingId);
                                        if (uploadSuccess) {
                                          setState(() {
                                            _showOtpDialog = true;
                                          });
                                        }
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Booking ID not found',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _allImagesUploaded
                                    ? const Color(0xFF120698)
                                    : Colors.grey.shade400,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isUploading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      _imagesAlreadyUploaded
                                          ? 'Proceed to OTP Verification'
                                          : _allImagesUploaded
                                          ? 'Proceed'
                                          : 'Capture All Images First',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // OTP verification overlay with blur effect
              if (_showOtpDialog)
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    color: const Color(0xFFFFFF).withOpacity(0.2),
                    width: double.infinity,
                    height: double.infinity,
                    child: Center(
                      child: _buildOtpVerificationCard(context, booking),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // Updated widget to display image category card with PhotoView integration
  Widget _buildImageCategoryCard(ImageCategory category) {
    final isCaptured = _capturedImages[category] != null;
    final isUploaded = _uploadedImages[category] != null;
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
                    onPressed: () => _deleteImage(category),
                    child: const Text('Retake', style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
          ),
          // Image area with zoom functionality
          GestureDetector(
            onTap: _imagesAlreadyUploaded ? null : () => _takePhoto(category),
            child: Container(
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
                  if (isUploaded && _uploadedImages[category] != null)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        image: DecorationImage(
                          image: _uploadedImages[category]!.startsWith('http')
                              ? NetworkImage(_uploadedImages[category]!)
                              : FileImage(File(_uploadedImages[category]!))
                                    as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  // Display captured image (local file)
                  else if (isCaptured && _capturedImages[category] != null)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        image: DecorationImage(
                          image: FileImage(_capturedImages[category]!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  // Show placeholder for empty state
                  else
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _imagesAlreadyUploaded
                              ? Icons.lock
                              : Icons.camera_alt,
                          size: 40,
                          color: _imagesAlreadyUploaded
                              ? Colors.grey.shade400
                              : Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _imagesAlreadyUploaded
                              ? 'Already uploaded'
                              : 'Tap to capture',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                  // Full screen view icon when image exists
                  if (hasImage)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: GestureDetector(
                        onTap: () => _showImageFullScreen(
                          imageFile: isCaptured
                              ? _capturedImages[category]
                              : null,
                          imageUrl: isUploaded
                              ? _uploadedImages[category]
                              : null,
                          title: category.displayName,
                        ),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.fullscreen,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
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
                          child: Icon(
                            Icons.lock,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Rest of the existing methods remain the same...
  Widget _buildOtpVerificationCard(BuildContext context, booking) {
    return Container(
      width: 343,
      height: 345,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Pickup otp verification',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) => _buildOtpTextField(index)),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                _verifyOtp(booking);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3182CE),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Verify',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpTextField(int index) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 2,
          ),
        ],
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            _focusNodes[index + 1].requestFocus();
          }
        },
      ),
    );
  }

  // All the existing helper methods remain the same (verifyOtp, download methods, etc.)
  Future<void> _verifyOtp(booking) async {
    // Get OTP from controllers
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
      // Get user ID from booking data
      print('helooooooooooooooooooooooooooooooooenteredotp$enteredOtp');
      int sendOtp = int.parse(enteredOtp);
      String bookingId = booking?.id.toString() ?? '';
      print('heloooooooooooooooooooooooooooooooo$bookingId');

      if (bookingId.isEmpty) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking ID not found in booking data')),
        );
        return;
      }

      // Make API call to verify OTP
      final response = await http.post(
        Uri.parse(
          'https://varahibackend.varahiselfdrivecars.com/api/staff/verify-otp/$bookingId',
        ),
        headers: {
          'Content-Type': 'application/json',
          // Add authorization header if needed
          // 'Authorization': 'Bearer $token',
        },
        body: json.encode({'otp': sendOtp}),
      );

      print(
        'qwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwqwwwwwwwwwwwwwwwwwwwwwww${json.decode(response.body)}',
      );

      if (response.statusCode == 200) {
        // OTP verification successful
        final responseData = json.decode(response.body);

        // Extract deposit PDF URL from response
        String? depositPdfPath = responseData['depositPDF'];
        if (depositPdfPath != null) {
          String fullPdfUrl =
              'https://varahibackend.varahiselfdrivecars.com$depositPdfPath';
          print('PDF URL: $fullPdfUrl');

          // Download PDF before navigation
          await _downloadPdfToDownloads(fullPdfUrl, bookingId);
        }

        Navigator.pop(context); // Close loading dialog

        // Update booking status to 'picked_up'
        final bookingProvider = context.read<SingleBookingProvider>();
        if (booking?.id != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AllBookingsScreen()),
          );
        } else {
          // If no booking ID, just navigate (fallback)
          setState(() {
            _showOtpDialog = false;
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AllBookingsScreen()),
          );
        }
      } else if (response.statusCode == 400) {
        Navigator.pop(context); // Close loading dialog
        // Invalid OTP
        final errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorData['message'] ?? 'Invalid OTP')),
        );
      } else if (response.statusCode == 404) {
        Navigator.pop(context); // Close loading dialog
        // User not found
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not found')));
      } else {
        Navigator.pop(context); // Close loading dialog
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: $e')));
    }
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
      _showDownloadProgress();

      // Download the file
      await dio.download(
        pdfUrl,
        filePath,
        options: Options(
          receiveTimeout: const Duration(minutes: 5),
          sendTimeout: const Duration(minutes: 5),
          headers: {
            'Accept': 'application/pdf',
            'User-Agent': 'Mozilla/5.0 (Android; Mobile)',
          },
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            double progress = received / total;
            print('Download progress: ${(progress * 100).toStringAsFixed(0)}%');
          }
        },
      );

      // Hide download progress
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Verify the file was downloaded successfully
      File downloadedFile = File(filePath);
      bool fileExists = await downloadedFile.exists();

      if (!fileExists) {
        throw Exception('File was not created at expected location');
      }

      int fileSize = await downloadedFile.length();
      if (fileSize == 0) {
        throw Exception('Downloaded file is empty');
      }

      print('File downloaded successfully: $filePath (Size: $fileSize bytes)');

      // For Android, add the file to MediaStore so it appears in file managers
      if (Platform.isAndroid) {
        await _addToMediaStore(filePath, fileName);
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF saved to Downloads'),
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: 'Show Location',
            onPressed: () => _showFileLocation(fileName),
          ),
        ),
      );
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

  // Open the downloaded PDF file
  Future<void> _openPdfFile(String filePath) async {
    try {
      // Try to open with default PDF viewer
      OpenResult result = await OpenFile.open(filePath);

      if (result.type == ResultType.done) {
        print('PDF opened successfully');
      } else {
        String errorMessage = 'Failed to open PDF';

        switch (result.type) {
          case ResultType.noAppToOpen:
            errorMessage =
                'No PDF viewer found. Please install a PDF reader app.';
            break;
          case ResultType.fileNotFound:
            errorMessage = 'PDF file not found';
            break;
          case ResultType.permissionDenied:
            errorMessage = 'Permission denied to open PDF';
            break;
          case ResultType.error:
            errorMessage = 'Error opening PDF: ${result.message}';
            break;
          default:
            errorMessage = 'Unknown error opening PDF';
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      print('Error opening PDF: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error opening PDF: $e')));
    }
  }

  // Alternative method using SAF (Storage Access Framework) for Android 10+
  Future<void> _downloadUsingSAF(String pdfUrl, String bookingId) async {
    try {
      if (!Platform.isAndroid) return;

      // Use SAF to let user choose where to save
      String? directoryPath = await FilePicker.getDirectoryPath();

      if (directoryPath == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No directory selected')));
        return;
      }

      String fileName =
          'deposit_receipt_${bookingId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      String filePath = '$directoryPath/$fileName';

      // Download using Dio
      Dio dio = Dio();
      _showDownloadProgress();

      await dio.download(pdfUrl, filePath);

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('PDF saved to: $directoryPath')));
    } catch (e) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      print('SAF download error: $e');
    }
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
