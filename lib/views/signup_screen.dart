import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:varahiowner/model/vendor_model.dart';
import 'package:varahiowner/providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  int _currentStep = 0;

  // Step 1 — Owner
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _idProofController = TextEditingController();

  // Step 2 — Vehicle
  final _carNameController = TextEditingController();
  final _regNumberController = TextEditingController();
  final _modelYearController = TextEditingController();
  String? _fuelType;
  String? _seatCapacity;

  // Step 3 — Documents
  PlatformFile? _rcFile;
  PlatformFile? _insuranceFile;

  static const _brand = Color(0xFF1D9E75);
  static const _brandLight = Color(0xFFE1F5EE);
  static const _brandDark = Color(0xFF0F6E56);

  final _fuelOptions = ['Petrol', 'Diesel', 'CNG', 'Electric', 'Hybrid'];
  final _seatOptions = ['4 seats', '5 seats', '6 seats', '7 seats'];

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _idProofController.dispose();
    _carNameController.dispose();
    _regNumberController.dispose();
    _modelYearController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(bool isRc) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        if (isRc) {
          _rcFile = result.files.first;
        } else {
          _insuranceFile = result.files.first;
        }
      });
    }
  }

  void _submit() {
    final provider = Provider.of<AuthProvider>(context, listen: false);
    final vendor = VendorModel(
      name: _nameController.text.trim(),
      mobile: _mobileController.text.trim(),
      idProof: _idProofController.text.trim(),
      carName: _carNameController.text.trim(),
      modelNumber: _modelYearController.text.trim(),
      registerNumber: _regNumberController.text.trim(),
      fuelType: _fuelType ?? '',
      carDocument: _rcFile?.path ?? '',
      pickupLocation: '',
      latitude: 0.0,
      longitude: 0.0,
    );
    provider.register(vendor);
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
          'Vendor registration',
          style: TextStyle(
            fontFamily: 'sans-serif',
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

  // ─── Step 1: Owner details ───────────────────────────────────────────────

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionCard(
          title: 'Owner details',
          children: [
            _Field(
              label: 'Full name',
              controller: _nameController,
              hint: 'As on ID proof',
            ),
            _Field(
              label: 'Mobile number',
              controller: _mobileController,
              hint: '+91 98765 43210',
              keyboardType: TextInputType.phone,
            ),
            _Field(
              label: 'ID proof number',
              controller: _idProofController,
              hint: 'Aadhaar / PAN / Passport',
            ),
          ],
        ),
        const SizedBox(height: 16),
        _PrimaryButton(
          label: 'Continue',
          onTap: () {
            if (_nameController.text.isEmpty ||
                _mobileController.text.isEmpty ||
                _idProofController.text.isEmpty) {
              _showError('Please fill all owner details.');
              return;
            }
            setState(() => _currentStep = 1);
          },
        ),
      ],
    );
  }

  // ─── Step 2: Vehicle details ─────────────────────────────────────────────

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionCard(
          title: 'Vehicle details',
          children: [
            _Field(
              label: 'Car name / make',
              controller: _carNameController,
              hint: 'e.g. Maruti Swift',
            ),
            _Field(
              label: 'Registration number',
              controller: _regNumberController,
              hint: 'KL 01 AB 1234',
              textCapitalization: TextCapitalization.characters,
            ),
            Row(
              children: [
                Expanded(
                  child: _DropdownField(
                    label: 'Fuel type',
                    value: _fuelType,
                    items: _fuelOptions,
                    onChanged: (v) => setState(() => _fuelType = v),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DropdownField(
                    label: 'Seating capacity',
                    value: _seatCapacity,
                    items: _seatOptions,
                    onChanged: (v) => setState(() => _seatCapacity = v),
                  ),
                ),
              ],
            ),
            _Field(
              label: 'Model year',
              controller: _modelYearController,
              hint: '2021',
              keyboardType: TextInputType.number,
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
                      _regNumberController.text.isEmpty ||
                      _fuelType == null) {
                    _showError('Please fill all vehicle details.');
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

  // ─── Step 3: Documents ───────────────────────────────────────────────────

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
          title: 'Vehicle documents',
          children: [
            _UploadTile(
              label: 'RC Book / Registration Certificate',
              file: _rcFile,
              onTap: () => _pickFile(true),
            ),
            const SizedBox(height: 10),
            _UploadTile(
              label: 'Insurance certificate',
              file: _insuranceFile,
              onTap: () => _pickFile(false),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (provider.statusMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              provider.statusMessage,
              style: const TextStyle(fontSize: 13, color: Colors.redAccent),
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
                  ? const Center(child: CircularProgressIndicator())
                  : _PrimaryButton(
                      label: 'Submit registration',
                      onTap: () {
                        if (_rcFile == null) {
                          _showError('Please upload the RC book.');
                          return;
                        }
                        _submit();
                        setState(() => _currentStep = 3);
                      },
                    ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Step 4: Success ─────────────────────────────────────────────────────

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
            'Registration submitted',
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
        const SizedBox(height: 16),
      ],
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ─── Step bar ─────────────────────────────────────────────────────────────────

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
    final labels = ['Owner', 'Vehicle', 'Documents'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(labels.length * 2 - 1, (i) {
          if (i.isOdd) {
            return Expanded(child: Container(height: 1, color: Colors.black12));
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
                            fontSize: 12,
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
                  fontSize: 12,
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

// ─── Section card ─────────────────────────────────────────────────────────────

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

// ─── Text field ───────────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;

  const _Field({
    required this.label,
    required this.controller,
    this.hint = '',
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.words,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
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

// ─── Dropdown field ───────────────────────────────────────────────────────────

class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 5),
          DropdownButtonFormField<String>(
            value: value,
            hint: const Text(
              'Select',
              style: TextStyle(fontSize: 14, color: Colors.black26),
            ),
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: Colors.black45,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
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
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// ─── Upload tile ──────────────────────────────────────────────────────────────

class _UploadTile extends StatelessWidget {
  final String label;
  final PlatformFile? file;
  final VoidCallback onTap;

  const _UploadTile({
    required this.label,
    required this.file,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = file != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: hasFile ? const Color(0xFFE1F5EE) : const Color(0xFFF7F7F5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasFile
                ? const Color(0xFF1D9E75).withOpacity(0.4)
                : Colors.black12,
            width: hasFile ? 1.0 : 0.5,
          ),
        ),
        child: hasFile
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
                          file!.name,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1D9E75),
                          ),
                          overflow: TextOverflow.ellipsis,
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
                    child: const Icon(
                      Icons.upload_file_outlined,
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
                        const Text(
                          'Tap to upload  •  PDF, JPG, PNG',
                          style: TextStyle(fontSize: 11, color: Colors.black38),
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
    );
  }
}

// ─── Buttons ──────────────────────────────────────────────────────────────────

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
