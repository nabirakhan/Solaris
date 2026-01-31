// File: lib/widgets/panda_mascot.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
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
  late Animation<double> _walkAnimation;
  late Animation<double> _bounceAnimation;
  
  bool _isWalking = false;
  double _currentPosition = 0.0;

  @override
  void initState() {
    super.initState();
    
    _walkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
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
      end: -20.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeOut,
    ));
    
    _startWalking();
  }

  @override
  void didUpdateWidget(PandaMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progressPercentage != widget.progressPercentage) {
      _onProgressUpdate();
    }
  }

  void _startWalking() {
    _isWalking = true;
    _walkController.repeat();
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
    super.dispose();
  }

  String _getPandaAnimation() {
    switch (widget.phase) {
      case 'menstrual':
        return 'assets/animations/panda_tired.json';
      case 'follicular':
        return 'assets/animations/panda_happy.json';
      case 'ovulation':
        return 'assets/animations/panda_energetic.json';
      case 'luteal':
        return 'assets/animations/panda_walking.json';
      default:
        return 'assets/animations/panda_walking.json';
    }
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
              bottom: 40,
              left: 20,
              right: 20,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: widget.progressPercentage.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getPandaColor().withOpacity(0.6),
                          _getPandaColor(),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
            
            // Walking Panda
            AnimatedBuilder(
              animation: Listenable.merge([_walkAnimation, _bounceAnimation]),
              builder: (context, child) {
                final walkProgress = _walkAnimation.value;
                final xPosition = (maxWidth - 120) * widget.progressPercentage;
                final oscillation = math.sin(walkProgress * math.pi * 2) * 5;
                
                return Positioned(
                  left: xPosition,
                  bottom: 45 + _bounceAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, oscillation),
                    child: child,
                  ),
                );
              },
              child: SizedBox(
                width: 120,
                height: 120,
                child: _buildPandaCharacter(),
              ),
            ),
            
            // Speech Bubble
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: _buildSpeechBubble(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPandaCharacter() {
    // Try to load Lottie animation, fallback to custom drawn panda
    return FutureBuilder(
      future: _checkAnimationExists(),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return Lottie.asset(
            _getPandaAnimation(),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _buildCustomPanda();
            },
          );
        }
        return _buildCustomPanda();
      },
    );
  }

  Future<bool> _checkAnimationExists() async {
    // This is a simplified check - in production, handle asset loading properly
    return false; // For now, always use custom panda
  }

  Widget _buildCustomPanda() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _getPandaColor().withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Panda Face
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Ears
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildEar(),
                          const SizedBox(width: 40),
                          _buildEar(),
                        ],
                      ),
                      
                      // Eyes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildEye(),
                          const SizedBox(width: 20),
                          _buildEye(),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Nose and Mouth
                      _buildNoseAndMouth(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEar() {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildEye() {
    String eyeShape = _getEyeShape();
    
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: eyeShape == 'happy' 
          ? BorderRadius.circular(12.5)
          : BorderRadius.circular(0),
      ),
      child: eyeShape == 'happy'
        ? const Icon(Icons.lens, color: Colors.white, size: 8)
        : Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
    );
  }

  String _getEyeShape() {
    switch (widget.phase) {
      case 'menstrual':
        return 'tired';
      case 'follicular':
        return 'happy';
      case 'ovulation':
        return 'excited';
      case 'luteal':
        return 'normal';
      default:
        return 'normal';
    }
  }

  Widget _buildNoseAndMouth() {
    return Column(
      children: [
        // Nose
        Container(
          width: 12,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
        ),
        
        const SizedBox(height: 4),
        
        // Mouth - changes based on phase
        CustomPaint(
          size: const Size(30, 15),
          painter: _MouthPainter(phase: widget.phase),
        ),
      ],
    );
  }

  Widget _buildSpeechBubble() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _getPandaColor().withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _getPandaColor().withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                _getPandaMessage(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MouthPainter extends CustomPainter {
  final String phase;
  
  _MouthPainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    switch (phase) {
      case 'menstrual':
        // Tired/neutral mouth
        path.moveTo(0, size.height / 2);
        path.lineTo(size.width, size.height / 2);
        break;
        
      case 'follicular':
      case 'ovulation':
        // Happy smile
        path.moveTo(0, 0);
        path.quadraticBezierTo(
          size.width / 2, size.height,
          size.width, 0,
        );
        break;
        
      case 'luteal':
        // Slight smile
        path.moveTo(0, size.height / 3);
        path.quadraticBezierTo(
          size.width / 2, size.height * 0.7,
          size.width, size.height / 3,
        );
        break;
        
      default:
        // Default smile
        path.moveTo(0, size.height / 3);
        path.quadraticBezierTo(
          size.width / 2, size.height,
          size.width, size.height / 3,
        );
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_MouthPainter oldDelegate) => oldDelegate.phase != phase;
}