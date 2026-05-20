import 'package:varahiowner/model/Staff/models/single_booking_model.dart';
import 'package:varahiowner/providers/Staff/providers/single_booking_provider.dart';
import 'package:varahiowner/views/Staff/return_upload_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CarPickupDetailsScreen extends StatefulWidget {
  final String? bookingId;
  const CarPickupDetailsScreen({Key? key, this.bookingId}) : super(key: key);

  @override
  State<CarPickupDetailsScreen> createState() => _CarPickupDetailsScreenState();
}

class _CarPickupDetailsScreenState extends State<CarPickupDetailsScreen> {
  bool isPickupExpanded = true;
  bool isReturnExpanded = false;
  bool isProceedEnabled = false;
  bool isProceed = false;
  bool isScreeshot = true;
  bool useSameDetails = false;
  bool isUploadingPaymentScreenshot = false;

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController altMobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // Date and time variables
  DateTime? returnDate;
  TimeOfDay? returnTime;
  DateTime? delayDate;
  TimeOfDay? delayTime;

  int delayAmount = 0;
  bool hasDelay = false;
  File? delayPaymentScreenshot;
  final ImagePicker _picker = ImagePicker();
  int? delayPerHour;
  int? delayPerDay;

  @override
  void initState() {
    super.initState();
    if (widget.bookingId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context
            .read<SingleBookingProvider>()
            .fetchSingleBooking(widget.bookingId!)
            .then((_) {
              final booking = context
                  .read<SingleBookingProvider>()
                  .currentBooking;
              if (booking != null) {
                setState(() {
                  delayPerHour = booking.car?.delayPerHour;
                  delayPerDay = booking.car?.delayPerDay;
                });

                _checkForAutomaticDelay();
              }
            });
      });
    }
  }

  void _checkForAutomaticDelay() {
    if (returnDate != null && returnTime != null) {
      final returnDateTime = DateTime(
        returnDate!.year,
        returnDate!.month,
        returnDate!.day,
        returnTime!.hour,
        returnTime!.minute,
      );

      final currentDateTime = DateTime.now();

      if (currentDateTime.isAfter(returnDateTime)) {
        final difference = currentDateTime.difference(returnDateTime);
        final totalHours = difference.inHours;
        final totalDays = difference.inDays;
        final remainingHours = totalHours - (totalDays * 24);

        double amount = 0;

        if (totalDays == 0) {
          amount = totalHours * delayPerHour!.toDouble();
        } else if (totalDays >= 2 && remainingHours == 0) {
          amount = totalDays * delayPerDay!.toDouble();
        } else {
          amount =
              (totalDays * delayPerDay!.toDouble()) +
              (remainingHours * delayPerHour!.toDouble());
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
          isProceedEnabled = false;
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

  bool _hasReturnDetails(Booking? booking) {
    return booking != null && booking.returnDetails.isNotEmpty;
  }

  void _populateReturnDateTimeFromBooking(Booking? booking) {
    if (booking != null) {
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

      _checkForAutomaticDelay();
    }
  }

  void _populateFromReturnDetails(Booking? booking) {
    if (booking != null && booking.returnDetails.isNotEmpty) {
      final returnDetail = booking.returnDetails[0];
      setState(() {
        nameController.text = returnDetail['name'] ?? '';
        mobileController.text = returnDetail['mobile'] ?? '';
        altMobileController.text = returnDetail['alternativeMobile'] ?? '';
        emailController.text = returnDetail['email'] ?? '';

        // Parse return date and time from returnDetails
        if (returnDetail['returnDate'] != null) {
          try {
            final dateParts = returnDetail['returnDate'].split('-');
            if (dateParts.length == 3) {
              returnDate = DateTime(
                int.parse(dateParts[0]),
                int.parse(dateParts[1]),
                int.parse(dateParts[2]),
              );
            }
          } catch (e) {
            print('Error parsing return date from returnDetails: $e');
          }
        }

        if (returnDetail['returnTime'] != null) {
          try {
            final timeStr = returnDetail['returnTime'].toString();
            final timeParts = timeStr.split(':');
            if (timeParts.length >= 2) {
              int hour = int.parse(timeParts[0]);
              int minute = int.parse(timeParts[1].split(' ')[0]);

              if (timeStr.contains('PM') && hour != 12) {
                hour += 12;
              } else if (timeStr.contains('AM') && hour == 12) {
                hour = 0;
              }

              returnTime = TimeOfDay(hour: hour, minute: minute);
            }
          } catch (e) {
            print('Error parsing return time from returnDetails: $e');
          }
        }

        // Handle delay information
        final delayTime = returnDetail['delayTime'] ?? 0;
        final delayDay = returnDetail['delayDay'] ?? 0;

        print("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk$delayTime");

        if (delayTime > 0 || delayDay > 0) {
          hasDelay = true;
          delayAmount = delayTime * 1000; // Assuming 100 per hour
        }

        isProceedEnabled = true; // Enable proceed since data is already filled
      });
    }
  }

  void _fillSameDetails(Booking? booking) {
    if (booking != null && booking.userId != null) {
      setState(() {
        nameController.text = booking.userId!.name ?? '';
        mobileController.text = booking.userId!.mobile ?? '';
        altMobileController.text = booking.userId!.mobile ?? '';
        emailController.text = booking.userId!.email ?? '';
        isProceedEnabled = true;
      });
    }
  }

  // void _calculateDelayAmount() {
  //   if (returnDate != null && returnTime != null && delayDate != null && delayTime != null) {
  //     final returnDateTime = DateTime(
  //       returnDate!.year,
  //       returnDate!.month,
  //       returnDate!.day,
  //       returnTime!.hour,
  //       returnTime!.minute,
  //     );

  //     final delayDateTime = DateTime(
  //       delayDate!.year,
  //       delayDate!.month,
  //       delayDate!.day,
  //       delayTime!.hour,
  //       delayTime!.minute,
  //     );

  //     if (delayDateTime.isAfter(returnDateTime)) {
  //       final difference = delayDateTime.difference(returnDateTime);
  //       final hoursDifference = difference.inHours;
  //       setState(() {
  //         delayAmount = hoursDifference * 100;
  //         hasDelay = true;
  //         isProceedEnabled = false;
  //         delayPaymentScreenshot = null;
  //       });
  //     } else {
  //       setState(() {
  //         delayAmount = 0;
  //         hasDelay = false;
  //         isProceedEnabled = true;
  //         delayPaymentScreenshot = null;
  //       });
  //     }
  //   } else {
  //     setState(() {
  //       delayAmount = 0;
  //       hasDelay = false;
  //       isProceedEnabled = !hasDelay;
  //     });
  //   }
  // }

  void _calculateDelayAmount() {
    print("kkkkkkkkkkkkhhhhhhhhhhhhhhhhhhhhhhhhggggggggggggggg$hasDelay");

    if (returnDate != null &&
        returnTime != null &&
        delayDate != null &&
        delayTime != null) {
      final returnDateTime = DateTime(
        returnDate!.year,
        returnDate!.month,
        returnDate!.day,
        returnTime!.hour,
        returnTime!.minute,
      );

      final delayDateTime = DateTime(
        delayDate!.year,
        delayDate!.month,
        delayDate!.day,
        delayTime!.hour,
        delayTime!.minute,
      );

      print(
        "kkkkkkkkkkkkhhhhhhhhhhhhhhhhhhhhhhhhggggggggggggggg$returnDateTime",
      );
      print(
        "kkkkkkkkkkkkhhhhhhhhhhhhhhhhhhhhhhhhggggggggggggggg$delayDateTime",
      );

      if (delayDateTime.isAfter(returnDateTime)) {
        final difference = delayDateTime.difference(returnDateTime);
        print("kkkkkkkkkkkkhhhhhhhhhhhhhhhhhhhhhhhhggggggggggggggg$difference");

        final totalHours = difference.inHours;
        final totalDays = difference.inDays;
        final remainingHours = totalHours - (totalDays * 24);
        print("kkkkkkkkkkkkhhhhhhhhhhhhhhhhhhhhhhhhggggggggggggggg$totalHours");

        print("Total Days$totalDays");

        print(
          "kkkkkkkkkkkkhhhhhhhhhhhhhhhhhhhhhhhhggggggggggggggg$remainingHours",
        );

        double amount = 0;

        if (totalDays == 0) {
          // Less than 24 hours → charge only by hours
          print("Amonuttttttttttttttttt$delayPerHour");

          amount = totalHours * delayPerHour!.toDouble();
          print("Amonuttttttttttttttt$amount");
        } else if (totalDays >= 2 && remainingHours == 0) {
          // Full days only → charge by days
          amount = totalDays * delayPerDay!.toDouble();
          print("Amonut11111111111111111$amount");
        } else {
          // Mix of days + hours → charge both
          print("ppppppppppppppp${delayPerDay!.toDouble()}");
          print("ppppppppppppppp${delayPerHour!.toDouble()}");

          amount =
              (totalDays * delayPerDay!.toDouble()) +
              (remainingHours * delayPerHour!.toDouble());

          print("Amonut2222222222222$amount");
        }

        print("Delay amonytttttttttt$delayAmount");

        setState(() {
          delayAmount = amount.round(); // converts double → int
          hasDelay = true;
          isProceedEnabled = false;
          delayPaymentScreenshot = null;
        });

        print("Delay amonytttttttttt$delayAmount");

        print("kkkkkkkkkkkkhhhhhhhhhhhhhhhhhhhhhhhhggggggggggggggg$hasDelay");
      } else {
        print("okokokokokokokookokkokok$hasDelay");

        setState(() {
          delayAmount = 0;
          hasDelay = false;
          isProceedEnabled = true;
          delayPaymentScreenshot = null;
        });
      }
    } else {
      setState(() {
        delayAmount = 0;
        hasDelay = false;
        isProceedEnabled = !hasDelay;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isReturn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isReturn) {
          returnDate = picked;
        } else {
          delayDate = picked;
        }
      });
      _calculateDelayAmount();
    }
  }

  Future<void> _selectTime(BuildContext context, bool isReturn) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        if (isReturn) {
          returnTime = picked;
        } else {
          delayTime = picked;
        }
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
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
          'https://varahibackend.varahiselfdrivecars.com/api/staff/upload-delaypaymentproof/${widget.bookingId}',
        ),
      );

      request.files.add(
        await http.MultipartFile.fromPath('paymentScreenshot', imageFile.path),
      );

      var response = await request.send();

      print(
        "rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr${response}",
      );

      if (response.statusCode == 200) {
        setState(() {
          delayPaymentScreenshot = imageFile;
          isScreeshot = true;
          isProceedEnabled = true;
          isUploadingPaymentScreenshot = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment screenshot uploaded successfully'),
          ),
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload error: $e')));
    }
  }

  Future<dynamic> _submitReturnData(hasReturnDetails) async {
    if (widget.bookingId == null) return;

    try {
      print(
        "kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk$hasReturnDetails",
      );
      if (!hasReturnDetails) {
        final url =
            'https://varahibackend.varahiselfdrivecars.com/api/staff/sendreturnotp/${widget.bookingId}';

        int delayTimeHours = 0;
        int delayDays = 0;

        if (hasDelay &&
            returnDate != null &&
            returnTime != null &&
            delayDate != null &&
            delayTime != null) {
          final returnDateTime = DateTime(
            returnDate!.year,
            returnDate!.month,
            returnDate!.day,
            returnTime!.hour,
            returnTime!.minute,
          );

          final delayDateTime = DateTime(
            delayDate!.year,
            delayDate!.month,
            delayDate!.day,
            delayTime!.hour,
            delayTime!.minute,
          );

          final difference = delayDateTime.difference(returnDateTime);
          delayTimeHours = difference.inHours;
          delayDays = difference.inDays;
        }

        final requestBody = {
          "name": nameController.text,
          "email": emailController.text,
          "mobile": mobileController.text,
          "alternativeMobile": altMobileController.text,
          "returnTime": returnTime != null ? returnTime!.format(context) : "",
          "returnDate": returnDate != null
              ? "${returnDate!.year}-${returnDate!.month.toString().padLeft(2, '0')}-${returnDate!.day.toString().padLeft(2, '0')}"
              : "",
          "delayTime": delayTimeHours,
          "delayDay": delayDays,
        };

        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestBody),
        );

        if (response.statusCode == 200) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ReturnUploadScreen(id: widget.bookingId!),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.statusCode}')),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ReturnUploadScreen(id: widget.bookingId!),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network Error: $e')));
    }
  }

  /// 🔴 OPTIONAL: Update balance amount status section
  Widget _buildBalanceStatusSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Balance Amount Status (Optional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Mark balance amount as settled if customer has paid.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text(
                  'Update Balance Status',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green,
                  side: const BorderSide(color: Colors.green),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _showBalanceConfirmationDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBalanceConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Confirm Action'),
        content: const Text(
          'Are you sure you want to mark the balance amount as paid?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              Navigator.pop(context);
              _updateBalanceAmountStatus();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateBalanceAmountStatus() async {
    if (widget.bookingId == null) return;

    try {
      final response = await http.put(
        Uri.parse(
          'https://varahibackend.varahiselfdrivecars.com/api/staff/replacedpaymentstatus/${widget.bookingId}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"staffPaymentStatus": "paid"}),
      );

      print("kkkkkkkkkkkkkkkkkkkkkkk${response.body}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Balance amount marked as paid'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status (${response.statusCode})'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Consumer<SingleBookingProvider>(
        builder: (context, bookingProvider, child) {
          if (bookingProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

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
                      if (widget.bookingId != null) {
                        bookingProvider.fetchSingleBooking(widget.bookingId!);
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final booking = bookingProvider.currentBooking;
          final hasReturnDetails = _hasReturnDetails(booking);

          // Auto-populate data when first loaded
          // if (booking != null && returnDate == null && returnTime == null) {
          //   WidgetsBinding.instance.addPostFrameCallback((_) {
          //     if (hasReturnDetails) {
          //       _populateFromReturnDetails(booking);
          //     } else {
          //       _populateReturnDateTimeFromBooking(booking);
          //     }
          //   });
          // }

          // Auto-populate data when first loaded
          if (booking != null && returnDate == null && returnTime == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (hasReturnDetails) {
                _populateFromReturnDetails(booking);
              } else {
                _populateReturnDateTimeFromBooking(booking);
              }
              // Check for delay after populating data
              _checkForAutomaticDelay();
            });
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
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
                          "ID: ${booking?.id != null ? booking!.id.substring(booking!.id.length - 4) : (widget.bookingId != null ? widget.bookingId!.substring(widget.bookingId!.length - 4) : '----')}",
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
                  _buildCarDetailsCard(booking, screenWidth),
                  const SizedBox(height: 30),

                  if ((booking?.carReplacementHistory?.staffPaymentDue ?? 0) >
                      0) ...[
                    _buildBalanceStatusSection(),
                    const SizedBox(height: 30),
                  ],

                  // Pickup Section
                  _buildCollapsibleSection(
                    title: 'Pickup details',
                    isExpanded: isPickupExpanded,
                    onTap: () {
                      setState(() {
                        isPickupExpanded = !isPickupExpanded;
                      });
                    },
                    child: isPickupExpanded
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 25),
                              // const Text(
                              //   'Pickup Details',
                              //   style: TextStyle(
                              //       fontSize: 18, fontWeight: FontWeight.bold),
                              // ),
                              _buildDisplayField(
                                icon: Icons.person_outline,
                                label: 'Name',
                                value: booking?.userId?.name ?? 'Not Available',
                              ),
                              _buildDisplayField(
                                icon: Icons.phone_outlined,
                                label: 'Mobile Number',
                                value:
                                    booking?.userId?.mobile ?? 'Not Available',
                              ),
                              _buildDisplayField(
                                icon: Icons.phone_outlined,
                                label: 'Alternate Mobile Number',
                                value:
                                    booking?.userId?.mobile ?? 'Not Available',
                              ),
                              _buildDisplayField(
                                icon: Icons.email_outlined,
                                label: 'Email',
                                value:
                                    booking?.userId?.email ?? 'Not Available',
                              ),
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
                                      value:
                                          booking?.rentalStartDate ?? 'Not set',
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20, thickness: 1),
                              _buildSecurityDepositSection(),
                            ],
                          )
                        : const SizedBox(),
                  ),

                  const SizedBox(height: 10),

                  // Return Section
                  _buildCollapsibleSection(
                    title: 'Return Details',
                    isExpanded: isReturnExpanded,
                    onTap: () {
                      setState(() {
                        isReturnExpanded = !isReturnExpanded;
                      });
                    },
                    child: isReturnExpanded
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 25),
                              Row(
                                children: [
                                  // const Text(
                                  //   'Return Details',
                                  //   style: TextStyle(
                                  //       fontSize: 18, fontWeight: FontWeight.bold),
                                  // ),
                                  if (hasReturnDetails) ...[
                                    const SizedBox(width: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.green.shade300,
                                        ),
                                      ),
                                      child: const Text(
                                        'Completed',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),

                              // Show checkbox only if no return details exist
                              if (!hasReturnDetails) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: useSameDetails,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            useSameDetails = value ?? false;
                                            if (useSameDetails) {
                                              isProceed = true;

                                              _fillSameDetails(booking);
                                            } else {
                                              nameController.clear();
                                              mobileController.clear();
                                              altMobileController.clear();
                                              emailController.clear();
                                              isProceedEnabled = false;
                                              isProceed = false;
                                            }
                                          });
                                        },
                                      ),
                                      const Text(
                                        'Use same details as pickup',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              // Show fields based on whether return details exist
                              if (hasReturnDetails) ...[
                                // Read-only display fields
                                _buildDisplayField(
                                  icon: Icons.person_outline,
                                  label: 'Name',
                                  value: nameController.text.isNotEmpty
                                      ? nameController.text
                                      : 'Not Available',
                                ),
                                _buildDisplayField(
                                  icon: Icons.phone_outlined,
                                  label: 'Mobile Number',
                                  value: mobileController.text.isNotEmpty
                                      ? mobileController.text
                                      : 'Not Available',
                                ),
                                _buildDisplayField(
                                  icon: Icons.phone_outlined,
                                  label: 'Alternate Mobile Number',
                                  value: altMobileController.text.isNotEmpty
                                      ? altMobileController.text
                                      : 'Not Available',
                                ),
                                _buildDisplayField(
                                  icon: Icons.email_outlined,
                                  label: 'Email',
                                  value: emailController.text.isNotEmpty
                                      ? emailController.text
                                      : 'Not Available',
                                ),
                              ] else ...[
                                // Editable input fields
                                _buildInputField(
                                  icon: Icons.person_outline,
                                  label: 'Name',
                                  controller: nameController,
                                ),
                                _buildInputField(
                                  icon: Icons.phone_outlined,
                                  label: 'Mobile Number',
                                  controller: mobileController,
                                ),
                                _buildInputField(
                                  icon: Icons.phone_outlined,
                                  label: 'Alternate Mobile Number',
                                  controller: altMobileController,
                                ),
                                _buildInputField(
                                  icon: Icons.email_outlined,
                                  label: 'Email',
                                  controller: emailController,
                                ),
                              ],

                              // Return time and date (always read-only)
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDisplayField(
                                      icon: Icons.access_time_outlined,
                                      label: 'Return time',
                                      value:
                                          returnTime?.format(context) ??
                                          'Not set',
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Fixed code to extract only date part
                                  Expanded(
                                    child: _buildDisplayField(
                                      icon: Icons.calendar_today_outlined,
                                      label: 'Return date',
                                      // value: returnDate != null
                                      //     ? "${returnDate!.year}-${returnDate!.month.toString().padLeft(2, '0')}-${returnDate!.day.toString().padLeft(2, '0')}"
                                      //     : (hasReturnDetails &&
                                      //             booking?.returnDetails
                                      //                     .isNotEmpty ==
                                      //                 true &&
                                      //             booking!.returnDetails[0]
                                      //                     ['returnDate'] !=
                                      //                 null)
                                      //         ? booking!.returnDetails[0]
                                      //                 ['returnDate']
                                      //             .toString()
                                      //             .split('T')[0]
                                      //         : 'Not set',
                                      value:
                                          booking?.rentalEndDate ?? "Not Set",
                                    ),
                                  ),
                                ],
                              ),

                              // Delay information - only show editable if no return details
                              // if (!hasReturnDetails) ...[
                              //   const Padding(
                              //     padding: EdgeInsets.all(16.0),
                              //     child: Text(
                              //       'Delay Information (Optional)',
                              //       style: TextStyle(
                              //         fontSize: 16,
                              //         fontWeight: FontWeight.bold,
                              //         color: Colors.orange,
                              //       ),
                              //     ),
                              //   ),
                              //   Row(
                              //     children: [
                              //       Expanded(
                              //         child: _buildDateTimeField(
                              //           icon: Icons.timelapse_outlined,
                              //           label: 'Delay time',
                              //           value: delayTime?.format(context) ??
                              //               'Select time',
                              //           onTap: () =>
                              //               _selectTime(context, false),
                              //         ),
                              //       ),
                              //       const SizedBox(width: 10),
                              //       Expanded(
                              //         child: _buildDateTimeField(
                              //           icon: Icons.date_range_outlined,
                              //           label: 'Delay date',
                              //           value: delayDate != null
                              //               ? "${delayDate!.day}/${delayDate!.month}/${delayDate!.year}"
                              //               : 'Select date',
                              //           onTap: () =>
                              //               _selectDate(context, false),
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ] else if (hasDelay) ...[
                              //   // Show delay info as read-only if return details exist and has delay
                              //   const Padding(
                              //     padding: EdgeInsets.all(16.0),
                              //     child: Text(
                              //       'Delay Information',
                              //       style: TextStyle(
                              //         fontSize: 16,
                              //         fontWeight: FontWeight.bold,
                              //         color: Colors.orange,
                              //       ),
                              //     ),
                              //   ),
                              //   Padding(
                              //     padding:
                              //         EdgeInsets.symmetric(horizontal: 16.0),
                              //     child: Text(
                              //       'Delay Time: ${booking?.returnDetails[0]['delayTime']} hr',
                              //       style: TextStyle(
                              //         fontSize: 14,
                              //         color: const Color.fromARGB(255, 0, 0, 0),
                              //         fontWeight: FontWeight.w500,
                              //       ),
                              //     ),
                              //   ),
                              //   const Padding(
                              //     padding:
                              //         EdgeInsets.symmetric(horizontal: 16.0),
                              //     child: Text(
                              //       'Delay charges applied',
                              //       style: TextStyle(
                              //         fontSize: 14,
                              //         color: Color.fromARGB(255, 0, 0, 0),
                              //         fontWeight: FontWeight.w500,
                              //       ),
                              //     ),
                              //   ),
                              // ],
                            ],
                          )
                        : const SizedBox(),
                  ),

                  const SizedBox(height: 10),

                  // Show delay amount and screenshot upload when there's delay
                  if (hasDelay && !hasReturnDetails) ...[
                    _buildDelayAmountDisplay(),
                    _buildScreenshotUploadSection(),
                  ] else if (hasDelay && hasReturnDetails) ...[
                    // _buildDelayAmountDisplay(),
                    // Show existing delay payment screenshots if they exist
                    _buildExistingDelayScreenshots(booking),
                  ],

                  const SizedBox(height: 130),
                  _buildButtons(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExistingDelayScreenshots(Booking? booking) {
    // This method would show existing delay payment screenshots from booking data
    // You'll need to add delay payment screenshot URLs to your booking model
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Screenshot',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green, width: 2),
              borderRadius: BorderRadius.circular(8),
              color: Colors.green.shade50,
            ),
            child: Stack(
              children: [
                const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 40, color: Colors.green),
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
                  ),
                ),
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
        ],
      ),
    );
  }

  // Continue from the existing code - this is the remaining part

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
              child: const Text(
                'Payment Required',
                style: TextStyle(
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  // Widget _buildExistingDelayScreenshots(Booking? booking) {
  //   // Check if booking has delay payment screenshots
  //   final hasDelayScreenshots = booking?.returnDetails.isNotEmpty == true &&
  //       booking!.returnDetails[0]['delayPaymentScreenshot'] != null;

  //   if (!hasDelayScreenshots) return const SizedBox();

  //   return Padding(
  //     padding: const EdgeInsets.all(16.0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text(
  //           'Payment Screenshot',
  //           style: TextStyle(
  //             fontSize: 16,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         const SizedBox(height: 12),
  //         Container(
  //           height: 150,
  //           width: double.infinity,
  //           decoration: BoxDecoration(
  //             border: Border.all(color: Colors.green, width: 2),
  //             borderRadius: BorderRadius.circular(8),
  //             color: Colors.green.shade50,
  //           ),
  //           child: Stack(
  //             children: [
  //               Center(
  //                 child: GestureDetector(
  //                   onTap: () {
  //                     // Show full image dialog
  //                     _showImageDialog(booking!.returnDetails[0]['delayPaymentScreenshot']);
  //                   },
  //                   child: const Column(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       Icon(
  //                         Icons.image,
  //                         size: 40,
  //                         color: Colors.green,
  //                       ),
  //                       SizedBox(height: 8),
  //                       Text(
  //                         'Payment Screenshot Uploaded',
  //                         style: TextStyle(
  //                           color: Colors.green,
  //                           fontSize: 14,
  //                           fontWeight: FontWeight.w500,
  //                         ),
  //                       ),
  //                       SizedBox(height: 4),
  //                       Text(
  //                         'Tap to view',
  //                         style: TextStyle(
  //                           color: Colors.grey,
  //                           fontSize: 12,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //               Positioned(
  //                 top: 8,
  //                 right: 8,
  //                 child: Container(
  //                   decoration: const BoxDecoration(
  //                     color: Colors.green,
  //                     shape: BoxShape.circle,
  //                   ),
  //                   child: const Icon(
  //                     Icons.check,
  //                     color: Colors.white,
  //                     size: 20,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: double.maxFinite,
            height: 400,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Payment Screenshot',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                Expanded(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(child: Text('Failed to load image'));
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCarDetailsCard(Booking? booking, double screenWidth) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                const SizedBox(width: 4),
                Text(
                  '${booking?.rentalEndDate ?? 'Not set'}',
                  style: const TextStyle(color: Colors.black87, fontSize: 13),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16, color: Colors.blue),
                const SizedBox(width: 4),
                Text(
                  '${booking?.to ?? 'Not set'}',
                  style: const TextStyle(color: Colors.black87, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildCarDetailsCard(Booking? booking, double screenWidth) {
  //   return Container(
  //     width: double.infinity,
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.grey.withOpacity(0.1),
  //           spreadRadius: 1,
  //           blurRadius: 5,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             booking?.car?.carName ?? 'Car Name',
  //             style: TextStyle(
  //               fontSize: screenWidth * 0.05,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //           const SizedBox(height: 8),
  //           Text(
  //             booking?.car?.model ?? 'Car Model',
  //             style: TextStyle(
  //               fontSize: screenWidth * 0.04,
  //               color: Colors.grey[600],
  //             ),
  //           ),
  //           const SizedBox(height: 12),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               _buildCarDetailItem(
  //                 'Number Plate',
  //                 booking?.car?.vehicleNumber ?? 'N/A',
  //                 screenWidth,
  //               ),
  //               // _buildCarDetailItem(
  //               //   'Fuel Type',
  //               //   booking?.car?.?? 'N/A',
  //               //   screenWidth,
  //               // ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildCarDetailItem(String label, String value, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: screenWidth * 0.03,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsibleSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: child,
            ),
        ],
      ),
    );
  }

  Widget _buildDisplayField({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  isProceedEnabled =
                      nameController.text.isNotEmpty &&
                      mobileController.text.isNotEmpty &&
                      altMobileController.text.isNotEmpty &&
                      emailController.text.isNotEmpty &&
                      returnDate != null &&
                      returnTime != null;
                  // (!hasDelay || delayPaymentScreenshot != null);
                });
              },
            ),
          ),
        ],
      ),
    );
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(value, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityDepositSection() {
    return Consumer<SingleBookingProvider>(
      builder: (context, bookingProvider, child) {
        final booking = bookingProvider.currentBooking;

        // Get deposit proof images from booking data
        final depositProof = booking?.depositeProof ?? [];

        print('kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk$depositProof');

        // Create a list of security deposit images
        List<Map<String, String>> securityImages = [];

        // Add deposit proof images (front and back of security deposit item)
        for (var proof in depositProof) {
          String title = 'Security Deposit';
          if (proof.label == 'depositeFront') {
            title = 'Security Deposit - Front';
          } else if (proof.label == 'depositeBack') {
            title = 'Security Deposit - Back';
          }

          securityImages.add({'title': title, 'url': proof.url ?? ''});
        }

        // If no deposit images available, show placeholders for front and back
        if (securityImages.isEmpty) {
          securityImages = [
            {'title': 'Security Deposit - Front', 'url': ''},
            {'title': 'Security Deposit - Back', 'url': ''},
          ];
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Security Deposit',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: securityImages.length,
                itemBuilder: (context, index) {
                  final imageData = securityImages[index];
                  return _buildSecurityDocumentCard(
                    title: imageData['title']!,
                    imageUrl: imageData['url']!,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSecurityDocumentCard({
    required String title,
    required String imageUrl,
  }) {
    return Container(
      height: 206,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade200,
      ),
      child: Stack(
        children: [
          // Main image
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade300,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Image not available',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            // Placeholder when no image URL
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade300,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.security, size: 40, color: Colors.grey.shade600),
                  const SizedBox(height: 8),
                  Text(
                    'Security Deposit',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          // Title overlay at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildSecurityDepositSection() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         'Security Deposit',
  //         style: TextStyle(
  //           fontSize: 16,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //       const SizedBox(height: 8),
  //       Container(
  //         padding: const EdgeInsets.all(12),
  //         decoration: BoxDecoration(
  //           color: Colors.green.shade50,
  //           borderRadius: BorderRadius.circular(8),
  //           border: Border.all(color: Colors.green.shade200),
  //         ),
  //         child: const Row(
  //           children: [
  //             Icon(Icons.check_circle, color: Colors.green, size: 20),
  //             SizedBox(width: 8),
  //             Text(
  //               'Security deposit collected',
  //               style: TextStyle(
  //                 color: Colors.green,
  //                 fontWeight: FontWeight.w500,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildButtons() {
    final hasReturnDetails = _hasReturnDetails(
      context.read<SingleBookingProvider>().currentBooking,
    );

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed:
                  ((hasReturnDetails || isProceed) &&
                      isProceedEnabled &&
                      isScreeshot)
                  ? () => _submitReturnData(hasReturnDetails)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: (hasReturnDetails || isProceedEnabled)
                    ? const Color.fromARGB(255, 255, 0, 0)
                    : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Proceed',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    altMobileController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
