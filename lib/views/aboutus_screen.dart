// ═════════════════════════════════════════════════════════════════════════════
// AboutUsScreen
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // add url_launcher to pubspec

// ─────────────────────────────────────────────────────────────────────────────
// Shared brand tokens
// ─────────────────────────────────────────────────────────────────────────────

const _brand = Color(0xFF1D9E75);
const _brandLight = Color(0xFFE1F5EE);
const _brandDark = Color(0xFF0F6E56);

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  static const _appVersion = '1.0.0';
  static const _buildNumber = '100';
  static const _websiteUrl = 'https://varahi.in';
  static const _emailUrl = 'mailto:support@varahi.in';
  static const _phoneUrl = 'tel:+918888888888';

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
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

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            child: Icon(Icons.arrow_back_rounded, size: 18, color: textPrimary),
          ),
        ),
        title: Text(
          'About',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Brand hero ─────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  // Logo mark
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: _brandLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _brand.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'V',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: _brandDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Varahi Owner',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Empowering vendors across India',
                    style: TextStyle(fontSize: 13, color: textMuted),
                  ),
                  const SizedBox(height: 16),
                  // Version pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _brandLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Version $_appVersion (Build $_buildNumber)',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _brandDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Mission ────────────────────────────────────────────────
            _SectionLabel(label: 'Our mission', textMuted: textMuted),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: Text(
                'Varahi Owner is built to simplify daily operations for '
                'vehicle-based service vendors. From tracking rides to '
                'managing earnings, we handle the backend so you can '
                'focus on what matters — serving your customers.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: textPrimary.withOpacity(0.8),
                  height: 1.6,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── App info ───────────────────────────────────────────────
            _SectionLabel(label: 'App information', textMuted: textMuted),
            const SizedBox(height: 8),
            _InfoGroup(
              cardColor: cardColor,
              borderColor: borderColor,
              items: [
                _InfoRow(
                  label: 'App name',
                  value: 'Varahi Owner',
                  textPrimary: textPrimary,
                  textMuted: textMuted,
                ),
                _InfoRow(
                  label: 'Version',
                  value: _appVersion,
                  textPrimary: textPrimary,
                  textMuted: textMuted,
                  showDivider: true,
                ),
                _InfoRow(
                  label: 'Build number',
                  value: _buildNumber,
                  textPrimary: textPrimary,
                  textMuted: textMuted,
                  showDivider: true,
                ),
                _InfoRow(
                  label: 'Platform',
                  value: 'Android & iOS',
                  textPrimary: textPrimary,
                  textMuted: textMuted,
                  showDivider: true,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Contact ────────────────────────────────────────────────
            _SectionLabel(label: 'Contact us', textMuted: textMuted),
            const SizedBox(height: 8),
            _ContactGroup(
              cardColor: cardColor,
              borderColor: borderColor,
              textPrimary: textPrimary,
              textMuted: textMuted,
              items: [
                _ContactItem(
                  icon: Icons.language_rounded,
                  iconColor: const Color(0xFF185FA5),
                  iconBg: const Color(0xFFE6F1FB),
                  label: 'Website',
                  value: 'www.varahi.in',
                  onTap: () => _launch(_websiteUrl),
                  textPrimary: textPrimary,
                  textMuted: textMuted,
                ),
                _ContactItem(
                  icon: Icons.mail_outline_rounded,
                  iconColor: const Color(0xFFBA7517),
                  iconBg: const Color(0xFFFAEEDA),
                  label: 'Email',
                  value: 'support@varahi.in',
                  onTap: () => _launch(_emailUrl),
                  textPrimary: textPrimary,
                  textMuted: textMuted,
                  showDivider: true,
                ),
                _ContactItem(
                  icon: Icons.phone_outlined,
                  iconColor: const Color(0xFF1D9E75),
                  iconBg: const Color(0xFFE1F5EE),
                  label: 'Phone',
                  value: '+91 88888 88888',
                  onTap: () => _launch(_phoneUrl),
                  textPrimary: textPrimary,
                  textMuted: textMuted,
                  showDivider: true,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Made with love footer ──────────────────────────────────
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Made with ',
                        style: TextStyle(fontSize: 12, color: textMuted),
                      ),
                      const Icon(
                        Icons.favorite_rounded,
                        size: 13,
                        color: Colors.redAccent,
                      ),
                      Text(
                        ' in India',
                        style: TextStyle(fontSize: 12, color: textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '© 2025 Varahi Technologies. All rights reserved.',
                    style: TextStyle(fontSize: 11, color: textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper widgets
// ─────────────────────────────────────────────────────────────────────────────

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

// ── Info group ────────────────────────────────────────────────────────────────

class _InfoGroup extends StatelessWidget {
  final List<_InfoRow> items;
  final Color cardColor, borderColor;

  const _InfoGroup({
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
          return Column(
            children: [
              items[i],
              if (items[i].showDivider)
                Divider(
                  height: 1,
                  thickness: 0.5,
                  indent: 16,
                  endIndent: 16,
                  color: borderColor,
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final Color textPrimary, textMuted;
  final bool showDivider;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.textPrimary,
    required this.textMuted,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13.5, color: textMuted)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Contact group ─────────────────────────────────────────────────────────────

class _ContactGroup extends StatelessWidget {
  final List<_ContactItem> items;
  final Color cardColor, borderColor, textPrimary, textMuted;

  const _ContactGroup({
    required this.items,
    required this.cardColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textMuted,
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
          return Column(
            children: [
              items[i],
              if (items[i].showDivider)
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

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor, iconBg;
  final String label, value;
  final VoidCallback onTap;
  final Color textPrimary, textMuted;
  final bool showDivider;

  const _ContactItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.onTap,
    required this.textPrimary,
    required this.textMuted,
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
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(value, style: TextStyle(fontSize: 12, color: textMuted)),
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
