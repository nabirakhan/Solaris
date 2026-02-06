// File: frontend/lib/providers/cycle_provider.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CycleProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<dynamic> _cycles = [];
  Map<String, dynamic>? _currentInsights;
  bool _isLoading = false;
  String? _error;
  
  List<dynamic> get cycles => _cycles;
  Map<String, dynamic>? get currentInsights => _currentInsights;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// Load all cycles for the current user
  Future<void> loadCycles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _cycles = await _apiService.getCycles();
      _error = null;
    } catch (e) {
      _error = 'Error loading cycles: $e';
      _cycles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Start a new menstrual cycle
  Future<bool> startNewCycle(DateTime startDate, String flow, String? notes) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _apiService.createCycle(
        startDate: startDate.toIso8601String(),
        flow: flow,
        notes: notes,
      );
      
      // Reload cycles after creating new one
      await loadCycles();
      // Also reload insights
      await loadCurrentInsights();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error creating cycle: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// End an existing cycle
  Future<bool> endCycle(String cycleId, DateTime endDate) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _apiService.updateCycle(
        id: cycleId,
        endDate: endDate.toIso8601String().split('T')[0],
      );
      
      await loadCycles();
      await loadCurrentInsights();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error ending cycle: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// NEW: Delete a cycle completely
  Future<bool> deleteCycle(String cycleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _apiService.deleteCycle(cycleId);
      
      // Reload cycles and insights after deletion
      await loadCycles();
      await loadCurrentInsights();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error deleting cycle: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// NEW: Add a single day to a cycle
  Future<bool> addDayToCycle({
    required String cycleId,
    required DateTime date,
    required String flow,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _apiService.addCycleDay(
        cycleId: cycleId,
        date: date.toIso8601String().split('T')[0],
        flow: flow,
        notes: notes,
      );
      
      // Reload cycles after adding day
      await loadCycles();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error adding day to cycle: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// NEW: Update a specific day in a cycle
  Future<bool> updateCycleDay({
    required String cycleId,
    required String dayId,
    String? flow,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _apiService.updateCycleDay(
        cycleId: cycleId,
        dayId: dayId,
        flow: flow,
        notes: notes,
      );
      
      // Reload cycles after updating day
      await loadCycles();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error updating cycle day: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// NEW: Delete a specific day from a cycle
  Future<bool> deleteCycleDay({
    required String cycleId,
    required String dayId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _apiService.deleteCycleDay(
        cycleId: cycleId,
        dayId: dayId,
      );
      
      // Reload cycles after deleting day
      await loadCycles();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error deleting cycle day: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Load current cycle insights and predictions
  Future<void> loadCurrentInsights() async {
    _error = null;
    
    try {
      _currentInsights = await _apiService.getCurrentInsights();
      _error = null;
    } catch (e) {
      _error = 'Error loading insights: $e';
      _currentInsights = null;
    }
    
    notifyListeners();
  }
  
  /// Request AI analysis for personalized insights
  Future<bool> requestAIAnalysis() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await _apiService.requestAnalysis();
      
      print('AI Analysis Response: $result');
      
      final success = 
          result['success'] == true ||
          result['status'] == 'success' ||
          result['hasData'] == true ||
          result['message']?.toLowerCase().contains('success') == true;
      
      if (success) {
        await loadCurrentInsights();
        await loadCycles();
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['message'] ?? result['error'] ?? 'Analysis failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('AI Analysis Error: $e');
      _error = 'Error requesting analysis: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Log symptoms for a specific date
  Future<bool> logSymptoms({
    required DateTime date,
    required Map<String, int> symptoms,
    double? sleepHours,
    int? stressLevel,
    String? notes,
  }) async {
    try {
      await _apiService.logSymptoms(
        date: date.toIso8601String().split('T')[0],
        symptoms: symptoms,
        sleepHours: sleepHours,
        stressLevel: stressLevel,
        notes: notes,
      );
      
      await loadCycles();
      return true;
    } catch (e) {
      _error = 'Error logging symptoms: $e';
      notifyListeners();
      return false;
    }
  }
  
  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  
  /// Get the start date of the most recent period
  DateTime? get lastPeriodStart {
    if (_cycles.isEmpty) return null;
    try {
      final firstCycle = _cycles.first;
      if (firstCycle == null || firstCycle is! Map) return null;
      
      final startDate = firstCycle['startDate'] ?? firstCycle['start_date'];
      if (startDate != null) {
        return DateTime.parse(startDate.toString());
      }
    } catch (e) {
      // Ignore parse errors
    }
    return null;
  }
  
  
  /// Get total number of cycles tracked
  int get totalCycles => _cycles.length;
  
  /// Get current cycle phase (follicular, ovulation, luteal, menstruation)
  String get currentPhase {
    if (_currentInsights == null) return 'unknown';
    return _currentInsights!['currentPhase'] ?? 
           _currentInsights!['current_phase'] ?? 
           'unknown';
  }
  
  /// Get days since the start of current cycle
  int get daysSinceStart {
    if (_currentInsights == null) return 0;
    return _currentInsights!['daysSinceStart'] ?? 
           _currentInsights!['days_since_start'] ?? 
           0;
  }
  
  /// Get the current active cycle (if any)
  Map<String, dynamic>? get currentCycle {
    if (_cycles.isEmpty) return null;
    
    try {
      for (var cycle in _cycles) {
        final endDate = cycle['endDate'] ?? cycle['end_date'];
        if (endDate == null) {
          return cycle;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Check if there's an active cycle
  bool get hasActiveCycle => currentCycle != null;
  
  /// Get predicted next period date
  DateTime? get predictedNextPeriod {
    if (_currentInsights == null) return null;
    
    try {
      final predictions = _currentInsights!['predictions'];
      if (predictions != null) {
        final nextPeriod = predictions['nextPeriodDate'] ?? predictions['next_period_date'];
        if (nextPeriod != null) {
          return DateTime.parse(nextPeriod);
        }
      }
    } catch (e) {
      // Ignore parse errors
    }
    return null;
  }
  
  /// Get average cycle length
  double? get averageCycleLength {
    if (_currentInsights == null) return null;
    
    final stats = _currentInsights!['statistics'];
    if (stats != null) {
      final avgLength = stats['averageCycleLength'] ?? stats['average_cycle_length'];
      return avgLength?.toDouble();
    }
    return null;
  }
  
  /// Get cycle regularity score
  double? get regularityScore {
    if (_currentInsights == null) return null;
    
    final stats = _currentInsights!['statistics'];
    if (stats != null) {
      final regularity = stats['regularityScore'] ?? stats['regularity_score'];
      return regularity?.toDouble();
    }
    return null;
  }
  
  /// Clear all data (useful for logout)
  void clear() {
    _cycles = [];
    _currentInsights = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}