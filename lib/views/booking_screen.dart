import 'package:flutter/material.dart';
import 'package:varahiowner/helpers/pdf_helper.dart';
import 'package:varahiowner/model/MyBookings/booking_model.dart';
import 'package:provider/provider.dart';
import 'package:varahiowner/providers/booking_provider.dart';
import 'package:varahiowner/views/Staff/booking_screen.dart';
import 'package:varahiowner/views/Staff/return_upload_screen.dart'; // Adjust path as needed

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedStatus = 'pending';

  final List<String> _statusTabs = [
    'pending',
    'confirmed',
    'active',
    'completed',
    'cancelled',
  ];

  final Map<String, String> _statusLabels = {
    'pending': 'Pending',
    'confirmed': 'Confirmed',
    'active': 'Active',
    'completed': 'Completed',
    'cancelled': 'Cancelled',
  };

  final Map<String, Color> _statusColors = {
    'pending': Colors.orange,
    'confirmed': Colors.blue,
    'active': Colors.green,
    'completed': Colors.teal,
    'cancelled': Colors.red,
  };

  final Map<String, IconData> _statusIcons = {
    'pending': Icons.pending_actions,
    'confirmed': Icons.check_circle_outline,
    'active': Icons.directions_car,
    'completed': Icons.done_all,
    'cancelled': Icons.cancel_outlined,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusTabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);
    _fetchBookings();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedStatus = _statusTabs[_tabController.index];
      });
      _fetchBookings();
    }
  }

  Future<void> _fetchBookings() async {
    final provider = context.read<MainBookingProvider>();
    await provider.fetchBookings();
  }

  List<BookingModel> _getFilteredBookings(List<BookingModel> bookings) {
    return bookings
        .where(
          (booking) =>
              booking.status.toLowerCase() == _selectedStatus.toLowerCase(),
        )
        .toList();
  }

  Future<void> _handleStatusUpdate(
    String bookingId,
    String currentStatus,
    String newStatus,
  ) async {
    final provider = context.read<MainBookingProvider>();
    final success = await provider.updateBookingStatus(bookingId, newStatus);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking ${newStatus.toUpperCase()} successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showStatusUpdateDialog(
    String bookingId,
    String currentStatus,
    String bookingTitle,
  ) {
    final List<String> availableStatuses = _getAvailableStatuses(currentStatus);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Update Status',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(bookingTitle, style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 20),
              ...availableStatuses.map((status) {
                return ListTile(
                  leading: Icon(
                    _statusIcons[status],
                    color: _statusColors[status],
                  ),
                  title: Text(
                    _statusLabels[status] ?? status,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _handleStatusUpdate(bookingId, currentStatus, status);
                  },
                );
              }),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  List<String> _getAvailableStatuses(String currentStatus) {
    switch (currentStatus.toLowerCase()) {
      case 'pending':
        return ['confirmed', 'cancelled'];
      case 'confirmed':
        return ['active', 'cancelled'];
      case 'active':
        return ['completed'];
      case 'completed':
        return [];
      case 'cancelled':
        return [];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'My Bookings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.blue,
          indicatorWeight: 3,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          tabs: _statusTabs.map((status) {
            return Tab(text: _statusLabels[status]);
          }).toList(),
        ),
      ),
      body: Consumer<MainBookingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading bookings...'),
                ],
              ),
            );
          }

          if (provider.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage,
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _fetchBookings(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final filteredBookings = _getFilteredBookings(provider.bookings);

          if (filteredBookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _statusIcons[_selectedStatus],
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No ${_statusLabels[_selectedStatus]} Bookings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You don\'t have any ${_statusLabels[_selectedStatus]} bookings yet',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _fetchBookings(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredBookings.length,
              itemBuilder: (context, index) {
                final booking = filteredBookings[index];
                return _BookingCard(
                  booking: booking,
                  statusColor: _statusColors[_selectedStatus]!,
                  statusIcon: _statusIcons[_selectedStatus]!,
                  onUpdateStatus: () => _showStatusUpdateDialog(
                    booking.id,
                    booking.status,
                    '${booking.car.carName} ${booking.car.model}',
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// class _BookingCard extends StatelessWidget {
//   final BookingModel booking;
//   final Color statusColor;
//   final IconData statusIcon;
//   final VoidCallback onUpdateStatus;

//   const _BookingCard({
//     required this.booking,
//     required this.statusColor,
//     required this.statusIcon,
//     required this.onUpdateStatus,
//   });

//   String _formatDate(String dateString) {
//     try {
//       final date = DateTime.parse(dateString);
//       return '${date.day}/${date.month}/${date.year}';
//     } catch (e) {
//       return dateString;
//     }
//   }

//   String _formatPrice(double price) {
//     return '₹${price.toStringAsFixed(2)}';
//   }

//   void _handleViewDetails(BuildContext context) {
//     final status = booking.status.toLowerCase();

//     if (status == 'confirmed') {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => BookingScreen(bookingId: booking.id),
//         ),
//       );
//     } else if (status == 'active') {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ReturnUploadScreen(id: booking.id),
//         ),
//       );
//     } else {
//       // For other statuses (pending, completed, cancelled)
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Details view not available for ${booking.status} bookings',
//           ),
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isCompletedOrCancelled =
//         booking.status.toLowerCase() == 'completed' ||
//         booking.status.toLowerCase() == 'cancelled';

//     // Determine button text based on status
//     String getProceedButtonText() {
//       final status = booking.status.toLowerCase();
//       if (status == 'confirmed') return 'Proceed';
//       if (status == 'active') return 'Return';
//       return 'View Details';
//     }

//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header with car name and status
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: statusColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(statusIcon, color: statusColor, size: 24),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         '${booking.car.carName} ${booking.car.model}',
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       Text(
//                         booking.car.vehicleNumber,
//                         style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 10,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: statusColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(color: statusColor.withOpacity(0.3)),
//                   ),
//                   child: Text(
//                     booking.status.toUpperCase(),
//                     style: TextStyle(
//                       fontSize: 11,
//                       fontWeight: FontWeight.w600,
//                       color: statusColor,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             const Divider(),
//             const SizedBox(height: 8),
//             // Booking details
//             Row(
//               children: [
//                 Expanded(
//                   child: _InfoRow(
//                     icon: Icons.calendar_today,
//                     label: 'Start Date',
//                     value: _formatDate(booking.rentalStartDate),
//                   ),
//                 ),
//                 Expanded(
//                   child: _InfoRow(
//                     icon: Icons.calendar_today,
//                     label: 'End Date',
//                     value: _formatDate(booking.rentalEndDate),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Expanded(
//                   child: _InfoRow(
//                     icon: Icons.attach_money,
//                     label: 'Total Price',
//                     value: _formatPrice(booking.totalPrice),
//                     valueColor: Colors.green,
//                   ),
//                 ),
//                 Expanded(
//                   child: _InfoRow(
//                     icon: Icons.person,
//                     label: 'Customer',
//                     value: booking.user.name,
//                     maxLines: 1,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Expanded(
//                   child: _InfoRow(
//                     icon: Icons.location_on,
//                     label: 'Pickup',
//                     value: booking.from,
//                     maxLines: 1,
//                   ),
//                 ),
//                 Expanded(
//                   child: _InfoRow(
//                     icon: Icons.location_on,
//                     label: 'Drop',
//                     value: booking.to,
//                     maxLines: 1,
//                   ),
//                 ),
//               ],
//             ),
//             if (booking.status == 'confirmed')
//               if (booking.otp > 0) ...[
//                 const SizedBox(height: 8),
//                 _InfoRow(
//                   icon: Icons.security,
//                   label: 'OTP',
//                   value: booking.otp.toString(),
//                   valueColor: Colors.blue,
//                 ),
//               ],
//             if (booking.status == 'active')
//               if (booking.otp > 0) ...[
//                 const SizedBox(height: 8),
//                 _InfoRow(
//                   icon: Icons.security,
//                   label: 'Return OTP',
//                   value: booking.returnOTP.toString(),
//                   valueColor: Colors.blue,
//                 ),
//               ],
//             const SizedBox(height: 12),
//             if (booking.status == "confirmed" || booking.status == "active")
//               // Action buttons
//               Row(
//                 children: [
//                   // if (!isCompletedOrCancelled) ...[
//                   //   Expanded(
//                   //     child: OutlinedButton.icon(
//                   //       onPressed: onUpdateStatus,
//                   //       icon: const Icon(Icons.update, size: 18),
//                   //       label: const Text('Update Status'),
//                   //       style: OutlinedButton.styleFrom(
//                   //         foregroundColor: statusColor,
//                   //         side: BorderSide(color: statusColor),
//                   //         padding: const EdgeInsets.symmetric(vertical: 10),
//                   //         shape: RoundedRectangleBorder(
//                   //           borderRadius: BorderRadius.circular(8),
//                   //         ),
//                   //       ),
//                   //     ),
//                   //   ),
//                   //   const SizedBox(width: 8),
//                   // ],
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       onPressed: () => _handleViewDetails(context),
//                       icon: Icon(
//                         booking.status.toLowerCase() == 'confirmed'
//                             ? Icons.play_arrow
//                             : booking.status.toLowerCase() == 'active'
//                             ? Icons.assignment_return
//                             : Icons.visibility,
//                         size: 18,
//                       ),
//                       label: Text(getProceedButtonText()),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: statusColor,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 10),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final Color statusColor;
  final IconData statusIcon;
  final VoidCallback onUpdateStatus;

  const _BookingCard({
    required this.booking,
    required this.statusColor,
    required this.statusIcon,
    required this.onUpdateStatus,
  });

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatPrice(double price) {
    return '₹${price.toStringAsFixed(2)}';
  }

  void _handleViewDetails(BuildContext context) {
    final status = booking.status.toLowerCase();

    if (status == 'confirmed') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingScreen(bookingId: booking.id),
        ),
      );
    } else if (status == 'active') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReturnUploadScreen(id: booking.id),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Details view not available for this booking status'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleDownloadPdf(BuildContext context) async {
    String? pdfUrl;
    String fileName;
    final status = booking.status.toLowerCase();

    if (status == 'active' && booking.depositPDF != null) {
      pdfUrl = booking.depositPDF!;
      fileName = 'deposit_${booking.id}.pdf';
    } else if (status == 'completed' && booking.finalBookingPDF != null) {
      pdfUrl = booking.finalBookingPDF!;
      fileName = 'final_booking_${booking.id}.pdf';
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No ${status == 'active' ? 'deposit' : 'final booking'} PDF available',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await PdfDownloadHelper.downloadAndOpenPdf(pdfUrl, fileName);
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF downloaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = booking.status.toLowerCase();
    final showDownloadButton =
        (status == 'active' &&
            booking.depositPDF != null &&
            booking.depositPDF!.isNotEmpty) ||
        (status == 'completed' &&
            booking.finalBookingPDF != null &&
            booking.finalBookingPDF!.isNotEmpty);

    String getProceedButtonText() {
      if (status == 'confirmed') return 'Proceed';
      if (status == 'active') return 'Return';
      return 'View Details';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with car name and status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${booking.car.carName} ${booking.car.model}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        booking.car.vehicleNumber,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    booking.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            // Booking details
            Row(
              children: [
                Expanded(
                  child: _InfoRow(
                    icon: Icons.calendar_today,
                    label: 'Start Date',
                    value: _formatDate(booking.rentalStartDate),
                  ),
                ),
                Expanded(
                  child: _InfoRow(
                    icon: Icons.calendar_today,
                    label: 'End Date',
                    value: _formatDate(booking.rentalEndDate),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _InfoRow(
                    icon: Icons.attach_money,
                    label: 'Total Price',
                    value: _formatPrice(booking.totalPrice),
                    valueColor: Colors.green,
                  ),
                ),
                Expanded(
                  child: _InfoRow(
                    icon: Icons.person,
                    label: 'Customer',
                    value: booking.user.name,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _InfoRow(
                    icon: Icons.location_on,
                    label: 'Pickup',
                    value: booking.from,
                    maxLines: 1,
                  ),
                ),
                Expanded(
                  child: _InfoRow(
                    icon: Icons.location_on,
                    label: 'Drop',
                    value: booking.to,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            if (booking.status == 'confirmed')
              if (booking.otp > 0) ...[
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.security,
                  label: 'OTP',
                  value: booking.otp.toString(),
                  valueColor: Colors.blue,
                ),
              ],
            if (booking.status == 'active')
              if (booking.otp > 0) ...[
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.security,
                  label: 'Return OTP',
                  value: booking.returnOTP.toString(),
                  valueColor: Colors.blue,
                ),
              ],
            const SizedBox(height: 12),

            // Action buttons row
            if (status == "confirmed" ||
                status == "active" ||
                showDownloadButton)
              Row(
                children: [
                  if (showDownloadButton)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _handleDownloadPdf(context),
                        icon: const Icon(Icons.download, size: 18),
                        label: Text(
                          status == 'active' ? 'Deposit PDF' : 'Final PDF',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: statusColor,
                          side: BorderSide(color: statusColor),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  if (showDownloadButton &&
                      (status == "confirmed" || status == "active"))
                    const SizedBox(width: 8),
                  if (status == "confirmed" || status == "active")
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _handleViewDetails(context),
                        icon: Icon(
                          status == 'confirmed'
                              ? Icons.play_arrow
                              : Icons.assignment_return,
                          size: 18,
                        ),
                        label: Text(getProceedButtonText()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: statusColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final int? maxLines;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? Colors.grey[800],
                ),
                maxLines: maxLines ?? 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
