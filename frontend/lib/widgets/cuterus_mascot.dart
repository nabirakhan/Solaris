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
  
  late Animation<double> _breathingAnimation;
  late Animation<double> _blinkAnimation;
  late Animation<double> _tearAnimation;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _sheddingAnimation;
  late Animation<double> _bounceAnimation;

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
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    _currentMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
              ),
            ),
          
          // Main Cuterus character
          Positioned(
            bottom: 20,
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _breathingAnimation,
                _bounceAnimation,
              ]),
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _bounceAnimation.value),
                  child: Transform.scale(
                    scale: _breathingAnimation.value,
                    child: CustomPaint(
                      size: Size(140, 140),
                      painter: _CuterusPainter(
                        phase: widget.phase,
                        blinkValue: _blinkAnimation.value,
                        tearValue: _tearAnimation.value,
                        sparkleValue: _sparkleAnimation.value,
                        sheddingValue: _sheddingAnimation.value,
                      ),
                    ),
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

    final bodyPaint = Paint()
      ..color = bodyColor
      ..style = PaintingStyle.fill;

    // Draw uterus body (pear shape)
    final bodyPath = Path();
    bodyPath.moveTo(centerX, centerY - 20);
    bodyPath.quadraticBezierTo(centerX - 35, centerY - 15, centerX - 40, centerY + 10);
    bodyPath.quadraticBezierTo(centerX - 35, centerY + 40, centerX, centerY + 50);
    bodyPath.quadraticBezierTo(centerX + 35, centerY + 40, centerX + 40, centerY + 10);
    bodyPath.quadraticBezierTo(centerX + 35, centerY - 15, centerX, centerY - 20);
    canvas.drawPath(bodyPath, bodyPaint);

    // Draw fallopian tubes (arms)
    final tubePaint = Paint()
      ..color = bodyColor.withOpacity(0.9)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Left tube
    final leftTube = Path();
    leftTube.moveTo(centerX - 20, centerY - 10);
    leftTube.quadraticBezierTo(centerX - 50, centerY - 30, centerX - 60, centerY - 20);
    canvas.drawPath(leftTube, tubePaint);

    // Right tube
    final rightTube = Path();
    rightTube.moveTo(centerX + 20, centerY - 10);
    rightTube.quadraticBezierTo(centerX + 50, centerY - 30, centerX + 60, centerY - 20);
    canvas.drawPath(rightTube, tubePaint);

    // Draw ovaries (hands)
    final ovaryPaint = Paint()
      ..color = Color(0xFFFFF0F5)
      ..style = PaintingStyle.fill;

    // Left ovary
    canvas.drawCircle(Offset(centerX - 60, centerY - 20), 12, ovaryPaint);
    canvas.drawCircle(Offset(centerX - 60, centerY - 20), 12, Paint()
      ..color = bodyColor.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke);

    // Right ovary
    canvas.drawCircle(Offset(centerX + 60, centerY - 20), 12, ovaryPaint);
    canvas.drawCircle(Offset(centerX + 60, centerY - 20), 12, Paint()
      ..color = bodyColor.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke);

    // Draw cute face
    final facePaint = Paint()
      ..color = Color(0xFF333333)
      ..style = PaintingStyle.fill;

    // Eyes
    final eyeHeight = 8.0 * blinkValue;
    final leftEyeRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX - 15, centerY + 5),
        width: 8,
        height: eyeHeight,
      ),
      Radius.circular(4),
    );
    final rightEyeRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX + 15, centerY + 5),
        width: 8,
        height: eyeHeight,
      ),
      Radius.circular(4),
    );
    canvas.drawRRect(leftEyeRect, facePaint);
    canvas.drawRRect(rightEyeRect, facePaint);

    // Blush
    final blushPaint = Paint()
      ..color = Color(0xFFFF6B9D).withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(centerX - 30, centerY + 12), 8, blushPaint);
    canvas.drawCircle(Offset(centerX + 30, centerY + 12), 8, blushPaint);

    // Mouth - changes based on phase
    final mouthPaint = Paint()
      ..color = Color(0xFF333333)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (phase == 'menstrual') {
      // Crying sad mouth
      final mouthPath = Path();
      mouthPath.moveTo(centerX - 12, centerY + 25);
      mouthPath.quadraticBezierTo(centerX, centerY + 20, centerX + 12, centerY + 25);
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
      mouthPath.moveTo(centerX - 15, centerY + 22);
      mouthPath.quadraticBezierTo(centerX, centerY + 28, centerX + 15, centerY + 22);
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
      
      // Winky eye effect (right eye slightly different)
      if (math.Random().nextDouble() > 0.7) {
        final winkPaint = Paint()
          ..color = Color(0xFF333333)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
          Offset(centerX + 11, centerY + 5),
          Offset(centerX + 19, centerY + 5),
          winkPaint,
        );
      }
    } else if (phase == 'follicular') {
      // Gentle smile
      final mouthPath = Path();
      mouthPath.moveTo(centerX - 12, centerY + 23);
      mouthPath.quadraticBezierTo(centerX, centerY + 26, centerX + 12, centerY + 23);
      canvas.drawPath(mouthPath, mouthPaint);
    } else {
      // Neutral/thoughtful
      canvas.drawLine(
        Offset(centerX - 10, centerY + 24),
        Offset(centerX + 10, centerY + 24),
        mouthPaint,
      );
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

    // Cute cervix detail at bottom
    final cervixPaint = Paint()
      ..color = bodyColor.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(centerX, centerY + 45), 6, cervixPaint);
    canvas.drawCircle(Offset(centerX, centerY + 45), 6, Paint()
      ..color = bodyColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke);
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