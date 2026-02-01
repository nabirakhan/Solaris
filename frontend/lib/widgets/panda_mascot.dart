// File: lib/widgets/panda_mascot.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class PandaMascot extends StatefulWidget {
  final String phase;
  final int cycleDay;
  final double progressPercentage; // 0.0 to 1.0
  final String? message;
  
  const PandaMascot({
    Key? key,
    required this.phase,
    this.cycleDay = 1,
    this.progressPercentage = 0.0,
    this.message,
  }) : super(key: key);

  @override
  State<PandaMascot> createState() => _PandaMascotState();
}

class _PandaMascotState extends State<PandaMascot>
    with TickerProviderStateMixin {
  late AnimationController _walkController;
  late AnimationController _bounceController;
  late AnimationController _blinkController;
  late AnimationController _breatheController;
  late AnimationController _wiggleController;
  late Animation<double> _walkAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _blinkAnimation;
  late Animation<double> _breatheAnimation;
  late Animation<double> _wiggleAnimation;
  
  bool _isWalking = false;

  @override
  void initState() {
    super.initState();
    
    _walkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    _wiggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _walkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _walkController,
      curve: Curves.easeInOut,
    ));
    
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: -15.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeOutCubic,
    ));
    
    _blinkAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _blinkController,
      curve: Curves.easeInOut,
    ));
    
    _breatheAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _breatheController,
      curve: Curves.easeInOut,
    ));
    
    _wiggleAnimation = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _wiggleController,
      curve: Curves.easeInOut,
    ));
    
    _startAnimations();
    _startPeriodicBlink();
  }

  @override
  void didUpdateWidget(PandaMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progressPercentage != widget.progressPercentage) {
      _onProgressUpdate();
    }
  }

  void _startAnimations() {
    _walkController.repeat();
    _breatheController.repeat(reverse: true);
    _wiggleController.repeat(reverse: true);
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

  void _onProgressUpdate() {
    _bounceController.forward().then((_) {
      _bounceController.reverse();
    });
  }

  @override
  void dispose() {
    _walkController.dispose();
    _bounceController.dispose();
    _blinkController.dispose();
    _breatheController.dispose();
    _wiggleController.dispose();
    super.dispose();
  }

  String _getPandaMessage() {
    if (widget.message != null) return widget.message!;
    
    switch (widget.phase) {
      case 'menstrual':
        return "Rest easy, I'm here with you! 🌙";
      case 'follicular':
        return "You're blooming beautifully! 🌱";
      case 'ovulation':
        return "You're unstoppable today! ✨";
      case 'luteal':
        return "Take care of yourself! 🍂";
      default:
        return "Let's track your journey together! 🐼";
    }
  }

  Color _getPandaColor() {
    switch (widget.phase) {
      case 'menstrual':
        return const Color(0xFFE57373);
      case 'follicular':
        return const Color(0xFF81C784);
      case 'ovulation':
        return const Color(0xFFFFD54F);
      case 'luteal':
        return const Color(0xFF9575CD);
      default:
        return const Color(0xFFE91E63);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        
        return Stack(
          children: [
            // Progress Track
            Positioned(
              bottom: 35,
              left: 20,
              right: 20,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: widget.progressPercentage.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getPandaColor().withOpacity(0.7),
                              _getPandaColor(),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: _getPandaColor().withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Walking Panda
            AnimatedBuilder(
              animation: Listenable.merge([
                _walkAnimation,
                _bounceAnimation,
                _breatheAnimation,
                _wiggleAnimation,
              ]),
              builder: (context, child) {
                final walkProgress = _walkAnimation.value;
                final xPosition = (maxWidth - 140) * widget.progressPercentage;
                final bobbing = math.sin(walkProgress * math.pi * 4) * 3;
                final rotation = _wiggleAnimation.value;
                
                return Positioned(
                  left: xPosition.clamp(0.0, maxWidth - 140),
                  bottom: 42 + _bounceAnimation.value + bobbing,
                  child: Transform.rotate(
                    angle: rotation,
                    child: Transform.scale(
                      scale: _breatheAnimation.value,
                      child: child,
                    ),
                  ),
                );
              },
              child: SizedBox(
                width: 140,
                height: 140,
                child: _buildRealisticPanda(),
              ),
            ),
            
            // Speech Bubble
            Positioned(
              top: 15,
              left: 20,
              right: 20,
              child: _buildSpeechBubble(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRealisticPanda() {
    return AnimatedBuilder(
      animation: _blinkAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: _RealisticPandaPainter(
            phase: widget.phase,
            blinkProgress: _blinkAnimation.value,
            phaseColor: _getPandaColor(),
          ),
        );
      },
    );
  }

  Widget _buildSpeechBubble() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: value,
            alignment: Alignment.bottomLeft,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _getPandaColor().withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _getPandaColor().withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _getPandaColor(),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                _getPandaMessage(),
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RealisticPandaPainter extends CustomPainter {
  final String phase;
  final double blinkProgress;
  final Color phaseColor;
  
  _RealisticPandaPainter({
    required this.phase,
    required this.blinkProgress,
    required this.phaseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Body (lower part)
    _drawBody(canvas, center, size);
    
    // Head
    _drawHead(canvas, center, size);
    
    // Ears
    _drawEars(canvas, center, size);
    
    // Eyes with expressions
    _drawEyes(canvas, center, size);
    
    // Nose
    _drawNose(canvas, center, size);
    
    // Mouth with expressions
    _drawMouth(canvas, center, size);
    
    // Cheek blushes
    _drawCheeks(canvas, center, size);
    
    // Accessories based on phase
    _drawPhaseAccessories(canvas, center, size);
  }

  void _drawBody(Canvas canvas, Offset center, Size size) {
    final bodyPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);
    
    // Body shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, size.height * 0.7),
        width: size.width * 0.5,
        height: size.height * 0.35,
      ),
      shadowPaint,
    );
    
    // Body
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, size.height * 0.68),
        width: size.width * 0.48,
        height: size.height * 0.32,
      ),
      bodyPaint,
    );
    
    // Body outline
    final outlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, size.height * 0.68),
        width: size.width * 0.48,
        height: size.height * 0.32,
      ),
      outlinePaint,
    );
  }

  void _drawHead(Canvas canvas, Offset center, Size size) {
    final headPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10);
    
    // Head shadow
    canvas.drawCircle(
      Offset(center.dx, center.dy + 2),
      size.width * 0.35,
      shadowPaint,
    );
    
    // Head
    canvas.drawCircle(
      center,
      size.width * 0.35,
      headPaint,
    );
    
    // Head outline
    final outlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    
    canvas.drawCircle(
      center,
      size.width * 0.35,
      outlinePaint,
    );
  }

  void _drawEars(Canvas canvas, Offset center, Size size) {
    final earPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    final innerEarPaint = Paint()
      ..color = Color(0xFF2D2D2D)
      ..style = PaintingStyle.fill;
    
    // Left ear
    final leftEarCenter = Offset(center.dx - size.width * 0.25, center.dy - size.height * 0.28);
    canvas.drawCircle(leftEarCenter, size.width * 0.12, earPaint);
    canvas.drawCircle(leftEarCenter, size.width * 0.07, innerEarPaint);
    
    // Right ear
    final rightEarCenter = Offset(center.dx + size.width * 0.25, center.dy - size.height * 0.28);
    canvas.drawCircle(rightEarCenter, size.width * 0.12, earPaint);
    canvas.drawCircle(rightEarCenter, size.width * 0.07, innerEarPaint);
  }

  void _drawEyes(Canvas canvas, Offset center, Size size) {
    final eyePatchPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    final eyeWhitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final pupilPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    final shinePaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    
    // Eye expressions based on phase
    double eyeOpenness = 1.0 - blinkProgress;
    double eyeWidth = size.width * 0.14;
    double eyeHeight = size.width * 0.16 * eyeOpenness;
    
    // Adjust eye shape based on phase
    if (phase == 'menstrual') {
      eyeHeight *= 0.6; // Tired eyes
    } else if (phase == 'ovulation') {
      eyeHeight *= 1.1; // Wide eyes
    }
    
    // Left eye patch
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - size.width * 0.15, center.dy - size.height * 0.05),
        width: size.width * 0.18,
        height: size.width * 0.22,
      ),
      eyePatchPaint,
    );
    
    // Right eye patch
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + size.width * 0.15, center.dy - size.height * 0.05),
        width: size.width * 0.18,
        height: size.width * 0.22,
      ),
      eyePatchPaint,
    );
    
    if (eyeOpenness > 0.1) {
      // Left eye white
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx - size.width * 0.15, center.dy - size.height * 0.05),
          width: eyeWidth,
          height: eyeHeight,
        ),
        eyeWhitePaint,
      );
      
      // Right eye white
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx + size.width * 0.15, center.dy - size.height * 0.05),
          width: eyeWidth,
          height: eyeHeight,
        ),
        eyeWhitePaint,
      );
      
      // Pupils
      double pupilSize = size.width * 0.065;
      double pupilOffsetY = 0;
      
      if (phase == 'follicular' || phase == 'ovulation') {
        pupilOffsetY = -size.height * 0.02; // Look up slightly when happy
      }
      
      // Left pupil
      canvas.drawCircle(
        Offset(center.dx - size.width * 0.15, center.dy - size.height * 0.05 + pupilOffsetY),
        pupilSize,
        pupilPaint,
      );
      
      // Right pupil
      canvas.drawCircle(
        Offset(center.dx + size.width * 0.15, center.dy - size.height * 0.05 + pupilOffsetY),
        pupilSize,
        pupilPaint,
      );
      
      // Eye shine
      double shineSize = pupilSize * 0.4;
      canvas.drawCircle(
        Offset(center.dx - size.width * 0.15 - pupilSize * 0.3, center.dy - size.height * 0.05 - pupilSize * 0.3 + pupilOffsetY),
        shineSize,
        shinePaint,
      );
      canvas.drawCircle(
        Offset(center.dx + size.width * 0.15 - pupilSize * 0.3, center.dy - size.height * 0.05 - pupilSize * 0.3 + pupilOffsetY),
        shineSize,
        shinePaint,
      );
    }
  }

  void _drawNose(Canvas canvas, Offset center, Size size) {
    final nosePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    final noseHighlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    // Nose
    final nosePath = Path();
    final noseCenter = Offset(center.dx, center.dy + size.height * 0.08);
    final noseWidth = size.width * 0.08;
    final noseHeight = size.width * 0.06;
    
    nosePath.moveTo(noseCenter.dx, noseCenter.dy - noseHeight / 2);
    nosePath.quadraticBezierTo(
      noseCenter.dx - noseWidth / 2, noseCenter.dy,
      noseCenter.dx, noseCenter.dy + noseHeight / 2,
    );
    nosePath.quadraticBezierTo(
      noseCenter.dx + noseWidth / 2, noseCenter.dy,
      noseCenter.dx, noseCenter.dy - noseHeight / 2,
    );
    
    canvas.drawPath(nosePath, nosePaint);
    
    // Nose highlight
    canvas.drawCircle(
      Offset(noseCenter.dx - noseWidth * 0.2, noseCenter.dy - noseHeight * 0.15),
      noseWidth * 0.2,
      noseHighlightPaint,
    );
  }

  void _drawMouth(Canvas canvas, Offset center, Size size) {
    final mouthPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final mouthPath = Path();
    final mouthCenter = Offset(center.dx, center.dy + size.height * 0.15);
    
    switch (phase) {
      case 'menstrual':
        // Neutral/tired mouth
        mouthPath.moveTo(mouthCenter.dx - size.width * 0.08, mouthCenter.dy);
        mouthPath.lineTo(mouthCenter.dx + size.width * 0.08, mouthCenter.dy);
        break;
        
      case 'follicular':
      case 'ovulation':
        // Big happy smile
        mouthPath.moveTo(mouthCenter.dx - size.width * 0.1, mouthCenter.dy - size.height * 0.02);
        mouthPath.quadraticBezierTo(
          mouthCenter.dx, mouthCenter.dy + size.height * 0.05,
          mouthCenter.dx + size.width * 0.1, mouthCenter.dy - size.height * 0.02,
        );
        
        // Draw tongue for extra happiness
        if (phase == 'ovulation') {
          final tonguePaint = Paint()
            ..color = Color(0xFFFF8A9B)
            ..style = PaintingStyle.fill;
          
          final tonguePath = Path();
          tonguePath.moveTo(mouthCenter.dx - size.width * 0.03, mouthCenter.dy + size.height * 0.02);
          tonguePath.quadraticBezierTo(
            mouthCenter.dx, mouthCenter.dy + size.height * 0.04,
            mouthCenter.dx + size.width * 0.03, mouthCenter.dy + size.height * 0.02,
          );
          canvas.drawPath(tonguePath, tonguePaint);
        }
        break;
        
      case 'luteal':
        // Gentle smile
        mouthPath.moveTo(mouthCenter.dx - size.width * 0.09, mouthCenter.dy);
        mouthPath.quadraticBezierTo(
          mouthCenter.dx, mouthCenter.dy + size.height * 0.02,
          mouthCenter.dx + size.width * 0.09, mouthCenter.dy,
        );
        break;
        
      default:
        // Default smile
        mouthPath.moveTo(mouthCenter.dx - size.width * 0.09, mouthCenter.dy);
        mouthPath.quadraticBezierTo(
          mouthCenter.dx, mouthCenter.dy + size.height * 0.03,
          mouthCenter.dx + size.width * 0.09, mouthCenter.dy,
        );
    }
    
    canvas.drawPath(mouthPath, mouthPaint);
  }

  void _drawCheeks(Canvas canvas, Offset center, Size size) {
    final cheekPaint = Paint()
      ..color = phaseColor.withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5);
    
    // Only show blush on happy phases
    if (phase == 'follicular' || phase == 'ovulation') {
      // Left cheek
      canvas.drawCircle(
        Offset(center.dx - size.width * 0.25, center.dy + size.height * 0.05),
        size.width * 0.08,
        cheekPaint,
      );
      
      // Right cheek
      canvas.drawCircle(
        Offset(center.dx + size.width * 0.25, center.dy + size.height * 0.05),
        size.width * 0.08,
        cheekPaint,
      );
    }
  }

  void _drawPhaseAccessories(Canvas canvas, Offset center, Size size) {
    switch (phase) {
      case 'menstrual':
        // Draw sleeping cap or moon
        _drawSleepyIndicator(canvas, center, size);
        break;
        
      case 'follicular':
        // Draw flowers or sparkles
        _drawFlowers(canvas, center, size);
        break;
        
      case 'ovulation':
        // Draw crown or stars
        _drawCrown(canvas, center, size);
        break;
        
      case 'luteal':
        // Draw cozy scarf
        _drawScarf(canvas, center, size);
        break;
    }
  }

  void _drawSleepyIndicator(Canvas canvas, Offset center, Size size) {
    final zzPaint = Paint()
      ..color = phaseColor.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'z',
        style: TextStyle(
          fontSize: size.width * 0.12,
          color: phaseColor.withOpacity(0.7),
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    // Draw three z's
    for (int i = 0; i < 3; i++) {
      final offset = Offset(
        center.dx + size.width * 0.25 + i * size.width * 0.08,
        center.dy - size.height * 0.35 + i * size.height * 0.08,
      );
      textPainter.paint(canvas, offset);
    }
  }

  void _drawFlowers(Canvas canvas, Offset center, Size size) {
    final flowerPaint = Paint()
      ..color = phaseColor
      ..style = PaintingStyle.fill;
    
    final centerPaint = Paint()
      ..color = Color(0xFFFFD54F)
      ..style = PaintingStyle.fill;
    
    // Draw small flowers around head
    final positions = [
      Offset(center.dx - size.width * 0.3, center.dy - size.height * 0.25),
      Offset(center.dx + size.width * 0.3, center.dy - size.height * 0.25),
    ];
    
    for (var pos in positions) {
      // Petals
      for (int i = 0; i < 5; i++) {
        final angle = (i * math.pi * 2 / 5);
        final petalPos = Offset(
          pos.dx + math.cos(angle) * size.width * 0.04,
          pos.dy + math.sin(angle) * size.width * 0.04,
        );
        canvas.drawCircle(petalPos, size.width * 0.025, flowerPaint);
      }
      // Center
      canvas.drawCircle(pos, size.width * 0.02, centerPaint);
    }
  }

  void _drawCrown(Canvas canvas, Offset center, Size size) {
    final crownPaint = Paint()
      ..color = phaseColor
      ..style = PaintingStyle.fill;
    
    final crownOutlinePaint = Paint()
      ..color = phaseColor.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final crownPath = Path();
    final crownTop = center.dy - size.height * 0.42;
    final crownLeft = center.dx - size.width * 0.15;
    final crownRight = center.dx + size.width * 0.15;
    
    crownPath.moveTo(crownLeft, crownTop + size.height * 0.05);
    crownPath.lineTo(crownLeft + size.width * 0.06, crownTop);
    crownPath.lineTo(crownLeft + size.width * 0.12, crownTop + size.height * 0.05);
    crownPath.lineTo(center.dx, crownTop - size.height * 0.02);
    crownPath.lineTo(crownRight - size.width * 0.12, crownTop + size.height * 0.05);
    crownPath.lineTo(crownRight - size.width * 0.06, crownTop);
    crownPath.lineTo(crownRight, crownTop + size.height * 0.05);
    crownPath.lineTo(crownRight, crownTop + size.height * 0.08);
    crownPath.lineTo(crownLeft, crownTop + size.height * 0.08);
    crownPath.close();
    
    canvas.drawPath(crownPath, crownPaint);
    canvas.drawPath(crownPath, crownOutlinePaint);
    
    // Draw jewels
    final jewelPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(center.dx, crownTop + size.height * 0.03),
      size.width * 0.015,
      jewelPaint,
    );
  }

  void _drawScarf(Canvas canvas, Offset center, Size size) {
    final scarfPaint = Paint()
      ..color = phaseColor
      ..style = PaintingStyle.fill;
    
    final scarfPath = Path();
    final neckY = center.dy + size.height * 0.25;
    
    // Scarf around neck
    scarfPath.addOval(
      Rect.fromCenter(
        center: Offset(center.dx, neckY),
        width: size.width * 0.4,
        height: size.height * 0.1,
      ),
    );
    
    canvas.drawPath(scarfPath, scarfPaint);
    
    // Scarf stripes
    final stripePaint = Paint()
      ..color = phaseColor.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(center.dx - size.width * 0.15 + i * size.width * 0.06, neckY - size.height * 0.03),
        Offset(center.dx - size.width * 0.15 + i * size.width * 0.06, neckY + size.height * 0.03),
        stripePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RealisticPandaPainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.blinkProgress != blinkProgress ||
      oldDelegate.phaseColor != phaseColor;
}