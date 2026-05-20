import 'package:varahiowner/model/Staff/models/single_booking_model.dart';
import 'package:varahiowner/providers/Staff/providers/single_booking_provider.dart';
import 'package:varahiowner/views/Staff/car_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:photo_view/photo_view.dart';

class PickupDetailsScreen extends StatefulWidget {
  final String id;

  const PickupDetailsScreen({super.key, required this.id});

  @override
  State<PickupDetailsScreen> createState() => _PickupDetailsScreenState();
}

class _PickupDetailsScreenState extends State<PickupDetailsScreen> {
  // Text controllers for the form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _alternateMobileController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pickupTimeController = TextEditingController();
  final TextEditingController _pickupDateController = TextEditingController();

  // Image variables
  File? _frontImage;
  File? _backImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingFrontImage = false;
  bool _isUploadingBackImage = false;

  // Variables to track existing deposit proof
  String? _existingFrontImageUrl;
  String? _existingBackImageUrl;

  // Variables to track upload success
  bool _frontImageUploaded = false;
  bool _backImageUploaded = false;

  @override
  void initState() {
    super.initState();
    // Call fetchSingleBooking after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SingleBookingProvider>().fetchSingleBooking(widget.id);
    });
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _nameController.dispose();
    _mobileController.dispose();
    _alternateMobileController.dispose();
    _emailController.dispose();
    _pickupTimeController.dispose();
    _pickupDateController.dispose();
    super.dispose();
  }

  void _populateFields(dynamic booking) {
    if (booking != null) {
      _nameController.text = booking['name'] ?? '';
      _mobileController.text = booking['mobile'] ?? '';
      _alternateMobileController.text = booking['alternateMobile'] ?? '';
      _emailController.text = booking['email'] ?? '';
      _pickupTimeController.text = booking['pickupTime'] ?? '';
      _pickupDateController.text = booking['pickupDate'] ?? '';
    }
  }

  void _checkExistingDepositProof(Booking booking) {
    for (var depositProof in booking.depositeProof) {
      if (depositProof.label == 'depositeFront') {
        setState(() {
          _existingFrontImageUrl = depositProof.url;
          _frontImageUploaded = true; // Mark as uploaded if existing
        });
      } else if (depositProof.label == 'depositeBack') {
        setState(() {
          _existingBackImageUrl = depositProof.url;
          _backImageUploaded = true; // Mark as uploaded if existing
        });
      }
    }
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

  // Show image source selection dialog
  void _showImageSourceDialog(String imageType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image Source for $imageType'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, imageType);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, imageType);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source, String imageType) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          if (imageType == 'front') {
            _frontImage = File(pickedFile.path);
            _frontImageUploaded =
                false; // Reset upload status when new image is selected
          } else {
            _backImage = File(pickedFile.path);
            _backImageUploaded =
                false; // Reset upload status when new image is selected
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  // Upload single image to API
  Future<bool> _uploadSingleImage(String imageType) async {
    File? imageFile = imageType == 'front' ? _frontImage : _backImage;

    if (imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select ${imageType} image first')),
      );
      return false;
    }

    setState(() {
      if (imageType == 'front') {
        _isUploadingFrontImage = true;
      } else {
        _isUploadingBackImage = true;
      }
    });

    try {
      // Replace this URL with your actual API endpoint
      final String apiUrl =
          'https://varahibackend.varahiselfdrivecars.com/api/staff/uploaddeposite/${widget.id}';

      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Add booking ID
      request.fields['bookingId'] = widget.id;

      // Add image with appropriate field name
      String fieldName = imageType == 'front'
          ? 'depositeFront'
          : 'depositeBack';
      request.files.add(
        await http.MultipartFile.fromPath(fieldName, imageFile.path),
      );

      // Add any additional headers if needed
      // request.headers['Authorization'] = 'Bearer YOUR_TOKEN';

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print('Upload ${imageType} response: ${response.statusCode}');

      if (response.statusCode == 200) {
        setState(() {
          if (imageType == 'front') {
            _frontImageUploaded = true;
          } else {
            _backImageUploaded = true;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${imageType.capitalize()} image uploaded successfully!',
            ),
          ),
        );

        // Refresh booking data to get updated deposit proof
        context.read<SingleBookingProvider>().fetchSingleBooking(widget.id);

        return true;
      } else {
        throw Exception(
          'Failed to upload ${imageType} image: ${response.statusCode}',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading ${imageType} image: $e')),
      );
      return false;
    } finally {
      setState(() {
        if (imageType == 'front') {
          _isUploadingFrontImage = false;
        } else {
          _isUploadingBackImage = false;
        }
      });
    }
  }

  // Check if both images are uploaded
  bool _areBothImagesUploaded() {
    return _frontImageUploaded && _backImageUploaded;
  }

  // Handle next button press
  Future<void> _handleNextPress() async {
    if (_areBothImagesUploaded()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CarDetails()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please upload both front and back images before proceeding',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<SingleBookingProvider>(
        builder: (context, bookingProvider, child) {
          // Handle loading state
          if (bookingProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle error state
          if (bookingProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${bookingProvider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      bookingProvider.clearError();
                      bookingProvider.fetchSingleBooking(widget.id);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final booking = bookingProvider.currentBooking;

          // Populate fields and check existing deposit proof when booking data is available
          if (booking != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // _populateFields(booking);
              _checkExistingDepositProof(booking);
            });
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 50),
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
                          "ID: ${booking?.id.substring(booking.id.length - 4) ?? widget.id.substring(widget.id.length - 4)}",
                          style: TextStyle(
                            color: const Color.fromARGB(255, 255, 0, 0),
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Pickup Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Name field
                  _buildDisplayField(
                    icon: Icons.person_outline,
                    label: 'Name',
                    value: booking?.car?.model ?? 'Not Available',
                  ),

                  // Mobile Number field
                  _buildDisplayField(
                    icon: Icons.phone_outlined,
                    label: 'Mobile Number',
                    value: booking?.userId!.mobile ?? 'Not Available',
                  ),

                  // Alternate Mobile Number field
                  _buildDisplayField(
                    icon: Icons.phone_outlined,
                    label: 'Alternate Mobile Number',
                    value: booking?.userId!.mobile ?? 'Not Available',
                  ),

                  // Email field
                  _buildDisplayField(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: booking?.userId?.email ?? 'Not Available',
                  ),

                  // Pickup time and date
                  Row(
                    children: [
                      Expanded(
                        child: _buildDisplayField(
                          icon: Icons.access_time_outlined,
                          label: 'Pickup time',
                          value: booking?.from ?? 'Not set',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDisplayField(
                          icon: Icons.calendar_today_outlined,
                          label: 'Pickup date',
                          value: booking?.rentalStartDate ?? 'Not set',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Security deposit section
                  const Text(
                    'Security deposit',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),

                  // Bike selection
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${booking?.deposit}',
                          style: TextStyle(
                            color: Color.fromARGB(255, 18, 11, 213),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Scan/Upload container
                  Container(
                    width: double.infinity,
                    height: 150,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B1B3D),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildImageOption(
                            icon: Icons.camera_alt,
                            title: 'Scan',
                            subtitle: 'Front & Back',
                            onTap: () => _showImageSourceDialog('front'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildImageOption(
                            icon: Icons.file_upload_outlined,
                            title: 'Upload',
                            subtitle: 'Front & Back',
                            onTap: () => _showImageSourceDialog('back'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ID cards - Front Image
                  _buildDocumentCard(
                    title: 'Front Side',
                    image: _frontImage,
                    existingImageUrl: _existingFrontImageUrl,
                    onTap: () => _showImageSourceDialog('front'),
                    onImageView: () => _showImageFullScreen(
                      imageFile: _frontImage,
                      imageUrl: _existingFrontImageUrl,
                      title: 'Front Side',
                    ),
                    onUpload: () => _uploadSingleImage('front'),
                    isUploading: _isUploadingFrontImage,
                    isUploaded: _frontImageUploaded,
                  ),

                  const SizedBox(height: 25),

                  // ID cards - Back Image
                  _buildDocumentCard(
                    title: 'Back Side',
                    image: _backImage,
                    existingImageUrl: _existingBackImageUrl,
                    onTap: () => _showImageSourceDialog('back'),
                    onImageView: () => _showImageFullScreen(
                      imageFile: _backImage,
                      imageUrl: _existingBackImageUrl,
                      title: 'Back Side',
                    ),
                    onUpload: () => _uploadSingleImage('back'),
                    isUploading: _isUploadingBackImage,
                    isUploaded: _backImageUploaded,
                  ),

                  SizedBox(height: 25),

                  // Next button - disabled if both images not uploaded
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _areBothImagesUploaded()
                          ? _handleNextPress
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _areBothImagesUploaded()
                            ? const Color(0xFF120698)
                            : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(
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
          );
        },
      ),
    );
  }

  Widget _buildDisplayField({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: const Color.fromARGB(255, 162, 162, 162)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade600, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: const Color.fromARGB(255, 162, 162, 162)),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: label,
                hintStyle: TextStyle(color: Colors.grey.shade500),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 65,
            height: 57,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color.fromARGB(255, 0, 0, 0),
              size: 36,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard({
    required String title,
    File? image,
    String? existingImageUrl,
    VoidCallback? onTap,
    VoidCallback? onImageView,
    VoidCallback? onUpload,
    bool isUploading = false,
    bool isUploaded = false,
  }) {
    // Determine which image to show - priority: new image > existing image > default
    ImageProvider imageProvider;
    bool hasImage = false;

    if (image != null) {
      imageProvider = FileImage(image);
      hasImage = true;
    } else if (existingImageUrl != null && existingImageUrl!.isNotEmpty) {
      imageProvider = NetworkImage(existingImageUrl!);
      hasImage = true;
    } else {
      imageProvider = const AssetImage('assets/security.jpeg');
      hasImage = false;
    }

    return GestureDetector(
      onTap: hasImage
          ? onImageView
          : onTap, // If image exists, show full screen, otherwise show picker
      child: Container(
        width: double.infinity,
        height: 206,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
        ),
        child: Stack(
          children: [
            // Gradient overlay at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 60,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Add edit button if image exists
                      if (hasImage)
                        GestureDetector(
                          onTap: onTap,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Upload/Success icon
            if (!isUploaded)
              Center(
                child: Positioned(
                  child: GestureDetector(
                    onTap: (image != null && !isUploaded) ? onUpload : null,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isUploaded
                            ? Colors.green
                            : (image != null && !isUploaded)
                            ? const Color(0xFF120698)
                            : const Color.fromARGB(
                                255,
                                81,
                                81,
                                81,
                              ).withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: isUploading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isUploaded
                                      ? Icons.check
                                      : (image != null && !isUploaded)
                                      ? Icons.cloud_upload
                                      : null,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(
                                  height: 4,
                                ), // space between icon & text
                                Text(
                                  "Upload",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),

            // Upload/Success icon
            if (isUploaded)
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: (image != null && !isUploaded) ? onUpload : null,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isUploaded
                          ? Colors.green
                          : (image != null && !isUploaded)
                          ? const Color(0xFF120698)
                          : Colors.grey.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: isUploading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : Icon(
                            isUploaded
                                ? Icons.check
                                : (image != null && !isUploaded)
                                ? Icons.cloud_upload
                                : Icons.add_a_photo,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                ),
              ),

            // Camera icon overlay if no image is selected and no existing image
            if (!hasImage && image == null)
              const Center(
                child: Icon(Icons.add_a_photo, color: Colors.white, size: 48),
              ),

            // Full screen view icon when image exists
            if (hasImage)
              Positioned(
                top: 12,
                left: 12,
                child: GestureDetector(
                  onTap: onImageView,
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
          ],
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

// Extension to capitalize string
extension StringCapitalization on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
