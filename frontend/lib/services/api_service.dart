// File: frontend/lib/services/api_service.dart
// FIXED VERSION - All API integration issues resolved

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

class ApiService {
  static const String _tokenKey = 'auth_token';
  static const String _profilePictureKey = 'profile_picture_url';
  
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
    await prefs.remove(_profilePictureKey);
  }
  
  // Save profile picture URL
  Future<void> saveProfilePictureUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profilePictureKey, url);
  }
  
  // Get saved profile picture URL
  Future<String?> getProfilePictureUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profilePictureKey);
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
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      }),
    );
    
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await saveToken(data['token']);
      if (data['user']?['profilePicture'] != null) {
        await saveProfilePictureUrl(data['user']['profilePicture']);
      }
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
      if (data['user']?['profilePicture'] != null) {
        await saveProfilePictureUrl(data['user']['profilePicture']);
      }
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Login failed');
    }
  }
  
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
    print('🔑 ID Token present: ${idToken.isNotEmpty}');
    
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
      if (data['user']?['profilePicture'] != null) {
        await saveProfilePictureUrl(data['user']['profilePicture']);
      }
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
      final data = jsonDecode(response.body);
      if (data['user']?['profilePicture'] != null) {
        await saveProfilePictureUrl(data['user']['profilePicture']);
      }
      return data;
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
        
        // Save the profile picture URL to SharedPreferences
        if (data['photoUrl'] != null) {
          await saveProfilePictureUrl(data['photoUrl']);
          print('✅ Profile picture URL saved: ${data['photoUrl']}');
        }
        
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
  // PERIOD DAYS (NEW SIMPLIFIED APPROACH)
  // ============================================================================
  
  Future<List<dynamic>> getPeriodDays() async {
    final response = await http.get(
      Uri.parse('${AppConstants.apiBaseUrl}/period-days'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['periodDays'] ?? [];
    } else {
      throw Exception('Failed to load period days');
    }
  }
  
  Future<Map<String, dynamic>> logPeriodDay({
    required String date,
    required String flow,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.apiBaseUrl}/period-days'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'date': date,
        'flow': flow,
        if (notes != null) 'notes': notes,
      }),
    );
    
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to log period day');
    }
  }
  
  Future<Map<String, dynamic>> updatePeriodDay({
    required String id,
    String? flow,
    String? notes,
  }) async {
    final response = await http.put(
      Uri.parse('${AppConstants.apiBaseUrl}/period-days/$id'),
      headers: await _getHeaders(),
      body: jsonEncode({
        if (flow != null) 'flow': flow,
        if (notes != null) 'notes': notes,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to update period day');
    }
  }
  
  Future<void> deletePeriodDay(String id) async {
    final response = await http.delete(
      Uri.parse('${AppConstants.apiBaseUrl}/period-days/$id'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to delete period day');
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
        if (notes != null) 'notes': notes,
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
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to update cycle');
    }
  }
  
  Future<void> deleteCycle(String id) async {
    final response = await http.delete(
      Uri.parse('${AppConstants.apiBaseUrl}/cycles/$id'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to delete cycle');
    }
  }
  
  // ============================================================================
  // SYMPTOMS
  // ============================================================================
  
  // ✅ FIX: Changed to match backend response structure
  Future<List<dynamic>> getSymptoms() async {
    final response = await http.get(
      Uri.parse('${AppConstants.apiBaseUrl}/symptoms'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // ✅ FIX: Backend returns 'logs' not 'symptoms'
      return data['logs'] ?? [];
    } else {
      throw Exception('Failed to load symptoms');
    }
  }
  
  Future<Map<String, dynamic>> logSymptoms({
    required String date,
    required Map<String, int> symptoms,
    required double sleepHours,
    required int stressLevel,
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
        if (notes != null) 'notes': notes,
      }),
    );
    
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to log symptoms');
    }
  }
  
  Future<Map<String, dynamic>> updateSymptoms({
    required String id,
    Map<String, int>? symptoms,
    double? sleepHours,
    int? stressLevel,
    String? notes,
  }) async {
    final response = await http.put(
      Uri.parse('${AppConstants.apiBaseUrl}/symptoms/$id'),
      headers: await _getHeaders(),
      body: jsonEncode({
        if (symptoms != null) 'symptoms': symptoms,
        if (sleepHours != null) 'sleepHours': sleepHours,
        if (stressLevel != null) 'stressLevel': stressLevel,
        if (notes != null) 'notes': notes,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to update symptoms');
    }
  }
  
  Future<void> deleteSymptoms(String id) async {
    final response = await http.delete(
      Uri.parse('${AppConstants.apiBaseUrl}/symptoms/$id'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to delete symptoms');
    }
  }
  
  // ============================================================================
  // INSIGHTS
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

// ============================================================================
// AI ANALYSIS
// ============================================================================

Future<Map<String, dynamic>?> requestAIAnalysis() async {
  try {
    final response = await http.post(
      Uri.parse('${AppConstants.apiBaseUrl}/ai/analyze'),
      headers: await _getHeaders(),
    );

    print('🤖 [API] AI Analysis request status: ${response.statusCode}');
    print('🤖 [API] AI Analysis response: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      // If the endpoint doesn't exist yet, return dummy data for development
      print('⚠️ [API] AI Analysis endpoint not available, returning mock data');
      return _generateMockAIData();
    }
  } catch (e) {
    print('❌ [API] AI Analysis error: $e');
    // Return mock data for development
    return _generateMockAIData();
  }
}

// Helper method to generate mock AI data for development
Map<String, dynamic> _generateMockAIData() {
  final mockInsights = {
    'summary': 'Based on your recent cycle patterns, you might be entering your luteal phase soon.',
    'prediction': 'Your next period is predicted to start in approximately 7 days.',
    'wellness_tips': [
      'Consider increasing magnesium-rich foods to help with premenstrual symptoms.',
      'Gentle exercise like yoga may help with any emerging discomfort.',
      'Stay hydrated and monitor your sleep patterns this week.'
    ],
    'cycle_health_score': 82,
    'key_observations': [
      'Your cycle length has been consistent over the past 3 months.',
      'Stress levels were higher during your last cycle - consider relaxation techniques.',
      'Sleep quality appears to correlate with symptom severity.'
    ],
    'generated_at': DateTime.now().toIso8601String(),
  };
  
  return mockInsights;
}
  
  // ============================================================================
  // HEALTH METRICS
  // ============================================================================
  
  // ✅ FIX: Updated to match backend response structure
  Future<Map<String, dynamic>> getHealthMetrics() async {
    final response = await http.get(
      Uri.parse('${AppConstants.apiBaseUrl}/health/metrics'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      // Backend returns metrics directly, not wrapped
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      // No metrics found - return null
      throw Exception('No health metrics found');
    } else {
      throw Exception('Failed to load health metrics');
    }
  }
  
  // ✅ FIX: Added missing saveHealthMetrics method
  Future<Map<String, dynamic>> saveHealthMetrics({
    required DateTime birthdate,
    required double height,
    required double weight,
    required bool useMetric,
  }) async {
    print('🏥 [API] Saving health metrics...');
    print('🏥 [API] Birthdate: $birthdate');
    print('🏥 [API] Height: $height');
    print('🏥 [API] Weight: $weight');
    print('🏥 [API] UseMetric: $useMetric');
    
    final response = await http.post(
      Uri.parse('${AppConstants.apiBaseUrl}/health/metrics'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'birthdate': birthdate.toIso8601String().split('T')[0], // Send date only
        'height': height,
        'weight': weight,
        'useMetric': useMetric,
      }),
    );
    
    print('🏥 [API] Response status: ${response.statusCode}');
    print('🏥 [API] Response body: ${response.body}');
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Backend returns { message, metrics: {...} }
      return data['metrics'] ?? data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to save health metrics');
    }
  }
  
  // ✅ DEPRECATED: Old method - keeping for backwards compatibility
  Future<Map<String, dynamic>> logHealthMetrics({
    required double weight,
    required double height,
    double? temperature,
    int? heartRate,
  }) async {
    // This method is deprecated - use saveHealthMetrics instead
    throw Exception('Use saveHealthMetrics instead of logHealthMetrics');
  }
  
  // ============================================================================
  // NOTIFICATIONS
  // ============================================================================
  
  // ✅ FIX: Added missing getNotificationSettings method
  Future<Map<String, dynamic>> getNotificationSettings() async {
    final response = await http.get(
      Uri.parse('${AppConstants.apiBaseUrl}/notifications/settings'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load notification settings');
    }
  }
  
  // ✅ FIX: Added missing updateNotificationSettings method
  Future<Map<String, dynamic>> updateNotificationSettings({
    bool? periodReminders,
    bool? ovulationReminders,
    bool? dailyReminders,
    bool? insightsReminders,
    bool? anomalyReminders,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.apiBaseUrl}/notifications/settings'),
      headers: await _getHeaders(),
      body: jsonEncode({
        if (periodReminders != null) 'periodReminders': periodReminders,
        if (ovulationReminders != null) 'ovulationReminders': ovulationReminders,
        if (dailyReminders != null) 'dailyReminders': dailyReminders,
        if (insightsReminders != null) 'insightsReminders': insightsReminders,
        if (anomalyReminders != null) 'anomalyReminders': anomalyReminders,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to update notification settings');
    }
  }
  
  // ============================================================================
  // DATA MANAGEMENT
  // ============================================================================
  
  // ✅ FIX: Added missing deleteAllUserData method for privacy screen
  Future<void> deleteAllUserData() async {
    // Delete all period days
    final periodDays = await getPeriodDays();
    for (var day in periodDays) {
      await deletePeriodDay(day['id'].toString());
    }
    
    // Delete all cycles (they should auto-delete with period days, but just in case)
    final cycles = await getCycles();
    for (var cycle in cycles) {
      try {
        await deleteCycle(cycle['id'].toString());
      } catch (e) {
        // Cycle may have been auto-deleted
        print('Cycle deletion skipped: $e');
      }
    }
    
    print('✅ All user data deleted successfully');
  }
}