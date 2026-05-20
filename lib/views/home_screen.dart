
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:varahiowner/helpers/toast_helper.dart';
import 'package:varahiowner/model/MyBookings/booking_model.dart';
import 'package:varahiowner/providers/BannerProvider/banner_provider.dart';
import 'package:varahiowner/providers/booking_provider.dart';
import 'package:varahiowner/views/Staff/booking_screen.dart';
import 'package:varahiowner/views/Staff/return_upload_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  static const _brand = Color(0xFF1D9E75);
  static const _brandDark = Color(0xFF0F6E56);

  DateTime? _selectedDate; // null means "All Bookings"
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isFirstLoad = true;

  static const Color _backgroundGradientStart = Color(0xFF004D47); // Dark Teal
  static const Color _backgroundGradientEnd = Color(0xFF00695C); // Medium Teal
  static const Color _primaryColor = Color(0xFF00BFA5); // Teal

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    // Load bookings after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookings();
      _fetchBanners();
    });
  }

    @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<MainBookingProvider>(context);
    
    // If data exists but might not be showing, force rebuild
    if (provider.bookings.isNotEmpty && !_isFirstLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  Future<void> _fetchBanners() async {
    try {
      await Provider.of<BannerProvider>(context, listen: false).fetchBanners();
      setState(() {});
    } catch (e) {
      print('Error fetching banners: $e');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }
  Future<void> _loadBookings() async {
    final provider = Provider.of<MainBookingProvider>(context, listen: false);
    final dateParam = _selectedDate?.toIso8601String().split('T')[0];

    print('Loading bookings with date param: $dateParam');

    final success = await provider.fetchBookings(date: dateParam);

    if (mounted) {
      if (!success) {
        ToastHelper.showError(
          context,
          provider.errorMessage ?? 'Failed to load bookings',
        );
      } else {
        _fadeController.forward(from: 0);
        print('Bookings loaded: ${provider.bookings.length}');
        
        // FORCE UI UPDATE - Add this
        setState(() {});
        
        // Double force update after a tiny delay
        Future.delayed(Duration(milliseconds: 100), () {
          if (mounted) setState(() {});
        });
      }
      _isFirstLoad = false;
    }
  }

  Future<void> _onDateSelected(DateTime? date) async {
    setState(() => _selectedDate = date);
    _fadeController.reset();
    await _loadBookings();
  }

  // Responsive breakpoints
  bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768;
  }

  bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  double getResponsiveValue(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  Widget _buildHeroBanner(BuildContext context, List<String> carouselImages) {
    final bannerHeight = getResponsiveValue(
      context,
      mobile: 250,
      tablet: 260,
      desktop: 280,
    );

    // If no images available, show placeholder
    if (carouselImages.isEmpty) {
      return Container(
        height: bannerHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          gradient: LinearGradient(
            colors: [_backgroundGradientStart, _backgroundGradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.directions_car,
                size: 48,
                color: Colors.white.withOpacity(0.9),
              ),
              SizedBox(height: 12),
              Text(
                'Drive Forward',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Your Premium Car Rental',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: bannerHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        child: CarouselSlider(
          items: carouselImages.map((imageUrl) {
            return Builder(
              builder: (BuildContext context) {
                return Image.network(
                  imageUrl,
                  fit: BoxFit.fill,
                  width: double.infinity,
                  height: bannerHeight,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                          color: _primaryColor,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 40,
                          color: Colors.grey[500],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }).toList(),
          options: CarouselOptions(
            height: bannerHeight,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 4),
            autoPlayAnimationDuration: Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: false,
            viewportFraction: 1.0,
            enableInfiniteScroll: true,
            pauseAutoPlayOnTouch: true,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainBookingProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bannerProvider = Provider.of<BannerProvider>(context);
    final List<String> carouselImages = bannerProvider.getAllImages();
    print('🏠 BUILD - Bookings in provider: ${provider.bookings.length}');

    return SafeArea(
      child: Scaffold(
        // appBar: PreferredSize(
        //   preferredSize: const Size.fromHeight(kToolbarHeight),
        //   child: Container(
        //     decoration: BoxDecoration(
        //       gradient: LinearGradient(
        //         begin: Alignment.topLeft,
        //         end: Alignment.bottomRight,
        //         colors: isDark
        //             ? [const Color(0xFF1A1A1A), const Color(0xFF1C1C1A)]
        //             : [
        //                 const Color(0xFFE8F5E9), // Light Green
        //                 const Color(0xFFE3F2FD), // Light Cream Blue
        //               ],
        //       ),
        //     ),
        //     child: AppBar(
        //       centerTitle: true,
        //       title: const Text(
        //         'Dashboard',
        //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        //       ),
        //       backgroundColor: Colors.transparent,
        //       foregroundColor: isDark ? Colors.white : Colors.black87,
        //       elevation: 0,
        //       bottom: PreferredSize(
        //         preferredSize: const Size.fromHeight(1),
        //         child: Divider(
        //           height: 1,
        //           color: isDark
        //               ? Colors.white.withOpacity(0.1)
        //               : Colors.black.withOpacity(0.05),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [const Color(0xFF1C1C1A), const Color(0xFF111110)]
                  : [
                      const Color(
                        0xFFE3F2FD,
                      ), // Light Cream Blue (continues from appbar)
                      const Color(0xFFF1F8E9), // Light Green
                    ],
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: getResponsiveValue(
                    context,
                    mobile: 0,
                    tablet: 24,
                    desktop: 32,
                  ),
                ),
                child: _buildHeroBanner(context, carouselImages),
              ),
              const SizedBox(height: 10),

              _buildDateSelector(isDark),
              _buildStatsRow(provider, isDark),
              const SizedBox(height: 4),
              Expanded(
                child: provider.isLoading && _isFirstLoad
                    ? const Center(
                        child: CircularProgressIndicator(color: _brand),
                      )
                    : provider.bookings.isEmpty
                    ? _buildEmptyState(isDark)
                    : FadeTransition(
                        opacity: _fadeAnimation,
                        child: RefreshIndicator(
                          onRefresh: _loadBookings,
                          color: _brand,
                          child: GridView.builder(
                            padding: const EdgeInsets.all(12),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.72,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                            itemCount: provider.bookings.length,
                            itemBuilder: (context, index) {
                              return _AnimatedBookingCard(
                                booking: provider.bookings[index],
                                isDark: isDark,
                                index: index,
                                onStatusUpdate: _loadBookings,
                              );
                            },
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

  Widget _buildDateSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: isDark ? const Color(0xFF1C1C1A) : Colors.white,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (context, child) => Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: _brand,
                        onPrimary: Colors.white,
                      ),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) await _onDateSelected(picked);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF242422)
                      : const Color(0xFFF7F7F5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 15,
                      color: isDark ? Colors.white60 : _brandDark,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _getDateDisplayText(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_drop_down,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_selectedDate != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => _onDateSelected(null), // Clear filter
              style: TextButton.styleFrom(
                foregroundColor: _brand,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              child: const Text(
                'All',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
          if (_selectedDate != null &&
              (_selectedDate!.day != DateTime.now().day ||
                  _selectedDate!.month != DateTime.now().month ||
                  _selectedDate!.year != DateTime.now().year)) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => _onDateSelected(DateTime.now()),
              style: TextButton.styleFrom(
                foregroundColor: _brand,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              child: const Text(
                'Today',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsRow(MainBookingProvider provider, bool isDark) {
    final confirmed = provider.bookings
        .where((b) => b.status == 'confirmed')
        .length;
    final pending = provider.bookings
        .where((b) => b.status == 'pending')
        .length;
    final completed = provider.bookings
        .where((b) => b.status == 'completed')
        .length;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Row(
        children: [
          _StatCard(
            label: 'Total',
            value: provider.totalBookings.toString(),
            color: _brand,
            isDark: isDark,
          ),
          const SizedBox(width: 6),
          _StatCard(
            label: 'Confirmed',
            value: confirmed.toString(),
            color: const Color(0xFF4CAF50),
            isDark: isDark,
          ),
          const SizedBox(width: 6),
          _StatCard(
            label: 'Pending',
            value: pending.toString(),
            color: const Color(0xFFFF9800),
            isDark: isDark,
          ),
          const SizedBox(width: 6),
          _StatCard(
            label: 'Done',
            value: completed.toString(),
            color: const Color(0xFF2196F3),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.grey.shade800.withOpacity(0.3)
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_busy_outlined,
              size: 60,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _selectedDate == null ? 'No Bookings Found' : 'No Bookings Found',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _selectedDate == null
                ? 'Pull down to refresh or select a date'
                : 'No bookings scheduled for this date',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white30 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  String _getDateDisplayText() {
    if (_selectedDate == null) return 'All Bookings';

    final now = DateTime.now();
    if (_selectedDate!.year == now.year &&
        _selectedDate!.month == now.month &&
        _selectedDate!.day == now.day)
      return 'Today';
    final tomorrow = now.add(const Duration(days: 1));
    if (_selectedDate!.year == tomorrow.year &&
        _selectedDate!.month == tomorrow.month &&
        _selectedDate!.day == tomorrow.day)
      return 'Tomorrow';
    return '${_selectedDate!.day} ${_getMonth(_selectedDate!.month)} ${_selectedDate!.year}';
  }

  String _getMonth(int month) {
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

// ─── Animated Booking Card ──────────────────────────────────────────────────

class _AnimatedBookingCard extends StatefulWidget {
  final BookingModel booking;
  final bool isDark;
  final int index;
  final VoidCallback onStatusUpdate;

  const _AnimatedBookingCard({
    required this.booking,
    required this.isDark,
    required this.index,
    required this.onStatusUpdate,
  });

  @override
  State<_AnimatedBookingCard> createState() => _AnimatedBookingCardState();
}

class _AnimatedBookingCardState extends State<_AnimatedBookingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _slideAnim;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnim = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _slideAnim = Tween<double>(
      begin: 30,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BookingDetailSheet(
        booking: widget.booking,
        isDark: widget.isDark,
        onStatusUpdate: widget.onStatusUpdate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _slideAnim.value),
        child: Transform.scale(scale: _scaleAnim.value, child: child),
      ),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _showDetails();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: _BookingCardCompact(booking: widget.booking),
        ),
      ),
    );
  }
}

// ─── Compact Grid Card ──────────────────────────────────────────────────────

class _BookingCardCompact extends StatelessWidget {
  final BookingModel booking;

  const _BookingCardCompact({required this.booking});

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF4CAF50);
      case 'pending':
        return const Color(0xFFFF9800);
      case 'completed':
        return const Color(0xFF2196F3);
      case 'active':
        return const Color(0xFF9C27B0);
      case 'cancelled':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = booking.status.toLowerCase();
    final color = _statusColor(status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Car Image – compact
          Stack(
            children: [
              SizedBox(
                height: 100,
                width: double.infinity,
                child: booking.car.carImage.isNotEmpty
                    ? Image.network(
                        booking.car.carImage.first,
                        fit: BoxFit.fill,
                        errorBuilder: (_, __, ___) => _imageFallback(),
                      )
                    : _imageFallback(),
              ),
              // Status chip on image
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _capitalize(status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Car name
                  Text(
                    '${booking.car.carName} ${booking.car.model}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    booking.car.vehicleNumber,
                    style: const TextStyle(fontSize: 10, color: Colors.black38),
                  ),

                  const Spacer(),

                  // Customer name
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: const Color(
                          0xFF1D9E75,
                        ).withOpacity(0.15),
                        child: Text(
                          booking.user.name.isNotEmpty
                              ? booking.user.name[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D9E75),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          booking.user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Price row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${booking.totalPrice}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D9E75),
                        ),
                      ),
                      // OTP badge
                      if (status == 'confirmed')
                        _OtpBadge(
                          label: 'OTP',
                          value: booking.otp.toString(),
                          color: const Color(0xFF1D9E75),
                        )
                      else if (status == 'active')
                        _OtpBadge(
                          label: 'RET',
                          value: booking.returnOTP?.toString() ?? '—',
                          color: const Color(0xFF9C27B0),
                        ),
                      // completed & cancelled: no OTP
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

  Widget _imageFallback() => Container(
    color: const Color(0xFFEEEEEC),
    child: const Center(
      child: Icon(Icons.directions_car, size: 36, color: Colors.grey),
    ),
  );

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _OtpBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _OtpBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(fontSize: 9, color: color.withOpacity(0.7)),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Full Detail Bottom Sheet ────────────────────────────────────────────────

class _BookingDetailSheet extends StatelessWidget {
  final BookingModel booking;
  final bool isDark;
  final VoidCallback onStatusUpdate;

  const _BookingDetailSheet({
    required this.booking,
    required this.isDark,
    required this.onStatusUpdate,
  });

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF4CAF50);
      case 'pending':
        return const Color(0xFFFF9800);
      case 'completed':
        return const Color(0xFF2196F3);
      case 'active':
        return const Color(0xFF9C27B0);
      case 'cancelled':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String _formatDate(String dateStr) {
    try {
      final d = DateTime.parse(dateStr);
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = booking.status.toLowerCase();
    final color = _statusColor(status);
    final bg = isDark ? const Color(0xFF1C1C1A) : Colors.white;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  // Car Image – full width
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 200,
                      child: booking.car.carImage.isNotEmpty
                          ? Image.network(
                              booking.car.carImage.first,
                              fit: BoxFit.fill,
                              errorBuilder: (_, __, ___) => _imgFallback(),
                            )
                          : _imgFallback(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Car & Status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${booking.car.carName} ${booking.car.model}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              booking.car.vehicleNumber,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _capitalize(status),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Customer
                  _SectionLabel(label: 'Customer', isDark: isDark),
                  const SizedBox(height: 8),
                  _DetailCard(
                    isDark: isDark,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: const Color(
                            0xFF1D9E75,
                          ).withOpacity(0.12),
                          child: Text(
                            booking.user.name.isNotEmpty
                                ? booking.user.name[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D9E75),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.user.name,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              Text(
                                booking.user.email,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Rental Dates
                  _SectionLabel(label: 'Rental Period', isDark: isDark),
                  const SizedBox(height: 8),
                  _DetailCard(
                    isDark: isDark,
                    child: Column(
                      children: [
                        _InfoRow2(
                          icon: Icons.flight_takeoff,
                          label: 'Pickup',
                          value:
                              '${_formatDate(booking.rentalStartDate)}  •  ${booking.from}',
                          isDark: isDark,
                        ),
                        const SizedBox(height: 10),
                        _InfoRow2(
                          icon: Icons.flight_land,
                          label: 'Return',
                          value:
                              '${_formatDate(booking.rentalEndDate)}  •  ${booking.to}',
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Payment
                  _SectionLabel(label: 'Payment', isDark: isDark),
                  const SizedBox(height: 8),
                  _DetailCard(
                    isDark: isDark,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Amount',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white38 : Colors.black38,
                              ),
                            ),
                            Text(
                              '₹${booking.totalPrice}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1D9E75),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Payment Status',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white38 : Colors.black38,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: booking.paymentStatus == 'Completed'
                                    ? const Color(0xFF4CAF50).withOpacity(0.12)
                                    : const Color(0xFFFF9800).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                booking.paymentStatus,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: booking.paymentStatus == 'Completed'
                                      ? const Color(0xFF4CAF50)
                                      : const Color(0xFFFF9800),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // OTP Section – conditional
                  if (status == 'confirmed') ...[
                    const SizedBox(height: 16),
                    _SectionLabel(label: 'Pickup OTP', isDark: isDark),
                    const SizedBox(height: 8),
                    _OtpDisplay(
                      label: 'Pickup OTP',
                      otp: booking.otp.toString(),
                      color: const Color(0xFF1D9E75),
                      isDark: isDark,
                    ),
                  ] else if (status == 'active') ...[
                    const SizedBox(height: 16),
                    _SectionLabel(label: 'Return OTP', isDark: isDark),
                    const SizedBox(height: 8),
                    _OtpDisplay(
                      label: 'Return OTP',
                      otp: booking.returnOTP?.toString() ?? '——',
                      color: const Color(0xFF9C27B0),
                      isDark: isDark,
                    ),
                  ],
                  // completed/cancelled → no OTP shown

                  // Action Buttons
                  if (status == 'confirmed') ...[
                    const SizedBox(height: 20),
                    _ActionButton(
                      label: 'Proceed with Pickup',
                      icon: Icons.arrow_forward_rounded,
                      color: const Color(0xFF1D9E75),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                BookingScreen(bookingId: booking.id),
                          ),
                        );
                      },
                    ),
                  ] else if (status == 'active') ...[
                    const SizedBox(height: 20),
                    _ActionButton(
                      label: 'Proceed with Return',
                      icon: Icons.keyboard_return_rounded,
                      color: Colors.orange,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReturnUploadScreen(id: booking.id),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imgFallback() => Container(
    color: isDark ? const Color(0xFF2A2A28) : const Color(0xFFEEEEEC),
    child: Center(
      child: Icon(
        Icons.directions_car,
        size: 60,
        color: isDark ? Colors.white24 : Colors.grey.shade400,
      ),
    ),
  );

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ─── Reusable Sheet Widgets ──────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) => Text(
    label.toUpperCase(),
    style: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
      color: isDark ? Colors.white38 : Colors.black38,
    ),
  );
}

class _DetailCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _DetailCard({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF242422) : const Color(0xFFF7F7F5),
      borderRadius: BorderRadius.circular(14),
    ),
    child: child,
  );
}

class _InfoRow2 extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _InfoRow2({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: const Color(0xFF1D9E75).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 14, color: const Color(0xFF1D9E75)),
      ),
      const SizedBox(width: 12),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    ],
  );
}

class _OtpDisplay extends StatelessWidget {
  final String label;
  final String otp;
  final Color color;
  final bool isDark;

  const _OtpDisplay({
    required this.label,
    required this.otp,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withOpacity(0.25)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Text(
          otp,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: 6,
            color: color,
          ),
        ),
      ],
    ),
  );
}

class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => setState(() => _pressed = true),
    onTapUp: (_) {
      setState(() => _pressed = false);
      widget.onTap();
    },
    onTapCancel: () => setState(() => _pressed = false),
    child: AnimatedScale(
      scale: _pressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Icon(widget.icon, color: Colors.white, size: 18),
          ],
        ),
      ),
    ),
  );
}

// ─── Stat Card ───────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1A) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
      ),
    ),
  );
}
