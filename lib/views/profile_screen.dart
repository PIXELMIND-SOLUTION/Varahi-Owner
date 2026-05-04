// ═════════════════════════════════════════════════════════════════════════════
// ProfileScreen
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:varahiowner/views/aboutus_screen.dart';
import 'package:varahiowner/views/login_screen.dart';
import 'package:varahiowner/views/my_cars_screen.dart';
import 'package:varahiowner/views/myprofile_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared constants
// ─────────────────────────────────────────────────────────────────────────────

const _brand = Color(0xFF1D9E75);
const _brandLight = Color(0xFFE1F5EE);
const _brandDark = Color(0xFF0F6E56);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Menu sections ────────────────────────────────────────────
            _SectionLabel(label: 'Account', textMuted: textMuted),
            const SizedBox(height: 8),
            _MenuGroup(
              cardColor: cardColor,
              borderColor: borderColor,
              items: [
                _MenuItem(
                  icon: Icons.person_outline_rounded,
                  iconColor: _brand,
                  iconBg: _brandLight,
                  label: 'My profile',
                  subtitle: 'Personal details',
                  textPrimary: textPrimary,
                  textMuted: textMuted,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyProfileScreen(),
                      ),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.car_rental,
                  iconColor: _brand,
                  iconBg: _brandLight,
                  label: 'My car',
                  subtitle: 'Vehicle details',
                  textPrimary: textPrimary,
                  textMuted: textMuted,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyCarsScreen()),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),
            _SectionLabel(label: 'Information', textMuted: textMuted),
            const SizedBox(height: 8),
            _MenuGroup(
              cardColor: cardColor,
              borderColor: borderColor,
              items: [
                _MenuItem(
                  icon: Icons.info_outline_rounded,
                  iconColor: const Color(0xFF185FA5),
                  iconBg: const Color(0xFFE6F1FB),
                  label: 'About',
                  subtitle: 'App version & company info',
                  textPrimary: textPrimary,
                  textMuted: textMuted,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AboutUsScreen()),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.privacy_tip_outlined,
                  iconColor: const Color(0xFF6B3FA0),
                  iconBg: const Color(0xFFF0EBFA),
                  label: 'Privacy policy',
                  subtitle: 'How we handle your data',
                  textPrimary: textPrimary,
                  textMuted: textMuted,
                  onTap: () {},
                  showDivider: true,
                ),
                _MenuItem(
                  icon: Icons.description_outlined,
                  iconColor: const Color(0xFFBA7517),
                  iconBg: const Color(0xFFFAEEDA),
                  label: 'Terms of use',
                  subtitle: 'Usage rules & agreements',
                  textPrimary: textPrimary,
                  textMuted: textMuted,
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 16),
            _SectionLabel(label: 'Support', textMuted: textMuted),
            const SizedBox(height: 8),
            _MenuGroup(
              cardColor: cardColor,
              borderColor: borderColor,
              items: [
                _MenuItem(
                  icon: Icons.headset_mic_outlined,
                  iconColor: const Color(0xFF1D9E75),
                  iconBg: const Color(0xFFE1F5EE),
                  label: 'Help & support',
                  subtitle: 'Contact us or raise an issue',
                  textPrimary: textPrimary,
                  textMuted: textMuted,
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Logout ───────────────────────────────────────────────────
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCEBEB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      size: 18,
                      color: Colors.redAccent,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Log out',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
            Center(
              child: Text(
                'Varahi Owner  •  v1.0.0',
                style: TextStyle(fontSize: 11, color: textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color cardColor, borderColor, textPrimary, textMuted;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.cardColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: _brand),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: textMuted)),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color textMuted;

  const _SectionLabel({required this.label, required this.textMuted});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: textMuted,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  final List<_MenuItem> items;
  final Color cardColor, borderColor;

  const _MenuGroup({
    required this.items,
    required this.cardColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Column(
            children: [
              item,
              if (i < items.length - 1)
                Divider(
                  height: 1,
                  thickness: 0.5,
                  indent: 56,
                  color: borderColor,
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor, iconBg;
  final String label, subtitle;
  final Color textPrimary, textMuted;
  final VoidCallback onTap;
  final bool showDivider;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.subtitle,
    required this.textPrimary,
    required this.textMuted,
    required this.onTap,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: textMuted),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: textMuted),
          ],
        ),
      ),
    );
  }
}
