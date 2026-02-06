// File: frontend/lib/providers/health_provider.dart
// FIXED VERSION - All API integration issues resolved

import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HealthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  Map<String, dynamic>? _healthMetrics;
  bool _isLoading = false;
  String? _error;
  
  Map<String, dynamic>? get healthMetrics => _healthMetrics;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadHealthMetrics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // ✅ FIX: Backend returns metrics directly, not wrapped
      final data = await _apiService.getHealthMetrics();
      _healthMetrics = data;
      _error = null;
      print('✅ Health metrics loaded: $data');
    } catch (e) {
      _error = 'Error loading health metrics: $e';
      _healthMetrics = null;
      print('❌ Error loading health metrics: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // ✅ FIX: Updated to use the new saveHealthMetrics method
  Future<bool> saveHealthMetrics({
    required DateTime birthdate,
    required double height,
    required double weight,
    required bool useMetric,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      print('🏥 [Provider] Saving health metrics...');
      print('🏥 [Provider] Birthdate: $birthdate');
      print('🏥 [Provider] Height: $height');
      print('🏥 [Provider] Weight: $weight');
      print('🏥 [Provider] UseMetric: $useMetric');
      
      // ✅ FIX: Using the correct API method
      final result = await _apiService.saveHealthMetrics(
        birthdate: birthdate,
        height: height,
        weight: weight,
        useMetric: useMetric,
      );
      
      print('🏥 [Provider] Save result: $result');
      
      // ✅ FIX: Update local state with returned metrics
      _healthMetrics = result;
      _error = null;
      _isLoading = false;
      notifyListeners();
      
      print('✅ Health metrics saved successfully');
      
      // Reload to ensure we have latest data
      await loadHealthMetrics();
      
      return true;
    } catch (e) {
      print('❌ Error saving health metrics: $e');
      _error = 'Error saving health metrics: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// ✅ FIX: Added clear method
  void clear() {
    _healthMetrics = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
    print('✅ Health metrics cleared');
  }
}