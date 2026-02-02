// File: lib/widgets/enhanced_panda_mascot.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class EnhancedPandaMascot extends StatefulWidget {
  const EnhancedPandaMascot({Key? key}) : super(key: key);

  @override
  State<EnhancedPandaMascot> createState() => _EnhancedPandaMascotState();
}

class _EnhancedPandaMascotState extends State<EnhancedPandaMascot>
    with TickerProviderStateMixin {
  late AnimationController _journeyController;
  late AnimationController _floatController;
  late AnimationController _blinkController;
  late AnimationController _armSwingController;
  late AnimationController _legSwingController;
  late AnimationController _cloudController;
  late AnimationController _petalController;
  late AnimationController _leafController;
  
  late Animation<double> _journeyAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _blinkAnimation;
  late Animation<double> _armSwingAnimation;
  late Animation<double> _legSwingAnimation;
  late Animation<double> _cloudAnimation;
  late Animation<double> _petalAnimation;
  late Animation<double> _leafAnimation;

  String _currentPhase = 'menstrual';
  String _currentMessage = 'Rest easy, I\'m here! 🌙';
  bool _showSpeechBubble = true;

  final List<Map<String, dynamic>> _phases = [
    {
      'name': 'menstrual',
      'color': const Color(0xFFE57373),
      'message': 'Rest easy, I\'m here! 🌙',
      'position': 0.0,
    },
    {
      'name': 'follicular',
      'color': const Color(0xFF81C784),
      'message': 'You\'re blooming! 🌱',
      'position': 0.25,
    },
    {
      'name': 'ovulation',
      'color': const Color(0xFFADD8E6),
      'message': 'You\'re amazing! ✨',
      'position': 0.5,
    },
    {
      'name': 'luteal',
      'color': const Color(0xFF9575CD),
      'message': 'Take care! 🍂',
      'position': 0.75,
    },
  ];

  @override
  void initState() {
    super.initState();
    
    _journeyController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
    
    _journeyAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _journeyController,
      curve: Curves.linear,
    ));
    
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    _floatAnimation = Tween<double>(
      begin: -8.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
    
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    _blinkAnimation = Tween<double>(
      begin: 1.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _blinkController,
      curve: Curves.easeInOut,
    ));
    
    _armSwingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _armSwingAnimation = Tween<double>(
      begin: -0.15,
      end: 0.15,
    ).animate(CurvedAnimation(
      parent: _armSwingController,
      curve: Curves.easeInOut,
    ));
    
    _legSwingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _legSwingAnimation = Tween<double>(
      begin: -0.12,
      end: 0.12,
    ).animate(CurvedAnimation(
      parent: _legSwingController,
      curve: Curves.easeInOut,
    ));
    
    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );
    
    _cloudAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cloudController,
      curve: Curves.linear,
    ));
    
    _petalController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    
    _petalAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _petalController,
      curve: Curves.linear,
    ));
    
    _leafController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    
    _leafAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _leafController,
      curve: Curves.linear,
    ));
    
    _startAnimations();
    _startPeriodicBlink();
    
    _journeyAnimation.addListener(_updatePhase);
    
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showSpeechBubble = false;
        });
      }
    });
  }

  void _startAnimations() {
    _floatController.repeat(reverse: true);
    _armSwingController.repeat(reverse: true);
    _legSwingController.repeat(reverse: true);
    _cloudController.repeat();
    _petalController.repeat();
    _leafController.repeat();
    _journeyController.repeat();
  }

  void _startPeriodicBlink() {
    Future.delayed(Duration(milliseconds: 2500 + math.Random().nextInt(2500)), () {
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

  void _updatePhase() {
    final progress = _journeyAnimation.value;
    String newPhase = _currentPhase;
    String newMessage = _currentMessage;
    
    for (int i = _phases.length - 1; i >= 0; i--) {
      if (progress >= _phases[i]['position']) {
        newPhase = _phases[i]['name'];
        newMessage = _phases[i]['message'];
        break;
      }
    }
    
    if (newPhase != _currentPhase) {
      setState(() {
        _currentPhase = newPhase;
        _currentMessage = newMessage;
        _showSpeechBubble = true;
      });
      
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showSpeechBubble = false;
          });
        }
      });
    }
  }

  Color _getCurrentColor() {
    return _phases.firstWhere((p) => p['name'] == _currentPhase)['color'];
  }

  @override
  void dispose() {
    _journeyController.dispose();
    _floatController.dispose();
    _blinkController.dispose();
    _armSwingController.dispose();
    _legSwingController.dispose();
    _cloudController.dispose();
    _petalController.dispose();
    _leafController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          height: 350,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Animated Background with integrated phase markers
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _journeyAnimation,
                    _cloudAnimation,
                    _petalAnimation,
                    _leafAnimation,
                  ]),
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _DetailedBackgroundPainter(
                        progress: _journeyAnimation.value,
                        cloudProgress: _cloudAnimation.value,
                        petalProgress: _petalAnimation.value,
                        leafProgress: _leafAnimation.value,
                        currentPhase: _currentPhase,
                        phaseColor: _getCurrentColor(),
                        phases: _phases,
                      ),
                    );
                  },
                ),
              ),
              
              // Animated panda
              AnimatedBuilder(
                animation: Listenable.merge([
                  _journeyAnimation,
                  _floatAnimation,
                  _blinkAnimation,
                  _armSwingAnimation,
                  _legSwingAnimation,
                ]),
                builder: (context, child) {
                  final screenWidth = constraints.maxWidth;
                  final xPosition = (screenWidth - 180) * _journeyAnimation.value;
                  
                  return Positioned(
                    left: xPosition.clamp(0.0, screenWidth - 180),
                    bottom: 80 + _floatAnimation.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedOpacity(
                          opacity: _showSpeechBubble ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: _getCurrentColor(),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: _getCurrentColor().withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              _currentMessage,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        
                        if (_showSpeechBubble) const SizedBox(height: 8),
                        
                        if (_showSpeechBubble)
                          CustomPaint(
                            size: const Size(20, 12),
                            painter: _SpeechBubbleTailPainter(
                              color: _getCurrentColor(),
                            ),
                          ),
                        
                        const SizedBox(height: 8),
                        
                        SizedBox(
                          width: 180,
                          height: 180,
                          child: CustomPaint(
                            painter: _FullBodyPandaPainter(
                              phase: _currentPhase,
                              blinkProgress: _blinkAnimation.value,
                              phaseColor: _getCurrentColor(),
                              armSwing: _armSwingAnimation.value,
                              legSwing: _legSwingAnimation.value,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SpeechBubbleTailPainter extends CustomPainter {
  final Color color;
  
  _SpeechBubbleTailPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = Path();
    path.moveTo(size.width * 0.5, 0);
    path.lineTo(size.width * 0.3, size.height);
    path.lineTo(size.width * 0.7, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(_SpeechBubbleTailPainter oldDelegate) => 
      oldDelegate.color != color;
}

// Full body panda painter (keeping the same detailed panda)
class _FullBodyPandaPainter extends CustomPainter {
  final String phase;
  final double blinkProgress;
  final Color phaseColor;
  final double armSwing;
  final double legSwing;

  _FullBodyPandaPainter({
    required this.phase,
    required this.blinkProgress,
    required this.phaseColor,
    required this.armSwing,
    required this.legSwing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.35);
    
    _drawShadow(canvas, Offset(size.width / 2, size.height * 0.95), size);
    _drawLegs(canvas, center, size);
    _drawBody(canvas, center, size);
    _drawArms(canvas, center, size);
    _drawHead(canvas, center, size);
    _drawEars(canvas, center, size);
    _drawEyes(canvas, center, size);
    _drawNose(canvas, center, size);
    _drawMouth(canvas, center, size);
    _drawCheeks(canvas, center, size);
    _drawPhaseAccessories(canvas, center, size);
  }

  void _drawShadow(Canvas canvas, Offset position, Size size) {
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    
    canvas.drawOval(
      Rect.fromCenter(
        center: position,
        width: size.width * 0.5,
        height: size.height * 0.1,
      ),
      shadowPaint,
    );
  }

  void _drawLegs(Canvas canvas, Offset center, Size size) {
    final legPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    final footPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final leftLegCenter = Offset(
      center.dx - size.width * 0.15,
      center.dy + size.height * 0.45,
    );
    
    canvas.save();
    canvas.translate(leftLegCenter.dx, leftLegCenter.dy);
    canvas.rotate(legSwing * 0.5);
    canvas.translate(-leftLegCenter.dx, -leftLegCenter.dy);
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: leftLegCenter,
          width: size.width * 0.18,
          height: size.height * 0.25,
        ),
        Radius.circular(size.width * 0.09),
      ),
      legPaint,
    );
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(leftLegCenter.dx, leftLegCenter.dy + size.height * 0.08),
        width: size.width * 0.12,
        height: size.height * 0.08,
      ),
      footPaint,
    );
    
    canvas.restore();
    
    final rightLegCenter = Offset(
      center.dx + size.width * 0.15,
      center.dy + size.height * 0.45,
    );
    
    canvas.save();
    canvas.translate(rightLegCenter.dx, rightLegCenter.dy);
    canvas.rotate(-legSwing * 0.5);
    canvas.translate(-rightLegCenter.dx, -rightLegCenter.dy);
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: rightLegCenter,
          width: size.width * 0.18,
          height: size.height * 0.25,
        ),
        Radius.circular(size.width * 0.09),
      ),
      legPaint,
    );
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(rightLegCenter.dx, rightLegCenter.dy + size.height * 0.08),
        width: size.width * 0.12,
        height: size.height * 0.08,
      ),
      footPaint,
    );
    
    canvas.restore();
  }

  void _drawBody(Canvas canvas, Offset center, Size size) {
    final bodyPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final bodyShadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    
    final bodyCenter = Offset(center.dx, center.dy + size.height * 0.18);
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(bodyCenter.dx + 2, bodyCenter.dy + 4),
        width: size.width * 0.52,
        height: size.height * 0.37,
      ),
      bodyShadowPaint,
    );
    
    canvas.drawOval(
      Rect.fromCenter(
        center: bodyCenter,
        width: size.width * 0.5,
        height: size.height * 0.35,
      ),
      bodyPaint,
    );
    
    final bellyPaint = Paint()
      ..color = phaseColor.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(bodyCenter.dx, bodyCenter.dy + size.height * 0.02),
        width: size.width * 0.3,
        height: size.height * 0.22,
      ),
      bellyPaint,
    );
  }

  void _drawArms(Canvas canvas, Offset center, Size size) {
    final armPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    final handPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final leftArmCenter = Offset(
      center.dx - size.width * 0.28,
      center.dy + size.height * 0.15,
    );
    
    canvas.save();
    canvas.translate(leftArmCenter.dx, leftArmCenter.dy - size.height * 0.08);
    canvas.rotate(armSwing);
    canvas.translate(-leftArmCenter.dx, -(leftArmCenter.dy - size.height * 0.08));
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: leftArmCenter,
          width: size.width * 0.14,
          height: size.height * 0.22,
        ),
        Radius.circular(size.width * 0.07),
      ),
      armPaint,
    );
    
    canvas.drawCircle(
      Offset(leftArmCenter.dx, leftArmCenter.dy + size.height * 0.09),
      size.width * 0.08,
      armPaint,
    );
    
    canvas.drawCircle(
      Offset(leftArmCenter.dx, leftArmCenter.dy + size.height * 0.09),
      size.width * 0.05,
      handPaint,
    );
    
    canvas.restore();
    
    final rightArmCenter = Offset(
      center.dx + size.width * 0.28,
      center.dy + size.height * 0.15,
    );
    
    canvas.save();
    canvas.translate(rightArmCenter.dx, rightArmCenter.dy - size.height * 0.08);
    canvas.rotate(-armSwing);
    canvas.translate(-rightArmCenter.dx, -(rightArmCenter.dy - size.height * 0.08));
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: rightArmCenter,
          width: size.width * 0.14,
          height: size.height * 0.22,
        ),
        Radius.circular(size.width * 0.07),
      ),
      armPaint,
    );
    
    canvas.drawCircle(
      Offset(rightArmCenter.dx, rightArmCenter.dy + size.height * 0.09),
      size.width * 0.08,
      armPaint,
    );
    
    canvas.drawCircle(
      Offset(rightArmCenter.dx, rightArmCenter.dy + size.height * 0.09),
      size.width * 0.05,
      handPaint,
    );
    
    canvas.restore();
  }

  void _drawHead(Canvas canvas, Offset center, Size size) {
    final headPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final headShadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    
    canvas.drawCircle(
      Offset(center.dx + 2, center.dy + 3),
      size.width * 0.22,
      headShadowPaint,
    );
    
    canvas.drawCircle(
      center,
      size.width * 0.2,
      headPaint,
    );
  }

  void _drawEars(Canvas canvas, Offset center, Size size) {
    final earPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    final innerEarPaint = Paint()
      ..color = phaseColor.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    
    final leftEarCenter = Offset(
      center.dx - size.width * 0.15,
      center.dy - size.height * 0.15,
    );
    
    canvas.drawCircle(leftEarCenter, size.width * 0.09, earPaint);
    canvas.drawCircle(leftEarCenter, size.width * 0.05, innerEarPaint);
    
    final rightEarCenter = Offset(
      center.dx + size.width * 0.15,
      center.dy - size.height * 0.15,
    );
    
    canvas.drawCircle(rightEarCenter, size.width * 0.09, earPaint);
    canvas.drawCircle(rightEarCenter, size.width * 0.05, innerEarPaint);
  }

  void _drawEyes(Canvas canvas, Offset center, Size size) {
    final eyeBackgroundPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final pupilPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - size.width * 0.12, center.dy - size.height * 0.02),
        width: size.width * 0.16,
        height: size.height * 0.12 * blinkProgress,
      ),
      eyeBackgroundPaint,
    );
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - size.width * 0.12, center.dy - size.height * 0.02),
        width: size.width * 0.11,
        height: size.height * 0.08 * blinkProgress,
      ),
      eyePaint,
    );
    
    canvas.drawCircle(
      Offset(center.dx - size.width * 0.12, center.dy - size.height * 0.02),
      size.width * 0.04 * blinkProgress,
      pupilPaint,
    );
    
    canvas.drawCircle(
      Offset(center.dx - size.width * 0.10, center.dy - size.height * 0.03),
      size.width * 0.018 * blinkProgress,
      highlightPaint,
    );
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + size.width * 0.12, center.dy - size.height * 0.02),
        width: size.width * 0.16,
        height: size.height * 0.12 * blinkProgress,
      ),
      eyeBackgroundPaint,
    );
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + size.width * 0.12, center.dy - size.height * 0.02),
        width: size.width * 0.11,
        height: size.height * 0.08 * blinkProgress,
      ),
      eyePaint,
    );
    
    canvas.drawCircle(
      Offset(center.dx + size.width * 0.12, center.dy - size.height * 0.02),
      size.width * 0.04 * blinkProgress,
      pupilPaint,
    );
    
    canvas.drawCircle(
      Offset(center.dx + size.width * 0.14, center.dy - size.height * 0.03),
      size.width * 0.018 * blinkProgress,
      highlightPaint,
    );
  }

  void _drawNose(Canvas canvas, Offset center, Size size) {
    final nosePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    final noseHighlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    
    final noseCenter = Offset(center.dx, center.dy + size.height * 0.06);
    
    canvas.drawOval(
      Rect.fromCenter(
        center: noseCenter,
        width: size.width * 0.08,
        height: size.height * 0.045,
      ),
      nosePaint,
    );
    
    canvas.drawCircle(
      Offset(noseCenter.dx - size.width * 0.02, noseCenter.dy - size.height * 0.01),
      size.width * 0.02,
      noseHighlightPaint,
    );
  }

  void _drawMouth(Canvas canvas, Offset center, Size size) {
    final mouthPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final mouthCenter = Offset(center.dx, center.dy + size.height * 0.1);
    final mouthPath = Path();
    
    switch (phase) {
      case 'menstrual':
        mouthPath.moveTo(mouthCenter.dx - size.width * 0.05, mouthCenter.dy);
        mouthPath.lineTo(mouthCenter.dx + size.width * 0.05, mouthCenter.dy);
        break;
        
      case 'follicular':
      case 'ovulation':
        mouthPath.moveTo(mouthCenter.dx - size.width * 0.09, mouthCenter.dy);
        mouthPath.quadraticBezierTo(
          mouthCenter.dx,
          mouthCenter.dy + size.height * 0.05,
          mouthCenter.dx + size.width * 0.09,
          mouthCenter.dy,
        );
        break;
        
      case 'luteal':
        mouthPath.moveTo(mouthCenter.dx - size.width * 0.06, mouthCenter.dy);
        mouthPath.quadraticBezierTo(
          mouthCenter.dx,
          mouthCenter.dy + size.height * 0.025,
          mouthCenter.dx + size.width * 0.06,
          mouthCenter.dy,
        );
        break;
        
      default:
        mouthPath.moveTo(mouthCenter.dx - size.width * 0.07, mouthCenter.dy);
        mouthPath.quadraticBezierTo(
          mouthCenter.dx,
          mouthCenter.dy + size.height * 0.03,
          mouthCenter.dx + size.width * 0.07,
          mouthCenter.dy,
        );
    }
    
    canvas.drawPath(mouthPath, mouthPaint);
  }

  void _drawCheeks(Canvas canvas, Offset center, Size size) {
    if (phase == 'follicular' || phase == 'ovulation') {
      final cheekPaint = Paint()
        ..color = phaseColor.withOpacity(0.4)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      
      canvas.drawCircle(
        Offset(center.dx - size.width * 0.18, center.dy + size.height * 0.03),
        size.width * 0.07,
        cheekPaint,
      );
      
      canvas.drawCircle(
        Offset(center.dx + size.width * 0.18, center.dy + size.height * 0.03),
        size.width * 0.07,
        cheekPaint,
      );
    }
  }

  void _drawPhaseAccessories(Canvas canvas, Offset center, Size size) {
    switch (phase) {
      case 'menstrual':
        _drawSleepyZs(canvas, center, size);
        break;
      case 'follicular':
        _drawFlowerCrown(canvas, center, size);
        break;
      case 'ovulation':
        _drawSparkles(canvas, center, size);
        break;
      case 'luteal':
        _drawHearts(canvas, center, size);
        break;
    }
  }

  void _drawSleepyZs(Canvas canvas, Offset center, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    
    for (int i = 0; i < 3; i++) {
      textPainter.text = TextSpan(
        text: 'z',
        style: TextStyle(
          fontSize: size.width * 0.09 + i * 4,
          color: phaseColor.withOpacity(0.7 - i * 0.15),
          fontWeight: FontWeight.bold,
        ),
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          center.dx + size.width * 0.20 + i * size.width * 0.09,
          center.dy - size.height * 0.25 + i * size.height * 0.07,
        ),
      );
    }
  }

  void _drawFlowerCrown(Canvas canvas, Offset center, Size size) {
    final flowerPaint = Paint()
      ..color = phaseColor
      ..style = PaintingStyle.fill;
    
    final centerPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.fill;
    
    final angles = [-0.7, -0.4, -0.1, 0.1, 0.4, 0.7];
    
    for (var angle in angles) {
      final flowerPos = Offset(
        center.dx + math.sin(angle) * size.width * 0.2,
        center.dy - size.height * 0.18 + math.cos(angle).abs() * size.height * 0.05,
      );
      
      for (int i = 0; i < 5; i++) {
        final petalAngle = (i * math.pi * 2 / 5);
        final petalPos = Offset(
          flowerPos.dx + math.cos(petalAngle) * size.width * 0.03,
          flowerPos.dy + math.sin(petalAngle) * size.width * 0.03,
        );
        canvas.drawCircle(petalPos, size.width * 0.02, flowerPaint);
      }
      
      canvas.drawCircle(flowerPos, size.width * 0.015, centerPaint);
    }
  }

  void _drawSparkles(Canvas canvas, Offset center, Size size) {
    final sparklePaint = Paint()
      ..color = phaseColor
      ..style = PaintingStyle.fill;
    
    final sparklePositions = [
      Offset(center.dx - size.width * 0.28, center.dy - size.height * 0.12),
      Offset(center.dx + size.width * 0.28, center.dy - size.height * 0.12),
      Offset(center.dx - size.width * 0.22, center.dy - size.height * 0.25),
      Offset(center.dx + size.width * 0.22, center.dy - size.height * 0.25),
    ];
    
    for (var pos in sparklePositions) {
      final path = Path();
      
      for (int i = 0; i < 8; i++) {
        final angle = (i * math.pi / 4);
        final radius = (i % 2 == 0) ? size.width * 0.045 : size.width * 0.018;
        final x = pos.dx + math.cos(angle) * radius;
        final y = pos.dy + math.sin(angle) * radius;
        
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      
      canvas.drawPath(path, sparklePaint);
    }
  }

  void _drawHearts(Canvas canvas, Offset center, Size size) {
    final heartPaint = Paint()
      ..color = phaseColor.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    
    final heartPositions = [
      Offset(center.dx - size.width * 0.25, center.dy - size.height * 0.08),
      Offset(center.dx + size.width * 0.25, center.dy - size.height * 0.08),
    ];
    
    for (var pos in heartPositions) {
      final path = Path();
      final heartSize = size.width * 0.07;
      
      path.moveTo(pos.dx, pos.dy + heartSize * 0.3);
      
      path.cubicTo(
        pos.dx - heartSize * 0.5, pos.dy - heartSize * 0.1,
        pos.dx - heartSize * 0.5, pos.dy - heartSize * 0.5,
        pos.dx, pos.dy - heartSize * 0.3,
      );
      
      path.cubicTo(
        pos.dx + heartSize * 0.5, pos.dy - heartSize * 0.5,
        pos.dx + heartSize * 0.5, pos.dy - heartSize * 0.1,
        pos.dx, pos.dy + heartSize * 0.3,
      );
      
      canvas.drawPath(path, heartPaint);
    }
  }

  @override
  bool shouldRepaint(_FullBodyPandaPainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.blinkProgress != blinkProgress ||
      oldDelegate.phaseColor != phaseColor ||
      oldDelegate.armSwing != armSwing ||
      oldDelegate.legSwing != legSwing;
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

// Detailed Background Painter with natural tree park layout and benches
class _DetailedBackgroundPainter extends CustomPainter {
  final double progress;
  final double cloudProgress;
  final double petalProgress;
  final double leafProgress;
  final String currentPhase;
  final Color phaseColor;
  final List<Map<String, dynamic>> phases;

  _DetailedBackgroundPainter({
    required this.progress,
    required this.cloudProgress,
    required this.petalProgress,
    required this.leafProgress,
    required this.currentPhase,
    required this.phaseColor,
    required this.phases,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawCrispSky(canvas, size);
    _drawDetailedClouds(canvas, size);
    _drawCelestialBody(canvas, size);
    _drawNaturalTreePark(canvas, size);
    _drawBenches(canvas, size); // Draw benches in background
    _drawFallingPetals(canvas, size);
    _drawFallingLeaves(canvas, size);
    _drawSeamlessPathWithMarkers(canvas, size);
  }

  void _drawCrispSky(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    List<Color> skyColors;
    switch (currentPhase) {
      case 'menstrual':
        skyColors = [
          const Color(0xFF2D1B4E),
          const Color(0xFF4A2C5F),
          const Color(0xFF6B4C8A),
        ];
        break;
      case 'follicular':
        skyColors = [
          const Color(0xFFFFE5EC),
          const Color(0xFFFFD6E8),
          const Color(0xFFFFC2E2),
        ];
        break;
      case 'ovulation':
        skyColors = [
          const Color(0xFFD5E8F7),
          const Color(0xFFBBDAF0),
          const Color(0xFFA8D0EC),
        ];
        break;
      case 'luteal':
        skyColors = [
          const Color(0xFFFFC1E0),
          const Color(0xFFFFB3D9),
          const Color(0xFFF8B4D9),
        ];
        break;
      default:
        skyColors = [
          const Color(0xFFFFE5EC),
          const Color(0xFFFFD6E8),
        ];
    }
    
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: skyColors,
    );
    
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
  }

  void _drawDetailedClouds(Canvas canvas, Size size) {
    final random = math.Random(42);
    
    for (int i = 0; i < 10; i++) {
      final cloudX = (size.width * (i / 9.0) + cloudProgress * size.width * 0.4) % (size.width + 120) - 60;
      final cloudY = size.height * 0.08 + random.nextDouble() * size.height * 0.35;
      final cloudSize = 35 + random.nextDouble() * 25;
      
      _drawDetailedCloud(canvas, cloudX, cloudY, cloudSize);
    }
  }

  void _drawDetailedCloud(Canvas canvas, double x, double y, double size) {
    final cloudPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(x, y), size, cloudPaint);
    canvas.drawCircle(Offset(x + size * 0.6, y - size * 0.15), size * 0.85, cloudPaint);
    canvas.drawCircle(Offset(x - size * 0.45, y - size * 0.08), size * 0.75, cloudPaint);
    canvas.drawCircle(Offset(x + size * 0.35, y + size * 0.25), size * 0.65, cloudPaint);
  }

  void _drawCelestialBody(Canvas canvas, Size size) {
    final bodyX = size.width * 0.78;
    final bodyY = size.height * 0.12;
    
    if (currentPhase == 'menstrual') {
      final moonPaint = Paint()
        ..color = const Color(0xFFFFF8DC)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(bodyX, bodyY), 38, moonPaint);
      
      final craterPaint = Paint()
        ..color = const Color(0xFFFFF0E1).withOpacity(0.4)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(bodyX - 10, bodyY - 8), 7, craterPaint);
      canvas.drawCircle(Offset(bodyX + 12, bodyY + 6), 5, craterPaint);
      canvas.drawCircle(Offset(bodyX - 3, bodyY + 10), 4, craterPaint);
    } else {
      final sunPaint = Paint()
        ..color = phaseColor.withOpacity(0.85)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(bodyX, bodyY), 32, sunPaint);
      
      final rayPaint = Paint()
        ..color = phaseColor.withOpacity(0.6)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      
      for (int i = 0; i < 16; i++) {
        final angle = (i * math.pi * 2 / 16);
        final startX = bodyX + math.cos(angle) * 38;
        final startY = bodyY + math.sin(angle) * 38;
        final endX = bodyX + math.cos(angle) * 52;
        final endY = bodyY + math.sin(angle) * 52;
        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), rayPaint);
      }
    }
  }

  void _drawNaturalTreePark(Canvas canvas, Size size) {
    // Natural park layout with trees facing different directions
    
    // Left side - trees facing right (towards center)
    _drawDetailedCherryTree(canvas, size.width * 0.08, size.height * 0.55, size, 0.9, facingRight: true);
    _drawDetailedCherryTree(canvas, size.width * 0.22, size.height * 0.52, size, 1.0, facingRight: true);
    
    // Left center - tree facing left (variety)
    _drawDetailedCherryTree(canvas, size.width * 0.35, size.height * 0.58, size, 0.85, facingRight: false);
    
    // Right center - tree facing right (variety)
    _drawDetailedCherryTree(canvas, size.width * 0.65, size.height * 0.58, size, 0.85, facingRight: true);
    
    // Right side - trees facing left (towards center)
    _drawDetailedCherryTree(canvas, size.width * 0.78, size.height * 0.52, size, 1.0, facingRight: false);
    _drawDetailedCherryTree(canvas, size.width * 0.92, size.height * 0.55, size, 0.9, facingRight: false);
  }

  void _drawDetailedCherryTree(Canvas canvas, double x, double y, Size size, double scale, {required bool facingRight}) {
    // Trunk
    final trunkPaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.fill;
    
    final trunkWidth = 18.0 * scale;
    final trunkHeight = size.height * 0.35 * scale;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x, y + trunkHeight / 2),
          width: trunkWidth,
          height: trunkHeight,
        ),
        Radius.circular(9 * scale),
      ),
      trunkPaint,
    );
    
    // More realistic branches with proper structure
    final branchPaint = Paint()
      ..color = const Color(0xFF6D4C41)
      ..strokeWidth = 4 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final random = math.Random(x.toInt() + y.toInt());
    
    // Main branches - fewer but more prominent
    for (int i = 0; i < 5; i++) {
      final branchY = y + trunkHeight * (0.3 + i * 0.15);
      final branchLength = 30.0 * scale + random.nextDouble() * 20 * scale;
      
      // Create more natural branch angles
      final baseAngle = facingRight ? (0.3 + random.nextDouble() * 0.4) : (-0.3 - random.nextDouble() * 0.4);
      
      final endX = x + math.cos(baseAngle) * branchLength;
      final endY = branchY - math.sin(baseAngle).abs() * branchLength * 0.7;
      
      // Draw main branch
      canvas.drawLine(Offset(x, branchY), Offset(endX, endY), branchPaint);
      
      // Add sub-branches for realism
      final subBranchPaint = Paint()
        ..color = const Color(0xFF6D4C41)
        ..strokeWidth = 2.5 * scale
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      
      // 2-3 sub-branches per main branch
      for (int j = 0; j < 2 + random.nextInt(2); j++) {
        final subBranchStart = Offset(
          x + (endX - x) * (0.4 + j * 0.3),
          branchY + (endY - branchY) * (0.4 + j * 0.3),
        );
        
        final subAngle = baseAngle + (random.nextDouble() - 0.5) * 0.8;
        final subLength = branchLength * (0.3 + random.nextDouble() * 0.3);
        
        final subEndX = subBranchStart.dx + math.cos(subAngle) * subLength;
        final subEndY = subBranchStart.dy - math.sin(subAngle).abs() * subLength * 0.5;
        
        canvas.drawLine(subBranchStart, Offset(subEndX, subEndY), subBranchPaint);
        
        // Blossoms on sub-branches
        _drawDetailedBlossomCluster(canvas, subEndX, subEndY, phaseColor, scale * 0.7);
      }
      
      // Blossoms on main branch end
      _drawDetailedBlossomCluster(canvas, endX, endY, phaseColor, scale);
    }
    
    // Main canopy with individual blossoms - reduced for less clutter
    for (int i = 0; i < 20; i++) {
      final angle = random.nextDouble() * math.pi * 2;
      final radius = random.nextDouble() * 40 * scale;
      final blossomX = x + math.cos(angle) * radius;
      final blossomY = y + math.sin(angle) * radius * 0.8;
      
      _drawIndividualBlossom(canvas, blossomX, blossomY, phaseColor, scale * 0.8);
    }
  }

  void _drawDetailedBlossomCluster(Canvas canvas, double x, double y, Color color, double scale) {
    final random = math.Random((x * y).toInt());
    final blossomCount = 4 + random.nextInt(3);
    
    for (int i = 0; i < blossomCount; i++) {
      final offsetX = x + (random.nextDouble() - 0.5) * 18 * scale;
      final offsetY = y + (random.nextDouble() - 0.5) * 18 * scale;
      
      _drawIndividualBlossom(canvas, offsetX, offsetY, color, scale);
    }
  }

  void _drawIndividualBlossom(Canvas canvas, double x, double y, Color color, double scale) {
    // Make blossoms darker during ovulation phase for visibility
    Color blossomColor = color;
    if (color == const Color(0xFFADD8E6)) {
      // If it's ovulation blue, use darker blue flowers
      blossomColor = const Color(0xFF4A90E2);
    }
    
    final blossomPaint = Paint()
      ..color = blossomColor.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    
    final centerPaint = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.9)
      ..style = PaintingStyle.fill;
    
    // Draw 5 petals
    for (int j = 0; j < 5; j++) {
      final angle = (j * math.pi * 2 / 5);
      final petalX = x + math.cos(angle) * 4.5 * scale;
      final petalY = y + math.sin(angle) * 4.5 * scale;
      canvas.drawCircle(Offset(petalX, petalY), 3.5 * scale, blossomPaint);
    }
    
    canvas.drawCircle(Offset(x, y), 2 * scale, centerPaint);
  }

  void _drawBenches(Canvas canvas, Size size) {
    // Draw prominent benches in the foreground between trees
    final benchPositions = [
      size.width * 0.28,  // Between left trees
      size.width * 0.50,  // Center
      size.width * 0.72,  // Between right trees
    ];
    
    for (var benchX in benchPositions) {
      _drawParkBench(canvas, benchX, size.height * 0.58, size);
    }
  }

  void _drawParkBench(Canvas canvas, double x, double y, Size size) {
    final benchScale = 1.2; // Much larger bench for visibility
    
    // Bench legs with shadow for depth
    final legShadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    final legPaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.fill;
    
    // Left leg with shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x - 18 * benchScale,
          y + 3,
          8 * benchScale,
          32 * benchScale,
        ),
        Radius.circular(4 * benchScale),
      ),
      legShadowPaint,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x - 20 * benchScale,
          y,
          8 * benchScale,
          32 * benchScale,
        ),
        Radius.circular(4 * benchScale),
      ),
      legPaint,
    );
    
    // Right leg with shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x + 14 * benchScale,
          y + 3,
          8 * benchScale,
          32 * benchScale,
        ),
        Radius.circular(4 * benchScale),
      ),
      legShadowPaint,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x + 12 * benchScale,
          y,
          8 * benchScale,
          32 * benchScale,
        ),
        Radius.circular(4 * benchScale),
      ),
      legPaint,
    );
    
    // Bench seat with shadow
    final seatShadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    
    final seatPaint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x - 23 * benchScale,
          y + 23 * benchScale,
          52 * benchScale,
          12 * benchScale,
        ),
        Radius.circular(6 * benchScale),
      ),
      seatShadowPaint,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x - 26 * benchScale,
          y + 20 * benchScale,
          52 * benchScale,
          12 * benchScale,
        ),
        Radius.circular(6 * benchScale),
      ),
      seatPaint,
    );
    
    // Bench backrest - taller and more visible
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x - 24 * benchScale,
          y + 2 * benchScale,
          8 * benchScale,
          25 * benchScale,
        ),
        Radius.circular(4 * benchScale),
      ),
      seatPaint,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x + 16 * benchScale,
          y + 2 * benchScale,
          8 * benchScale,
          25 * benchScale,
        ),
        Radius.circular(4 * benchScale),
      ),
      seatPaint,
    );
    
    // Add slats for detail
    final slatPaint = Paint()
      ..color = const Color(0xFF6D4C41).withOpacity(0.7)
      ..strokeWidth = 3 * benchScale
      ..style = PaintingStyle.stroke;
    
    for (int i = 0; i < 5; i++) {
      canvas.drawLine(
        Offset(x - 26 * benchScale + i * 13 * benchScale, y + 24 * benchScale),
        Offset(x - 26 * benchScale + i * 13 * benchScale, y + 28 * benchScale),
        slatPaint,
      );
    }
  }

  void _drawFallingPetals(Canvas canvas, Size size) {
    final random = math.Random(789);
    
    for (int i = 0; i < 30; i++) {
      final petalX = (size.width * (i / 29.0) + petalProgress * size.width * 0.6) % size.width;
      final petalY = (size.height * 0.6 * petalProgress + random.nextDouble() * size.height * 0.4) % (size.height * 0.75);
      final rotation = petalProgress * math.pi * 4 + i;
      
      _drawFallingPetal(canvas, petalX, petalY, rotation, phaseColor);
    }
  }

  void _drawFallingPetal(Canvas canvas, double x, double y, double rotation, Color color) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(rotation);
    
    final petalPaint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    
    final petalPath = Path();
    petalPath.moveTo(0, -7);
    petalPath.quadraticBezierTo(4, -3, 0, 0);
    petalPath.quadraticBezierTo(-4, -3, 0, -7);
    
    canvas.drawPath(petalPath, petalPaint);
    canvas.restore();
  }

  void _drawFallingLeaves(Canvas canvas, Size size) {
    final random = math.Random(456);
    
    for (int i = 0; i < 25; i++) {
      final leafX = (size.width * (i / 24.0) + leafProgress * size.width * 0.7) % size.width;
      final leafY = (size.height * 0.7 * leafProgress + random.nextDouble() * size.height * 0.3) % (size.height * 0.75);
      final rotation = leafProgress * math.pi * 3 + i * 0.5;
      
      Color leafColor;
      if (currentPhase == 'menstrual' || currentPhase == 'luteal') {
        leafColor = i % 3 == 0 ? const Color(0xFFD4A574) : 
                    i % 3 == 1 ? const Color(0xFFC17D2D) : 
                    const Color(0xFF9B6B3B);
      } else {
        leafColor = i % 2 == 0 ? const Color(0xFF81C784) : const Color(0xFF66BB6A);
      }
      
      _drawFallingLeaf(canvas, leafX, leafY, rotation, leafColor);
    }
  }

  void _drawFallingLeaf(Canvas canvas, double x, double y, double rotation, Color color) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(rotation);
    
    final leafPaint = Paint()
      ..color = color.withOpacity(0.75)
      ..style = PaintingStyle.fill;
    
    final leafPath = Path();
    leafPath.moveTo(0, -6);
    leafPath.quadraticBezierTo(5, -2, 4, 3);
    leafPath.quadraticBezierTo(1, 4, 0, 6);
    leafPath.quadraticBezierTo(-1, 4, -4, 3);
    leafPath.quadraticBezierTo(-5, -2, 0, -6);
    
    canvas.drawPath(leafPath, leafPaint);
    
    final veinPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(const Offset(0, -6), const Offset(0, 6), veinPaint);
    
    canvas.restore();
  }

  void _drawSeamlessPathWithMarkers(Canvas canvas, Size size) {
    // Ground that blends naturally
    final groundRect = Rect.fromLTWH(0, size.height * 0.75, size.width, size.height * 0.25);
    
    Color groundColor1, groundColor2;
    switch (currentPhase) {
      case 'menstrual':
        groundColor1 = const Color(0xFF4A3456);
        groundColor2 = const Color(0xFF2D1B3C);
        break;
      case 'follicular':
        groundColor1 = const Color(0xFFB4E7CE);
        groundColor2 = const Color(0xFF8FD6BD);
        break;
      case 'ovulation':
        groundColor1 = const Color(0xFFB8D8EA);
        groundColor2 = const Color(0xFF9BCCE0);
        break;
      case 'luteal':
        groundColor1 = const Color(0xFFD4A5C4);
        groundColor2 = const Color(0xFFB88AA8);
        break;
      default:
        groundColor1 = const Color(0xFFB4E7CE);
        groundColor2 = const Color(0xFF8FD6BD);
    }
    
    final groundGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [groundColor1, groundColor2],
    );
    
    canvas.drawRect(groundRect, Paint()..shader = groundGradient.createShader(groundRect));
    
    // Park-style walkway path
    final pathY = size.height * 0.85;
    final pathHeight = size.height * 0.1;
    
    // Main path with sandy/beige color like park walkway
    final pathBasePaint = Paint()
      ..color = const Color(0xFFE8D5B7)
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, pathY, size.width, pathHeight),
        const Radius.circular(8),
      ),
      pathBasePaint,
    );
    
    // Add texture lines to path (like paving stones)
    final pathLinePaint = Paint()
      ..color = const Color(0xFFD4C4A8).withOpacity(0.4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(
        Offset(i, pathY),
        Offset(i, pathY + pathHeight),
        pathLinePaint,
      );
    }
    
    // Add horizontal lines for dimension
    canvas.drawLine(
      Offset(0, pathY + pathHeight * 0.3),
      Offset(size.width, pathY + pathHeight * 0.3),
      pathLinePaint,
    );
    canvas.drawLine(
      Offset(0, pathY + pathHeight * 0.7),
      Offset(size.width, pathY + pathHeight * 0.7),
      pathLinePaint,
    );
    
    // Draw phase markers CENTERED on the screen
    final markerY = pathY + pathHeight / 2;
    final totalMarkerWidth = size.width * 0.6; // Use 60% of width for better centering
    final markerStartX = (size.width - totalMarkerWidth) / 2; // Center the markers
    
    // Adjust positions to be more evenly distributed
    final adjustedPhases = [
      {'phase': phases[0], 'position': 0.0},
      {'phase': phases[1], 'position': 0.333},
      {'phase': phases[2], 'position': 0.666},
      {'phase': phases[3], 'position': 1.0},
    ];
    
    for (var item in adjustedPhases) {
      final phase = item['phase'] as Map<String, dynamic>;
      final position = item['position'] as double;
      final markerX = markerStartX + (totalMarkerWidth * position);
      final isActive = phase['name'] == currentPhase;
      
      // Phase dot with shadow for depth
      if (isActive) {
        // Glow effect for active phase
        final glowPaint = Paint()
          ..color = phase['color'].withOpacity(0.4)
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(
          Offset(markerX, markerY),
          18,
          glowPaint,
        );
      }
      
      // Main phase dot
      final dotPaint = Paint()
        ..color = isActive ? phase['color'] : phase['color'].withOpacity(0.5)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(markerX, markerY),
        isActive ? 11 : 8,
        dotPaint,
      );
      
      // Dot border for definition
      final borderPaint = Paint()
        ..color = isActive ? Colors.white : Colors.white.withOpacity(0.5)
        ..strokeWidth = isActive ? 3 : 2
        ..style = PaintingStyle.stroke;
      
      canvas.drawCircle(
        Offset(markerX, markerY),
        isActive ? 11 : 8,
        borderPaint,
      );
      
      // Phase name with better visibility
      final textPainter = TextPainter(
        text: TextSpan(
          text: phase['name'].toString().capitalize(),
          style: TextStyle(
            fontSize: isActive ? 14 : 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
            color: isActive ? phase['color'] : Colors.white.withOpacity(0.9),
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 4,
                offset: const Offset(1, 1),
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(markerX - textPainter.width / 2, markerY + 22),
      );
    }
    
    // Progress indicator - subtle vertical line with adjusted positioning
    final adjustedProgress = progress <= 0.25 ? progress / 0.25 * 0.333 :
                              progress <= 0.5 ? 0.333 + (progress - 0.25) / 0.25 * 0.333 :
                              progress <= 0.75 ? 0.666 + (progress - 0.5) / 0.25 * 0.334 :
                              0.666 + (progress - 0.75) / 0.25 * 0.334;
    final progressX = markerStartX + (totalMarkerWidth * adjustedProgress);
    final progressPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(
      Offset(progressX, pathY + 8),
      Offset(progressX, pathY + pathHeight - 8),
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_DetailedBackgroundPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.cloudProgress != cloudProgress ||
      oldDelegate.petalProgress != petalProgress ||
      oldDelegate.leafProgress != leafProgress ||
      oldDelegate.currentPhase != currentPhase ||
      oldDelegate.phaseColor != phaseColor;
}