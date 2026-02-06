// File: lib/widgets/cuterus_mascot.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class CuterusMascot extends StatefulWidget {
  final String phase;
  
  const CuterusMascot({
    Key? key,
    required this.phase,
  }) : super(key: key);

  @override
  State<CuterusMascot> createState() => _CuterusMascotState();
}

class _CuterusMascotState extends State<CuterusMascot>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _blinkController;
  late AnimationController _tearController;
  late AnimationController _sparkleController;
  late AnimationController _sheddingController;
  late AnimationController _bounceController;
  late AnimationController _floatingController; // ✅ NEW: Floating animation
  
  late Animation<double> _breathingAnimation;
  late Animation<double> _blinkAnimation;
  late Animation<double> _tearAnimation;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _sheddingAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _floatingAnimation; // ✅ NEW: Floating animation

  bool _showSpeechBubble = false;
  String _currentMessage = "";

  @override
  void initState() {
    super.initState();
    
    // Breathing animation - gentle pulsing
    _breathingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    _breathingAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));
    
    // ✅ NEW: Floating animation - continuous up and down motion
    _floatingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    
    _floatingAnimation = Tween<double>(
      begin: -8.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));
    
    // Blinking animation
    _blinkController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
    );
    
    _blinkAnimation = Tween<double>(
      begin: 1.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _blinkController,
      curve: Curves.easeInOut,
    ));
    
    // Tear animation (for menstrual phase)
    _tearController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    
    _tearAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _tearController,
      curve: Curves.easeInOut,
    ));
    
    // Sparkle animation (for ovulation phase)
    _sparkleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    
    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeInOut,
    ));
    
    // Shedding animation (dramatic for menstrual)
    _sheddingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );
    
    _sheddingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sheddingController,
      curve: Curves.easeInOut,
    ));
    
    // Bounce animation (for ovulation - flirty)
    _bounceController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: -15.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeOut,
    ));
    
    _startPeriodicBlink();
    _triggerPhaseAnimation();
  }

  void _startPeriodicBlink() {
    Future.delayed(Duration(milliseconds: 2000 + math.Random().nextInt(3000)), () {
      if (mounted) {
        _blinkController.forward().then((_) {
          _blinkController.reverse().then((_) {
            if (mounted) {
              _startPeriodicBlink();
            }
          });
        });
      }
    });
  }

  void _triggerPhaseAnimation() {
    // Show speech bubble with phase-specific message
    setState(() {
      _showSpeechBubble = true;
      _currentMessage = _getPhaseMessage();
    });

    // Phase-specific animations
    if (widget.phase == 'menstrual') {
      _sheddingController.forward();
      _tearController.repeat(reverse: true);
    } else if (widget.phase == 'ovulation') {
      _sparkleController.repeat(reverse: true);
      _bounceController.forward().then((_) {
        _bounceController.reverse();
      });
    }

    // Hide speech bubble after 4 seconds
    Future.delayed(Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showSpeechBubble = false;
        });
      }
    });
  }

  @override
  void didUpdateWidget(CuterusMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phase != widget.phase) {
      _resetAnimations();
      _triggerPhaseAnimation();
    }
  }

  void _resetAnimations() {
    _sheddingController.reset();
    _tearController.reset();
    _sparkleController.reset();
    _bounceController.reset();
  }

  String _getPhaseMessage() {
    switch (widget.phase) {
      case 'menstrual':
        final messages = [
          "NO BABY? AGAIN??? AAAHHH! 😭",
          "Why do I even try anymore... 💔",
          "Another month, another betrayal! 😤",
          "I prepared EVERYTHING! For what?! 😢",
        ];
        return messages[math.Random().nextInt(messages.length)];
      case 'follicular':
        return "Okay, getting ready again... 🌱";
      case 'ovulation':
        final messages = [
          "Hey there... looking good today 😏✨",
          "Is it hot in here or is it just me? 💕",
          "Ready to make magic happen 🌟",
          "Feeling myself today! 💅✨",
        ];
        return messages[math.Random().nextInt(messages.length)];
      case 'luteal':
        return "Hmm, we'll see what happens... 🤔";
      default:
        return "Hello! I'm Cuterus! 💖";
    }
  }

  Color _getPhaseColor() {
    switch (widget.phase) {
      case 'menstrual':
        return Color(0xFFFF8A9B);
      case 'follicular':
        return Color(0xFFFFB6C1);
      case 'ovulation':
        return Color(0xFFFFE5EC);
      case 'luteal':
        return Color(0xFFFFD6E0);
      default:
        return Color(0xFFFFB6C1);
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _blinkController.dispose();
    _tearController.dispose();
    _sparkleController.dispose();
    _sheddingController.dispose();
    _bounceController.dispose();
    _floatingController.dispose(); // ✅ NEW: Dispose floating controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Speech bubble
          if (_showSpeechBubble)
            Positioned(
              top: 0,
              child: AnimatedOpacity(
                opacity: _showSpeechBubble ? 1.0 : 0.0,
                duration: Duration(milliseconds: 300),
                child: Container(
                  constraints: BoxConstraints(maxWidth: 250),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _currentMessage,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

          // ✅ UPDATED: Combined floating and breathing animations
          AnimatedBuilder(
            animation: Listenable.merge([
              _breathingController,
              _bounceController,
              _floatingController, // ✅ NEW: Include floating animation
            ]),
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _bounceAnimation.value + _floatingAnimation.value), // ✅ NEW: Add floating offset
                child: Transform.scale(
                  scale: _breathingAnimation.value,
                  child: child,
                ),
              );
            },
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _blinkController,
                _tearController,
                _sparkleController,
                _sheddingController,
              ]),
              builder: (context, child) {
                return CustomPaint(
                  size: Size(180, 160),
                  painter: _CuterusPainter(
                    phase: widget.phase,
                    blinkValue: _blinkAnimation.value,
                    tearValue: _tearAnimation.value,
                    sparkleValue: _sparkleAnimation.value,
                    sheddingValue: _sheddingAnimation.value,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CuterusPainter extends CustomPainter {
  final String phase;
  final double blinkValue;
  final double tearValue;
  final double sparkleValue;
  final double sheddingValue;

  _CuterusPainter({
    required this.phase,
    required this.blinkValue,
    required this.tearValue,
    required this.sparkleValue,
    required this.sheddingValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Main body color based on phase
    Color bodyColor = Color(0xFFFF8A9B);
    if (phase == 'follicular') bodyColor = Color(0xFFFFB6C1);
    if (phase == 'ovulation') bodyColor = Color(0xFFFFD6E0);
    if (phase == 'luteal') bodyColor = Color(0xFFFFC0CB);

    // ✅ NEW: Add black outline for depth
    final outlinePaint = Paint()
      ..color = Color(0xFF000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final bodyPaint = Paint()
      ..color = bodyColor
      ..style = PaintingStyle.fill;

    // ✅ NEW: Shadow paint for depth
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6);

    // Draw shadow first
    final shadowPath = Path();
    shadowPath.moveTo(centerX, centerY - 18);
    shadowPath.quadraticBezierTo(centerX - 35, centerY - 13, centerX - 40, centerY + 10);
    shadowPath.quadraticBezierTo(centerX - 35, centerY + 40, centerX, centerY + 50);
    shadowPath.quadraticBezierTo(centerX + 35, centerY + 40, centerX + 40, centerY + 10);
    shadowPath.quadraticBezierTo(centerX + 35, centerY - 13, centerX, centerY - 18);
    canvas.drawPath(shadowPath, shadowPaint);

    // Draw uterus body (pear shape) with outline
    final bodyPath = Path();
    bodyPath.moveTo(centerX, centerY - 20);
    bodyPath.quadraticBezierTo(centerX - 35, centerY - 15, centerX - 40, centerY + 10);
    bodyPath.quadraticBezierTo(centerX - 35, centerY + 40, centerX, centerY + 50);
    bodyPath.quadraticBezierTo(centerX + 35, centerY + 40, centerX + 40, centerY + 10);
    bodyPath.quadraticBezierTo(centerX + 35, centerY - 15, centerX, centerY - 20);
    
    canvas.drawPath(bodyPath, bodyPaint);
    canvas.drawPath(bodyPath, outlinePaint);

    // ✅ NEW: Add highlight for depth (top left)
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(centerX - 10, centerY - 10), 15, highlightPaint);

    // ✅ NEW: Small highlight dots (like in reference image)
    final smallHighlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(centerX + 15, centerY - 15), 3, smallHighlightPaint);
    canvas.drawCircle(Offset(centerX + 20, centerY - 17), 2, smallHighlightPaint);

    // Draw fallopian tubes (arms) with outline
    final tubePaint = Paint()
      ..color = bodyColor.withOpacity(0.9)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final tubeOutlinePaint = Paint()
      ..color = Color(0xFF000000)
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Left tube
    final leftTube = Path();
    leftTube.moveTo(centerX - 20, centerY - 10);
    leftTube.quadraticBezierTo(centerX - 50, centerY - 30, centerX - 60, centerY - 20);
    canvas.drawPath(leftTube, tubeOutlinePaint);
    canvas.drawPath(leftTube, tubePaint);

    // Right tube
    final rightTube = Path();
    rightTube.moveTo(centerX + 20, centerY - 10);
    rightTube.quadraticBezierTo(centerX + 50, centerY - 30, centerX + 60, centerY - 20);
    canvas.drawPath(rightTube, tubeOutlinePaint);
    canvas.drawPath(rightTube, tubePaint);

    // Draw ovaries (hands) with outline and depth
    final ovaryPaint = Paint()
      ..color = Color(0xFFFFF0F5)
      ..style = PaintingStyle.fill;

    final ovaryOutlinePaint = Paint()
      ..color = Color(0xFF000000)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // ✅ NEW: Ovary shadows for depth
    final ovaryShadowPaint = Paint()
      ..color = bodyColor.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    // Left ovary
    canvas.drawCircle(Offset(centerX - 60, centerY - 20), 12, ovaryShadowPaint);
    canvas.drawCircle(Offset(centerX - 60, centerY - 20), 12, ovaryPaint);
    canvas.drawCircle(Offset(centerX - 60, centerY - 20), 12, ovaryOutlinePaint);

    // Right ovary
    canvas.drawCircle(Offset(centerX + 60, centerY - 20), 12, ovaryShadowPaint);
    canvas.drawCircle(Offset(centerX + 60, centerY - 20), 12, ovaryPaint);
    canvas.drawCircle(Offset(centerX + 60, centerY - 20), 12, ovaryOutlinePaint);

    // ✅ UPDATED: Better eyes with white sclera and black pupils (like reference image)
    final scleraPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final scleraOutlinePaint = Paint()
      ..color = Color(0xFF000000)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final pupilPaint = Paint()
      ..color = Color(0xFF000000)
      ..style = PaintingStyle.fill;

    // Eye dimensions
    final eyeWidth = 18.0;
    final eyeHeight = 22.0 * blinkValue;
    
    // Left eye
    final leftEyeOval = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX - 15, centerY + 5),
        width: eyeWidth,
        height: eyeHeight,
      ),
      Radius.circular(eyeWidth / 2),
    );
    canvas.drawRRect(leftEyeOval, scleraPaint);
    canvas.drawRRect(leftEyeOval, scleraOutlinePaint);
    
    // Left pupil (offset slightly to create looking effect)
    if (blinkValue > 0.3) {
      canvas.drawCircle(
        Offset(centerX - 18, centerY + 5),
        6 * blinkValue,
        pupilPaint,
      );
    }

    // Right eye
    final rightEyeOval = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX + 15, centerY + 5),
        width: eyeWidth,
        height: eyeHeight,
      ),
      Radius.circular(eyeWidth / 2),
    );
    canvas.drawRRect(rightEyeOval, scleraPaint);
    canvas.drawRRect(rightEyeOval, scleraOutlinePaint);
    
    // Right pupil (offset slightly to create looking effect)
    if (blinkValue > 0.3) {
      canvas.drawCircle(
        Offset(centerX + 12, centerY + 5),
        6 * blinkValue,
        pupilPaint,
      );
    }

    // Blush - enhanced
    final blushPaint = Paint()
      ..color = Color(0xFFFF6B9D).withOpacity(0.35)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(centerX - 30, centerY + 15), 6, blushPaint);
    canvas.drawCircle(Offset(centerX + 30, centerY + 15), 6, blushPaint);

    // ✅ NEW: Small blush dots (like in reference image)
    final blushDotPaint = Paint()
      ..color = Color(0xFFFF6B9D).withOpacity(0.5)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(centerX - 32, centerY + 17), 1.5, blushDotPaint);
    canvas.drawCircle(Offset(centerX - 28, centerY + 17), 1.5, blushDotPaint);
    canvas.drawCircle(Offset(centerX + 28, centerY + 17), 1.5, blushDotPaint);
    canvas.drawCircle(Offset(centerX + 32, centerY + 17), 1.5, blushDotPaint);

    // Mouth - changes based on phase
    final mouthPaint = Paint()
      ..color = Color(0xFF333333)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (phase == 'menstrual') {
      // Crying sad mouth
      final mouthPath = Path();
      mouthPath.moveTo(centerX - 12, centerY + 28);
      mouthPath.quadraticBezierTo(centerX, centerY + 23, centerX + 12, centerY + 28);
      canvas.drawPath(mouthPath, mouthPaint);
      
      // Tears!
      if (tearValue > 0) {
        final tearPaint = Paint()
          ..color = Color(0xFF87CEEB).withOpacity(0.7)
          ..style = PaintingStyle.fill;
        
        // Left tear
        final leftTearPath = Path();
        leftTearPath.moveTo(centerX - 15, centerY + 13);
        leftTearPath.quadraticBezierTo(
          centerX - 17, 
          centerY + 13 + (20 * tearValue), 
          centerX - 15, 
          centerY + 13 + (25 * tearValue)
        );
        leftTearPath.quadraticBezierTo(
          centerX - 13, 
          centerY + 13 + (20 * tearValue), 
          centerX - 15, 
          centerY + 13
        );
        canvas.drawPath(leftTearPath, tearPaint);
        
        // Right tear
        final rightTearPath = Path();
        rightTearPath.moveTo(centerX + 15, centerY + 13);
        rightTearPath.quadraticBezierTo(
          centerX + 17, 
          centerY + 13 + (20 * tearValue), 
          centerX + 15, 
          centerY + 13 + (25 * tearValue)
        );
        rightTearPath.quadraticBezierTo(
          centerX + 13, 
          centerY + 13 + (20 * tearValue), 
          centerX + 15, 
          centerY + 13
        );
        canvas.drawPath(rightTearPath, tearPaint);
      }
    } else if (phase == 'ovulation') {
      // Flirty smile
      final mouthPath = Path();
      mouthPath.moveTo(centerX - 15, centerY + 25);
      mouthPath.quadraticBezierTo(centerX, centerY + 31, centerX + 15, centerY + 25);
      canvas.drawPath(mouthPath, mouthPaint);
      
      // Sparkles!
      if (sparkleValue > 0) {
        final sparklePaint = Paint()
          ..color = Color(0xFFFFD700).withOpacity(sparkleValue)
          ..style = PaintingStyle.fill;
        
        _drawSparkle(canvas, centerX - 50, centerY - 35, 6, sparklePaint);
        _drawSparkle(canvas, centerX + 50, centerY - 35, 6, sparklePaint);
        _drawSparkle(canvas, centerX - 40, centerY + 40, 5, sparklePaint);
        _drawSparkle(canvas, centerX + 40, centerY + 40, 5, sparklePaint);
      }
    } else if (phase == 'follicular') {
      // Gentle smile
      final mouthPath = Path();
      mouthPath.moveTo(centerX - 12, centerY + 26);
      mouthPath.quadraticBezierTo(centerX, centerY + 29, centerX + 12, centerY + 26);
      canvas.drawPath(mouthPath, mouthPaint);
    } else {
      // Neutral/thoughtful - cute little line
      final mouthPath = Path();
      mouthPath.moveTo(centerX - 8, centerY + 27);
      mouthPath.lineTo(centerX - 3, centerY + 25);
      mouthPath.lineTo(centerX + 3, centerY + 25);
      mouthPath.lineTo(centerX + 8, centerY + 27);
      canvas.drawPath(mouthPath, mouthPaint);
    }

    // Shedding effect for menstrual phase
    if (phase == 'menstrual' && sheddingValue > 0) {
      final sheddingPaint = Paint()
        ..color = Color(0xFFFF6B9D).withOpacity(0.6 * (1 - sheddingValue))
        ..style = PaintingStyle.fill;
      
      // Falling particles
      for (int i = 0; i < 8; i++) {
        final angle = (i / 8) * 2 * math.pi;
        final distance = 30 + (sheddingValue * 40);
        final x = centerX + math.cos(angle) * distance;
        final y = centerY + math.sin(angle) * distance + (sheddingValue * 20);
        canvas.drawCircle(Offset(x, y), 3 - (sheddingValue * 2), sheddingPaint);
      }
    }

    // ✅ UPDATED: Cute cervix detail at bottom with outline and depth
    final cervixShadowPaint = Paint()
      ..color = bodyColor.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final cervixPaint = Paint()
      ..color = bodyColor.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final cervixOutlinePaint = Paint()
      ..color = Color(0xFF000000)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    canvas.drawCircle(Offset(centerX, centerY + 46), 7, cervixShadowPaint);
    canvas.drawCircle(Offset(centerX, centerY + 45), 6, cervixPaint);
    canvas.drawCircle(Offset(centerX, centerY + 45), 6, cervixOutlinePaint);
  }

  void _drawSparkle(Canvas canvas, double x, double y, double size, Paint paint) {
    final path = Path();
    path.moveTo(x, y - size);
    path.lineTo(x + size * 0.3, y - size * 0.3);
    path.lineTo(x + size, y);
    path.lineTo(x + size * 0.3, y + size * 0.3);
    path.lineTo(x, y + size);
    path.lineTo(x - size * 0.3, y + size * 0.3);
    path.lineTo(x - size, y);
    path.lineTo(x - size * 0.3, y - size * 0.3);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CuterusPainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.blinkValue != blinkValue ||
      oldDelegate.tearValue != tearValue ||
      oldDelegate.sparkleValue != sparkleValue ||
      oldDelegate.sheddingValue != sheddingValue;
}