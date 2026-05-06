import 'package:flutter/material.dart';

// Use this widget anywhere you need the icon in your UI
class ExactIcon extends StatelessWidget {
  final double size;
  final Color color;
  
  const ExactIcon({
    super.key, 
    this.size = 60.0, 
    this.color = const Color(0xFF120698)
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: ExactThreeCirclePainter(color: color),
    );
  }
}

class ExactThreeCirclePainter extends CustomPainter {
  final Color color;
  
  ExactThreeCirclePainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final centerTop = Offset(size.width / 2, size.height * 0.25);
    final centerLeft = Offset(size.width * 0.3, size.height * 0.65);
    final centerRight = Offset(size.width * 0.7, size.height * 0.65);
    final radius = size.width * 0.2;

    // Draw Top Full Circle
    canvas.drawCircle(centerTop, radius, paint);

    // Path for Left Circle with Cut
    final leftPath = Path()
      ..addOval(Rect.fromCircle(center: centerLeft, radius: radius));

    final leftCut = Path()
      ..addArc(
        Rect.fromCircle(center: Offset(size.width / 2, size.height * 0.5), radius: radius * 0.95),
        0,
        3.14,
      );

    canvas.drawPath(
      Path.combine(PathOperation.difference, leftPath, leftCut),
      paint,
    );

    // Path for Right Circle with Cut
    final rightPath = Path()
      ..addOval(Rect.fromCircle(center: centerRight, radius: radius));

    final rightCut = Path()
      ..addArc(
        Rect.fromCircle(center: Offset(size.width / 2, size.height * 0.5), radius: radius * 0.95),
        3.14,
        3.14,
      );

    canvas.drawPath(
      Path.combine(PathOperation.difference, rightPath, rightCut),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is ExactThreeCirclePainter) {
      return color != oldDelegate.color;
    }
    return true;
  }
}