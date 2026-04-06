// ═════════════════════════════════════════════════════════════════════════════
// MyCarScreen  –  view & update full vehicle details
// ═════════════════════════════════════════════════════════════════════════════

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart'; // image_picker in pubspec

// ─────────────────────────────────────────────────────────────────────────────
// Brand tokens
// ─────────────────────────────────────────────────────────────────────────────

const _brand = Color(0xFF1D9E75);
const _brandLight = Color(0xFFE1F5EE);
const _brandDark = Color(0xFF0F6E56);

// ─────────────────────────────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────────────────────────────

class _CarData {
  String make;
  String model;
  String year;
  String color;
  String registrationNumber;
  String chassisNumber;
  String engineNumber;
  String fuelType;
  String vehicleType;
  String seatingCapacity;
  String insurancePolicyNumber;
  String insuranceExpiry;
  String rcExpiry;
  String fitnessExpiry;
  String permitExpiry;

  _CarData({
    this.make = 'Maruti Suzuki',
    this.model = 'Ertiga',
    this.year = '2022',
    this.color = 'Pearl White',
    this.registrationNumber = 'KL 01 AB 1234',
    this.chassisNumber = 'MA3ERLF1S00123456',
    this.engineNumber = 'K15BN1234567',
    this.fuelType = 'Petrol',
    this.vehicleType = 'SUV',
    this.seatingCapacity = '7',
    this.insurancePolicyNumber = 'INS-2024-00789',
    this.insuranceExpiry = '31/12/2025',
    this.rcExpiry = '15/08/2037',
    this.fitnessExpiry = '15/08/2026',
    this.permitExpiry = '20/06/2025',
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class MyCarScreen extends StatefulWidget {
  const MyCarScreen({super.key});

  @override
  State<MyCarScreen> createState() => _MyCarScreenState();
}

class _MyCarScreenState extends State<MyCarScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final _data = _CarData();
  bool _saving = false;
  File? _carImage;

  // Controllers – basic info
  late final _makeCtrl = TextEditingController(text: _data.make);
  late final _modelCtrl = TextEditingController(text: _data.model);
  late final _yearCtrl = TextEditingController(text: _data.year);
  late final _colorCtrl = TextEditingController(text: _data.color);
  late final _regCtrl = TextEditingController(text: _data.registrationNumber);
  late final _chassisCtrl = TextEditingController(text: _data.chassisNumber);
  late final _engineCtrl = TextEditingController(text: _data.engineNumber);
  late final _seatingCtrl = TextEditingController(text: _data.seatingCapacity);

  // Dropdowns
  String _fuelType = 'Petrol';
  String _vehicleType = 'SUV';

  // Controllers – documents
  late final _insurancePolicyCtrl = TextEditingController(
    text: _data.insurancePolicyNumber,
  );
  late final _insuranceExpiryCtrl = TextEditingController(
    text: _data.insuranceExpiry,
  );
  late final _rcExpiryCtrl = TextEditingController(text: _data.rcExpiry);
  late final _fitnessExpiryCtrl = TextEditingController(
    text: _data.fitnessExpiry,
  );
  late final _permitExpiryCtrl = TextEditingController(
    text: _data.permitExpiry,
  );

  static const _fuelTypes = ['Petrol', 'Diesel', 'CNG', 'Electric', 'Hybrid'];
  static const _vehicleTypes = [
    'Sedan',
    'SUV',
    'Hatchback',
    'Van',
    'Mini Bus',
    'Auto',
  ];

  // ── Pick car photo ────────────────────────────────────────────────────────

  Future<void> _pickCarImage() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1C1C1A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vehicle photo',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              _SheetTile(
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                isDark: isDark,
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              const SizedBox(height: 10),
              _SheetTile(
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                isDark: isDark,
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    if (source == null) return;
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
    );
    if (picked != null) setState(() => _carImage = File(picked.path));
  }

  // ── Date picker ───────────────────────────────────────────────────────────

  Future<void> _pickDate(TextEditingController ctrl) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2040),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _brand,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      ctrl.text =
          '${picked.day.toString().padLeft(2, '0')}/'
          '${picked.month.toString().padLeft(2, '0')}/'
          '${picked.year}';
    }
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    // TODO: hook up to your API / state management
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Vehicle details updated successfully'),
        backgroundColor: _brand,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    for (final c in [
      _makeCtrl,
      _modelCtrl,
      _yearCtrl,
      _colorCtrl,
      _regCtrl,
      _chassisCtrl,
      _engineCtrl,
      _seatingCtrl,
      _insurancePolicyCtrl,
      _insuranceExpiryCtrl,
      _rcExpiryCtrl,
      _fitnessExpiryCtrl,
      _permitExpiryCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF111110) : const Color(0xFFF7F7F5);
    final cardColor = isDark ? const Color(0xFF1C1C1A) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.07);
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textMuted = isDark ? Colors.white54 : Colors.black45;
    final inputFill = isDark
        ? const Color(0xFF242422)
        : const Color(0xFFF7F7F5);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            child: Icon(Icons.arrow_back_rounded, size: 18, color: textPrimary),
          ),
        ),
        title: Text(
          'My Vehicle',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textPrimary,
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
              // ── Vehicle photo ──────────────────────────────────────────
              _CarPhotoBanner(
                carImage: _carImage,
                isDark: isDark,
                cardColor: cardColor,
                borderColor: borderColor,
                textMuted: textMuted,
                textPrimary: textPrimary,
                onTap: _pickCarImage,
              ),

              const SizedBox(height: 20),

              // ── Registration number hero chip ─────────────────────────
              _RegNumberHero(
                regNumber: _regCtrl.text,
                cardColor: cardColor,
                borderColor: borderColor,
                textPrimary: textPrimary,
              ),

              const SizedBox(height: 20),

              // ── Basic details ─────────────────────────────────────────
              _SectionLabel(label: 'Basic details', textMuted: textMuted),
              const SizedBox(height: 8),
              _FieldCard(
                cardColor: cardColor,
                borderColor: borderColor,
                children: [
                  _FieldRow(
                    children: [
                      _CarField(
                        label: 'Make',
                        controller: _makeCtrl,
                        hint: 'e.g. Maruti',
                        icon: Icons.directions_car_outlined,
                        fillColor: inputFill,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        validator: _required,
                      ),
                      const SizedBox(width: 12),
                      _CarField(
                        label: 'Model',
                        controller: _modelCtrl,
                        hint: 'e.g. Ertiga',
                        icon: Icons.drive_eta_outlined,
                        fillColor: inputFill,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        validator: _required,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _FieldRow(
                    children: [
                      _CarField(
                        label: 'Year',
                        controller: _yearCtrl,
                        hint: 'e.g. 2022',
                        icon: Icons.calendar_today_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        fillColor: inputFill,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          final y = int.tryParse(v);
                          if (y == null || y < 1990 || y > 2030) {
                            return 'Invalid year';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(width: 12),
                      _CarField(
                        label: 'Color',
                        controller: _colorCtrl,
                        hint: 'e.g. White',
                        icon: Icons.palette_outlined,
                        fillColor: inputFill,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        validator: _required,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _FieldRow(
                    children: [
                      Expanded(
                        child: _DropdownField(
                          label: 'Fuel type',
                          value: _fuelType,
                          items: _fuelTypes,
                          icon: Icons.local_gas_station_outlined,
                          fillColor: inputFill,
                          borderColor: borderColor,
                          textPrimary: textPrimary,
                          textMuted: textMuted,
                          onChanged: (v) => setState(() => _fuelType = v!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DropdownField(
                          label: 'Vehicle type',
                          value: _vehicleType,
                          items: _vehicleTypes,
                          icon: Icons.category_outlined,
                          fillColor: inputFill,
                          borderColor: borderColor,
                          textPrimary: textPrimary,
                          textMuted: textMuted,
                          onChanged: (v) => setState(() => _vehicleType = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _CarField(
                    label: 'Seating capacity',
                    controller: _seatingCtrl,
                    hint: 'e.g. 7',
                    icon: Icons.event_seat_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    fillColor: inputFill,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textMuted: textMuted,
                    validator: _required,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Registration details ───────────────────────────────────
              _SectionLabel(
                label: 'Registration details',
                textMuted: textMuted,
              ),
              const SizedBox(height: 8),
              _FieldCard(
                cardColor: cardColor,
                borderColor: borderColor,
                children: [
                  _CarField(
                    label: 'Registration number',
                    controller: _regCtrl,
                    hint: 'e.g. KL 01 AB 1234',
                    icon: Icons.badge_outlined,
                    textCapitalization: TextCapitalization.characters,
                    fillColor: inputFill,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textMuted: textMuted,
                    validator: _required,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 14),
                  _CarField(
                    label: 'Chassis number (VIN)',
                    controller: _chassisCtrl,
                    hint: 'e.g. MA3ERLF1S00123456',
                    icon: Icons.tag_outlined,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                      LengthLimitingTextInputFormatter(17),
                    ],
                    fillColor: inputFill,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textMuted: textMuted,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (v.length < 10) return 'Too short';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _CarField(
                    label: 'Engine number',
                    controller: _engineCtrl,
                    hint: 'e.g. K15BN1234567',
                    icon: Icons.settings_outlined,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                      LengthLimitingTextInputFormatter(20),
                    ],
                    fillColor: inputFill,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textMuted: textMuted,
                    validator: _required,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Documents & expiry ─────────────────────────────────────
              _SectionLabel(label: 'Documents & expiry', textMuted: textMuted),
              const SizedBox(height: 8),
              _FieldCard(
                cardColor: cardColor,
                borderColor: borderColor,
                children: [
                  _CarField(
                    label: 'Insurance policy number',
                    controller: _insurancePolicyCtrl,
                    hint: 'e.g. INS-2024-00789',
                    icon: Icons.shield_outlined,
                    fillColor: inputFill,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textMuted: textMuted,
                    validator: _required,
                  ),
                  const SizedBox(height: 14),
                  _FieldRow(
                    children: [
                      _DateField(
                        label: 'Insurance expiry',
                        controller: _insuranceExpiryCtrl,
                        fillColor: inputFill,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        onTap: () => _pickDate(_insuranceExpiryCtrl),
                        expiryStatus: _expiryStatus(_insuranceExpiryCtrl.text),
                      ),
                      const SizedBox(width: 12),
                      _DateField(
                        label: 'RC expiry',
                        controller: _rcExpiryCtrl,
                        fillColor: inputFill,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        onTap: () => _pickDate(_rcExpiryCtrl),
                        expiryStatus: _expiryStatus(_rcExpiryCtrl.text),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _FieldRow(
                    children: [
                      _DateField(
                        label: 'Fitness expiry',
                        controller: _fitnessExpiryCtrl,
                        fillColor: inputFill,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        onTap: () => _pickDate(_fitnessExpiryCtrl),
                        expiryStatus: _expiryStatus(_fitnessExpiryCtrl.text),
                      ),
                      const SizedBox(width: 12),
                      _DateField(
                        label: 'Permit expiry',
                        controller: _permitExpiryCtrl,
                        fillColor: inputFill,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        onTap: () => _pickDate(_permitExpiryCtrl),
                        expiryStatus: _expiryStatus(_permitExpiryCtrl.text),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Expiry legend ──────────────────────────────────────────
              _ExpiryLegend(cardColor: cardColor, borderColor: borderColor),

              const SizedBox(height: 28),

              // ── Update button ──────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brand,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _brand.withOpacity(0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline_rounded, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Update vehicle details',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

String? _required(String? v) =>
    (v == null || v.trim().isEmpty) ? 'Required' : null;

/// Returns: 0 = valid, 1 = expiring soon (≤ 30 days), 2 = expired
int _expiryStatus(String dateStr) {
  try {
    final parts = dateStr.split('/');
    if (parts.length != 3) return 0;
    final date = DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
    final diff = date.difference(DateTime.now()).inDays;
    if (diff < 0) return 2;
    if (diff <= 30) return 1;
    return 0;
  } catch (_) {
    return 0;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color textMuted;
  const _SectionLabel({required this.label, required this.textMuted});

  @override
  Widget build(BuildContext context) => Text(
    label.toUpperCase(),
    style: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: textMuted,
      letterSpacing: 0.8,
    ),
  );
}

// ── Car photo banner ──────────────────────────────────────────────────────────

class _CarPhotoBanner extends StatelessWidget {
  final File? carImage;
  final bool isDark;
  final Color cardColor, borderColor, textMuted, textPrimary;
  final VoidCallback onTap;

  const _CarPhotoBanner({
    required this.carImage,
    required this.isDark,
    required this.cardColor,
    required this.borderColor,
    required this.textMuted,
    required this.textPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        clipBehavior: Clip.hardEdge,
        child: carImage != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(carImage!, fit: BoxFit.cover),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.camera_alt_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Change photo',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _brandLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.directions_car_rounded,
                      size: 26,
                      color: _brand,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Add vehicle photo',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to upload from camera or gallery',
                    style: TextStyle(fontSize: 12, color: textMuted),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Registration number hero ──────────────────────────────────────────────────

class _RegNumberHero extends StatelessWidget {
  final String regNumber;
  final Color cardColor, borderColor, textPrimary;

  const _RegNumberHero({
    required this.regNumber,
    required this.cardColor,
    required this.borderColor,
    required this.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _brandLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _brand.withOpacity(0.3), width: 1.5),
            ),
            child: Text(
              regNumber.isNotEmpty ? regNumber : 'KL 00 XX 0000',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _brandDark,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Registration number',
                style: TextStyle(
                  fontSize: 11,
                  color: textPrimary.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Government of India',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _brand,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Field card wrapper ────────────────────────────────────────────────────────

class _FieldCard extends StatelessWidget {
  final List<Widget> children;
  final Color cardColor, borderColor;

  const _FieldCard({
    required this.children,
    required this.cardColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: borderColor),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}

// ── Field row (two columns) ───────────────────────────────────────────────────

class _FieldRow extends StatelessWidget {
  final List<Widget> children;
  const _FieldRow({required this.children});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: children
        .map((c) => c is SizedBox ? c : Expanded(child: c))
        .toList(),
  );
}

// ── Text field ────────────────────────────────────────────────────────────────

class _CarField extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final Color fillColor, borderColor, textPrimary, textMuted;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const _CarField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.words,
    this.inputFormatters,
    required this.fillColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textMuted,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textMuted,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13, color: textMuted),
            filled: true,
            fillColor: fillColor,
            prefixIcon: Icon(icon, size: 16, color: textMuted),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _brand, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Dropdown ──────────────────────────────────────────────────────────────────

class _DropdownField extends StatelessWidget {
  final String label, value;
  final List<String> items;
  final IconData icon;
  final Color fillColor, borderColor, textPrimary, textMuted;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.icon,
    required this.fillColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textMuted,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textMuted,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: textMuted,
          ),
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
          dropdownColor: fillColor,
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColor,
            prefixIcon: Icon(icon, size: 16, color: textMuted),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _brand, width: 1.5),
            ),
          ),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
        ),
      ],
    );
  }
}

// ── Date field (tap-to-pick) ──────────────────────────────────────────────────

class _DateField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Color fillColor, borderColor, textPrimary, textMuted;
  final VoidCallback onTap;
  final int expiryStatus; // 0 ok, 1 warning, 2 expired

  const _DateField({
    required this.label,
    required this.controller,
    required this.fillColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textMuted,
    required this.onTap,
    required this.expiryStatus,
  });

  Color get _statusColor {
    switch (expiryStatus) {
      case 1:
        return const Color(0xFFBA7517);
      case 2:
        return Colors.redAccent;
      default:
        return _brand;
    }
  }

  IconData get _statusIcon {
    switch (expiryStatus) {
      case 1:
        return Icons.warning_amber_rounded;
      case 2:
        return Icons.error_outline_rounded;
      default:
        return Icons.check_circle_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textMuted,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 4),
            if (expiryStatus > 0)
              Icon(_statusIcon, size: 11, color: _statusColor),
          ],
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            child: TextFormField(
              controller: controller,
              readOnly: true,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: expiryStatus > 0 ? _statusColor : textPrimary,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: expiryStatus == 2
                    ? Colors.redAccent.withOpacity(0.06)
                    : expiryStatus == 1
                    ? const Color(0xFFFAEEDA)
                    : fillColor,
                prefixIcon: Icon(
                  Icons.event_available_outlined,
                  size: 16,
                  color: expiryStatus > 0 ? _statusColor : textMuted,
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 13,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: expiryStatus > 0
                        ? _statusColor.withOpacity(0.4)
                        : borderColor,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: expiryStatus > 0
                        ? _statusColor.withOpacity(0.4)
                        : borderColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: _statusColor, width: 1.5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Expiry legend ─────────────────────────────────────────────────────────────

class _ExpiryLegend extends StatelessWidget {
  final Color cardColor, borderColor;
  const _ExpiryLegend({required this.cardColor, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DOCUMENT STATUS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _brand,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _LegendDot(color: _brand),
              const SizedBox(width: 6),
              const Text(
                'Valid',
                style: TextStyle(fontSize: 12, color: _brandDark),
              ),
              const SizedBox(width: 18),
              _LegendDot(color: const Color(0xFFBA7517)),
              const SizedBox(width: 6),
              const Text(
                'Expiring within 30 days',
                style: TextStyle(fontSize: 12, color: Color(0xFFBA7517)),
              ),
              const SizedBox(width: 18),
              _LegendDot(color: Colors.redAccent),
              const SizedBox(width: 6),
              const Text(
                'Expired',
                style: TextStyle(fontSize: 12, color: Colors.redAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  const _LegendDot({required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: 9,
    height: 9,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

// ── Bottom sheet tile ─────────────────────────────────────────────────────────

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _SheetTile({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF242422) : const Color(0xFFF7F7F5);
    final fg = isDark ? Colors.white : Colors.black87;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: _brand),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
