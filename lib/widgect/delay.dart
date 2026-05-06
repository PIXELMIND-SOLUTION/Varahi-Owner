import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class DelayHandlingSection extends StatefulWidget {
  final String bookingId;
  final int? delayPerHour;
  final int? delayPerDay;
  final DateTime? returnDate;
  final TimeOfDay? returnTime;
  final bool hasReturnDetails;

  const DelayHandlingSection({
    Key? key,
    required this.bookingId,
    this.delayPerHour,
    this.delayPerDay,
    this.returnDate,
    this.returnTime,
    required this.hasReturnDetails,
  }) : super(key: key);

  @override
  State<DelayHandlingSection> createState() => _DelayHandlingSectionState();
}

class _DelayHandlingSectionState extends State<DelayHandlingSection> {
  DateTime? delayDate;
  TimeOfDay? delayTime;
  int delayAmount = 0;
  bool hasDelay = false;
  File? delayPaymentScreenshot;
  final ImagePicker _picker = ImagePicker();
  bool isScreeshot = true;
  bool isUploadingPaymentScreenshot = false;

  @override
  void initState() {
    super.initState();
    _checkForAutomaticDelay();
  }

  void _checkForAutomaticDelay() {
    if (widget.returnDate != null && widget.returnTime != null) {
      final returnDateTime = DateTime(
        widget.returnDate!.year,
        widget.returnDate!.month,
        widget.returnDate!.day,
        widget.returnTime!.hour,
        widget.returnTime!.minute,
      );

      final currentDateTime = DateTime.now();

      if (currentDateTime.isAfter(returnDateTime)) {
        final difference = currentDateTime.difference(returnDateTime);
        var totalHours = difference.inHours;
        final totalDays = difference.inDays;
        final remainingHours = totalHours - (totalDays * 24);

        double amount = 0;

        if (totalDays == 0) {
          if (totalHours == 0) {
            totalHours = 1;
          }
          amount = totalHours * (widget.delayPerHour ?? 100).toDouble();
          print("sfjlfldskfjkfdkjfklfjlfjljfjflfjdfjl000;$totalHours");
          print(
              "sfjlfldskfjkfdkjfklfjlfjljfjflfjdfjl000;${widget.delayPerHour}");

          print("sfjlfldskfjkfdkjfklfjlfjljfjflfjdfjl;$amount");
        } else if (totalDays >= 2 && remainingHours == 0) {
          amount = totalDays * (widget.delayPerDay ?? 1000).toDouble();
          print("sfjlfldskfjkfdkjfklfjlfjljfjflfjdfj2;$amount");
        } else {
          amount = (totalDays * (widget.delayPerDay ?? 1000).toDouble()) +
              (remainingHours * (widget.delayPerHour ?? 100).toDouble());
          print("sfjlfldskfjkfdkjfklfjlfjljfjflfjdfj3;$amount");
        }

        setState(() {
          delayDate = DateTime(
            currentDateTime.year,
            currentDateTime.month,
            currentDateTime.day,
          );
          delayTime = TimeOfDay(
            hour: currentDateTime.hour,
            minute: currentDateTime.minute,
          );
          delayAmount = amount.round();
          isScreeshot = false;
          hasDelay = true;
          delayPaymentScreenshot = null;
        });
      } else {
        setState(() {
          hasDelay = false;
          delayAmount = 0;
          delayDate = null;
          delayTime = null;
          delayPaymentScreenshot = null;
        });
      }
    }
  }

  void _calculateDelayAmount() {
    if (widget.returnDate != null &&
        widget.returnTime != null &&
        delayDate != null &&
        delayTime != null) {
      final returnDateTime = DateTime(
        widget.returnDate!.year,
        widget.returnDate!.month,
        widget.returnDate!.day,
        widget.returnTime!.hour,
        widget.returnTime!.minute,
      );

      final delayDateTime = DateTime(
        delayDate!.year,
        delayDate!.month,
        delayDate!.day,
        delayTime!.hour,
        delayTime!.minute,
      );

      if (delayDateTime.isAfter(returnDateTime)) {
        final difference = delayDateTime.difference(returnDateTime);
        final totalHours = difference.inHours;
        final totalDays = difference.inDays;
        final remainingHours = totalHours - (totalDays * 24);

        double amount = 0;

        if (totalDays == 0) {
          amount = totalHours * (widget.delayPerHour ?? 100).toDouble();
        } else if (totalDays >= 2 && remainingHours == 0) {
          amount = totalDays * (widget.delayPerDay ?? 1000).toDouble();
        } else {
          amount = (totalDays * (widget.delayPerDay ?? 1000).toDouble()) +
              (remainingHours * (widget.delayPerHour ?? 100).toDouble());
        }

        setState(() {
          delayAmount = amount.round();
          hasDelay = true;
          isScreeshot = false;
          delayPaymentScreenshot = null;
        });
      } else {
        setState(() {
          delayAmount = 0;
          hasDelay = false;
          delayPaymentScreenshot = null;
        });
      }
    } else {
      setState(() {
        delayAmount = 0;
        hasDelay = false;
        delayPaymentScreenshot = null;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        delayDate = picked;
      });
      _calculateDelayAmount();
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        delayTime = picked;
      });
      _calculateDelayAmount();
    }
  }

  Future<void> _pickDelayPaymentScreenshotBottomSheet() async {
    try {
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.cancel),
                  title: const Text('Cancel'),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
        },
      );

      if (source == null) return;

      final XFile? image = await _picker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 80,
      );

      if (image != null) {
        await _uploadDelayPaymentScreenshot(File(image.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _uploadDelayPaymentScreenshot(File imageFile) async {
    setState(() {
      isUploadingPaymentScreenshot = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://varahibackend.varahiselfdrivecars.com/api/staff/upload-delaypaymentproof/${widget.bookingId}'),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'paymentScreenshot',
          imageFile.path,
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        setState(() {
          delayPaymentScreenshot = imageFile;
          isScreeshot = true;
          isUploadingPaymentScreenshot = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Payment screenshot uploaded successfully')),
        );
      } else {
        setState(() {
          isUploadingPaymentScreenshot = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() {
        isUploadingPaymentScreenshot = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload error: $e')),
      );
    }
  }

  Widget _buildDateTimeField({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDelayAmountDisplay() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Delay Charges',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹$delayAmount',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                isScreeshot ? 'Payment Uploaded' : 'Payment Required',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenshotUploadSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload Payment Screenshot',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap:
                delayPaymentScreenshot == null && !isUploadingPaymentScreenshot
                    ? _pickDelayPaymentScreenshotBottomSheet
                    : null,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: delayPaymentScreenshot != null
                      ? Colors.green
                      : Colors.grey.shade400,
                  width: 2,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(8),
                color: delayPaymentScreenshot != null
                    ? Colors.green.shade50
                    : Colors.grey.shade50,
              ),
              child: Stack(
                children: [
                  Center(
                    child: isUploadingPaymentScreenshot
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 8),
                              Text(
                                'Uploading...',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          )
                        : delayPaymentScreenshot != null
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 40,
                                    color: Colors.green,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Payment Screenshot Uploaded',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cloud_upload_outlined,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Tap to upload payment screenshot',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                  ),
                  if (delayPaymentScreenshot != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
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

  @override
  Widget build(BuildContext context) {
    print(
        "kkkkkkkkkkkkkkkkkkkkkgggggggggggggggggggggffffffffffffffffffffff${widget.bookingId}");
    print(
        "kkkkkkkkkkkkkkkkkkkkkgggggggggggggggggggggffffffffffffffffffffff${widget.delayPerDay}");
    print(
        "kkkkkkkkkkkkkkkkkkkkkgggggggggggggggggggggffffffffffffffffffffff${widget.delayPerHour}");
    print(
        "kkkkkkkkkkkkkkkkkkkkkgggggggggggggggggggggffffffffffffffffffffff${widget.hasReturnDetails}");
    print(
        "kkkkkkkkkkkkkkkkkkkkkgggggggggggggggggggggffffffffffffffffffffff${widget.returnDate}");
    print(
        "kkkkkkkkkkkkkkkkkkkkkgggggggggggggggggggggffffffffffffffffffffff${widget.returnTime}");
    if (widget.hasReturnDetails) {
      // If return details already exist, don't show delay section
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Delay Information (Optional)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ),

        // Delay date and time selection
        Row(
          children: [
            Expanded(
              child: _buildDateTimeField(
                icon: Icons.timelapse_outlined,
                label: 'Delay time',
                value: delayTime?.format(context) ?? 'Select time',
                onTap: () => _selectTime(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildDateTimeField(
                icon: Icons.date_range_outlined,
                label: 'Delay date',
                value: delayDate != null
                    ? "${delayDate!.day}/${delayDate!.month}/${delayDate!.year}"
                    : 'Select date',
                onTap: () => _selectDate(context),
              ),
            ),
          ],
        ),

        // Show delay amount and screenshot upload when there's delay
        if (hasDelay) ...[
          _buildDelayAmountDisplay(),
          _buildScreenshotUploadSection(),
        ],
      ],
    );
  }
}
