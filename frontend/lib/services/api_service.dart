// File: lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

class ApiService {
  static const String _tokenKey = 'auth_token';
  
  // Get stored auth token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  // Save auth token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }
  
  // Clear auth token
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
  
  // Get headers with auth token
  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  // ============================================================================
  // AUTHENTICATION
  // ============================================================================
  
  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String name,
    String? dateOfBirth,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.apiBaseUrl}/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
        'dateOfBirth': dateOfBirth,
      }),
    );
    
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await saveToken(data['token']);
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Signup failed');
    }
  }
  
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.apiBaseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveToken(data['token']);
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Login failed');
    }
  }
  
 // Replace your current googleSignIn() method with this:
  Future<Map<String, dynamic>> googleSignIn({
    required String email,
    required String name,
    String? photoUrl,
    required String googleId,
    required String idToken,
    String? accessToken,
  }) async {
    print('🔍 [API DEBUG] Sending Google sign-in to backend...');
    print('📧 Email: $email');
    print('👤 Name: $name');
    print('🆔 Google ID: $googleId');
    print('🔑 ID Token present: ${idToken != null}');
    
    final response = await http.post(
      Uri.parse('${AppConstants.apiBaseUrl}/auth/google/mobile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'name': name,
        'photoUrl': photoUrl,
        'googleId': googleId,
        'idToken': idToken,
        'accessToken': accessToken,
      }),
    );
    
    print('🔍 [API DEBUG] Backend response: ${response.statusCode}');
    print('🔍 [API DEBUG] Backend body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveToken(data['token']);
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Google sign-in failed');
    }
  }
  
  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await http.get(
      Uri.parse('${AppConstants.apiBaseUrl}/auth/me'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user data');
    }
  }
  
  Future<void> logout() async {
    await clearToken();
  }
  
  Future<Map<String, dynamic>?> uploadProfilePicture(File imageFile) async {
    try {
      print('📸 Upload starting...');
      print('📸 File path: ${imageFile.path}');
      print('📸 File exists: ${await imageFile.exists()}');
      
      final headers = await _getHeaders();
      print('📸 Auth headers obtained');
      headers.remove('Content-Type'); // Let multipart set this
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConstants.apiBaseUrl}/auth/profile/picture'),
      );
      
      print('📸 Request URL: ${AppConstants.apiBaseUrl}/auth/profile/picture');
      
      request.headers.addAll(headers);
      request.files.add(
        await http.MultipartFile.fromPath(
          'picture',
          imageFile.path,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );
      
      print('📸 Sending request...');
      final streamedResponse = await request.send();
      print('📸 Response status code: ${streamedResponse.statusCode}');
      
      final response = await http.Response.fromStream(streamedResponse);
      print('📸 Response body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ Upload successful! Data: $data');
        return data;
      } else {
        print('❌ Upload failed with status: ${response.statusCode}');
        print('❌ Response: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      print('❌ Upload error: $e');
      print('❌ Stack trace: $stackTrace');
      return null;
    }
  }
  
  // ============================================================================
  // CYCLES
  // ============================================================================
  
  Future<List<dynamic>> getCycles() async {
    final response = await http.get(
      Uri.parse('${AppConstants.apiBaseUrl}/cycles'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['cycles'] ?? [];
    } else {
      throw Exception('Failed to load cycles');
    }
  }
  
  Future<Map<String, dynamic>> createCycle({
    required String startDate,
    required String flow,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.apiBaseUrl}/cycles'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'startDate': startDate,
        'flow': flow,
        'notes': notes,
      }),
    );
    
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to create cycle');
    }
  }
  
  Future<Map<String, dynamic>> updateCycle({
    required String id,
    String? endDate,
    String? flow,
    String? notes,
  }) async {
    final response = await http.put(
      Uri.parse('${AppConstants.apiBaseUrl}/cycles/$id'),
      headers: await _getHeaders(),
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

  /// NEW: Delete a cycle
  Future<void> deleteCycle(String cycleId) async {
    final response = await http.delete(
      Uri.parse('${AppConstants.apiBaseUrl}/cycles/$cycleId'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to delete cycle');
    }
  }

  /// NEW: Add a single day to a cycle (manual day logging)
  Future<Map<String, dynamic>> addCycleDay({
    required String cycleId,
    required String date,
    required String flow,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.apiBaseUrl}/cycles/$cycleId/days'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'date': date,
        'flow': flow,
        'notes': notes,
      }),
    );
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to add cycle day');
    }
  }

  /// NEW: Update a specific day in a cycle
  Future<Map<String, dynamic>> updateCycleDay({
    required String cycleId,
    required String dayId,
    String? flow,
    String? notes,
  }) async {
    final response = await http.put(
      Uri.parse('${AppConstants.apiBaseUrl}/cycles/$cycleId/days/$dayId'),
      headers: await _getHeaders(),
      body: jsonEncode({
        if (flow != null) 'flow': flow,
        if (notes != null) 'notes': notes,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update cycle day');
    }
  }

  /// NEW: Delete a specific day from a cycle
  Future<void> deleteCycleDay({
    required String cycleId,
    required String dayId,
  }) async {
    final response = await http.delete(
      Uri.parse('${AppConstants.apiBaseUrl}/cycles/$cycleId/days/$dayId'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to delete cycle day');
    }
  }
  
  // ============================================================================
  // SYMPTOMS
  // ============================================================================
  
  Future<Map<String, dynamic>> logSymptoms({
    required String date,
    required Map<String, int> symptoms,
    double? sleepHours,
    int? stressLevel,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.apiBaseUrl}/symptoms'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'date': date,
        'symptoms': symptoms,
        'sleepHours': sleepHours,
        'stressLevel': stressLevel,
        'notes': notes,
      }),
    );
    
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to log symptoms');
    }
  }
  
  Future<List<dynamic>> getSymptoms({String? startDate, String? endDate}) async {
    var url = '${AppConstants.apiBaseUrl}/symptoms';
    if (startDate != null && endDate != null) {
      url += '?startDate=$startDate&endDate=$endDate';
    }
    
    final response = await http.get(
      Uri.parse(url),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['logs'] ?? [];
    } else {
      throw Exception('Failed to load symptoms');
    }
  }
  
  // ============================================================================
  // AI INSIGHTS & ANALYSIS
  // ============================================================================
  
  Future<Map<String, dynamic>> getCurrentInsights() async {
    final response = await http.get(
      Uri.parse('${AppConstants.apiBaseUrl}/insights/current'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load insights');
    }
  }
  
  Future<Map<String, dynamic>> requestAnalysis() async {
    final response = await http.post(
      Uri.parse('${AppConstants.apiBaseUrl}/insights/analyze'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200 || response.statusCode == 503) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Analysis failed');
    }
  }
  
  Future<List<dynamic>> getInsightHistory({int limit = 30}) async {
    final response = await http.get(
      Uri.parse('${AppConstants.apiBaseUrl}/insights/history?limit=$limit'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['insights'] ?? [];
    } else {
      throw Exception('Failed to load insight history');
    }
  }
  
  Future<List<dynamic>> getUnviewedInsights() async {
    final response = await http.get(
      Uri.parse('${AppConstants.apiBaseUrl}/insights/unviewed'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['insights'] ?? [];
    } else {
      throw Exception('Failed to load unviewed insights');
    }
  }
  
  Future<void> markInsightAsViewed(String insightId) async {
    await http.put(
      Uri.parse('${AppConstants.apiBaseUrl}/insights/$insightId/viewed'),
      headers: await _getHeaders(),
    );
  }
  
  // ============================================================================
  // HEALTH METRICS
  // ============================================================================
  
  Future<Map<String, dynamic>> getHealthMetrics() async {
    final response = await http.get(
      Uri.parse('${AppConstants.apiBaseUrl}/health/metrics'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else if (response.statusCode == 404) {
      return {};
    } else {
      throw Exception('Failed to load health metrics');
    }
  }
  
  Future<Map<String, dynamic>> saveHealthMetrics({
    required DateTime birthdate,
    required double height,
    required double weight,
    required bool useMetric,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.apiBaseUrl}/health/metrics'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'birthdate': birthdate.toIso8601String().split('T')[0],
        'height': height,
        'weight': weight,
        'useMetric': useMetric,
      }),
    );
    
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['metrics'] ?? data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to save health metrics');
    }
  }
  
  // ============================================================================
  // NOTIFICATIONS
  // ============================================================================
  
  Future<Map<String, dynamic>> getNotificationSettings() async {
    final response = await http.get(
      Uri.parse('${AppConstants.apiBaseUrl}/notifications/settings'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {
        'periodReminders': false,
        'ovulationReminders': false,
        'dailyReminders': false,
        'insightsReminders': false,
        'anomalyReminders': false,
      };
    }
  }
  
  Future<void> updateNotificationSettings({
    required bool periodReminders,
    required bool ovulationReminders,
    required bool dailyReminders,
    required bool insightsReminders,
    required bool anomalyReminders,
  }) async {
    await http.post(
      Uri.parse('${AppConstants.apiBaseUrl}/notifications/settings'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'periodReminders': periodReminders,
        'ovulationReminders': ovulationReminders,
        'dailyReminders': dailyReminders,
        'insightsReminders': insightsReminders,
        'anomalyReminders': anomalyReminders,
      }),
    );
  }
  
  // ============================================================================
  // DATA MANAGEMENT
  // ============================================================================
  
  Future<void> deleteAllUserData() async {
    await http.delete(
      Uri.parse('${AppConstants.apiBaseUrl}/user/data'),
      headers: await _getHeaders(),
    );
  }
}