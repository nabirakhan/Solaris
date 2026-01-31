// File: frontend/lib/config/constants.dart
import 'package:flutter/material.dart';

class AppConstants {
  // ============================================================================
  // API CONFIGURATION
  // ============================================================================
  
  // CRITICAL: Update this IP address to match your computer's IP
  // 
  // To find your IP:
  // - Windows: Open CMD and run "ipconfig" → Look for IPv4 Address
  // - Mac: Open Terminal and run "ifconfig | grep inet"
  // - Linux: Open Terminal and run "hostname -I"
  //
  // Example: If your IP is 192.168.100.9, use:
  // static const String baseUrl = 'http://192.168.100.9:5000/api';
  
  static const String baseUrl = 'http://192.168.100.9:5000/api';
  static const String apiUrl = baseUrl;
  
  // Alternative configurations (comment out the one above and use these if needed):
  
  // For Android Emulator (10.0.2.2 is the host machine from emulator)
  // static const String baseUrl = 'http://10.0.2.2:5000/api';
  
  // For iOS Simulator (localhost works on iOS simulator)
  // static const String baseUrl = 'http://localhost:5000/api';
  
  // For web development on same machine
  // static const String baseUrl = 'http://localhost:5000/api';
  
  // ============================================================================
  // APP INFO
  // ============================================================================
  
  static const String appName = 'Solaris';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Your Personal Period Companion';
  static const String appDescription = 'AI-powered period tracking for better health insights';
  
  // ============================================================================
  // ANIMATION DURATIONS
  // ============================================================================
  
  static const Duration ultraFastAnimation = Duration(milliseconds: 100);
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  static const Duration verySlowAnimation = Duration(milliseconds: 800);
  
  // ============================================================================
  // UI CONSTANTS
  // ============================================================================
  
  // Border Radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;
  static const double borderRadiusCircle = 999.0;
  
  // Padding & Margins
  static const double paddingXS = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  static const double paddingXXLarge = 48.0;
  
  // Elevation
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  static const double elevationVeryHigh = 16.0;
  
  // Icon Sizes
  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;
  static const double iconSizeXXLarge = 64.0;
  
  // ============================================================================
  // COLORS (matching AppTheme)
  // ============================================================================
  
  // Primary Colors
  static const Color primaryColor = Color(0xFFE91E63);
  static const Color primaryLight = Color(0xFFF8BBD0);
  static const Color primaryDark = Color(0xFFC2185B);
  
  static const Color secondaryColor = Color(0xFF9C27B0);
  static const Color secondaryLight = Color(0xFFE1BEE7);
  static const Color secondaryDark = Color(0xFF7B1FA2);
  
  static const Color accentColor = Color(0xFFFF4081);
  
  // Cycle Phase Colors
  static const Color menstrualPhaseColor = Color(0xFFE57373);
  static const Color follicularPhaseColor = Color(0xFF81C784);
  static const Color ovulationPhaseColor = Color(0xFFFFD54F);
  static const Color lutealPhaseColor = Color(0xFF9575CD);
  
  // UI Colors
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color cardColor = Colors.white;
  static const Color errorColor = Color(0xFFF44336);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color infoColor = Color(0xFF2196F3);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  
  // ============================================================================
  // GRADIENTS
  // ============================================================================
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFCE4EC), Color(0xFFFAFAFA)],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFFAFAFA)],
  );
  
  // ============================================================================
  // TEXT STYLES
  // ============================================================================
  
  static const TextStyle headingLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.5,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.3,
  );
  
  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textHint,
  );
  
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
  );
  
  // ============================================================================
  // CYCLE CONFIGURATION
  // ============================================================================
  
  static const int defaultCycleLength = 28;
  static const int defaultPeriodLength = 5;
  static const int minCycleLength = 21;
  static const int maxCycleLength = 35;
  static const int minPeriodLength = 2;
  static const int maxPeriodLength = 10;
  
  // ============================================================================
  // PHASE INFORMATION
  // ============================================================================
  
  static const Map<String, String> phaseDescriptions = {
    'menstrual': 'Your period has started. Focus on rest and self-care.',
    'follicular': 'Energy is building. Great time for new activities and challenges!',
    'ovulation': 'Peak fertility window. You may feel most energetic and confident.',
    'luteal': 'Body is preparing for next cycle. Be gentle with yourself.',
    'unknown': 'Start tracking to see personalized insights about your cycle!',
  };
  
  static const Map<String, IconData> phaseIcons = {
    'menstrual': Icons.water_drop,
    'follicular': Icons.wb_sunny,
    'ovulation': Icons.favorite,
    'luteal': Icons.nightlight,
    'unknown': Icons.help_outline,
  };
  
  static const Map<String, String> phaseEmojis = {
    'menstrual': '🌙',
    'follicular': '🌱',
    'ovulation': '🌸',
    'luteal': '🍂',
    'unknown': '💫',
  };
  
  static const Map<String, List<String>> phaseTips = {
    'menstrual': [
      'Stay hydrated and rest when needed',
      'Light exercise like yoga can help',
      'Use a heating pad for cramps',
    ],
    'follicular': [
      'Great time to start new projects',
      'Energy levels are rising',
      'Perfect for social activities',
    ],
    'ovulation': [
      'Peak energy and confidence',
      'Ideal time for important meetings',
      'You may feel more outgoing',
    ],
    'luteal': [
      'Practice extra self-care',
      'Be patient with yourself',
      'Maintain healthy eating habits',
    ],
  };
  
  // ============================================================================
  // SYMPTOM TYPES
  // ============================================================================
  
  static const List<String> commonSymptoms = [
    'Cramps',
    'Headache',
    'Bloating',
    'Fatigue',
    'Mood Swings',
    'Tender Breasts',
    'Acne',
    'Back Pain',
  ];
  
  static const Map<String, IconData> symptomIcons = {
    'Cramps': Icons.favorite_border,
    'Headache': Icons.healing,
    'Bloating': Icons.sentiment_dissatisfied,
    'Fatigue': Icons.bedtime,
    'Mood Swings': Icons.mood,
    'Tender Breasts': Icons.health_and_safety,
    'Acne': Icons.face,
    'Back Pain': Icons.accessibility_new,
  };
  
  // ============================================================================
  // FLOW INTENSITIES
  // ============================================================================
  
  static const List<String> flowIntensities = ['light', 'medium', 'heavy'];
  
  static const Map<String, String> flowDescriptions = {
    'light': 'Light flow - spotting or light bleeding',
    'medium': 'Medium flow - regular bleeding',
    'heavy': 'Heavy flow - heavy bleeding',
  };
  
  static const Map<String, IconData> flowIcons = {
    'light': Icons.water_drop_outlined,
    'medium': Icons.water_drop,
    'heavy': Icons.water_damage,
  };
  
  static const Map<String, Color> flowColors = {
    'light': Color(0xFFF8BBD0),
    'medium': Color(0xFFE91E63),
    'heavy': Color(0xFFC2185B),
  };
}