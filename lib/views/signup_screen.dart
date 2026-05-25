
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:varahiowner/helpers/toast_helper.dart';
import 'package:varahiowner/model/car_model.dart';
import 'package:varahiowner/model/owner_model.dart';
import 'package:varahiowner/providers/auth_provider.dart';
import 'package:varahiowner/views/login_screen.dart';
import 'package:varahiowner/views/navbar_screen.dart';
import 'package:geolocator/geolocator.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  int _currentStep = 0;

  // Step 1 — Owner Details
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _aadharController = TextEditingController();

  // Step 2 — Car Details
  final _carNameController = TextEditingController();
  final _modelController = TextEditingController();
  String? _selectedYear;
  String? _selectedFuelType;
  String? _selectedTransmission;
  String? _selectedCarType;
  String? _selectedSeats;
  final _pricePerHourController = TextEditingController();
  final _pricePerDayController = TextEditingController();
  final _delayPerHourController = TextEditingController();
  final _delayPerDayController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _branchNameController = TextEditingController();
  final _branchLatController = TextEditingController();
  final _branchLngController = TextEditingController();
  bool _isPremium = true;

  // Step 3 — Documents
  List<File> _carImages = [];
  List<File> _carDocs = [];

  // Dropdown options
  final List<String> _years = List.generate(104, (i) => (1947 + i).toString());
  final List<String> _fuelTypes = [
    'Petrol',
    'Diesel',
    'Electric',
    'Hybrid',
    'CNG',
  ];
  final List<String> _transmissions = ['Manual', 'Automatic', 'CVT', 'DCT'];
  final List<String> _carTypes = [
    'Sedan',
    'SUV',
    'Hatchback',
    'MUV',
    'Coupe',
    'Convertible',
  ];
  final List<String> _seatsOptions = [
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '12',
    '14',
    '16',
  ];

  bool _isFetchingLocation = false;

  static const _brand = Color(0xFF1D9E75);
  static const _brandLight = Color(0xFFE1F5EE);
  static const _brandDark = Color(0xFF0F6E56);

  @override
  void initState() {
    super.initState();
    // Add a listener to handle Android back button
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupBackButtonListener();
    });
  }

  void _setupBackButtonListener() {
    // This handles the Android physical back button
    if (Navigator.of(context).canPop()) {
      // Don't override if we can pop normally
      return;
    }
  }

  // Future<bool> _onWillPop() async {
  //   if (_currentStep == 0) {
  //     // On owner details screen, ask for confirmation
  //     return await _showExitConfirmation();
  //   } else {
  //     // On other screens, just go back to previous step
  //     setState(() {
  //       _currentStep--;
  //     });
  //     return false; // Prevent default back button behavior
  //   }
  // }

  Future<bool> _onWillPop() async {
    if (_currentStep == 3) {
      // On success screen, navigate to login
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
      return false; // Prevent default back behavior
    } else if (_currentStep == 0) {
      // On owner details screen, ask for confirmation
      return await _showExitConfirmation();
    } else {
      // On other screens, just go back to previous step
      setState(() {
        _currentStep--;
      });
      return false;
    }
  }

  Future<bool> _showExitConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Exit Registration?'),
        content: const Text(
          'Your entered data will be lost if you go back. Are you sure you want to exit?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
            child: const Text('Stay'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _brand,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );

    if (result == true) {
      // User confirmed exit, go to login screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
      return false; // We're handling navigation ourselves
    }
    return false; // User cancelled, stay on current screen
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _aadharController.dispose();
    _carNameController.dispose();
    _modelController.dispose();
    _pricePerHourController.dispose();
    _pricePerDayController.dispose();
    _delayPerHourController.dispose();
    _delayPerDayController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _vehicleNumberController.dispose();
    _branchNameController.dispose();
    _branchLatController.dispose();
    _branchLngController.dispose();
    super.dispose();
  }

  // Fetch current location
  Future<void> _fetchCurrentLocation() async {
    setState(() {
      _isFetchingLocation = true;
    });

    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ToastHelper.showError(context, 'Location permission denied');
          setState(() {
            _isFetchingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ToastHelper.showError(
          context,
          'Location permission permanently denied. Please enable from settings.',
        );
        setState(() {
          _isFetchingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _branchLatController.text = position.latitude.toStringAsFixed(6);
        _branchLngController.text = position.longitude.toStringAsFixed(6);
        _isFetchingLocation = false;
      });

      ToastHelper.showSuccess(context, 'Location fetched successfully');

      // Optionally get address from coordinates
    } catch (e) {
      setState(() {
        _isFetchingLocation = false;
      });
      ToastHelper.showError(context, 'Failed to get location: ${e.toString()}');
    }
  }

Future<void> _pickCarImages() async {
  final result = await FilePicker.pickFiles(
    type: FileType.image,
    allowMultiple: true,
    withData: true,  // <-- change this
  );

  if (result == null || result.files.isEmpty) return;

  List<File> newFiles = [];

  for (var file in result.files) {
    if (file.path == null) continue;

    if (file.size <= 5 * 1024 * 1024) {
      final exists = _carImages.any((e) => e.path == file.path);
      if (!exists) {
        newFiles.add(File(file.path!));
      }
    } else {
      ToastHelper.showError(context, 'File ${file.name} exceeds 5MB limit');
    }
  }

  if (newFiles.isNotEmpty) {
    setState(() {
      _carImages = [..._carImages, ...newFiles];
    });
    ToastHelper.showSuccess(context, '${newFiles.length} image(s) added');
  }
}

  // Update validation - only 1 image required
  bool _validateStep3() {
    if (_carImages.isEmpty) {
      ToastHelper.showError(context, 'Please upload at least one car image');
      return false;
    }

    // Remove the minimum 2 images check
    // if (_carImages.length < 2) {
    //   ToastHelper.showError(
    //     context,
    //     'Please upload at least 2 car images for better visibility',
    //   );
    //   return false;
    // }

    if (_carDocs.isEmpty) {
      ToastHelper.showError(
        context,
        'Please upload car documents (RC Book/Insurance)',
      );
      return false;
    }

    return true;
  }

  Future<void> _pickCarDocs() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      allowMultiple: true,
    );
    if (result != null && result.files.isNotEmpty) {
      // Check file sizes (max 5MB each)
      bool validFiles = true;
      for (var file in result.files) {
        if (file.size > 5 * 1024 * 1024) {
          ToastHelper.showError(context, 'File ${file.name} exceeds 5MB limit');
          validFiles = false;
          break;
        }
      }

      if (validFiles) {
        setState(() {
          _carDocs = result.files.map((file) => File(file.path!)).toList();
        });
        ToastHelper.showSuccess(
          context,
          '${_carDocs.length} document(s) selected',
        );
      }
    }
  }

  void _removeCarImage(int index) {
    setState(() {
      _carImages.removeAt(index);
    });
    ToastHelper.showInfo(context, 'Image removed');
  }

  void _removeCarDoc(int index) {
    setState(() {
      _carDocs.removeAt(index);
    });
    ToastHelper.showInfo(context, 'Document removed');
  }

  // Validate all fields with detailed error messages
  Future<bool> _validateStep1() async {
    if (_fullNameController.text.trim().isEmpty) {
      ToastHelper.showError(context, 'Please enter your full name');
      return false;
    }

    if (_fullNameController.text.trim().length < 3) {
      ToastHelper.showError(context, 'Full name must be at least 3 characters');
      return false;
    }

    if (_mobileController.text.trim().isEmpty) {
      ToastHelper.showError(context, 'Please enter mobile number');
      return false;
    }

    if (_mobileController.text.trim().length != 10) {
      ToastHelper.showError(
        context,
        'Please enter a valid 10-digit mobile number',
      );
      return false;
    }

    if (!RegExp(r'^[0-9]{10}$').hasMatch(_mobileController.text.trim())) {
      ToastHelper.showError(
        context,
        'Please enter a valid mobile number (digits only)',
      );
      return false;
    }

    if (_emailController.text.trim().isEmpty) {
      ToastHelper.showError(context, 'Please enter email address');
      return false;
    }

    if (!_emailController.text.contains('@') ||
        !_emailController.text.contains('.')) {
      ToastHelper.showError(context, 'Please enter a valid email address');
      return false;
    }

    if (_passwordController.text.isEmpty) {
      ToastHelper.showError(context, 'Please enter password');
      return false;
    }

    if (_passwordController.text.length < 6) {
      ToastHelper.showError(context, 'Password must be at least 6 characters');
      return false;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ToastHelper.showError(context, 'Passwords do not match');
      return false;
    }

    return true;
  }

  bool _validateStep2() {
    if (_carNameController.text.trim().isEmpty) {
      ToastHelper.showError(context, 'Please enter car name');
      return false;
    }

    if (_modelController.text.trim().isEmpty) {
      ToastHelper.showError(context, 'Please enter car model');
      return false;
    }

    if (_selectedYear == null) {
      ToastHelper.showError(context, 'Please select manufacturing year');
      return false;
    }

    if (_selectedFuelType == null) {
      ToastHelper.showError(context, 'Please select fuel type');
      return false;
    }

    if (_selectedTransmission == null) {
      ToastHelper.showError(context, 'Please select transmission type');
      return false;
    }

    if (_selectedCarType == null) {
      ToastHelper.showError(context, 'Please select car type');
      return false;
    }

    if (_selectedSeats == null) {
      ToastHelper.showError(context, 'Please select seating capacity');
      return false;
    }

    if (_vehicleNumberController.text.trim().isEmpty) {
      ToastHelper.showError(context, 'Please enter vehicle number');
      return false;
    }

    if (_vehicleNumberController.text.trim().length < 9) {
      ToastHelper.showError(context, 'Please enter a valid vehicle number');
      return false;
    }

    if (_branchNameController.text.trim().isEmpty) {
      ToastHelper.showError(context, 'Please enter branch name');
      return false;
    }

    if (_branchLatController.text.trim().isEmpty ||
        _branchLngController.text.trim().isEmpty) {
      ToastHelper.showError(
        context,
        'Please fetch or enter branch location coordinates',
      );
      return false;
    }

    return true;
  }

  void _goToPreviousStep() {
    if (_currentStep == 0) {
      // On step 0, show exit confirmation
      _showExitConfirmation();
    } else {
      // Go to previous step
      setState(() {
        _currentStep--;
      });
    }
  }

  // Update the _submitRegistration method
  Future<void> _submitRegistration() async {
    // Validate all steps
    if (!await _validateStep1()) return;
    if (!_validateStep2()) return;
    if (!_validateStep3()) return;

    final owner = OwnerModel(
      fullName: _fullNameController.text.trim(),
      mobileNumber: _mobileController.text.trim(),
      email: _emailController.text.trim(),
      aadharNumber: _aadharController.text.isNotEmpty
          ? _aadharController.text.trim()
          : null,
      password: _passwordController.text,
    );

    final car = CarModel(
      carName: _carNameController.text.trim(),
      model: _modelController.text.trim(),
      year: _selectedYear!,
      pricePerHour: double.tryParse(_pricePerHourController.text) ?? 0,
      pricePerDay: double.tryParse(_pricePerDayController.text) ?? 0,
      delayPerHour: double.tryParse(_delayPerHourController.text) ?? 0,
      delayPerDay: double.tryParse(_delayPerDayController.text) ?? 0,
      extendedPrice: {'perHour': 200, 'perDay': 1500},
      type: _selectedCarType!,
      description: _descriptionController.text.trim().isEmpty
          ? 'Comfortable city car with AC'
          : _descriptionController.text.trim(),
      location: _locationController.text.trim().isEmpty
          ? 'Mumbai'
          : _locationController.text.trim(),
      carType: _selectedTransmission!,
      fuel: _selectedFuelType!,
      seats: int.parse(_selectedSeats!),
      vehicleNumber: _vehicleNumberController.text.trim().toUpperCase(),
      branchName: _branchNameController.text.trim(),
      branchLat: double.tryParse(_branchLatController.text) ?? 0,
      branchLng: double.tryParse(_branchLngController.text) ?? 0,
      isPremium: _isPremium,
      availability: [
        {
          'date': DateTime.now().toIso8601String(),
          'timeSlots': ['09:00', '18:00'],
        },
      ],
    );

    final provider = Provider.of<AuthProvider>(context, listen: false);

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 10),
                Text('Registering...', style: TextStyle(color: _brand)),
              ],
            ),
          ),
        ),
      ),
    );

    final success = await provider.registerWithCar(
      owner: owner,
      car: car,
      carImages: _carImages,
      carDocs: _carDocs,
    );

    if (mounted) {
      Navigator.pop(context); // Close loading dialog
    }

    if (success) {
      ToastHelper.showSuccess(context, 'Registration submitted successfully!');
      if (mounted) {
        // Force a rebuild and go to success screen
        setState(() {
          _currentStep = 3;
        });
      }
    } else {
      if (mounted) {
        ToastHelper.showError(
          context,
          provider.errorMessage.isNotEmpty
              ? provider.errorMessage
              : 'Registration failed. Please try again.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuthProvider>(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF7F7F5),
          elevation: 0,
          centerTitle: true,
          leading: _currentStep == 3
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  color: Colors.black87,
                  onPressed: () {
                    // On success screen, go to login
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                )
              : (_currentStep == 0
                    ? IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                        ),
                        color: Colors.black87,
                        onPressed: () => _showExitConfirmation(),
                      )
                    : (_currentStep < 3
                          ? IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 18,
                              ),
                              color: Colors.black87,
                              onPressed: _goToPreviousStep,
                            )
                          : null)),
          title: const Text(
            'Vendor Registration',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        body: Column(
          children: [
            _StepBar(
              currentStep: _currentStep,
              brand: _brand,
              brandLight: _brandLight,
              brandDark: _brandDark,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.04, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(_currentStep),
                    child: [
                      _buildStep1(),
                      _buildStep2(),
                      _buildStep3(provider),
                      _buildSuccess(),
                    ][_currentStep],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Step 1: Owner details
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionCard(
          title: 'Owner Details',
          children: [
            _Field(
              label: 'Full name',
              controller: _fullNameController,
              hint: 'As on ID proof',
              required: true,
            ),
            _Field(
              label: 'Mobile number',
              controller: _mobileController,
              hint: '10 digit mobile number',
              keyboardType: TextInputType.phone,
              required: true,
            ),
            _Field(
              label: 'Email address',
              controller: _emailController,
              hint: 'your@email.com',
              keyboardType: TextInputType.emailAddress,
              required: true,
            ),
            _Field(
              label: 'Password',
              controller: _passwordController,
              hint: 'Minimum 6 characters',
              obscureText: true,
              required: true,
            ),
            _Field(
              label: 'Confirm password',
              controller: _confirmPasswordController,
              hint: 'Re-enter password',
              obscureText: true,
              required: true,
            ),
            _Field(
              label: 'Aadhar number',
              controller: _aadharController,
              hint: '12 digit Aadhar number (Optional)',
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _PrimaryButton(
          label: 'Continue',
          onTap: () async {
            if (await _validateStep1()) {
              setState(() => _currentStep = 1);
            }
          },
        ),
      ],
    );
  }

  // Step 2: Car details
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionCard(
          title: 'Car Details',
          children: [
            _Field(
              label: 'Car name',
              controller: _carNameController,
              hint: 'e.g. Maruti Swift, Honda City',
              required: true,
            ),
            _Field(
              label: 'Model',
              controller: _modelController,
              hint: 'e.g. ZXI, VXI, V',
              required: true,
            ),
            _DropdownField(
              label: 'Manufacturing Year',
              value: _selectedYear,
              items: _years,
              hint: 'Select year',
              required: true,
              onChanged: (value) => setState(() => _selectedYear = value),
            ),
            _DropdownField(
              label: 'Fuel Type',
              value: _selectedFuelType,
              items: _fuelTypes,
              hint: 'Select fuel type',
              required: true,
              onChanged: (value) => setState(() => _selectedFuelType = value),
            ),
            _DropdownField(
              label: 'Transmission',
              value: _selectedTransmission,
              items: _transmissions,
              hint: 'Select transmission',
              required: true,
              onChanged: (value) =>
                  setState(() => _selectedTransmission = value),
            ),
            _DropdownField(
              label: 'Car Type',
              value: _selectedCarType,
              items: _carTypes,
              hint: 'Select car type',
              required: true,
              onChanged: (value) => setState(() => _selectedCarType = value),
            ),
            _DropdownField(
              label: 'Seating Capacity',
              value: _selectedSeats,
              items: _seatsOptions,
              hint: 'Select seats',
              required: true,
              onChanged: (value) => setState(() => _selectedSeats = value),
            ),
            _Field(
              label: 'Vehicle number',
              controller: _vehicleNumberController,
              hint: 'MH01AB1234',
              textCapitalization: TextCapitalization.characters,
              required: true,
            ),

            _Field(
              label: 'Location/City',
              controller: _locationController,
              hint: 'City name',
            ),
            _Field(
              label: 'Description',
              controller: _descriptionController,
              hint: 'Comfortable city car with AC',
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'BRANCH LOCATION',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black45,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),
            _Field(
              label: 'Branch name',
              controller: _branchNameController,
              hint: 'e.g. Andheri Branch',
              required: true,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _Field(
                    label: 'Latitude',
                    controller: _branchLatController,
                    hint: '17.315289',
                    keyboardType: TextInputType.number,
                    required: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Field(
                    label: 'Longitude',
                    controller: _branchLngController,
                    hint: '78.561221',
                    keyboardType: TextInputType.number,
                    required: true,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  margin: const EdgeInsets.only(top: 24),
                  child: _LocationButton(
                    onTap: _fetchCurrentLocation,
                    isLoading: _isFetchingLocation,
                  ),
                ),
              ],
            ),
            _PremiumToggle(
              value: _isPremium,
              onChanged: (val) => setState(() => _isPremium = val),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _SecondaryButton(label: 'Back', onTap: _goToPreviousStep),
            const SizedBox(width: 10),
            Expanded(
              child: _PrimaryButton(
                label: 'Continue',
                onTap: () {
                  if (_validateStep2()) {
                    setState(() => _currentStep = 2);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Step 3: Documents
  Widget _buildStep3(AuthProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _brandLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _brand.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: _brandDark),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Upload clear photos or scanned PDFs. Files must be under 5 MB each. Minimum 1 car image required.',
                  style: TextStyle(
                    fontSize: 13,
                    color: _brandDark,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Car Images',
          children: [
            _UploadTile(
              label: 'Car Photos',
              files: _carImages,
              onTap: _pickCarImages,
              onRemove: _removeCarImage,
              isImage: true,
              required: true,
            ),
            // Remove the warning message about needing 2+ images
            // if (_carImages.isNotEmpty && _carImages.length < 2)
            //   Padding(
            //     padding: const EdgeInsets.only(top: 8),
            //     child: Text(
            //       '⚠️ Please add at least 2 images',
            //       style: TextStyle(fontSize: 11, color: Colors.orange.shade700),
            //     ),
            //   ),
          ],
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Document',
          children: [
            _UploadTile(
              label: 'RC Book / Insurance',
              files: _carDocs,
              onTap: _pickCarDocs,
              onRemove: _removeCarDoc,
              isImage: false,
              required: true,
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (provider.errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 16,
                    color: Colors.red.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      provider.errorMessage,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        Row(
          children: [
            _SecondaryButton(label: 'Back', onTap: _goToPreviousStep),
            const SizedBox(width: 10),
            Expanded(
              child: provider.isLoading
                  ? Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: _brand,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      ),
                    )
                  : _PrimaryButton(
                      label: 'Submit Registration',
                      onTap: _submitRegistration,
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    return WillPopScope(
      onWillPop: () async {
        // When back button is pressed on success screen, go to login
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
        return false;
      },
      child: Container(
        key: const ValueKey('success_screen'),
        child: Column(
          children: [
            _SectionCard(
              title: '',
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _brandLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: _brandDark,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Registration Submitted!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Your details are under review. We\'ll notify you once your account is approved — usually within 24 hours.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _PrimaryButton(
                  label: 'Go to Login',
                  onTap: () {
                    // Use pushAndRemoveUntil to clear all previous routes
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false, // Remove all previous routes
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Location Button Widget ──────────────────────────────────────────────────

class _LocationButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;

  const _LocationButton({required this.onTap, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFF1D9E75).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF1D9E75).withOpacity(0.3)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1D9E75)),
                ),
              )
            : const Icon(Icons.my_location, size: 20, color: Color(0xFF1D9E75)),
      ),
    );
  }
}

// ─── Dropdown Field Widget ───────────────────────────────────────────────────

class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final String hint;
  final bool required;
  final Function(String?) onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.hint,
    required this.onChanged,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              if (required) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: TextStyle(fontSize: 12, color: Colors.red.shade400),
                ),
              ],
            ],
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black12, width: 0.5),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                hint: Text(
                  hint,
                  style: const TextStyle(fontSize: 14, color: Colors.black38),
                ),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                iconSize: 20,
                elevation: 2,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                onChanged: onChanged,
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                underline: const SizedBox(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step Bar Widget ─────────────────────────────────────────────────────────

class _StepBar extends StatelessWidget {
  final int currentStep;
  final Color brand, brandLight, brandDark;

  const _StepBar({
    required this.currentStep,
    required this.brand,
    required this.brandLight,
    required this.brandDark,
  });

  @override
  Widget build(BuildContext context) {
    final labels = ['Owner', 'Car', 'Document', 'Success'];
    final totalSteps = labels.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final isDone = index < currentStep;
          final isActive = index == currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone
                              ? brand
                              : isActive
                              ? brandLight
                              : Colors.transparent,
                          border: isDone
                              ? null
                              : Border.all(
                                  color: isActive ? brand : Colors.black26,
                                  width: isActive ? 1.5 : 0.8,
                                ),
                        ),
                        child: Center(
                          child: isDone
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isActive
                                        ? brandDark
                                        : Colors.black45,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        labels[index],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isActive || isDone
                              ? Colors.black87
                              : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index != totalSteps - 1)
                  Container(
                    width: 30,
                    height: 1,
                    color: Colors.black12,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─── Section Card Widget ─────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.07)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black45,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 14),
          ],
          ...children,
        ],
      ),
    );
  }
}

// ─── Text Field Widget ───────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final bool obscureText;
  final bool required;
  final int maxLines;

  const _Field({
    required this.label,
    required this.controller,
    this.hint = '',
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.words,
    this.obscureText = false,
    this.required = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              if (required) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: TextStyle(fontSize: 12, color: Colors.red.shade400),
                ),
              ],
            ],
          ),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            obscureText: obscureText,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 14, color: Colors.black26),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 11,
              ),
              filled: true,
              fillColor: const Color(0xFFF7F7F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.black12, width: 0.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.black12, width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF1D9E75),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Premium Toggle Widget ───────────────────────────────────────────────────

class _PremiumToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PremiumToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Row(
        children: [
          const Text(
            'Premium Listing',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(width: 12),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF1D9E75),
              activeTrackColor: const Color(0xFF1D9E75).withOpacity(0.3),
            ),
          ),
          const Spacer(),
          if (value)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF1D9E75).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Featured',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1D9E75),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Upload Tile Widget ──────────────────────────────────────────────────────

class _UploadTile extends StatelessWidget {
  final String label;
  final List<File> files;
  final VoidCallback onTap;
  final Function(int)? onRemove;
  final bool isImage;
  final bool required;

  const _UploadTile({
    required this.label,
    required this.files,
    required this.onTap,
    this.onRemove,
    this.isImage = true,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasFiles = files.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: hasFiles
                  ? const Color(0xFFE1F5EE)
                  : const Color(0xFFF7F7F5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: hasFiles
                    ? const Color(0xFF1D9E75).withOpacity(0.4)
                    : Colors.black12,
                width: hasFiles ? 1.0 : 0.5,
              ),
            ),
            child: hasFiles
                ? Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D9E75).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Color(0xFF0F6E56),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  label,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF0F6E56),
                                  ),
                                ),
                                if (required && files.length < 2 && isImage)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text(
                                      '(Need 2+)',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            Text(
                              '${files.length} file(s) selected',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF1D9E75),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.edit_outlined,
                        size: 14,
                        color: Color(0xFF1D9E75),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black12, width: 0.5),
                        ),
                        child: Icon(
                          isImage
                              ? Icons.add_photo_alternate_outlined
                              : Icons.upload_file_outlined,
                          size: 16,
                          color: Colors.black45,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isImage
                                  ? 'Tap to upload images'
                                  : 'Tap to upload documents',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black38,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: Colors.black26,
                      ),
                    ],
                  ),
          ),
        ),
        // if (hasFiles && onRemove != null) ...[
        //   const SizedBox(height: 8),
          // Wrap(
          //   spacing: 8,
          //   runSpacing: 8,
          //   children: List.generate(files.length, (index) {
          //     return Container(
          //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          //       decoration: BoxDecoration(
          //         color: Colors.grey.shade100,
          //         borderRadius: BorderRadius.circular(12),
          //         border: Border.all(color: Colors.grey.shade300),
          //       ),
          //       child: Row(
          //         mainAxisSize: MainAxisSize.min,
          //         children: [
          //           Icon(
          //             isImage
          //                 ? Icons.image_outlined
          //                 : Icons.description_outlined,
          //             size: 12,
          //             color: Colors.grey.shade600,
          //           ),
          //           const SizedBox(width: 4),
          //           Text(
          //             'File ${index + 1}',
          //             style: TextStyle(
          //               fontSize: 11,
          //               color: Colors.grey.shade700,
          //             ),
          //           ),
          //           const SizedBox(width: 4),
          //           GestureDetector(
          //             onTap: () => onRemove?.call(index),
          //             child: Icon(
          //               Icons.close_rounded,
          //               size: 14,
          //               color: Colors.grey.shade500,
          //             ),
          //           ),
          //         ],
          //       ),
          //     );
          //   }),
          // ),


if (hasFiles && onRemove != null && isImage) ...[
  const SizedBox(height: 12),

  SizedBox(
    height: 110,
    child: GridView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: files.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
          ),
      itemBuilder: (context, index) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: FileImage(files[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Positioned(
              top: -5,
              right: -5,
              child: InkWell(
                onTap: () => onRemove?.call(index),
                child: Container(
                  height: 24,
                  width: 24,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  ),

        ],
      ],
    );
  }
}

// ─── Buttons ─────────────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1D9E75),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SecondaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black54,
          side: const BorderSide(color: Colors.black26, width: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
