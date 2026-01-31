// File: frontend/lib/providers/auth_provider.dart
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
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final response = await _apiService.googleSignIn(
        email: googleUser.email,
        name: googleUser.displayName ?? 'User',
        photoUrl: googleUser.photoUrl,
        googleId: googleUser.id,
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