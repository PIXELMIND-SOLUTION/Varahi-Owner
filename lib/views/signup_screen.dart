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
  final _yearController = TextEditingController();
  final _pricePerHourController = TextEditingController();
  final _pricePerDayController = TextEditingController();
  final _delayPerHourController = TextEditingController();
  final _delayPerDayController = TextEditingController();
  final _typeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _carTypeController = TextEditingController();
  final _fuelController = TextEditingController();
  final _seatsController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _branchNameController = TextEditingController();
  final _branchLatController = TextEditingController();
  final _branchLngController = TextEditingController();
  bool _isPremium = true;

  // Step 3 — Documents
  List<File> _carImages = [];
  List<File> _carDocs = [];

  static const _brand = Color(0xFF1D9E75);
  static const _brandLight = Color(0xFFE1F5EE);
  static const _brandDark = Color(0xFF0F6E56);

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
    _yearController.dispose();
    _pricePerHourController.dispose();
    _pricePerDayController.dispose();
    _delayPerHourController.dispose();
    _delayPerDayController.dispose();
    _typeController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _carTypeController.dispose();
    _fuelController.dispose();
    _seatsController.dispose();
    _vehicleNumberController.dispose();
    _branchNameController.dispose();
    _branchLatController.dispose();
    _branchLngController.dispose();
    super.dispose();
  }

  Future<void> _pickCarImages() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _carImages = result.files.map((file) => File(file.path!)).toList();
      });
      ToastHelper.showSuccess(context, '${_carImages.length} image(s) selected');
    }
  }

  Future<void> _pickCarDocs() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      allowMultiple: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _carDocs = result.files.map((file) => File(file.path!)).toList();
      });
      ToastHelper.showSuccess(context, '${_carDocs.length} document(s) selected');
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

  Future<void> _submitRegistration() async {
    // Validate Step 1
    if (_fullNameController.text.isEmpty ||
        _mobileController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ToastHelper.showError(context, 'Please fill all owner details');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ToastHelper.showError(context, 'Passwords do not match');
      return;
    }

    if (_mobileController.text.length != 10) {
      ToastHelper.showError(context, 'Please enter a valid 10-digit mobile number');
      return;
    }

    if (!_emailController.text.contains('@')) {
      ToastHelper.showError(context, 'Please enter a valid email address');
      return;
    }

    if (_passwordController.text.length < 6) {
      ToastHelper.showError(context, 'Password must be at least 6 characters');
      return;
    }

    // Validate Step 2
    if (_carNameController.text.isEmpty ||
        _modelController.text.isEmpty ||
        _yearController.text.isEmpty ||
        _vehicleNumberController.text.isEmpty) {
      ToastHelper.showError(context, 'Please fill all required car details');
      return;
    }

    // Validate Step 3
    if (_carImages.isEmpty) {
      ToastHelper.showError(context, 'Please upload at least one car image');
      return;
    }

    if (_carDocs.isEmpty) {
      ToastHelper.showError(context, 'Please upload car documents');
      return;
    }

    final owner = OwnerModel(
      fullName: _fullNameController.text.trim(),
      mobileNumber: _mobileController.text.trim(),
      email: _emailController.text.trim(),
      aadharNumber: _aadharController.text.isNotEmpty ? _aadharController.text.trim() : null,
      password: _passwordController.text,
    );

    final car = CarModel(
      carName: _carNameController.text.trim(),
      model: _modelController.text.trim(),
      year: _yearController.text.trim(),
      pricePerHour: double.tryParse(_pricePerHourController.text) ?? 0,
      pricePerDay: double.tryParse(_pricePerDayController.text) ?? 0,
      delayPerHour: double.tryParse(_delayPerHourController.text) ?? 0,
      delayPerDay: double.tryParse(_delayPerDayController.text) ?? 0,
      extendedPrice: {
        'perHour': 200,
        'perDay': 1500,
      },
      type: _typeController.text.trim().isEmpty ? 'Sedan' : _typeController.text.trim(),
      description: _descriptionController.text.trim().isEmpty 
          ? 'Comfortable city car' 
          : _descriptionController.text.trim(),
      location: _locationController.text.trim().isEmpty ? 'Mumbai' : _locationController.text.trim(),
      carType: _carTypeController.text.trim().isEmpty ? 'Manual' : _carTypeController.text.trim(),
      fuel: _fuelController.text.trim().isEmpty ? 'Petrol' : _fuelController.text.trim(),
      seats: int.tryParse(_seatsController.text) ?? 5,
      vehicleNumber: _vehicleNumberController.text.trim().toUpperCase(),
      branchName: _branchNameController.text.trim().isEmpty 
          ? 'Main Branch' 
          : _branchNameController.text.trim(),
      branchLat: double.tryParse(_branchLatController.text) ?? 17.315289,
      branchLng: double.tryParse(_branchLngController.text) ?? 78.561221,
      isPremium: _isPremium,
      availability: [
        {
          'date': '2025/12/20',
          'timeSlots': ['09:00', '18:00']
        }
      ],
    );

    final provider = Provider.of<AuthProvider>(context, listen: false);
    final success = await provider.registerWithCar(
      owner: owner,
      car: car,
      carImages: _carImages,
      carDocs: _carDocs,
    );
print("kkkkkkkkkkkk$success");
    if (success) {
      ToastHelper.showSuccess(context, 'Registration successful!');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } else {
      ToastHelper.showError(context, provider.errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F5),
        elevation: 0,
        centerTitle: true,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                color: Colors.black87,
                onPressed: () => setState(() => _currentStep--),
              )
            : null,
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
          onTap: () {
            if (_fullNameController.text.isEmpty ||
                _mobileController.text.isEmpty ||
                _emailController.text.isEmpty ||
                _passwordController.text.isEmpty ||
                _confirmPasswordController.text.isEmpty) {
              ToastHelper.showError(context, 'Please fill all required fields');
              return;
            }
            if (_passwordController.text != _confirmPasswordController.text) {
              ToastHelper.showError(context, 'Passwords do not match');
              return;
            }
            if (_mobileController.text.length != 10) {
              ToastHelper.showError(context, 'Please enter a valid 10-digit mobile number');
              return;
            }
            setState(() => _currentStep = 1);
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
            Row(
              children: [
                Expanded(
                  child: _Field(
                    label: 'Year',
                    controller: _yearController,
                    hint: '2023',
                    keyboardType: TextInputType.number,
                    required: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Field(
                    label: 'Seats',
                    controller: _seatsController,
                    hint: '4, 5, 6, 7',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _Field(
                    label: 'Price per Hour (₹)',
                    controller: _pricePerHourController,
                    hint: '0',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Field(
                    label: 'Price per Day (₹)',
                    controller: _pricePerDayController,
                    hint: '0',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _Field(
                    label: 'Delay per Hour (₹)',
                    controller: _delayPerHourController,
                    hint: '0',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Field(
                    label: 'Delay per Day (₹)',
                    controller: _delayPerDayController,
                    hint: '0',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            _Field(
              label: 'Vehicle number',
              controller: _vehicleNumberController,
              hint: 'MH01AB1234',
              textCapitalization: TextCapitalization.characters,
              required: true,
            ),
            Row(
              children: [
                Expanded(
                  child: _Field(
                    label: 'Fuel type',
                    controller: _fuelController,
                    hint: 'Petrol / Diesel / Electric',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Field(
                    label: 'Transmission',
                    controller: _carTypeController,
                    hint: 'Manual / Automatic',
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _Field(
                    label: 'Car type',
                    controller: _typeController,
                    hint: 'Sedan / SUV / Hatchback',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Field(
                    label: 'Location',
                    controller: _locationController,
                    hint: 'City name',
                  ),
                ),
              ],
            ),
            _Field(
              label: 'Description',
              controller: _descriptionController,
              hint: 'Comfortable city car with AC',
              maxLines: 2,
            ),
            _Field(
              label: 'Branch name',
              controller: _branchNameController,
              hint: 'e.g. Andheri Branch',
            ),
            Row(
              children: [
                Expanded(
                  child: _Field(
                    label: 'Branch Latitude',
                    controller: _branchLatController,
                    hint: '17.315289',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Field(
                    label: 'Branch Longitude',
                    controller: _branchLngController,
                    hint: '78.561221',
                    keyboardType: TextInputType.number,
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
            _SecondaryButton(
              label: 'Back',
              onTap: () => setState(() => _currentStep = 0),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PrimaryButton(
                label: 'Continue',
                onTap: () {
                  if (_carNameController.text.isEmpty ||
                      _modelController.text.isEmpty ||
                      _yearController.text.isEmpty ||
                      _vehicleNumberController.text.isEmpty) {
                    ToastHelper.showError(context, 'Please fill all required car details');
                    return;
                  }
                  setState(() => _currentStep = 2);
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
                  'Upload clear photos or scanned PDFs. Files must be under 5 MB each.',
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
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Documents',
          children: [
            _UploadTile(
              label: 'RC Book / Insurance',
              files: _carDocs,
              onTap: _pickCarDocs,
              onRemove: _removeCarDoc,
              isImage: false,
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
                  Icon(Icons.error_outline, size: 16, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      provider.errorMessage,
                      style: TextStyle(fontSize: 13, color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ),
        Row(
          children: [
            _SecondaryButton(
              label: 'Back',
              onTap: () => setState(() => _currentStep = 1),
            ),
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

  // Step 4: Success
  Widget _buildSuccess() {
    return _SectionCard(
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
            child: Icon(Icons.check_rounded, color: _brandDark, size: 28),
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
            style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.6),
          ),
        ),
        const SizedBox(height: 24),
        _PrimaryButton(
          label: 'Go to Login',
          onTap: () {
            Navigator.pop(context);
          },
        ),
        const SizedBox(height: 16),
      ],
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
    final labels = ['Owner', 'Car', 'Documents'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(labels.length * 2 - 1, (i) {
          if (i.isOdd) {
            return Expanded(
              child: Container(
                height: 1,
                color: Colors.black12,
              ),
            );
          }
          final idx = i ~/ 2;
          final isDone = idx < currentStep;
          final isActive = idx == currentStep;
          return Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
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
                          size: 14,
                          color: Colors.white,
                        )
                      : Text(
                          '${idx + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isActive ? brandDark : Colors.black45,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                labels[idx],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isActive || isDone ? Colors.black87 : Colors.black45,
                ),
              ),
            ],
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

  const _SectionCard({
    required this.title,
    required this.children,
  });

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
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red.shade400,
                  ),
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

  const _PremiumToggle({
    required this.value,
    required this.onChanged,
  });

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

  const _UploadTile({
    required this.label,
    required this.files,
    required this.onTap,
    this.onRemove,
    this.isImage = true,
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
              color: hasFiles ? const Color(0xFFE1F5EE) : const Color(0xFFF7F7F5),
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
                            Text(
                              label,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF0F6E56),
                              ),
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
                          isImage ? Icons.add_photo_alternate_outlined : Icons.upload_file_outlined,
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
                              isImage ? 'Tap to upload images' : 'Tap to upload documents',
                              style: const TextStyle(fontSize: 11, color: Colors.black38),
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
        if (hasFiles && onRemove != null) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(files.length, (index) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isImage ? Icons.image_outlined : Icons.description_outlined,
                      size: 12,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'File ${index + 1}',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => onRemove?.call(index),
                      child: Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              );
            }),
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

  const _PrimaryButton({
    required this.label,
    required this.onTap,
  });

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

  const _SecondaryButton({
    required this.label,
    required this.onTap,
  });

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