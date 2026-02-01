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
      _healthMetrics = await _apiService.getHealthMetrics();
      _error = null;
    } catch (e) {
      _error = 'Error loading health metrics: $e';
      _healthMetrics = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
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
      print('Saving health metrics: birthdate=$birthdate, height=$height, weight=$weight, useMetric=$useMetric');
      
      final result = await _apiService.saveHealthMetrics(
        birthdate: birthdate,
        height: height,
        weight: weight,
        useMetric: useMetric,
      );
      
      print('Save result: $result');
      
      // Update local state with saved metrics
      _healthMetrics = result;
      _error = null;
      _isLoading = false;
      notifyListeners();
      
      // Reload to ensure we have latest data
      await loadHealthMetrics();
      
      return true;
    } catch (e) {
      print('Error saving health metrics: $e');
      _error = 'Error saving health metrics: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  void clear() {
    _healthMetrics = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}