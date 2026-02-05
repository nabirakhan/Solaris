// File: lib/config/constants.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppConstants {
  // ============================================================================
  // API CONFIGURATION
  // ============================================================================
  
  // Automatically detect the correct API URL based on platform
  static String get apiBaseUrl {
    if (kIsWeb) {
      // For web builds
      return 'http://localhost:5000/api';
    } else if (Platform.isAndroid) {
      // For Android emulator - 10.0.2.2 maps to host machine's localhost
      return 'http://10.0.2.2:5000/api';
    } else if (Platform.isIOS) {
      // For iOS simulator
      return 'http://localhost:5000/api';
    } else {
      // Fallback
      return 'http://localhost:5000/api';
    }
  }
  
  // For testing with physical devices, uncomment and update with your computer's local IP:
  // Find your IP by running:
  // - Windows: ipconfig (look for IPv4 Address)
  // - Mac/Linux: ifconfig or ip addr (look for inet)
  // static const String apiBaseUrl = 'http://192.168.1.100:5000/api';
  
  // AI Service URL
  static String get aiServiceUrl {
    if (kIsWeb) {
      return 'http://localhost:5001';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5001';
    } else if (Platform.isIOS) {
      return 'http://localhost:5001';
    } else {
      return 'http://localhost:5001';
    }
  }

  // Debug helper - call this in your main.dart
  static void printApiInfo() {
    debugPrint('🌐 ========================================');
    debugPrint('🌐 API Configuration');
    debugPrint('🌐 ========================================');
    debugPrint('📍 Base URL: $apiBaseUrl');
    debugPrint('🤖 AI Service: $aiServiceUrl');
    debugPrint('📱 Platform: ${kIsWeb ? 'Web' : Platform.operatingSystem}');
    debugPrint('🌐 ========================================');
  }

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