import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../state/story_buddy_provider.dart';
import '../theme/app_theme.dart';

class BuddyAvatar extends StatefulWidget {
  final BuddyMood mood;

  const BuddyAvatar({
    Key? key,
    required this.mood,
  }) : super(key: key);

  @override
  State<BuddyAvatar> createState() => _BuddyAvatarState();
}

class _BuddyAvatarState extends State<BuddyAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(); // Keep repeating to run the breathing/mouth animations
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Calculate dynamic properties based on time and mood
        double breathOffset = math.sin(_controller.value * 2 * math.pi) * 3;
        double rotationOffset = 0.0;
        double bounceOffset = 0.0;
        double gearRotation = _controller.value * 2 * math.pi;

        if (widget.mood == BuddyMood.happy) {
          // Bounce up and down quickly
          bounceOffset = -(math.sin(_controller.value * 4 * math.pi)).abs() * 12;
          rotationOffset = math.sin(_controller.value * 4 * math.pi) * 0.05;
        } else if (widget.mood == BuddyMood.thinking) {
          // Rotate head slightly back and forth
          rotationOffset = math.sin(_controller.value * 2 * math.pi) * 0.03;
          gearRotation = _controller.value * 4 * math.pi; // Spin gear faster
        } else if (widget.mood == BuddyMood.sad) {
          // Droop down
          breathOffset = 4.0;
        }

        return Container(
          height: 180,
          alignment: Alignment.bottomCenter,
          child: Transform.translate(
            offset: Offset(0, bounceOffset + breathOffset),
            child: Transform.rotate(
              angle: rotationOffset,
              child: Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: [
                  // Shadow under robot
                  Positioned(
                    bottom: -10,
                    child: Container(
                      width: 110,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.06),
                        borderRadius: BorderRadius.all(Radius.elliptical(110, 12)),
                      ),
                    ),
                  ),
                  
                  // Robot Body & Head
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Rotating Gear on Head
                      Transform.rotate(
                        angle: gearRotation,
                        child: _buildGear(),
                      ),
                      
                      // Antenna Neck/Stem
                      Container(
                        width: 8,
                        height: 12,
                        color: AppTheme.textLight,
                      ),
                      
                      // Head Container
                      Container(
                        width: 120,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppTheme.buddyPrimary,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: AppTheme.textDark,
                            width: 5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.textDark.withOpacity(0.15),
                              offset: const Offset(4, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Ears & Screen Overlay
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildEye(widget.mood),
                                  _buildEye(widget.mood),
                                ],
                              ),
                              
                              // Mouth
                              _buildMouth(widget.mood, _controller.value),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Draw the gear on top of Pip's head
  Widget _buildGear() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Main gear circle with notches
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.buddyAccent,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.textDark,
              width: 4,
            ),
          ),
        ),
        // Notches
        ...List.generate(4, (index) {
          double angle = (index * math.pi) / 2;
          return Transform.rotate(
            angle: angle,
            child: Container(
              width: 42,
              height: 8,
              decoration: BoxDecoration(
                color: AppTheme.buddyAccent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
        // Inner gear circle
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  // Render eyes according to buddy mood
  Widget _buildEye(BuddyMood mood) {
    if (mood == BuddyMood.happy) {
      // Arch/Smiling eyes (^^)
      return Container(
        width: 24,
        height: 24,
        margin: const EdgeInsets.only(top: 8),
        child: CustomPaint(
          painter: _HappyEyePainter(color: Colors.white, strokeWidth: 5),
        ),
      );
    }

    if (mood == BuddyMood.sad) {
      // Downward angled sad/sorry eyes (\ /)
      return Container(
        width: 24,
        height: 24,
        margin: const EdgeInsets.only(top: 8),
        child: CustomPaint(
          painter: _SadEyePainter(color: Colors.white, strokeWidth: 5),
        ),
      );
    }

    // Default: Round glowing eyes
    Color eyeColor = mood == BuddyMood.thinking ? AppTheme.secondary : Colors.white;
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: eyeColor,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.textDark, width: 4),
      ),
      child: Center(
        child: Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppTheme.textDark,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  // Render interactive mouth animations
  Widget _buildMouth(BuddyMood mood, double animationValue) {
    if (mood == BuddyMood.happy) {
      // Wide open happy smile
      return Container(
        width: 36,
        height: 18,
        margin: const EdgeInsets.only(bottom: 4),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        ),
      );
    }

    if (mood == BuddyMood.sad) {
      // Frown
      return Container(
        width: 28,
        height: 8,
        margin: const EdgeInsets.only(bottom: 8),
        child: CustomPaint(
          painter: _FrownPainter(color: Colors.white, strokeWidth: 4),
        ),
      );
    }

    if (mood == BuddyMood.talking) {
      // Mouth moves up and down
      double height = 6.0 + (math.sin(animationValue * 6 * math.pi) + 1.0) * 5.0; // Oscillates
      return Container(
        width: 24,
        height: height,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.textDark, width: 2),
        ),
      );
    }

    // Idle: simple lines
    return Container(
      width: 24,
      height: 6,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

// Custom painter to render arching happy eyes
class _HappyEyePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _HappyEyePainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width / 2,
      size.height * 0.2,
      size.width,
      size.height * 0.7,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter to render drooped sad eyes
class _SadEyePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _SadEyePainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Angle eye brows downwards
    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.6), paint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.7), 4, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter to render a frown curve
class _FrownPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _FrownPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
      size.width / 2,
      0,
      size.width,
      size.height,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
