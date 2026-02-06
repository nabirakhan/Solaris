// File: frontend/lib/providers/auth_provider.dart
import 'dart:io';
import 'dart:convert'; // Add this import
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  
  bool _isAuthenticated = false;
  bool _isLoading = false;
  Map<String, dynamic>? _user;
  String? _errorMessage;
  
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get user => _user;
  String? get errorMessage => _errorMessage;
  
  // Check if user is already logged in
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final token = await _apiService.getToken();
      if (token != null) {
        final response = await _apiService.getCurrentUser();
        _user = response['user'];
        _isAuthenticated = true;
      }
    } catch (e) {
      await _apiService.clearToken();
      _isAuthenticated = false;
      _user = null;
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  // ============================================================================
  // Email/Password Signup - OTP VERSION
  // ============================================================================
  
  Future<Map<String, dynamic>> signup({
  required String email,
  required String password,
  required String name,
  String? dateOfBirth,
}) async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();
  
  try {
    final response = await _apiService.signup(
      email: email,
      password: password,
      name: name,
      dateOfBirth: dateOfBirth,
    );
    
    _isLoading = false;
    notifyListeners();
    
    return {
      'success': true,
      'userId': response['userId'],
      'email': email,
      'maskedEmail': response['email'] ?? _maskEmail(email),
      'expiresAt': response['expiresAt'],
      'message': response['message'],
    };
  } catch (e) {
    _isLoading = false;
    
    try {
      // Try to parse the error as JSON
      final errorString = e.toString().replaceAll('Exception: ', '');
      final errorJson = json.decode(errorString);
      _errorMessage = errorJson['error']?.toString() ?? 'Signup failed';
      
      notifyListeners();
      
      // Return the full error response including userId if present
      return {
        'success': false,
        'error': _errorMessage,
        if (errorJson['userId'] != null) 'userId': errorJson['userId'].toString(),
        if (errorJson['emailVerified'] != null) 'emailVerified': errorJson['emailVerified'],
      };
    } catch (_) {
      // If not JSON, use the string error
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return {
        'success': false,
        'error': _errorMessage,
      };
    }
  }
}
  
  // Verify OTP Code
  Future<Map<String, dynamic>> verifyOTP({
    required String email,
    required String otp,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiService.verifyOTP(
        email: email,
        otp: otp,
      );
      
      // OTP verified successfully - save token and user data
      _user = response['user'];
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      
      return {
        'success': true,
        'user': _user,
      };
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'error': _errorMessage,
      };
    }
  }
  
  // Resend OTP Code
Future<Map<String, dynamic>> resendOTP({
  required String email,
}) async {
  _errorMessage = null;
  notifyListeners();
  
  try {
    // Change from named parameter to positional parameter
    final response = await _apiService.resendOTP(email);
    return {
      'success': true,
      'attemptsRemaining': response['attemptsRemaining'] ?? 2,
      'expiresAt': response['expiresAt'],
    };
  } catch (e) {
    _errorMessage = e.toString().replaceAll('Exception: ', '');
    notifyListeners();
    return {
      'success': false,
      'error': _errorMessage,
    };
  }
}
  
  // ============================================================================
  // Email/Password Login
  // ============================================================================
  
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _apiService.login(
        email: email,
        password: password,
      );
      
      _user = response['user'];
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      
      return {
        'success': true,
        'user': _user,
      };
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'error': _errorMessage,
      };
    }
  }
  
  // ============================================================================
  // Google Sign-In (No OTP Required)
  // ============================================================================
  
  Future<Map<String, dynamic>> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      print('🔄 AuthProvider: Starting Google Sign-In...');
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        _errorMessage = 'Sign-in cancelled by user';
        _isLoading = false;
        notifyListeners();
        return {'success': false, 'error': _errorMessage};
      }
      
      print('✅ AuthProvider: Got Google user: ${googleUser.email}');
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      print('✅ AuthProvider: Got Google auth tokens');
      print('🔑 ID Token present: ${googleAuth.idToken != null}');
      
      final response = await _apiService.googleSignIn(
        email: googleUser.email,
        name: googleUser.displayName ?? 'User',
        photoUrl: googleUser.photoUrl,
        googleId: googleUser.id,
        idToken: googleAuth.idToken ?? '',
        accessToken: googleAuth.accessToken,
      );
      
      _user = response['user'];
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      
      print('✅ AuthProvider: Google Sign-In successful!');
      return {'success': true, 'user': _user};
      
    } catch (e) {
      print('❌ AuthProvider Google Sign-In error: $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'error': _errorMessage};
    }
  }
  
  // ============================================================================
  // Profile Picture Upload
  // ============================================================================
  
  Future<Map<String, dynamic>?> uploadProfilePicture(File imageFile) async {
    try {
      print('📸 Starting profile picture upload...');
      final result = await _apiService.uploadProfilePicture(imageFile);
      
      print('📸 Upload result: $result');
      
      if (result != null && result['user'] != null) {
        _user = Map<String, dynamic>.from(result['user']);
        print('📸 Updated user photoUrl: ${_user?['photoUrl']}');
        notifyListeners();
      } else if (result != null && result['photoUrl'] != null) {
        if (_user != null) {
          _user = Map<String, dynamic>.from(_user!);
          _user!['photoUrl'] = result['photoUrl'];
          print('📸 Updated photoUrl directly: ${result['photoUrl']}');
          notifyListeners();
        }
      }
      
      return result;
    } catch (e) {
      print('❌ Error uploading profile picture: $e');
      return null;
    }
  }
  
  Future<void> refreshUserData() async {
    try {
      final response = await _apiService.getCurrentUser();
      if (response['user'] != null) {
        _user = Map<String, dynamic>.from(response['user']);
        notifyListeners();
        print('✅ User data refreshed successfully');
      }
    } catch (e) {
      print('❌ Error refreshing user data: $e');
    }
  }
  
  // ============================================================================
  // Logout
  // ============================================================================
  
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      
      await _apiService.logout();
      
      _isAuthenticated = false;
      _user = null;
      _errorMessage = null;
    } catch (e) {
      print('Logout error: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  // Helper method to mask email (t***t@e***e.com)
  String _maskEmail(String email) {
    if (email.length < 5) return email;
    
    final parts = email.split('@');
    if (parts.length != 2) return email;
    
    final localPart = parts[0];
    final domain = parts[1];
    
    final maskedLocal = localPart.length > 2 
      ? '${localPart[0]}${'*' * (localPart.length - 2)}${localPart[localPart.length - 1]}'
      : localPart;
    
    final domainParts = domain.split('.');
    if (domainParts.length < 2) return email;
    
    final mainDomain = domainParts[0];
    final maskedDomain = mainDomain.length > 2
      ? '${mainDomain[0]}${'*' * (mainDomain.length - 2)}${mainDomain[mainDomain.length - 1]}'
      : mainDomain;
    
    return '$maskedLocal@$maskedDomain.${domainParts.sublist(1).join('.')}';
  }
}