import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared constants
// ─────────────────────────────────────────────────────────────────────────────

const _brand = Color(0xFF1D9E75);
const _brandLight = Color(0xFFE1F5EE);
const _brandDark = Color(0xFF0F6E56);

// ─────────────────────────────────────────────────────────────────────────────
// Booking model (reuse from home_screen.dart or keep here)
// ─────────────────────────────────────────────────────────────────────────────

enum BookingStatus { pending, confirmed, completed, cancelled }

class BookingModel {
  final String id;
  final String customerName;
  final String carName;
  final String carImageUrl;
  final String pickupLocation;
  final String dropLocation;
  final String time;
  final String date;
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
    required this.date,
    required this.amount,
    required this.status,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Mock data
// ─────────────────────────────────────────────────────────────────────────────

const _carImg =
    'https://imgd.aeplcdn.com/664x374/n/cw/ec/159099/swift-exterior-right-front-three-quarter-2.jpeg';

const _allBookings = [
  BookingModel(
    id: 'BK001',
    customerName: 'Arun Kumar',
    carName: 'Maruti Swift',
    carImageUrl: _carImg,
    pickupLocation: 'Thiruvananthapuram Central',
    dropLocation: 'Technopark Phase 3',
    time: '09:00 AM',
    date: 'Today',
    amount: '₹450',
    status: BookingStatus.pending,
  ),
  BookingModel(
    id: 'BK002',
    customerName: 'Priya Nair',
    carName: 'Maruti Swift',
    carImageUrl: _carImg,
    pickupLocation: 'Kowdiar Junction',
    dropLocation: 'Airport',
    time: '02:30 PM',
    date: 'Today',
    amount: '₹780',
    status: BookingStatus.pending,
  ),
  BookingModel(
    id: 'BK003',
    customerName: 'Rahul Menon',
    carName: 'Maruti Swift',
    carImageUrl: _carImg,
    pickupLocation: 'Pattom',
    dropLocation: 'Kazhakootam',
    time: '10:15 AM',
    date: 'Yesterday',
    amount: '₹320',
    status: BookingStatus.confirmed,
  ),
  BookingModel(
    id: 'BK004',
    customerName: 'Sreeja Pillai',
    carName: 'Maruti Swift',
    carImageUrl: _carImg,
    pickupLocation: 'Vellayambalam',
    dropLocation: 'Medical College',
    time: '08:00 AM',
    date: '4 Apr',
    amount: '₹210',
    status: BookingStatus.confirmed,
  ),
  BookingModel(
    id: 'BK005',
    customerName: 'Vivek Raj',
    carName: 'Maruti Swift',
    carImageUrl: _carImg,
    pickupLocation: 'Sasthamangalam',
    dropLocation: 'Technopark Phase 1',
    time: '06:00 PM',
    date: '3 Apr',
    amount: '₹540',
    status: BookingStatus.completed,
  ),
  BookingModel(
    id: 'BK006',
    customerName: 'Anjali Das',
    carName: 'Maruti Swift',
    carImageUrl: _carImg,
    pickupLocation: 'Kesavadasapuram',
    dropLocation: 'Railway Station',
    time: '11:00 AM',
    date: '2 Apr',
    amount: '₹380',
    status: BookingStatus.completed,
  ),
  BookingModel(
    id: 'BK007',
    customerName: 'Arjun Nambiar',
    carName: 'Maruti Swift',
    carImageUrl: _carImg,
    pickupLocation: 'Palayam',
    dropLocation: 'Neyyatinkara',
    time: '03:00 PM',
    date: '1 Apr',
    amount: '₹920',
    status: BookingStatus.cancelled,
  ),
  BookingModel(
    id: 'BK008',
    customerName: 'Meera Varma',
    carName: 'Maruti Swift',
    carImageUrl: _carImg,
    pickupLocation: 'Statue Junction',
    dropLocation: 'Kovalam Beach',
    time: '07:30 AM',
    date: '31 Mar',
    amount: '₹660',
    status: BookingStatus.cancelled,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// BookingsScreen
// ─────────────────────────────────────────────────────────────────────────────

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _tabs = [
    _TabMeta(
      label: 'Pending',
      status: BookingStatus.pending,
      color: Color(0xFFBA7517),
      bg: Color(0xFFFAEEDA),
    ),
    _TabMeta(
      label: 'Confirmed',
      status: BookingStatus.confirmed,
      color: Color(0xFF1D9E75),
      bg: Color(0xFFE1F5EE),
    ),
    _TabMeta(
      label: 'Completed',
      status: BookingStatus.completed,
      color: Color(0xFF185FA5),
      bg: Color(0xFFE6F1FB),
    ),
    _TabMeta(
      label: 'Cancelled',
      status: BookingStatus.cancelled,
      color: Color(0xFFA32D2D),
      bg: Color(0xFFFCEBEB),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<BookingModel> _filtered(BookingStatus status) =>
      _allBookings.where((b) => b.status == status).toList();

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

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Summary chips ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: _tabs.map((t) {
                final count = _filtered(t.status).length;
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: _tabs.last == t ? 0 : 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: t.color,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t.label,
                          style: TextStyle(fontSize: 10, color: textMuted),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // ── Tab bar ────────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            padding: const EdgeInsets.all(4),
            child: TabBar(
              controller: _tabController,
              isScrollable: false,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: _brand,
                borderRadius: BorderRadius.circular(9),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: textMuted,
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              tabs: _tabs.map((t) => Tab(text: t.label, height: 36)).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // ── Tab views ──────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map((t) {
                final list = _filtered(t.status);
                return list.isEmpty
                    ? _EmptyTab(meta: t, textMuted: textMuted)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                        itemCount: list.length,
                        itemBuilder: (_, i) => _BookingListCard(
                          booking: list[i],
                          meta: t,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          textPrimary: textPrimary,
                          textMuted: textMuted,
                          isDark: isDark,
                        ),
                      );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Booking list card
// ─────────────────────────────────────────────────────────────────────────────

class _BookingListCard extends StatelessWidget {
  final BookingModel booking;
  final _TabMeta meta;
  final Color cardColor, borderColor, textPrimary, textMuted;
  final bool isDark;

  const _BookingListCard({
    required this.booking,
    required this.meta,
    required this.cardColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textMuted,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          // Car image strip
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(14),
            ),
            child: Image.network(
              booking.carImageUrl,
              width: 96,
              height: 110,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 96,
                height: 110,
                color: isDark
                    ? const Color(0xFF2A2A28)
                    : const Color(0xFFF0F0EE),
                child: Icon(
                  Icons.directions_car_rounded,
                  size: 32,
                  color: textMuted,
                ),
              ),
            ),
          ),

          // Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ID + status badge
                  Row(
                    children: [
                      Text(
                        booking.id,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: textMuted,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: meta.bg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          meta.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: meta.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Customer name
                  Text(
                    booking.customerName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    booking.carName,
                    style: TextStyle(fontSize: 11, color: textMuted),
                  ),
                  const SizedBox(height: 8),

                  // Route
                  Row(
                    children: [
                      Icon(Icons.radio_button_checked, size: 10, color: _brand),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          booking.pickupLocation,
                          style: TextStyle(fontSize: 11, color: textMuted),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 10,
                        color: Colors.redAccent.withOpacity(0.8),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          booking.dropLocation,
                          style: TextStyle(fontSize: 11, color: textMuted),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Time + amount
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 11,
                        color: textMuted,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${booking.date}  •  ${booking.time}',
                        style: TextStyle(fontSize: 11, color: textMuted),
                      ),
                      const Spacer(),
                      Text(
                        booking.amount,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _brandDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty tab state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyTab extends StatelessWidget {
  final _TabMeta meta;
  final Color textMuted;

  const _EmptyTab({required this.meta, required this.textMuted});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: meta.bg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.inbox_rounded, size: 26, color: meta.color),
          ),
          const SizedBox(height: 12),
          Text(
            'No ${meta.label.toLowerCase()} bookings',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Nothing here yet.',
            style: TextStyle(fontSize: 13, color: textMuted.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab metadata helper
// ─────────────────────────────────────────────────────────────────────────────

class _TabMeta {
  final String label;
  final BookingStatus status;
  final Color color;
  final Color bg;

  const _TabMeta({
    required this.label,
    required this.status,
    required this.color,
    required this.bg,
  });
}
