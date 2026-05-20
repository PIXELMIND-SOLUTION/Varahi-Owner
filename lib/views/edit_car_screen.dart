import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:varahiowner/helpers/toast_helper.dart';
import 'package:varahiowner/providers/car_provider.dart';
import 'package:varahiowner/providers/auth_provider.dart';

class EditCarScreen extends StatefulWidget {
  final String carId;
  const EditCarScreen({super.key, required this.carId});

  @override
  State<EditCarScreen> createState() => _EditCarScreenState();
}

class _EditCarScreenState extends State<EditCarScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;

  // Controllers
  late final TextEditingController _carNameCtrl;
  late final TextEditingController _modelCtrl;
  late final TextEditingController _yearCtrl;
  late final TextEditingController _pricePerHourCtrl;
  late final TextEditingController _pricePerDayCtrl;
  late final TextEditingController _delayPerHourCtrl;
  late final TextEditingController _delayPerDayCtrl;
  late final TextEditingController _typeCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _carTypeCtrl;
  late final TextEditingController _fuelCtrl;
  late final TextEditingController _seatsCtrl;
  late final TextEditingController _vehicleNumberCtrl;
  late final TextEditingController _branchNameCtrl;
  late final TextEditingController _branchLatCtrl;
  late final TextEditingController _branchLngCtrl;

  bool _isPremium = false;
  List<File> _newCarImages = [];
  List<File> _newCarDocs = [];
  List<String> _existingCarImages = [];
  List<String> _existingCarDocs = [];

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

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadCarData();
  }

  void _initializeControllers() {
    _carNameCtrl = TextEditingController();
    _modelCtrl = TextEditingController();
    _yearCtrl = TextEditingController();
    _pricePerHourCtrl = TextEditingController();
    _pricePerDayCtrl = TextEditingController();
    _delayPerHourCtrl = TextEditingController();
    _delayPerDayCtrl = TextEditingController();
    _typeCtrl = TextEditingController();
    _descriptionCtrl = TextEditingController();
    _locationCtrl = TextEditingController();
    _carTypeCtrl = TextEditingController();
    _fuelCtrl = TextEditingController();
    _seatsCtrl = TextEditingController();
    _vehicleNumberCtrl = TextEditingController();
    _branchNameCtrl = TextEditingController();
    _branchLatCtrl = TextEditingController();
    _branchLngCtrl = TextEditingController();
  }

  Future<void> _loadCarData() async {
    final provider = Provider.of<CarProvider>(context, listen: false);
    final success = await provider.fetchCarById(widget.carId);

    if (success && provider.selectedCar != null) {
      final car = provider.selectedCar!;
      setState(() {
        _carNameCtrl.text = car.carName;
        _modelCtrl.text = car.model;
        _yearCtrl.text = car.year;
        _pricePerHourCtrl.text = car.pricePerHour.toString();
        _pricePerDayCtrl.text = car.pricePerDay.toString();
        _delayPerHourCtrl.text = car.delayPerHour.toString();
        _delayPerDayCtrl.text = car.delayPerDay.toString();
        _typeCtrl.text = car.type;
        _descriptionCtrl.text = car.description;
        _locationCtrl.text = car.location;
        _carTypeCtrl.text = car.carType;
        _fuelCtrl.text = car.fuel;
        _seatsCtrl.text = car.seats.toString();
        _vehicleNumberCtrl.text = car.vehicleNumber;
        _branchNameCtrl.text = car.branchName;
        _branchLatCtrl.text = car.branchLat.toString();
        _branchLngCtrl.text = car.branchLng.toString();
        _isPremium = car.isPremium;
        _existingCarImages = List.from(car.carImage);
        _existingCarDocs = List.from(car.carDocs);
        _isLoading = false;
      });
    } else if (mounted) {
      ToastHelper.showError(context, provider.errorMessage);
      Navigator.pop(context);
    }
  }

  Future<void> _pickImages(bool isCarImage) async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        if (isCarImage) {
          _newCarImages.addAll(picked.map((p) => File(p.path)));
        } else {
          _newCarDocs.addAll(picked.map((p) => File(p.path)));
        }
      });
      ToastHelper.showSuccess(context, '${picked.length} file(s) selected');
    }
  }

  void _removeExistingImage(int index, bool isCarImage) {
    setState(() {
      if (isCarImage) {
        _existingCarImages.removeAt(index);
      } else {
        _existingCarDocs.removeAt(index);
      }
    });
  }

  void _removeNewImage(int index, bool isCarImage) {
    setState(() {
      if (isCarImage) {
        _newCarImages.removeAt(index);
      } else {
        _newCarDocs.removeAt(index);
      }
    });
  }

  Future<void> _updateCar() async {
    if (!_formKey.currentState!.validate()) return;

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
    final success = await provider.updateCar(
      carId: widget.carId,
      fields: fields,
      carImages: _newCarImages,
      carDocs: _newCarDocs,
    );

    if (success && mounted) {
      ToastHelper.showSuccess(context, 'Car updated successfully');
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

    if (_isLoading || provider.isLoading) {
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
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Vehicle',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          if (provider.isUpdating)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Existing Images
              if (_existingCarImages.isNotEmpty) ...[
                _SectionLabel('Existing Car Images', isDark),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _existingCarImages.length,
                    itemBuilder: (context, index) => Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(_existingCarImages[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 16,
                          child: GestureDetector(
                            onTap: () => _removeExistingImage(index, true),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // New Car Images
              _ImageUploadSection(
                label: 'Add New Car Images',
                files: _newCarImages,
                onTap: () => _pickImages(true),
                onRemove: (index) => _removeNewImage(index, true),
                isDark: isDark,
              ),

              const SizedBox(height: 20),

              // Basic Details
              _SectionLabel('Basic Details', isDark),
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
              //     Expanded(
              //       child: _buildTextField(
              //         _delayPerHourCtrl,
              //         'Delay/Hour (₹)',
              //         '0',
              //         Icons.timer,
              //         isDark,
              //         true,
              //         keyboardType: TextInputType.number,
              //       ),
              //     ),
              //     const SizedBox(width: 12),
              //     Expanded(
              //       child: _buildTextField(
              //         _delayPerDayCtrl,
              //         'Delay/Day (₹)',
              //         '0',
              //         Icons.timer,
              //         isDark,
              //         true,
              //         keyboardType: TextInputType.number,
              //       ),
              //     ),
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
              _buildDropdownField(_fuelCtrl, 'Fuel Type', _fuelTypes, isDark),
              const SizedBox(height: 12),
              _buildDropdownField(_carTypeCtrl, 'Car Type', _carTypes, isDark),
              const SizedBox(height: 12),
              _buildDropdownField(
                _typeCtrl,
                'Transmission',
                _transmissions,
                isDark,
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
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _branchLatCtrl,
                      'Latitude',
                      '0.0',
                      Icons.map,
                      isDark,
                      false,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      _branchLngCtrl,
                      'Longitude',
                      '0.0',
                      Icons.map,
                      isDark,
                      false,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Premium Toggle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1C1A) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
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

              // Update Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: provider.isUpdating ? null : _updateCar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D9E75),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: provider.isUpdating
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Update Vehicle',
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
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
  // Update the _buildDropdownField method in EditCarScreen

  Widget _buildDropdownField(
    TextEditingController controller,
    String label,
    List<String> items,
    bool isDark,
  ) {
    // Find if the current value exists in items
    String? currentValue = controller.text.isEmpty ? null : controller.text;
    if (currentValue != null && !items.contains(currentValue)) {
      currentValue = null; // Reset if value not in list
    }

    return DropdownButtonFormField<String>(
      value: currentValue,
      decoration: InputDecoration(
        labelText: label,
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select $label';
        }
        return null;
      },
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
                          'Tap to add images',
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
