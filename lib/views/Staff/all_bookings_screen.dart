// import 'dart:io';
// import 'package:varahiowner/model/Staff/models/single_booking_model.dart';
// import 'package:varahiowner/providers/Staff/providers/single_booking_provider.dart';
// import 'package:varahiowner/views/Staff/booking_detail_screen.dart';
// import 'package:varahiowner/widgect/custom_search.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:dio/dio.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:open_file/open_file.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:provider/provider.dart';

// class AllBookingsScreen extends StatefulWidget {
//   const AllBookingsScreen({super.key});

//   @override
//   State<AllBookingsScreen> createState() => _AllBookingsScreenState();
// }

// class _AllBookingsScreenState extends State<AllBookingsScreen>
//     with TickerProviderStateMixin {
//   late TabController _tabController;
//   final TextEditingController _searchController = TextEditingController();

//   // Current selected date and status
//   DateTime? _selectedDate; // Changed to nullable
//   String _currentStatus = 'active'; // 'active' or 'completed'
//   bool _hasUserSelectedDate =
//       false; // Track if user has manually selected a date

//   // Date picker state
//   List<DateTime> _dateOptions = [];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _generateDateOptions();

//     // Load initial data (active bookings without date filter)
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _fetchBookings();
//     });

//     // Listen to tab changes
//     _tabController.addListener(() {
//       if (_tabController.indexIsChanging) {
//         setState(() {
//           if (_tabController.index == 0) {
//             _currentStatus = 'active';
//           } else if (_tabController.index == 1) {
//             _currentStatus = 'completed';
//           } else {
//             _currentStatus = 'cancelled';
//           }
//         });
//         _fetchBookings();
//       }
//     });
//   }

//   void _generateDateOptions() {
//     _dateOptions = List.generate(4, (index) {
//       return DateTime.now().add(Duration(days: index));
//     });
//   }

//   void _fetchBookings() {
//     final provider = Provider.of<SingleBookingProvider>(context, listen: false);

//     // Only pass date if user has specifically selected one
//     if (_hasUserSelectedDate && _selectedDate != null) {
//       final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
//       provider.fetchBookingsWithStatusAndDate(
//         _currentStatus,
//         date: formattedDate,
//       );
//     } else {
//       // Call without date parameter
//       provider.fetchBookingsWithStatusAndDate(_currentStatus);
//     }
//   }

//   // Pull-to-refresh handler
//   Future<void> _onRefresh() async {
//     // Add a small delay to show the refresh indicator
//     await Future.delayed(const Duration(milliseconds: 500));
//     _fetchBookings();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }

//   // Function to download PDF and save to public Downloads folder
//   Future<void> _downloadPdfToDownloads(String pdfUrl, String bookingId) async {
//     try {
//       // Request storage permission
//       bool hasPermission = await _requestStoragePermission();
//       if (!hasPermission) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Storage permission denied. Cannot download PDF.'),
//           ),
//         );
//         return;
//       }

//       // Create Dio instance for downloading
//       Dio dio = Dio();

//       String fileName =
//           'deposit_receipt_${bookingId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
//       String filePath;

//       if (Platform.isAndroid) {
//         // For Android - save to public Downloads directory
//         filePath = '/storage/emulated/0/Download/$fileName';

//         // Alternative paths to try if the first one fails
//         List<String> possiblePaths = [
//           '/storage/emulated/0/Download/$fileName',
//           '/sdcard/Download/$fileName',
//           '/storage/sdcard0/Download/$fileName',
//         ];

//         // Try to create the Downloads directory if it doesn't exist
//         for (String path in possiblePaths) {
//           try {
//             Directory downloadsDir = Directory(
//               path.substring(0, path.lastIndexOf('/')),
//             );
//             if (!await downloadsDir.exists()) {
//               await downloadsDir.create(recursive: true);
//             }
//             filePath = path;
//             break;
//           } catch (e) {
//             print('Failed to create directory for path: $path');
//             continue;
//           }
//         }
//       } else if (Platform.isIOS) {
//         // For iOS, save to app documents directory (iOS doesn't have a public Downloads folder)
//         Directory appDocDir = await getApplicationDocumentsDirectory();
//         filePath = '${appDocDir.path}/$fileName';
//       } else {
//         throw Exception('Unsupported platform');
//       }

//       print('Attempting to save PDF to: $filePath');

//       // Show downloading progress
//       _showDownloadProgress();

//       // Download the file
//       await dio.download(
//         pdfUrl,
//         filePath,
//         options: Options(
//           receiveTimeout: const Duration(minutes: 5),
//           sendTimeout: const Duration(minutes: 5),
//           headers: {
//             'Accept': 'application/pdf',
//             'User-Agent': 'Mozilla/5.0 (Android; Mobile)',
//           },
//         ),
//         onReceiveProgress: (received, total) {
//           if (total != -1) {
//             double progress = received / total;
//             print('Download progress: ${(progress * 100).toStringAsFixed(0)}%');
//           }
//         },
//       );

//       // Hide download progress
//       if (Navigator.of(context).canPop()) {
//         Navigator.of(context).pop();
//       }

//       // Verify the file was downloaded successfully
//       File downloadedFile = File(filePath);
//       bool fileExists = await downloadedFile.exists();

//       if (!fileExists) {
//         throw Exception('File was not created at expected location');
//       }

//       int fileSize = await downloadedFile.length();
//       if (fileSize == 0) {
//         throw Exception('Downloaded file is empty');
//       }

//       print('File downloaded successfully: $filePath (Size: $fileSize bytes)');

//       // For Android, add the file to MediaStore so it appears in file managers
//       if (Platform.isAndroid) {
//         await _addToMediaStore(filePath, fileName);
//       }

//       // Show success message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('PDF saved to Downloads'),
//           duration: const Duration(seconds: 6),
//           action: SnackBarAction(
//             label: 'Show Location',
//             onPressed: () => _showFileLocation(fileName),
//           ),
//         ),
//       );
//     } catch (e) {
//       // Hide download progress if showing
//       if (Navigator.of(context).canPop()) {
//         Navigator.of(context).pop();
//       }

//       print('Error downloading PDF: $e');

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Download failed: ${e.toString()}'),
//           duration: const Duration(seconds: 5),
//           action: SnackBarAction(
//             label: 'Retry',
//             onPressed: () => _downloadPdfToDownloads(pdfUrl, bookingId),
//           ),
//         ),
//       );
//     }
//   }

//   // Show file location instead of trying to open
//   void _showFileLocation(String fileName) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('PDF Downloaded'),
//         content: Text(
//           'Your receipt has been saved to:\n\n'
//           'Downloads > $fileName\n\n'
//           'You can find it in your phone\'s Downloads folder using any file manager app.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   // Add file to Android MediaStore so it appears in file managers
//   Future<void> _addToMediaStore(String filePath, String fileName) async {
//     try {
//       if (Platform.isAndroid) {
//         // Use method channel to add file to MediaStore
//         const platform = MethodChannel('file_operations');
//         await platform.invokeMethod('addToMediaStore', {
//           'filePath': filePath,
//           'fileName': fileName,
//           'mimeType': 'application/pdf',
//         });
//       }
//     } catch (e) {
//       print('Error adding to MediaStore: $e');
//       // This is not critical, file should still be accessible
//     }
//   }

//   // Improved permission handling for different Android versions
//   Future<bool> _requestStoragePermission() async {
//     if (Platform.isAndroid) {
//       DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//       AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
//       int sdkInt = androidInfo.version.sdkInt;

//       print('Android SDK version: $sdkInt');

//       if (sdkInt >= 33) {
//         // Android 13+ (API 33+) - Scoped storage, no special permission needed for Downloads
//         return true;
//       } else if (sdkInt >= 30) {
//         // Android 11-12 (API 30-32) - Need MANAGE_EXTERNAL_STORAGE
//         var status = await Permission.manageExternalStorage.status;
//         if (status.isDenied) {
//           status = await Permission.manageExternalStorage.request();
//         }

//         if (status.isDenied) {
//           // Fallback to regular storage permission
//           var storageStatus = await Permission.storage.request();
//           return storageStatus.isGranted;
//         }
//         return status.isGranted;
//       } else {
//         // Android 10 and below - Use regular storage permission
//         var status = await Permission.storage.request();
//         return status.isGranted;
//       }
//     }
//     return true; // iOS or other platforms
//   }

//   // Open the downloaded PDF file
//   Future<void> _openPdfFile(String filePath) async {
//     try {
//       // Try to open with default PDF viewer
//       OpenResult result = await OpenFile.open(filePath);

//       if (result.type == ResultType.done) {
//         print('PDF opened successfully');
//       } else {
//         String errorMessage = 'Failed to open PDF';

//         switch (result.type) {
//           case ResultType.noAppToOpen:
//             errorMessage =
//                 'No PDF viewer found. Please install a PDF reader app.';
//             break;
//           case ResultType.fileNotFound:
//             errorMessage = 'PDF file not found';
//             break;
//           case ResultType.permissionDenied:
//             errorMessage = 'Permission denied to open PDF';
//             break;
//           case ResultType.error:
//             errorMessage = 'Error opening PDF: ${result.message}';
//             break;
//           default:
//             errorMessage = 'Unknown error opening PDF';
//         }

//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text(errorMessage)));
//       }
//     } catch (e) {
//       print('Error opening PDF: $e');
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error opening PDF: $e')));
//     }
//   }

//   // Alternative method using SAF (Storage Access Framework) for Android 10+
//   Future<void> _downloadUsingSAF(String pdfUrl, String bookingId) async {
//     try {
//       if (!Platform.isAndroid) return;

//       // Use SAF to let user choose where to save
//       String? directoryPath = await FilePicker.getDirectoryPath();

//       if (directoryPath == null) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('No directory selected')));
//         return;
//       }

//       String fileName =
//           'deposit_receipt_${bookingId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
//       String filePath = '$directoryPath/$fileName';

//       // Download using Dio
//       Dio dio = Dio();
//       _showDownloadProgress();

//       await dio.download(pdfUrl, filePath);

//       if (Navigator.of(context).canPop()) {
//         Navigator.of(context).pop();
//       }

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('PDF saved to: $directoryPath')));
//     } catch (e) {
//       if (Navigator.of(context).canPop()) {
//         Navigator.of(context).pop();
//       }
//       print('SAF download error: $e');
//     }
//   }

//   void _showDownloadProgress() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return const AlertDialog(
//           content: Row(
//             children: [
//               CircularProgressIndicator(),
//               SizedBox(width: 20),
//               Text('Downloading PDF...'),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final screenWidth = screenSize.width;
//     final screenHeight = screenSize.height;
//     final paddingValue = screenWidth * 0.04;

//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           elevation: 0,
//           centerTitle: true,
//           automaticallyImplyLeading: false, // Removes the default back arrow
//           title: Text(
//             "Bookings",
//             style: TextStyle(
//               color: Colors.black,
//               fontSize: screenWidth * 0.055,
//               fontWeight: FontWeight.w800,
//             ),
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//         body: Column(
//           children: [
//             SizedBox(height: screenHeight * 0.03),
//             // Header with back button and title
//             // Padding(
//             //   padding: EdgeInsets.symmetric(horizontal: paddingValue),
//             //   child: Row(
//             //     children: [
//             //       Container(
//             //         decoration: BoxDecoration(
//             //           color: Colors.grey.shade200,
//             //           shape: BoxShape.circle,
//             //         ),
//             //         child: IconButton(
//             //           icon: Icon(
//             //             Icons.arrow_back,
//             //             color: Colors.black,
//             //             size: screenWidth * 0.06,
//             //           ),
//             //           onPressed: () {
//             //             Navigator.pop(context);
//             //           },
//             //         ),
//             //       ),
//             //       SizedBox(width: screenWidth * 0.25),
//             //       Expanded(
//             //         child: Text(
//             //           "Bookings",
//             //           style: TextStyle(
//             //             color: Colors.black,
//             //             fontSize: screenWidth * 0.045,
//             //             fontWeight: FontWeight.w800,
//             //           ),
//             //           overflow: TextOverflow.ellipsis,
//             //         ),
//             //       ),
//             //     ],
//             //   ),
//             // ),
//             // SizedBox(height: screenHeight * 0.02),

//             // TabBar for Pickup/Return tabs
//             // TabBar for Ongoing/Finished/Cancelled tabs
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: paddingValue),
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: TabBar(
//                   controller: _tabController,
//                   isScrollable: true,
//                   padding: EdgeInsets.zero,
//                   tabAlignment: TabAlignment.start,
//                   tabs: [
//                     Tab(
//                       child: SizedBox(
//                         width: screenWidth * 0.28,
//                         height: screenHeight * 0.04,
//                         child: Center(
//                           child: Text(
//                             "Ongoing",
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: screenWidth * 0.038,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Tab(
//                       child: SizedBox(
//                         width: screenWidth * 0.28,
//                         height: screenHeight * 0.04,
//                         child: Center(
//                           child: Text(
//                             "Finished",
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: screenWidth * 0.038,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Tab(
//                       child: SizedBox(
//                         width: screenWidth * 0.28,
//                         height: screenHeight * 0.04,
//                         child: Center(
//                           child: Text(
//                             "Cancelled",
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: screenWidth * 0.038,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                   labelColor: Colors.white,
//                   unselectedLabelColor: const Color(0XFF1808C5),
//                   indicator: BoxDecoration(
//                     color: const Color(0XFF1808C5),
//                     borderRadius: BorderRadius.circular(screenWidth * 0.02),
//                   ),
//                   indicatorSize: TabBarIndicatorSize.label,
//                   dividerColor: Colors.transparent,
//                 ),
//               ),
//             ),

//             // Search bar
//             Padding(
//               padding: EdgeInsets.symmetric(
//                 horizontal: paddingValue,
//                 vertical: screenHeight * 0.02,
//               ),
//               child: CustomSearchBar(
//                 controller: _searchController,
//                 onChanged: (value) {
//                   // Implement search functionality here if needed
//                   setState(() {});
//                 },
//                 onClear: () {
//                   _searchController.clear();
//                   setState(() {});
//                 },
//               ),
//             ),

//             // Date picker row
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: paddingValue),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Date options
//                   ...List.generate(4, (index) {
//                     DateTime date = _dateOptions[index];
//                     String day = DateFormat('d').format(date);
//                     String month = DateFormat('MMM').format(date);

//                     bool isSelected =
//                         _hasUserSelectedDate &&
//                         _selectedDate != null &&
//                         _selectedDate!.day == date.day &&
//                         _selectedDate!.month == date.month &&
//                         _selectedDate!.year == date.year;

//                     return GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           _selectedDate = date;
//                           _hasUserSelectedDate = true;
//                         });
//                         _fetchBookings();
//                       },
//                       child: Stack(
//                         alignment: Alignment.topCenter,
//                         children: [
//                           Positioned(
//                             top: 0,
//                             child: Container(
//                               height: 6,
//                               width: 50,
//                               decoration: BoxDecoration(
//                                 color: isSelected
//                                     ? const Color(0XFF120698)
//                                     : Colors.black,
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                             ),
//                           ),
//                           Container(
//                             margin: const EdgeInsets.only(top: 4),
//                             height: 80,
//                             width: 60,
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                             decoration: BoxDecoration(
//                               color: isSelected
//                                   ? const Color(0XFF120698)
//                                   : Colors.white,
//                               borderRadius: BorderRadius.circular(8),
//                               border: Border.all(color: Colors.black12),
//                             ),
//                             child: Column(
//                               children: [
//                                 Text(
//                                   day,
//                                   style: TextStyle(
//                                     color: isSelected
//                                         ? Colors.white
//                                         : Colors.black,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   month,
//                                   style: TextStyle(
//                                     color: isSelected
//                                         ? Colors.white
//                                         : Colors.black,
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }),

//                   // Calendar icon
//                   GestureDetector(
//                     onTap: () => _selectFromCalendar(),
//                     child: Stack(
//                       alignment: Alignment.topCenter,
//                       children: [
//                         Positioned(
//                           top: 0,
//                           child: Container(
//                             height: 6,
//                             width: 50,
//                             decoration: BoxDecoration(
//                               color: Colors.black,
//                               borderRadius: BorderRadius.circular(30),
//                             ),
//                           ),
//                         ),
//                         Container(
//                           margin: const EdgeInsets.only(top: 4),
//                           height: 80,
//                           width: 55,
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(color: Colors.black12),
//                           ),
//                           child: const Icon(Icons.calendar_month_sharp),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Clear date filter button (show only when date is selected)
//             if (_hasUserSelectedDate)
//               Padding(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: paddingValue,
//                   vertical: screenHeight * 0.01,
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     GestureDetector(
//                       onTap: _clearDateFilter,
//                       child: Container(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: screenWidth * 0.04,
//                           vertical: screenHeight * 0.008,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade200,
//                           borderRadius: BorderRadius.circular(
//                             screenWidth * 0.02,
//                           ),
//                           border: Border.all(color: Colors.grey.shade400),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(
//                               Icons.clear,
//                               size: screenWidth * 0.04,
//                               color: Colors.grey.shade700,
//                             ),
//                             SizedBox(width: screenWidth * 0.01),
//                             Text(
//                               "Clear Date Filter",
//                               style: TextStyle(
//                                 fontSize: screenWidth * 0.03,
//                                 color: Colors.grey.shade700,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//             SizedBox(height: screenHeight * 0.02),

//             // TabBarView content with Provider Consumer and RefreshIndicator
//             Expanded(
//               child: Consumer<SingleBookingProvider>(
//                 builder: (context, bookingProvider, child) {
//                   if (bookingProvider.isLoading) {
//                     return const Center(child: CircularProgressIndicator());
//                   }

//                   if (bookingProvider.error != null) {
//                     return RefreshIndicator(
//                       onRefresh: _onRefresh,
//                       child: SingleChildScrollView(
//                         physics: const AlwaysScrollableScrollPhysics(),
//                         child: Container(
//                           height: MediaQuery.of(context).size.height * 0.5,
//                           child: Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   'Error: ${bookingProvider.error}',
//                                   style: TextStyle(
//                                     fontSize: screenWidth * 0.04,
//                                     color: Colors.red,
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 ),
//                                 SizedBox(height: 16),
//                                 ElevatedButton(
//                                   onPressed: _fetchBookings,
//                                   child: Text('Retry'),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   }

//                   // return TabBarView(
//                   //   controller: _tabController,
//                   //   physics: const NeverScrollableScrollPhysics(),
//                   //   children: [
//                   //     // Active bookings tab with RefreshIndicator
//                   //     RefreshIndicator(
//                   //       onRefresh: _onRefresh,
//                   //       color: const Color(0XFF1808C5),
//                   //       backgroundColor: Colors.white,
//                   //       child: _buildBookingList(
//                   //         context,
//                   //         bookingProvider.bookings,
//                   //         "No active bookings found",
//                   //         paddingValue,
//                   //         screenWidth,
//                   //         screenHeight,
//                   //       ),
//                   //     ),

//                   //     // Completed bookings tab with RefreshIndicator
//                   //     RefreshIndicator(
//                   //       onRefresh: _onRefresh,
//                   //       color: const Color(0XFF1808C5),
//                   //       backgroundColor: Colors.white,
//                   //       child: _buildBookingList(
//                   //         context,
//                   //         bookingProvider.bookings,
//                   //         "No completed bookings found",
//                   //         paddingValue,
//                   //         screenWidth,
//                   //         screenHeight,
//                   //       ),
//                   //     ),
//                   //   ],
//                   // );

//                   return TabBarView(
//                     controller: _tabController,
//                     physics: const NeverScrollableScrollPhysics(),
//                     children: [
//                       // Active bookings tab with RefreshIndicator
//                       RefreshIndicator(
//                         onRefresh: _onRefresh,
//                         color: const Color(0XFF1808C5),
//                         backgroundColor: Colors.white,
//                         child: _buildBookingList(
//                           context,
//                           bookingProvider.bookings,
//                           "No active bookings found",
//                           paddingValue,
//                           screenWidth,
//                           screenHeight,
//                         ),
//                       ),

//                       // Completed bookings tab with RefreshIndicator
//                       RefreshIndicator(
//                         onRefresh: _onRefresh,
//                         color: const Color(0XFF1808C5),
//                         backgroundColor: Colors.white,
//                         child: _buildBookingList(
//                           context,
//                           bookingProvider.bookings,
//                           "No completed bookings found",
//                           paddingValue,
//                           screenWidth,
//                           screenHeight,
//                         ),
//                       ),

//                       // Cancelled bookings tab with RefreshIndicator
//                       RefreshIndicator(
//                         onRefresh: _onRefresh,
//                         color: const Color(0XFF1808C5),
//                         backgroundColor: Colors.white,
//                         child: _buildBookingList(
//                           context,
//                           bookingProvider.bookings,
//                           "No cancelled bookings found",
//                           paddingValue,
//                           screenWidth,
//                           screenHeight,
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBookingList(
//     BuildContext context,
//     List<Booking> bookings,
//     String emptyMessage,
//     double paddingValue,
//     double screenWidth,
//     double screenHeight,
//   ) {
//     // Filter bookings based on search text
//     List<Booking> filteredBookings = bookings;
//     if (_searchController.text.isNotEmpty) {
//       filteredBookings = bookings.where((booking) {
//         final searchText = _searchController.text.toLowerCase();
//         return booking.car?.carName.toLowerCase().contains(searchText) ==
//                 true ||
//             booking.car?.model.toLowerCase().contains(searchText) == true ||
//             booking.id.toLowerCase().contains(searchText);
//       }).toList();
//     }

//     if (filteredBookings.isEmpty) {
//       return SingleChildScrollView(
//         physics: const AlwaysScrollableScrollPhysics(),
//         child: Container(
//           height: MediaQuery.of(context).size.height * 0.5,
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.inbox_outlined,
//                   size: screenWidth * 0.15,
//                   color: Colors.grey.shade400,
//                 ),
//                 SizedBox(height: screenHeight * 0.02),
//                 Text(
//                   emptyMessage,
//                   style: TextStyle(
//                     fontSize: screenWidth * 0.04,
//                     color: Colors.grey,
//                   ),
//                 ),
//                 SizedBox(height: screenHeight * 0.01),
//                 Text(
//                   "Pull down to refresh",
//                   style: TextStyle(
//                     fontSize: screenWidth * 0.035,
//                     color: Colors.grey.shade400,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }

//     return ListView.builder(
//       physics: const AlwaysScrollableScrollPhysics(),
//       padding: EdgeInsets.all(paddingValue),
//       itemCount: filteredBookings.length,
//       itemBuilder: (context, index) {
//         final booking = filteredBookings[index];
//         return Column(
//           children: [
//             _buildBookingCard(
//               context,
//               booking: booking,
//               screenWidth: screenWidth,
//               screenHeight: screenHeight,
//             ),
//             SizedBox(height: screenHeight * 0.02),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildBookingCard(
//     BuildContext context, {
//     required Booking booking,
//     required double screenWidth,
//     required double screenHeight,
//   }) {
//     return GestureDetector(
//       onTap: () {
//         if (booking.status == "active") {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) =>
//                   CarPickupDetailsScreen(bookingId: booking.id),
//             ),
//           );
//         } else if (booking.status == "completed") {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('This booking has been Finished')),
//           );
//         } else if (booking.status == "cancelled") {
//           // Handle cancelled booking tap if needed
//           // Show cancelled booking details or message
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('This booking has been cancelled')),
//           );
//         }
//       },
//       child: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: const Color.fromARGB(255, 255, 255, 255),
//           borderRadius: BorderRadius.circular(screenWidth * 0.03),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.2),
//               offset: const Offset(0, 2),
//               blurRadius: 6,
//             ),
//           ],
//         ),
//         child: Stack(
//           children: [
//             Padding(
//               padding: EdgeInsets.all(screenWidth * 0.04),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       // Left side: Car name
//                       Text(
//                         booking.car?.carName ?? 'Unknown Car',
//                         style: TextStyle(
//                           fontSize: screenWidth * 0.04,
//                           fontWeight: FontWeight.bold,
//                           color: const Color.fromARGB(255, 0, 0, 0),
//                         ),
//                       ),

//                       // Right side: ID and download icon
//                       Row(
//                         children: [
//                           Text(
//                             booking.status == "completed"
//                                 ? "Completed"
//                                 : booking.status == "cancelled"
//                                 ? "Cancelled"
//                                 : "ID: ${booking.id.length > 4 ? booking.id.substring(booking.id.length - 4) : booking.id}",
//                             style: TextStyle(
//                               fontSize: screenWidth * 0.03,
//                               fontWeight: FontWeight.bold,
//                               color: booking.status == "completed"
//                                   ? Colors
//                                         .green
//                                         .shade400 // Green for completed
//                                   : booking.status == "cancelled"
//                                   ? Colors
//                                         .orange
//                                         .shade400 // Orange for cancelled
//                                   : Colors.red.shade400, // Red for active
//                             ),
//                           ),
//                           const SizedBox(
//                             width: 8,
//                           ), // spacing between text and icon
//                           if (booking.status != 'cancelled')
//                             GestureDetector(
//                               onTap: () async {
//                                 print(
//                                   'hhhhhhhhhhhhhhhhhhhhhhhhhh${booking.depositPDF}',
//                                 );
//                                 if (booking.depositPDF != null &&
//                                     booking.status == "active") {
//                                   String fullPdfUrl =
//                                       'https://varahibackend.varahiselfdrivecars.com${booking.depositPDF}';
//                                   print(
//                                     'PDF URLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL: $fullPdfUrl',
//                                   );

//                                   // Download PDF before navigation
//                                   await _downloadPdfToDownloads(
//                                     fullPdfUrl,
//                                     booking.id,
//                                   );
//                                 } else if (booking.finalBookingPDF != null &&
//                                     booking.status == "completed") {
//                                   String fullPdfUrl =
//                                       'https://varahibackend.varahiselfdrivecars.com${booking.finalBookingPDF}';
//                                   print('PDF URL: $fullPdfUrl');

//                                   // Download PDF before navigation
//                                   await _downloadPdfToDownloads(
//                                     fullPdfUrl,
//                                     booking.id,
//                                   );
//                                 }
//                               },
//                               child: const Icon(
//                                 Icons.file_download_outlined,
//                                 color: Colors.green,
//                                 size: 24,
//                               ),
//                             ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: screenHeight * 0.015),
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.settings,
//                                   size: screenWidth * 0.04,
//                                   color: Colors.black87,
//                                 ),
//                                 SizedBox(width: screenWidth * 0.02),
//                                 Text(
//                                   (booking.car?.model ?? "Unknown").substring(
//                                     0,
//                                     (booking.car?.model ?? "Unknown").length >
//                                             19
//                                         ? 19
//                                         : (booking.car?.model ?? "Unknown")
//                                               .length,
//                                   ),
//                                   style: TextStyle(
//                                     fontSize: screenWidth * 0.035,
//                                     color: const Color.fromARGB(
//                                       255,
//                                       0,
//                                       0,
//                                       0,
//                                     ).withOpacity(0.9),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: screenHeight * 0.012),
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.location_on,
//                                   size: screenWidth * 0.04,
//                                   color: Colors.black87,
//                                 ),
//                                 SizedBox(width: screenWidth * 0.02),
//                                 Expanded(
//                                   child: Text(
//                                     booking.pickupLocation,
//                                     style: TextStyle(
//                                       fontSize: screenWidth * 0.035,
//                                       color: const Color.fromARGB(
//                                         255,
//                                         0,
//                                         0,
//                                         0,
//                                       ).withOpacity(0.9),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: screenHeight * 0.015),
//                             Text(
//                               "Collect Date & time: ${booking.rentalStartDate}, ${booking.from}",
//                               style: TextStyle(
//                                 fontSize: screenWidth * 0.025,
//                                 color: const Color.fromARGB(255, 0, 0, 0),
//                               ),
//                             ),
//                             SizedBox(height: screenHeight * 0.008),
//                             Text(
//                               "Return Date & time: ${booking.rentalEndDate}, ${booking.to}",
//                               style: TextStyle(
//                                 fontSize: screenWidth * 0.025,
//                                 color: const Color.fromARGB(255, 0, 0, 0),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Container(
//                         width: screenWidth * 0.32,
//                         height: screenHeight * 0.08,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(
//                             screenWidth * 0.02,
//                           ),
//                           image: (booking.car?.carImage.isNotEmpty == true)
//                               ? DecorationImage(
//                                   image: NetworkImage(
//                                     booking.car!.carImage.first,
//                                   ),
//                                   fit: BoxFit.cover,
//                                   onError: (exception, stackTrace) {
//                                     // Handle image load error
//                                   },
//                                 )
//                               : null,
//                         ),
//                         child: (booking.car?.carImage.isEmpty ?? true)
//                             ? Icon(
//                                 Icons.directions_car,
//                                 size: screenWidth * 0.12,
//                                 color: Colors.black54,
//                               )
//                             : null,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             Positioned(
//               bottom: 0,
//               right: 0,
//               child: Container(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: screenWidth * 0.03,
//                   vertical: screenHeight * 0.01,
//                 ),
//                 decoration: BoxDecoration(
//                   color: const Color(0XFF1808C5),
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(screenWidth * 0.03),
//                     bottomRight: Radius.circular(screenWidth * 0.03),
//                   ),
//                 ),
//                 child: Text(
//                   "₹${booking.totalPrice}/-",
//                   style: TextStyle(
//                     fontSize: screenWidth * 0.035,
//                     color: const Color.fromARGB(255, 255, 255, 255),
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _selectFromCalendar() async {
//     final DateTime today = DateTime.now();
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? today,
//       firstDate: DateTime(today.year - 1),
//       lastDate: DateTime(today.year + 1),
//     );

//     if (picked != null) {
//       setState(() {
//         _selectedDate = picked;
//         _hasUserSelectedDate = true;
//       });
//       _fetchBookings();
//     }
//   }

//   void _clearDateFilter() {
//     setState(() {
//       _selectedDate = null;
//       _hasUserSelectedDate = false;
//     });
//     _fetchBookings();
//   }
// }
