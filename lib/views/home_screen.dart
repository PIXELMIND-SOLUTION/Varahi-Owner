import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mock data model
// ─────────────────────────────────────────────────────────────────────────────

class BookingModel {
  final String id;
  final String customerName;
  final String carName;
  final String carImageUrl;
  final String pickupLocation;
  final String dropLocation;
  final String time;
  final String amount;
  final BookingStatus status;

  const BookingModel({
    required this.id,
    required this.customerName,
    required this.carName,
    required this.carImageUrl,
    required this.pickupLocation,
    required this.dropLocation,
    required this.time,
    required this.amount,
    required this.status,
  });
}

enum BookingStatus { confirmed, pending, completed, cancelled }

// ─────────────────────────────────────────────────────────────────────────────
// Mock data — keyed by date offset from today
// ─────────────────────────────────────────────────────────────────────────────

final Map<int, List<BookingModel>> _mockBookings = {
  0: [
    BookingModel(
      id: 'BK001',
      customerName: 'Arun Kumar',
      carName: 'Maruti Swift',
      carImageUrl:
          'https://www.carpro.com/hs-fs/hubfs/2023-Chevrolet-Corvette-Z06-credit-chevrolet.jpeg?width=1020&name=2023-Chevrolet-Corvette-Z06-credit-chevrolet.jpeg',
      pickupLocation: 'Thiruvananthapuram Central',
      dropLocation: 'Technopark Phase 3',
      time: '09:00 AM',
      amount: '₹450',
      status: BookingStatus.confirmed,
    ),
    BookingModel(
      id: 'BK002',
      customerName: 'Priya Nair',
      carName: 'Maruti Swift',
      carImageUrl:
          'https://www.carpro.com/hs-fs/hubfs/2023-Chevrolet-Corvette-Z06-credit-chevrolet.jpeg?width=1020&name=2023-Chevrolet-Corvette-Z06-credit-chevrolet.jpeg',
      pickupLocation: 'Kowdiar Junction',
      dropLocation: 'Airport',
      time: '02:30 PM',
      amount: '₹780',
      status: BookingStatus.pending,
    ),
  ],
  1: [
    BookingModel(
      id: 'BK003',
      customerName: 'Rahul Menon',
      carName: 'Maruti Swift',
      carImageUrl:
          'https://www.carpro.com/hs-fs/hubfs/2023-Chevrolet-Corvette-Z06-credit-chevrolet.jpeg?width=1020&name=2023-Chevrolet-Corvette-Z06-credit-chevrolet.jpeg',
      pickupLocation: 'Pattom',
      dropLocation: 'Kazhakootam',
      time: '10:15 AM',
      amount: '₹320',
      status: BookingStatus.confirmed,
    ),
  ],
  2: [
    BookingModel(
      id: 'BK004',
      customerName: 'Sreeja Pillai',
      carName: 'Maruti Swift',
      carImageUrl:
          'https://www.carpro.com/hs-fs/hubfs/2023-Chevrolet-Corvette-Z06-credit-chevrolet.jpeg?width=1020&name=2023-Chevrolet-Corvette-Z06-credit-chevrolet.jpeg',
      pickupLocation: 'Vellayambalam',
      dropLocation: 'Medical College',
      time: '08:00 AM',
      amount: '₹210',
      status: BookingStatus.completed,
    ),
    BookingModel(
      id: 'BK005',
      customerName: 'Vivek Raj',
      carName: 'Maruti Swift',
      carImageUrl:
          'https://www.carpro.com/hs-fs/hubfs/2023-Chevrolet-Corvette-Z06-credit-chevrolet.jpeg?width=1020&name=2023-Chevrolet-Corvette-Z06-credit-chevrolet.jpeg',
      pickupLocation: 'Sasthamangalam',
      dropLocation: 'Technopark Phase 1',
      time: '06:00 PM',
      amount: '₹540',
      status: BookingStatus.confirmed,
    ),
  ],
  3: [],
  4: [
    BookingModel(
      id: 'BK006',
      customerName: 'Anjali Das',
      carName: 'Maruti Swift',
      carImageUrl:
          'https://www.carpro.com/hs-fs/hubfs/2023-Chevrolet-Corvette-Z06-credit-chevrolet.jpeg?width=1020&name=2023-Chevrolet-Corvette-Z06-credit-chevrolet.jpeg',
      pickupLocation: 'Kesavadasapuram',
      dropLocation: 'Railway Station',
      time: '11:00 AM',
      amount: '₹380',
      status: BookingStatus.cancelled,
    ),
  ],
  5: [
    BookingModel(
      id: 'BK007',
      customerName: 'Arjun Nambiar',
      carName: 'Maruti Swift',
      carImageUrl:
          'https://www.carpro.com/hs-fs/hubfs/2023-Chevrolet-Corvette-Z06-credit-chevrolet.jpeg?width=1020&name=2023-Chevrolet-Corvette-Z06-credit-chevrolet.jpeg',
      pickupLocation: 'Palayam',
      dropLocation: 'Neyyatinkara',
      time: '03:00 PM',
      amount: '₹920',
      status: BookingStatus.confirmed,
    ),
  ],
};

// ─────────────────────────────────────────────────────────────────────────────
// HomeScreen
// ─────────────────────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _brand = Color(0xFF1D9E75);
  static const _brandLight = Color(0xFFE1F5EE);
  static const _brandDark = Color(0xFF0F6E56);

  final PageController _bannerController = PageController();
  int _selectedDateOffset = 0; // 0 = today, 1-5 = next days
  DateTime? _calendarSelectedDate;
  int _bannerIndex = 0;

  final List<_BannerItem> _banners = const [
    _BannerItem(
      title: 'Get more rides',
      subtitle: 'Keep your availability updated to earn more',
      color: Color(0xFF1D9E75),
      icon: Icons.directions_car_rounded,
    ),
    _BannerItem(
      title: 'Safety first',
      subtitle: 'Check your vehicle documents before every trip',
      color: Color(0xFF185FA5),
      icon: Icons.verified_user_rounded,
    ),
    _BannerItem(
      title: 'Earnings this week',
      subtitle: 'You have earned ₹3,840 so far this week',
      color: Color(0xFFBA7517),
      icon: Icons.account_balance_wallet_rounded,
    ),
  ];

  List<BookingModel> get _bookingsForSelected {
    if (_calendarSelectedDate != null) {
      final today = DateTime.now();
      final diff = _calendarSelectedDate!
          .difference(DateTime(today.year, today.month, today.day))
          .inDays;
      return _mockBookings[diff] ?? [];
    }
    return _mockBookings[_selectedDateOffset] ?? [];
  }

  DateTime _dateForOffset(int offset) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).add(Duration(days: offset));
  }

  String _dayLabel(int offset) {
    if (offset == 0) return 'Today';
    if (offset == 1) return 'Tomorrow';
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[_dateForOffset(offset).weekday - 1];
  }

  Future<void> _pickFromCalendar() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _brand,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _calendarSelectedDate = picked;
        _selectedDateOffset = -1;
      });
    }
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F5),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Carousel banner ──────────────────────────────────────────
            SliverToBoxAdapter(child: _buildBanner()),

            // ── Date selector ────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildDateSelector()),

            // ── Section header ───────────────────────────────────────────
            SliverToBoxAdapter(child: _buildBookingsHeader()),

            // ── Bookings list ────────────────────────────────────────────
            _bookingsForSelected.isEmpty
                ? SliverToBoxAdapter(child: _buildEmptyState())
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _BookingCard(
                        booking: _bookingsForSelected[i],
                        brand: _brand,
                        brandLight: _brandLight,
                        brandDark: _brandDark,
                      ),
                      childCount: _bookingsForSelected.length,
                    ),
                  ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  // ── Carousel banner ────────────────────────────────────────────────────────

  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          SizedBox(
            height: 120,
            child: PageView.builder(
              controller: _bannerController,
              itemCount: _banners.length,
              onPageChanged: (i) => setState(() => _bannerIndex = i),
              itemBuilder: (context, i) {
                final b = _banners[i];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: b.color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              b.title,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              b.subtitle,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.8),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(b.icon, color: Colors.white, size: 26),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          // Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _banners.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _bannerIndex == i ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _bannerIndex == i
                      ? _brand
                      : Colors.black.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Date selector ──────────────────────────────────────────────────────────

  Widget _buildDateSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select date',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black45,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Today + next 5 days
                ...List.generate(6, (i) {
                  final date = _dateForOffset(i);
                  final isSelected =
                      _calendarSelectedDate == null && _selectedDateOffset == i;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedDateOffset = i;
                      _calendarSelectedDate = null;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? _brand : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? _brand
                              : Colors.black.withOpacity(0.08),
                          width: isSelected ? 1.5 : 0.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _dayLabel(i),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white.withOpacity(0.85)
                                  : Colors.black45,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _monthShort(date.month),
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected
                                  ? Colors.white.withOpacity(0.75)
                                  : Colors.black38,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                // Calendar picker tile
                GestureDetector(
                  onTap: _pickFromCalendar,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _calendarSelectedDate != null
                          ? _brandLight
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _calendarSelectedDate != null
                            ? _brand
                            : Colors.black.withOpacity(0.08),
                        width: _calendarSelectedDate != null ? 1.5 : 0.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _calendarSelectedDate != null
                              ? _monthShort(_calendarSelectedDate!.month)
                              : 'Pick',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _calendarSelectedDate != null
                                ? _brandDark
                                : Colors.black45,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _calendarSelectedDate != null
                            ? Text(
                                '${_calendarSelectedDate!.day}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: _brandDark,
                                ),
                              )
                            : Icon(
                                Icons.calendar_month_rounded,
                                size: 22,
                                color: Colors.black45,
                              ),
                        const SizedBox(height: 2),
                        Text(
                          _calendarSelectedDate != null
                              ? '${_calendarSelectedDate!.year}'
                              : 'Date',
                          style: TextStyle(
                            fontSize: 10,
                            color: _calendarSelectedDate != null
                                ? _brand
                                : Colors.black38,
                          ),
                        ),
                      ],
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

  // ── Bookings header ────────────────────────────────────────────────────────

  Widget _buildBookingsHeader() {
    final count = _bookingsForSelected.length;
    String dateLabel;
    if (_calendarSelectedDate != null) {
      dateLabel =
          '${_calendarSelectedDate!.day} ${_monthShort(_calendarSelectedDate!.month)} ${_calendarSelectedDate!.year}';
    } else if (_selectedDateOffset == 0) {
      dateLabel = 'Today';
    } else if (_selectedDateOffset == 1) {
      dateLabel = 'Tomorrow';
    } else {
      final d = _dateForOffset(_selectedDateOffset);
      dateLabel = '${d.day} ${_monthShort(d.month)}';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bookings — $dateLabel',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  '$count ride${count == 1 ? '' : 's'} scheduled',
                  style: const TextStyle(fontSize: 13, color: Colors.black45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFE1F5EE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.event_available_rounded,
                size: 28,
                color: Color(0xFF0F6E56),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'No bookings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'No rides scheduled for this day.',
              style: TextStyle(fontSize: 13, color: Colors.black38),
            ),
          ],
        ),
      ),
    );
  }

  String _monthShort(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Booking card
// ─────────────────────────────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final Color brand, brandLight, brandDark;

  const _BookingCard({
    required this.booking,
    required this.brand,
    required this.brandLight,
    required this.brandDark,
  });

  Color get _statusColor {
    switch (booking.status) {
      case BookingStatus.confirmed:
        return const Color(0xFF1D9E75);
      case BookingStatus.pending:
        return const Color(0xFFBA7517);
      case BookingStatus.completed:
        return const Color(0xFF185FA5);
      case BookingStatus.cancelled:
        return const Color(0xFFA32D2D);
    }
  }

  Color get _statusBg {
    switch (booking.status) {
      case BookingStatus.confirmed:
        return const Color(0xFFE1F5EE);
      case BookingStatus.pending:
        return const Color(0xFFFAEEDA);
      case BookingStatus.completed:
        return const Color(0xFFE6F1FB);
      case BookingStatus.cancelled:
        return const Color(0xFFFCEBEB);
    }
  }

  String get _statusLabel {
    switch (booking.status) {
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Car image ──────────────────────────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                Image.network(
                  booking.carImageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 160,
                    color: const Color(0xFFF0F0EE),
                    child: const Center(
                      child: Icon(
                        Icons.directions_car_rounded,
                        size: 48,
                        color: Colors.black26,
                      ),
                    ),
                  ),
                ),
                // Status badge overlay
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _statusBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      _statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _statusColor,
                      ),
                    ),
                  ),
                ),
                // Booking ID
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      booking.id,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Card body ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer + time row
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: brandLight,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          booking.customerName[0],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: brandDark,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.customerName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            booking.carName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          booking.amount,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: brandDark,
                          ),
                        ),
                        Text(
                          booking.time,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(
                  height: 1,
                  thickness: 0.5,
                  color: Color(0xFFEEEEEB),
                ),
                const SizedBox(height: 14),

                // Route
                _RouteRow(
                  pickup: booking.pickupLocation,
                  drop: booking.dropLocation,
                  brand: brand,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Route row widget
// ─────────────────────────────────────────────────────────────────────────────

class _RouteRow extends StatelessWidget {
  final String pickup;
  final String drop;
  final Color brand;

  const _RouteRow({
    required this.pickup,
    required this.drop,
    required this.brand,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: brand, shape: BoxShape.circle),
            ),
            Container(
              width: 1.5,
              height: 22,
              color: Colors.black.withOpacity(0.12),
            ),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black38, width: 2),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pickup,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                drop,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Banner item data
// ─────────────────────────────────────────────────────────────────────────────

class _BannerItem {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _BannerItem({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });
}
