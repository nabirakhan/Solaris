// File: frontend/lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // CRITICAL: Make sure this is correct for your device
  // Android Emulator: 'http://10.0.2.2:5000/api'
  // Real Device: 'http://192.168.100.9:5000/api'
  // Web (Flutter web running on localhost): 'http://192.168.100.9:5000/api'
  static const String baseUrl = 'http://192.168.100.9:5000/api'; // Update based on device
  
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
  
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
  
  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  // SIGNUP - POST /api/auth/signup
  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String name,
    String? dateOfBirth,
  }) async {
    final url = Uri.parse('$baseUrl/auth/signup');
    
    print('🔵 Signup URL: $url');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
        }),
      ).timeout(Duration(seconds: 30));
      
      print('🔵 Signup Response: ${response.statusCode}');
      print('🔵 Signup Body: ${response.body}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveToken(data['token']);
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Signup failed');
      }
    } catch (e) {
      print('❌ Signup Error: $e');
      rethrow;
    }
  }
  
  // LOGIN - POST /api/auth/login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login');
    
    print('🔵 Login URL: $url');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(Duration(seconds: 30));
      
      print('🔵 Login Response: ${response.statusCode}');
      print('🔵 Login Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveToken(data['token']);
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Login failed');
      }
    } catch (e) {
      print('❌ Login Error: $e');
      rethrow;
    }
  }
  
  // GOOGLE SIGN-IN (Mobile) - POST /api/auth/google/mobile
  Future<Map<String, dynamic>> googleSignIn({
    required String email,
    required String name,
    String? photoUrl,
    required String googleId,
  }) async {
    final url = Uri.parse('$baseUrl/auth/google/mobile');
    
    print('🔵 Google Mobile URL: $url');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'name': name,
          'photoUrl': photoUrl,
          'googleId': googleId,
        }),
      ).timeout(Duration(seconds: 30));
      
      print('🔵 Google Response: ${response.statusCode}');
      print('🔵 Google Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveToken(data['token']);
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Google sign-in failed');
      }
    } catch (e) {
      print('❌ Google Sign-In Error: $e');
      rethrow;
    }
  }
  
  // GET CURRENT USER - GET /api/auth/me
  Future<Map<String, dynamic>> getCurrentUser() async {
    final url = Uri.parse('$baseUrl/auth/me');
    final headers = await _getHeaders();
    
    final response = await http.get(url, headers: headers);
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user');
    }
  }
  
  // LOGOUT
  Future<void> logout() async {
    await clearToken();
  }
  
  // GET CYCLES - GET /api/cycles
  Future<List<dynamic>> getCycles() async {
    final url = Uri.parse('$baseUrl/cycles');
    final headers = await _getHeaders();
    
    final response = await http.get(url, headers: headers);
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['cycles'] ?? [];
    } else {
      throw Exception('Failed to get cycles');
    }
  }
  
  // CREATE CYCLE - POST /api/cycles
  Future<Map<String, dynamic>> createCycle({
    required String startDate,
    required String flow,
    String? notes,
  }) async {
    final url = Uri.parse('$baseUrl/cycles');
    final headers = await _getHeaders();
    
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'startDate': startDate,
        'flow': flow,
        if (notes != null) 'notes': notes,
      }),
    );
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create cycle');
    }
  }
  
  // UPDATE CYCLE - PUT /api/cycles/:id
  Future<Map<String, dynamic>> updateCycle({
    required String id,
    String? endDate,
    String? flow,
    String? notes,
  }) async {
    final url = Uri.parse('$baseUrl/cycles/$id');
    final headers = await _getHeaders();
    
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode({
        if (endDate != null) 'endDate': endDate,
        if (flow != null) 'flow': flow,
        if (notes != null) 'notes': notes,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update cycle');
    }
  }
  
  // GET INSIGHTS - GET /api/insights/current
  Future<Map<String, dynamic>> getCurrentInsights() async {
    final url = Uri.parse('$baseUrl/insights/current');
    final headers = await _getHeaders();
    
    final response = await http.get(url, headers: headers);
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get insights');
    }
  }
  
  // REQUEST AI ANALYSIS - POST /api/insights/analyze
  Future<Map<String, dynamic>> requestAnalysis() async {
    final url = Uri.parse('$baseUrl/insights/analyze');
    final headers = await _getHeaders();
    
    final response = await http.post(url, headers: headers);
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to request analysis');
    }
  }
  
  // LOG SYMPTOMS - POST /api/symptoms
  Future<Map<String, dynamic>> logSymptoms({
    required String date,
    required Map<String, int> symptoms,
    double? sleepHours,
    int? stressLevel,
    String? notes,
  }) async {
    final url = Uri.parse('$baseUrl/symptoms');
    final headers = await _getHeaders();
    
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'date': date,
        'symptoms': symptoms,
        if (sleepHours != null) 'sleepHours': sleepHours,
        if (stressLevel != null) 'stressLevel': stressLevel,
        if (notes != null) 'notes': notes,
      }),
    );
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to log symptoms');
    }
  }
}