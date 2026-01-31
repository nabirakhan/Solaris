// File: frontend/lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // ============================================================================
  // COLORS - Modern Pink/Purple Palette
  // ============================================================================
  
  // Primary Colors
  static const Color primaryPink = Color(0xFFE91E63); // Vibrant pink
  static const Color darkPink = Color(0xFFC2185B); // Deep pink
  static const Color lightPink = Color(0xFFF8BBD0); // Soft pink
  static const Color blushPink = Color(0xFFFCE4EC); // Very light pink
  
  // Purple Accents
  static const Color primaryPurple = Color(0xFF9C27B0);
  static const Color lightPurple = Color(0xFFE1BEE7);
  
  // Neutral Colors
  static const Color almostWhite = Color(0xFFFAFAFA);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF212121);
  static const Color textGray = Color(0xFF757575);
  static const Color textLight = Color(0xFFBDBDBD);
  static const Color divider = Color(0xFFE0E0E0);
  
  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Phase Colors
  static const Color menstrualPhase = Color(0xFFE57373); // Red
  static const Color follicularPhase = Color(0xFF81C784); // Green
  static const Color ovulationPhase = Color(0xFFFFD54F); // Yellow
  static const Color lutealPhase = Color(0xFF9575CD); // Purple
  
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
  
  static LinearGradient phaseGradient(String phase) {
    switch (phase) {
      case 'menstrual':
        return const LinearGradient(
          colors: [Color(0xFFE57373), Color(0xFFEF5350)],
        );
      case 'follicular':
        return const LinearGradient(
          colors: [Color(0xFF81C784), Color(0xFF66BB6A)],
        );
      case 'ovulation':
        return const LinearGradient(
          colors: [Color(0xFFFFD54F), Color(0xFFFFCA28)],
        );
      case 'luteal':
        return const LinearGradient(
          colors: [Color(0xFF9575CD), Color(0xFF7E57C2)],
        );
      default:
        return primaryGradient;
    }
  }
  
  // ============================================================================
  // THEME DATA
  // ============================================================================
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryPink,
        primary: primaryPink,
        secondary: primaryPurple,
        surface: pureWhite,
        background: almostWhite,
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: textDark,
        iconTheme: IconThemeData(color: primaryPink),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: pureWhite,
        shadowColor: primaryPink.withOpacity(0.1),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPink,
          foregroundColor: pureWhite,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryPink,
          side: const BorderSide(color: primaryPink, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryPink,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: almostWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryPink, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: textGray),
        hintStyle: TextStyle(color: textLight),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textDark,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textDark,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textDark,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textGray,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: textLight,
        ),
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
        space: 1,
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: primaryPink,
        size: 24,
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryPink,
        linearTrackColor: blushPink,
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryPink,
        foregroundColor: pureWhite,
        elevation: 6,
      ),
    );
  }
  
  // ============================================================================
  // ANIMATION DURATIONS
  // ============================================================================
  
  static const Duration ultraFast = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);
  
  // ============================================================================
  // BORDER RADIUS
  // ============================================================================
  
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusCircle = 999.0;
  
  // ============================================================================
  // SPACING
  // ============================================================================
  
  static const double spaceXS = 4.0;
  static const double spaceS = 8.0;
  static const double spaceM = 16.0;
  static const double spaceL = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;
  
  // ============================================================================
  // ELEVATION
  // ============================================================================
  
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  static const double elevationVeryHigh = 16.0;
}