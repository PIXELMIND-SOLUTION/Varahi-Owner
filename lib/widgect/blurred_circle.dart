import 'dart:ui';

import 'package:flutter/material.dart';

class BlurredCircle extends StatelessWidget {
  final Color color;
  const BlurredCircle({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.6), color.withOpacity(0.5)],
          radius: 0.6,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}
