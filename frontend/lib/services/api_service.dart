// File: lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

class ApiService {
  static const String baseUrl = 'http://192.168.100.9:5000/api';
  
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
  
  // AUTHENTICATION
  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String name,
    String? dateOfBirth,
  }) async {
    final url = Uri.parse('$baseUrl/auth/signup');
    
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
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveToken(data['token']);
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Signup failed');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveToken(data['token']);
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Login failed');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> googleSignIn({
    required String email,
    required String name,
    String? photoUrl,
    required String googleId,
  }) async {
    final url = Uri.parse('$baseUrl/auth/google/mobile');
    
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
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveToken(data['token']);
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Google sign-in failed');
      }
    } catch (e) {
      rethrow;
    }
  }
  
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
  
  // PROFILE PICTURE UPLOAD - TEMPORARILY DISABLED FOR WEB
  Future<Map<String, dynamic>> uploadProfilePicture(File imageFile) async {
    // Temporarily disable for web until we fix web compatibility
    if (kIsWeb) {
      throw Exception('Profile picture upload is temporarily disabled for web. Please use the mobile app for this feature.');
    }
    
    final url = Uri.parse('$baseUrl/profile/picture');
    final token = await getToken();
    
    if (token == null) {
      throw Exception('Not authenticated');
    }
    
    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';
    
    request.files.add(
      await http.MultipartFile.fromPath('profilePicture', imageFile.path),
    );
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to upload profile picture');
    }
  }
  
  // HEALTH METRICS
  Future<Map<String, dynamic>> getHealthMetrics() async {
    final url = Uri.parse('$baseUrl/health/metrics');
    final headers = await _getHeaders();
    
    final response = await http.get(url, headers: headers);
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      return {}; // No metrics yet
    } else {
      throw Exception('Failed to get health metrics');
    }
  }
  
  Future<Map<String, dynamic>> saveHealthMetrics({
    required DateTime birthdate,
    required double height,
    required double weight,
    required bool useMetric,
  }) async {
    final url = Uri.parse('$baseUrl/health/metrics');
    final headers = await _getHeaders();
    
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'birthdate': birthdate.toIso8601String(),
        'height': height,
        'weight': weight,
        'useMetric': useMetric,
      }),
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to save health metrics');
    }
  }
  
  // NOTIFICATION SETTINGS
  Future<Map<String, dynamic>> getNotificationSettings() async {
    final url = Uri.parse('$baseUrl/notifications/settings');
    final headers = await _getHeaders();
    
    final response = await http.get(url, headers: headers);
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      return {
        'periodReminders': false,
        'ovulationReminders': false,
        'dailyReminders': false,
        'insightsReminders': false,
        'anomalyReminders': false,
      };
    } else {
      throw Exception('Failed to get notification settings');
    }
  }
  
  Future<void> updateNotificationSettings({
    required bool periodReminders,
    required bool ovulationReminders,
    required bool dailyReminders,
    required bool insightsReminders,
    required bool anomalyReminders,
  }) async {
    final url = Uri.parse('$baseUrl/notifications/settings');
    final headers = await _getHeaders();
    
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode({
        'periodReminders': periodReminders,
        'ovulationReminders': ovulationReminders,
        'dailyReminders': dailyReminders,
        'insightsReminders': insightsReminders,
        'anomalyReminders': anomalyReminders,
      }),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to update notification settings');
    }
  }
  
  // PRIVACY
  Future<void> deleteAllUserData() async {
    final url = Uri.parse('$baseUrl/user/data');
    final headers = await _getHeaders();
    
    final response = await http.delete(url, headers: headers);
    
    if (response.statusCode != 200) {
      throw Exception('Failed to delete data');
    }
  }
  
  // CYCLES
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
  
  // INSIGHTS
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
  
  Future<Map<String, dynamic>> requestAnalysis() async {
    final url = Uri.parse('$baseUrl/insights/analyze');
    final headers = await _getHeaders();
    
    print('Requesting AI analysis from: $url');
    
    final response = await http.post(url, headers: headers);
    
    print('AI Analysis Response Status: ${response.statusCode}');
    print('AI Analysis Response Body: ${response.body}');
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to request analysis: ${response.statusCode}');
    }
  }
  
  // SYMPTOMS
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
  
  Future<void> logout() async {
    await clearToken();
  }
}