// File: frontend/lib/providers/auth_provider.dart
import 'dart:io'; // Keep this for mobile
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
  
  // Email/Password Signup
  Future<bool> signup({
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
      
      _user = response['user'];
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Email/Password Login
  Future<bool> login({
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
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Google Sign-In
  Future<bool> signInWithGoogle() async {
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
        return false;
      }
      
      print('✅ AuthProvider: Got Google user: ${googleUser.email}');
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      print('✅ AuthProvider: Got Google auth tokens');
      print('🔑 ID Token present: ${googleAuth.idToken != null}');
      print('🔑 Access Token present: ${googleAuth.accessToken != null}');
      
      // IMPORTANT: Pass the idToken to ApiService
      final response = await _apiService.googleSignIn(
        email: googleUser.email,
        name: googleUser.displayName ?? 'User',
        photoUrl: googleUser.photoUrl,
        googleId: googleUser.id,
        idToken: googleAuth.idToken ?? '', // ADD THIS - CRITICAL!
        accessToken: googleAuth.accessToken,
      );
      
      _user = response['user'];
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      
      print('✅ AuthProvider: Google Sign-In successful!');
      return true;
      
    } catch (e) {
      print('❌ AuthProvider Google Sign-In error: $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // ✅ FIX #2: Fixed profile picture upload with proper state update
  Future<Map<String, dynamic>?> uploadProfilePicture(File imageFile) async {
    try {
      print('📸 Starting profile picture upload...');
      final result = await _apiService.uploadProfilePicture(imageFile);
      
      print('📸 Upload result: $result');
      
      // ✅ FIX #2: Update user state immediately and notify listeners
      if (result != null && result['user'] != null) {
        // Create a new map to ensure the UI updates
        _user = Map<String, dynamic>.from(result['user']);
        print('📸 Updated user photoUrl: ${_user?['photoUrl']}');
        notifyListeners(); // This triggers UI rebuild
      } else if (result != null && result['photoUrl'] != null) {
        // Alternative: if only photoUrl is returned, update it directly
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
  
  // ✅ FIX #2: Method to manually update user data (can be called after upload)
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
  
  // Logout
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
}