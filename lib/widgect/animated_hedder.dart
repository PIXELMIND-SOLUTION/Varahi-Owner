import 'package:varahiowner/views/profile_screen.dart';
import 'package:flutter/material.dart';

class AnimatedLocationHeader extends StatefulWidget {
  final String? profileImage;
  final String? localImageUrl;

  const AnimatedLocationHeader({
    Key? key,
    this.profileImage,
    required this.localImageUrl,
  }) : super(key: key);

  @override
  State<AnimatedLocationHeader> createState() => _AnimatedLocationHeaderState();
}

class _AnimatedLocationHeaderState extends State<AnimatedLocationHeader>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _textController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    print(
      "hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh${widget.profileImage}",
    );

    // Rotation controller for the dotted ring
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Fade animation for text
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Slide animation for text
    _slideAnimation =
        Tween<Offset>(begin: const Offset(-0.5, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _textController,
            curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
          ),
        );

    // Start text animation
    _textController.forward();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildLocationHeader();
  }

  Widget _buildLocationHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // LOGO + TEXT
          Row(
            children: [
              // Logo with rotating dotted ring
              Stack(
                alignment: Alignment.center,
                children: [
                  // Rotating dotted ring
                  AnimatedBuilder(
                    animation: _rotationController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationController.value * 2 * 1.14159,
                        child: Container(
                          width: screenWidth * 0.18,
                          height: screenWidth * 0.18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF120698),
                              width: 2,
                              style: BorderStyle.none,
                            ),
                          ),
                          child: CustomPaint(
                            painter: DottedCirclePainter(
                              color: const Color(0xFF120698),
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // Logo image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      'assets/logoo.jpg',
                      width: screenWidth * 0.16,
                      height: screenWidth * 0.16,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // Animated text
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Animated "Varahi" text
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: TextStyle(
                              fontSize: screenWidth * 0.055,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF120698),
                            ),
                            child: const Text("Varahi"),
                          ),
                          const SizedBox(height: 2),
                          // Animated "Self Drive Cars" text
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                            ),
                            child: const Text("Self Drive Cars"),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          // PROFILE IMAGE
          Container(
            width: screenWidth * 0.18,
            height: screenHeight * 0.08,
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Color(0XFF120698),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                topLeft: Radius.circular(30),
              ),
            ),
            child: Center(
              child: widget.profileImage == null
                  ? GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          (widget.localImageUrl.toString()),
                        ),
                      ),
                    )
                  : CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(
                        (widget.profileImage.toString()),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for dotted circle
class DottedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  DottedCirclePainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    const dashWidth = 8.0;
    const dashSpace = 6.0;
    final circumference = 2 * 3.14159 * radius;
    final dashCount = (circumference / (dashWidth + dashSpace)).floor();

    for (int i = 0; i < dashCount; i++) {
      final startAngle = (i * (dashWidth + dashSpace) / radius);
      final endAngle = startAngle + (dashWidth / radius);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        endAngle - startAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
