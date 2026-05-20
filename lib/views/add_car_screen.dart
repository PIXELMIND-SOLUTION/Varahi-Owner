import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:varahiowner/helpers/toast_helper.dart';
import 'package:varahiowner/providers/car_provider.dart';
import 'package:location/location.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _isGettingLocation = false;

  // Controllers for Car Details
  final _carNameCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _pricePerHourCtrl = TextEditingController();
  final _pricePerDayCtrl = TextEditingController();
  final _delayPerHourCtrl = TextEditingController();
  final _delayPerDayCtrl = TextEditingController();
  final _typeCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _carTypeCtrl = TextEditingController();
  final _fuelCtrl = TextEditingController();
  final _seatsCtrl = TextEditingController();
  final _vehicleNumberCtrl = TextEditingController();
  final _branchNameCtrl = TextEditingController();
  final _branchLatCtrl = TextEditingController();
  final _branchLngCtrl = TextEditingController();

  bool _isPremium = false;
  List<File> _carImages = [];
  List<File> _carDocs = [];

  // Dropdown options
  final List<String> _fuelTypes = [
    'Petrol',
    'Diesel',
    'CNG',
    'Electric',
    'Hybrid',
  ];
  final List<String> _carTypes = [
    'Sedan',
    'SUV',
    'Hatchback',
    'Van',
    'Mini Bus',
  ];
  final List<String> _transmissions = ['Manual', 'Automatic'];

  final Location _location = Location();

  Future<void> _pickImages(bool isCarImage) async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        if (isCarImage) {
          _carImages.addAll(picked.map((p) => File(p.path)));
        } else {
          _carDocs.addAll(picked.map((p) => File(p.path)));
        }
      });
      ToastHelper.showSuccess(context, '${picked.length} file(s) selected');
    }
  }

  void _removeImage(int index, bool isCarImage) {
    setState(() {
      if (isCarImage) {
        _carImages.removeAt(index);
      } else {
        _carDocs.removeAt(index);
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      // Check if location service is enabled
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          ToastHelper.showError(
            context,
            'Location service is disabled. Please enable it.',
          );
          setState(() {
            _isGettingLocation = false;
          });
          return;
        }
      }

      // Check permission
      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          ToastHelper.showError(
            context,
            'Location permission is required to get current location.',
          );
          setState(() {
            _isGettingLocation = false;
          });
          return;
        }
      }

      // Get current location
      final LocationData locationData = await _location.getLocation();

      setState(() {
        _branchLatCtrl.text =
            locationData.latitude?.toStringAsFixed(6) ?? '0.0';
        _branchLngCtrl.text =
            locationData.longitude?.toStringAsFixed(6) ?? '0.0';
        _isGettingLocation = false;
      });

      ToastHelper.showSuccess(
        context,
        'Location captured\nLat: ${locationData.latitude?.toStringAsFixed(6)}\nLng: ${locationData.longitude?.toStringAsFixed(6)}',
      );
    } catch (e) {
      setState(() {
        _isGettingLocation = false;
      });
      ToastHelper.showError(context, 'Failed to get location: $e');
    }
  }

  Future<void> _submitAddCar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_carImages.isEmpty) {
      ToastHelper.showError(context, 'Please upload at least one car image');
      return;
    }

    if (_carDocs.isEmpty) {
      ToastHelper.showError(context, 'Please upload car documents');
      return;
    }

    final fields = <String, String>{
      'carName': _carNameCtrl.text.trim(),
      'model': _modelCtrl.text.trim(),
      'year': _yearCtrl.text.trim(),
      'pricePerHour': _pricePerHourCtrl.text,
      'pricePerDay': _pricePerDayCtrl.text,
      'delayPerHour': _delayPerHourCtrl.text,
      'delayPerDay': _delayPerDayCtrl.text,
      'extendedPrice': '{"perHour":200,"perDay":1500}',
      'type': _typeCtrl.text.trim(),
      'description': _descriptionCtrl.text.trim(),
      'location': _locationCtrl.text.trim(),
      'carType': _carTypeCtrl.text.trim(),
      'fuel': _fuelCtrl.text.trim(),
      'seats': _seatsCtrl.text,
      'vehicleNumber': _vehicleNumberCtrl.text.trim().toUpperCase(),
      'branchName': _branchNameCtrl.text.trim(),
      'branchLat': _branchLatCtrl.text,
      'branchLng': _branchLngCtrl.text,
      'isPremium': _isPremium.toString(),
      'availability': '[{"date":"2025/12/20","timeSlots":["09:00","18:00"]}]',
    };

    final provider = Provider.of<CarProvider>(context, listen: false);
    final success = await provider.addCar(
      fields: fields,
      carImages: _carImages,
      carDocs: _carDocs,
    );

    if (success && mounted) {
      ToastHelper.showSuccess(context, 'Car added successfully!');
      Navigator.pop(context, true);
    } else if (mounted) {
      ToastHelper.showError(context, provider.errorMessage);
    }
  }

  @override
  void dispose() {
    _carNameCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _pricePerHourCtrl.dispose();
    _pricePerDayCtrl.dispose();
    _delayPerHourCtrl.dispose();
    _delayPerDayCtrl.dispose();
    _typeCtrl.dispose();
    _descriptionCtrl.dispose();
    _locationCtrl.dispose();
    _carTypeCtrl.dispose();
    _fuelCtrl.dispose();
    _seatsCtrl.dispose();
    _vehicleNumberCtrl.dispose();
    _branchNameCtrl.dispose();
    _branchLatCtrl.dispose();
    _branchLngCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CarProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF111110)
          : const Color(0xFFF7F7F5),
      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF111110)
            : const Color(0xFFF7F7F5),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add New Car',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Car Images Section
              _ImageUploadSection(
                label: 'Car Images *',
                files: _carImages,
                onTap: () => _pickImages(true),
                onRemove: (index) => _removeImage(index, true),
                isDark: isDark,
              ),

              const SizedBox(height: 20),

              // Documents Section
              _ImageUploadSection(
                label: 'Documents (RC, Insurance) *',
                files: _carDocs,
                onTap: () => _pickImages(false),
                onRemove: (index) => _removeImage(index, false),
                isDark: isDark,
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),

              // Car Details Section
              _SectionLabel('Car Details', isDark),
              const SizedBox(height: 12),
              _buildTextField(
                _carNameCtrl,
                'Car Name',
                'e.g. Maruti Swift',
                Icons.directions_car,
                isDark,
                true,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                _modelCtrl,
                'Model',
                'e.g. ZXI, VXI',
                Icons.model_training,
                isDark,
                true,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _yearCtrl,
                      'Year',
                      '2023',
                      Icons.calendar_today,
                      isDark,
                      true,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      _seatsCtrl,
                      'Seats',
                      '5',
                      Icons.event_seat,
                      isDark,
                      true,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              // const SizedBox(height: 12),
              // Row(
              //   children: [
              //     Expanded(child: _buildTextField(_pricePerHourCtrl, 'Price/Hour (₹)', '0', Icons.currency_rupee, isDark, true, keyboardType: TextInputType.number)),
              //     const SizedBox(width: 12),
              //     Expanded(child: _buildTextField(_pricePerDayCtrl, 'Price/Day (₹)', '0', Icons.currency_rupee, isDark, true, keyboardType: TextInputType.number)),
              //   ],
              // ),
              // const SizedBox(height: 12),
              // Row(
              //   children: [
              //     Expanded(child: _buildTextField(_delayPerHourCtrl, 'Delay/Hour (₹)', '0', Icons.timer, isDark, true, keyboardType: TextInputType.number)),
              //     const SizedBox(width: 12),
              //     Expanded(child: _buildTextField(_delayPerDayCtrl, 'Delay/Day (₹)', '0', Icons.timer, isDark, true, keyboardType: TextInputType.number)),
              //   ],
              // ),
              const SizedBox(height: 12),
              _buildTextField(
                _vehicleNumberCtrl,
                'Vehicle Number',
                'MH01AB1234',
                Icons.badge,
                isDark,
                true,
              ),
              const SizedBox(height: 12),
              _buildDropdownField(
                _fuelCtrl,
                'Fuel Type',
                _fuelTypes,
                isDark,
                true,
              ),
              const SizedBox(height: 12),
              _buildDropdownField(
                _carTypeCtrl,
                'Car Type',
                _carTypes,
                isDark,
                true,
              ),
              const SizedBox(height: 12),
              _buildDropdownField(
                _typeCtrl,
                'Transmission',
                _transmissions,
                isDark,
                true,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                _descriptionCtrl,
                'Description',
                'Car description',
                Icons.description,
                isDark,
                false,
                maxLines: 3,
              ),

              const SizedBox(height: 20),

              // Location Details
              _SectionLabel('Location Details', isDark),
              const SizedBox(height: 12),
              _buildTextField(
                _locationCtrl,
                'Location',
                'City name',
                Icons.location_on,
                isDark,
                false,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                _branchNameCtrl,
                'Branch Name',
                'e.g. Andheri Branch',
                Icons.business,
                isDark,
                false,
              ),
              const SizedBox(height: 12),

              // Lat/Long with Get Current Location Button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildTextField(
                      _branchLatCtrl,
                      'Latitude *',
                      'e.g. 17.315289',
                      Icons.map,
                      isDark,
                      true,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                      _branchLngCtrl,
                      'Longitude *',
                      'e.g. 78.561221',
                      Icons.map,
                      isDark,
                      true,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Get Current Location Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isGettingLocation ? null : _getCurrentLocation,
                  icon: _isGettingLocation
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location, size: 18),
                  label: Text(
                    _isGettingLocation
                        ? 'Getting Location...'
                        : 'Get Current Location',
                    style: const TextStyle(fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFF242422)
                        : const Color(0xFFF0F0EE),
                    foregroundColor: const Color(0xFF1D9E75),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Premium Toggle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1C1A) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Premium Listing',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Switch(
                      value: _isPremium,
                      onChanged: (val) => setState(() => _isPremium = val),
                      activeColor: const Color(0xFF1D9E75),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: provider.isAdding ? null : _submitAddCar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D9E75),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: provider.isAdding
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Add Vehicle',
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
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon,
    bool isDark,
    bool required, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      obscureText: obscureText,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: isDark ? const Color(0xFF1C1C1A) : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1D9E75), width: 1.5),
        ),
      ),
      validator: required
          ? (v) => v == null || v.isEmpty ? 'Required' : null
          : null,
    );
  }

  Widget _buildDropdownField(
    TextEditingController controller,
    String label,
    List<String> items,
    bool isDark,
    bool required,
  ) {
    return DropdownButtonFormField<String>(
      value: controller.text.isEmpty ? null : controller.text,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        prefixIcon: const Icon(Icons.arrow_drop_down, size: 20),
        filled: true,
        fillColor: isDark ? const Color(0xFF1C1C1A) : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (value) {
        if (value != null) {
          controller.text = value;
        }
      },
      validator: required
          ? (value) =>
                value == null || value.isEmpty ? 'Please select $label' : null
          : null,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionLabel(this.label, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white70 : Colors.black54,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _ImageUploadSection extends StatelessWidget {
  final String label;
  final List<File> files;
  final VoidCallback onTap;
  final Function(int) onRemove;
  final bool isDark;

  const _ImageUploadSection({
    required this.label,
    required this.files,
    required this.onTap,
    required this.onRemove,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label, isDark),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1A) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
              ),
            ),
            child: files.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 30,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to add files',
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: files.length,
                    itemBuilder: (context, index) => Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(8),
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(files[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => onRemove(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
