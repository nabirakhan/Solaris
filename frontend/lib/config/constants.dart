// File: lib/config/constants.dart
import 'package:flutter/material.dart';

class AppConstants {
  // ============================================================================
  // API CONFIGURATION
  // ============================================================================
  
  // IMPORTANT: Change this to your backend URL
  // For local development with Android emulator: http://10.0.2.2:5000/api
  // For local development with physical device: http://YOUR_LOCAL_IP:5000/api
  // For production: your deployed backend URL
  static const String apiBaseUrl = 'http://10.0.2.2:5000/api';
  
  // AI Service URL
  static const String aiServiceUrl = 'http://10.0.2.2:5001';

  // ============================================================================
  // APP INFORMATION
  // ============================================================================
  
  static const String appName = 'Solaris';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Your Personal Period Companion';

  // ============================================================================
  // COLORS - Glassmorphism Theme
  // ============================================================================
  
  static const Color primaryColor = Color(0xFFE91E63); // Vibrant pink
  static const Color secondaryColor = Color(0xFF9C27B0); // Purple
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  
  static const Color errorColor = Color(0xFFF44336);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color infoColor = Color(0xFF2196F3);

  // Glassmorphism colors
  static const Color glassLight = Color(0x40FFFFFF);
  static const Color glassDark = Color(0x10FFFFFF);

  // ============================================================================
  // GRADIENTS
  // ============================================================================
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x40FFFFFF),
      Color(0x10FFFFFF),
    ],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFCE4EC),
      Color(0xFFFAFAFA),
    ],
  );

  // ============================================================================
  // SPACING
  // ============================================================================
  
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // ============================================================================
  // BORDER RADIUS
  // ============================================================================
  
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;

  // ============================================================================
  // ELEVATION
  // ============================================================================
  
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // ============================================================================
  // ICON SIZES
  // ============================================================================
  
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;

  // ============================================================================
  // ANIMATIONS
  // ============================================================================
  
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

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
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: textSecondary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: textHint,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
}