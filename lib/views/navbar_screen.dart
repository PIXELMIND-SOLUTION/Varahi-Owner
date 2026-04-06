import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:varahiowner/views/booking_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Theme notifier
// ─────────────────────────────────────────────────────────────────────────────

class ThemeNotifier extends ValueNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light);

  void toggle() {
    value = value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  bool get isDark => value == ThemeMode.dark;
}

final themeNotifier = ThemeNotifier();

// ─────────────────────────────────────────────────────────────────────────────
// Main entry — wrap your MaterialApp like this
// ─────────────────────────────────────────────────────────────────────────────
//
// void main() {
//   runApp(
//     ChangeNotifierProvider(create: (_) => AuthProvider(),
//       child: const VarahiApp(),
//     ),
//   );
// }
//
// class VarahiApp extends StatelessWidget {
//   const VarahiApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<ThemeMode>(
//       valueListenable: themeNotifier,
//       builder: (_, mode, __) => MaterialApp(
//         title: 'Varahi Owner',
//         themeMode: mode,
//         theme: VarahiTheme.light,
//         darkTheme: VarahiTheme.dark,
//         home: const MainShell(),
//       ),
//     );
//   }
// }

// ─────────────────────────────────────────────────────────────────────────────
// Theme definitions
// ─────────────────────────────────────────────────────────────────────────────

class VarahiTheme {
  static const _brand = Color(0xFF1D9E75);

  static final light = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF7F7F5),
    colorScheme: ColorScheme.fromSeed(
      seedColor: _brand,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );

  static final dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF111110),
    colorScheme: ColorScheme.fromSeed(
      seedColor: _brand,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// MainShell — bottom nav + shared app bar
// ─────────────────────────────────────────────────────────────────────────────

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _brand = Color(0xFF1D9E75);
  static const _brandLight = Color(0xFFE1F5EE);
  static const _brandDark = Color(0xFF0F6E56);

  final List<Widget> _screens = const [
    HomeScreen(),
    BookingsScreen(),
    ProfileScreen(),
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    _NavItem(
      label: 'Bookings',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
    ),
    _NavItem(
      label: 'Profile',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: bgColor,
        // ── Custom app bar ───────────────────────────────────────────────
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: SafeArea(
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: bgColor,
                border: Border(
                  bottom: BorderSide(color: borderColor, width: 0.5),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Brand logo tile
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/ic_launcher.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Brand name + greeting
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Varahi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _brand,
                          letterSpacing: -0.4,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _greeting,
                        style: TextStyle(
                          fontSize: 12,
                          color: textMuted,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Dark / light mode toggle
                  // ValueListenableBuilder<ThemeMode>(
                  //   valueListenable: themeNotifier,
                  //   builder: (_, mode, __) {
                  //     final dark = mode == ThemeMode.dark;
                  //     return GestureDetector(
                  //       onTap: () {
                  //         themeNotifier.toggle();
                  //       },
                  //       child: AnimatedContainer(
                  //         duration: const Duration(milliseconds: 250),
                  //         width: 56,
                  //         height: 30,
                  //         padding: const EdgeInsets.all(3),
                  //         decoration: BoxDecoration(
                  //           color: dark
                  //               ? const Color(0xFF2A2A28)
                  //               : const Color(0xFFEAEAE6),
                  //           borderRadius: BorderRadius.circular(20),
                  //           border: Border.all(
                  //             color: dark
                  //                 ? Colors.white.withOpacity(0.1)
                  //                 : Colors.black.withOpacity(0.1),
                  //             width: 0.5,
                  //           ),
                  //         ),
                  //         child: Stack(
                  //           children: [
                  //             AnimatedAlign(
                  //               duration: const Duration(milliseconds: 250),
                  //               curve: Curves.easeInOut,
                  //               alignment: dark
                  //                   ? Alignment.centerRight
                  //                   : Alignment.centerLeft,
                  //               child: Container(
                  //                 width: 24,
                  //                 height: 24,
                  //                 decoration: BoxDecoration(
                  //                   color: dark
                  //                       ? const Color(0xFF3A3A38)
                  //                       : Colors.white,
                  //                   shape: BoxShape.circle,
                  //                   boxShadow: [
                  //                     BoxShadow(
                  //                       color: Colors.black.withOpacity(0.12),
                  //                       blurRadius: 4,
                  //                       offset: const Offset(0, 1),
                  //                     ),
                  //                   ],
                  //                 ),
                  //                 child: Icon(
                  //                   dark
                  //                       ? Icons.nightlight_round
                  //                       : Icons.wb_sunny_rounded,
                  //                   size: 13,
                  //                   color: dark
                  //                       ? const Color(0xFFBBBBBB)
                  //                       : const Color(0xFFE8A020),
                  //                 ),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     );
                  //   },
                  // ),
                  const SizedBox(width: 10),

                  // Notification bell
                ],
              ),
            ),
          ),
        ),

        // ── Body ─────────────────────────────────────────────────────────
        body: IndexedStack(index: _currentIndex, children: _screens),

        // ── Bottom nav ───────────────────────────────────────────────────
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: cardColor,
            border: Border(top: BorderSide(color: borderColor, width: 0.5)),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 64,
              child: Row(
                children: List.generate(_navItems.length, (i) {
                  final item = _navItems[i];
                  final isActive = _currentIndex == i;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _currentIndex = i),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? _brandLight
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              isActive ? item.activeIcon : item.icon,
                              size: 22,
                              color: isActive ? _brandDark : textMuted,
                            ),
                          ),
                          const SizedBox(height: 3),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isActive ? _brandDark : textMuted,
                            ),
                            child: Text(item.label),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Nav item data
// ─────────────────────────────────────────────────────────────────────────────

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}
