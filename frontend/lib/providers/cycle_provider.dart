// File: frontend/lib/providers/cycle_provider.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CycleProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<dynamic> _cycles = [];
  List<dynamic> _periodDays = [];
  Map<String, dynamic>? _currentInsights;
  bool _isLoading = false;
  String? _error;
  
  List<dynamic> get cycles => _cycles;
  List<dynamic> get periodDays => _periodDays;
  Map<String, dynamic>? get currentInsights => _currentInsights;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // ✅ ADDED: Missing properties for TodayScreen
  int get totalCycles => _cycles.length;
  
  double? get averageCycleLength {
    if (_cycles.isEmpty) return null;
    
    try {
      // Calculate average length from completed cycles
      final completedCycles = _cycles.where((cycle) {
        final endDate = cycle['end_date'] ?? cycle['endDate'];
        return endDate != null;
      }).toList();
      
      if (completedCycles.isEmpty) return null;
      
      double totalDays = 0;
      for (final cycle in completedCycles) {
        final startDate = DateTime.parse(cycle['startDate'] ?? cycle['start_date']);
        final endDate = DateTime.parse(cycle['endDate'] ?? cycle['end_date']);
        totalDays += endDate.difference(startDate).inDays + 1;
      }
      
      return totalDays / completedCycles.length;
    } catch (e) {
      print('❌ Error calculating average cycle length: $e');
      return null;
    }
  }
  
  // ✅ ADDED: Regularity score calculation
  double? get regularityScore {
    if (_cycles.length < 2) return null;
    
    try {
      // Calculate cycle lengths
      final completedCycles = _cycles.where((cycle) {
        final endDate = cycle['end_date'] ?? cycle['endDate'];
        return endDate != null;
      }).toList();
      
      if (completedCycles.length < 2) return 0.5; // Default score for limited data
      
      final lengths = <int>[];
      DateTime? prevEndDate;
      
      // Sort cycles by start date
      completedCycles.sort((a, b) {
        final aStart = DateTime.parse(a['startDate'] ?? a['start_date']);
        final bStart = DateTime.parse(b['startDate'] ?? b['start_date']);
        return aStart.compareTo(bStart);
      });
      
      for (final cycle in completedCycles) {
        final startDate = DateTime.parse(cycle['startDate'] ?? cycle['start_date']);
        final endDate = DateTime.parse(cycle['endDate'] ?? cycle['end_date']);
        
        // Calculate cycle length in days
        final length = endDate.difference(startDate).inDays + 1;
        lengths.add(length);
        
        // Calculate gap between cycles if we have previous cycle
        if (prevEndDate != null) {
          final gap = startDate.difference(prevEndDate).inDays;
          if (gap > 0) {
            lengths.add(gap); // Consider gaps as part of regularity
          }
        }
        
        prevEndDate = endDate;
      }
      
      // Calculate standard deviation
      final mean = lengths.reduce((a, b) => a + b) / lengths.length;
      final variance = lengths.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / lengths.length;
      final stdDev = sqrt(variance);
      
      // Convert to a score between 0 and 1 (lower stdDev = more regular)
      // Assuming typical cycle variation: stdDev < 7 days is quite regular
      final maxExpectedStdDev = 10.0;
      final score = 1.0 - (stdDev / maxExpectedStdDev).clamp(0.0, 1.0);
      
      return score;
    } catch (e) {
      print('❌ Error calculating regularity score: $e');
      return 0.5; // Default neutral score
    }
  }
  
  // ✅ ADDED: Days since start calculation for TodayScreen
  int get daysSinceStart {
    if (!hasActiveCycle) return 0;
    
    try {
      final currentCycle = this.currentCycle;
      if (currentCycle == null) return 0;
      
      final startDateStr = currentCycle['startDate'] ?? currentCycle['start_date'];
      if (startDateStr == null) return 0;
      
      final startDate = DateTime.parse(startDateStr.toString());
      final now = DateTime.now();
      
      // Calculate days difference
      final difference = now.difference(startDate).inDays;
      
      // Return at least 1 if we're in a cycle
      return difference + 1;
    } catch (e) {
      print('❌ Error calculating days since start: $e');
      return 1; // Default to day 1
    }
  }
  
  // ✅ ADDED: Current phase detection for TodayScreen
  String get currentPhase {
    if (!hasActiveCycle) return 'unknown';
    
    try {
      final daysSince = daysSinceStart;
      
      // Simplified phase detection based on cycle day
      if (daysSince <= 5) return 'menstrual';
      if (daysSince <= 11) return 'follicular';
      if (daysSince <= 17) return 'ovulation';
      return 'luteal';
    } catch (e) {
      print('❌ Error detecting current phase: $e');
      return 'unknown';
    }
  }
  
  // ✅ FIX: Better null handling
  bool get hasActiveCycle {
    if (_cycles.isEmpty) return false;
    try {
      return _cycles.any((cycle) => 
        cycle['end_date'] == null || cycle['endDate'] == null
      );
    } catch (e) {
      print('❌ Error checking active cycle: $e');
      return false;
    }
  }
  
  // ✅ FIX: Safer currentCycle getter with null handling
  Map<String, dynamic>? get currentCycle {
    if (_cycles.isEmpty) return null;
    try {
      return _cycles.firstWhere(
        (cycle) => cycle['end_date'] == null || cycle['endDate'] == null,
        orElse: () => null,
      );
    } catch (e) {
      print('❌ Error getting current cycle: $e');
      return null;
    }
  }

  // ✅ ADDED: Request AI analysis method for TodayScreen
  Future<bool> requestAIAnalysis() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Trigger AI analysis
      final insights = await _apiService.requestAIAnalysis();
      
      if (insights != null) {
        _currentInsights = insights;
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to get AI analysis';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error requesting AI analysis: $e';
      _isLoading = false;
      notifyListeners();
      print('❌ Error requesting AI analysis: $e');
      return false;
    }
  }

  // ✅ ADDED: Add day to existing cycle method for CycleManagementScreen
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
      // First, log the period day
      final dateString = date.toIso8601String();
      await _apiService.logPeriodDay(
        date: dateString,
        flow: flow,
        notes: notes,
      );
      
      // If this is the first day of a new cycle, we need to update the cycle
      // Check if there's already a period day on this date
      final existingDays = _periodDays.where((day) {
        final dayDate = DateTime.parse(day['date']).toLocal();
        return dayDate.year == date.year &&
               dayDate.month == date.month &&
               dayDate.day == date.day;
      }).toList();
      
      // If no existing period day for this date, it might be a new cycle
      if (existingDays.isEmpty) {
        // Check if we need to end the current cycle
        final currentCycle = this.currentCycle;
        if (currentCycle != null) {
          final currentCycleId = currentCycle['_id'] ?? currentCycle['id'];
          if (currentCycleId == cycleId) {
            // This is adding to current active cycle - no need to end it
          } else {
            // This might be starting a new cycle while another is active
            // For simplicity, we'll just log the day
            print('⚠️ Adding day to different cycle - current cycle remains active');
          }
        }
      }
      
      // Reload data
      await loadPeriodDays();
      await loadCycles();
      await loadCurrentInsights();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error adding day to cycle: $e';
      _isLoading = false;
      notifyListeners();
      print('❌ Error adding day to cycle: $e');
      return false;
    }
  }

  // ... rest of your existing methods remain the same ...

  /// Load all period days for the current user
  Future<void> loadPeriodDays() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.getPeriodDays();
      _periodDays = response['periodDays'] ?? [];
      _error = null;
    } catch (e) {
      _error = 'Error loading period days: $e';
      _periodDays = [];
      print('❌ Error loading period days: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Load all cycles for the current user
  Future<void> loadCycles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // ✅ FIX: Clear cycles before loading to prevent stale data
      _cycles = [];
      notifyListeners();
      
      _cycles = await _apiService.getCycles();
      _error = null;
      print('✅ Loaded ${_cycles.length} cycles');
    } catch (e) {
      _error = 'Error loading cycles: $e';
      _cycles = [];
      print('❌ Error loading cycles: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Log a single period day (simplified approach)
  Future<bool> logPeriodDay(DateTime date, String flow, String? notes) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Convert DateTime to ISO string for API
      final dateString = date.toIso8601String();
      
      await _apiService.logPeriodDay(
        date: dateString,
        flow: flow,
        notes: notes,
      );
      
      // Reload period days and cycles
      await loadPeriodDays();
      await loadCycles();
      await loadCurrentInsights();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error logging period day: $e';
      _isLoading = false;
      notifyListeners();
      print('❌ Error logging period day: $e');
      return false;
    }
  }

  /// Update a period day
  Future<bool> updatePeriodDay(String dayId, {
    String? flow,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _apiService.updatePeriodDay(
        id: dayId,
        flow: flow,
        notes: notes,
      );
      
      await loadPeriodDays();
      await loadCycles();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error updating period day: $e';
      _isLoading = false;
      notifyListeners();
      print('❌ Error updating period day: $e');
      return false;
    }
  }

  /// Delete a period day
  Future<bool> deletePeriodDay(String dayId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _apiService.deletePeriodDay(dayId);
      
      await loadPeriodDays();
      await loadCycles();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error deleting period day: $e';
      _isLoading = false;
      notifyListeners();
      print('❌ Error deleting period day: $e');
      return false;
    }
  }
  
  /// Start a new menstrual cycle (legacy method - kept for compatibility)
  Future<bool> startNewCycle(DateTime startDate, String flow, String? notes) async {
    return await logPeriodDay(startDate, flow, notes);
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
      print('❌ Error ending cycle: $e');
      return false;
    }
  }

  /// Delete a cycle completely
  /// ✅ FIX: Clear cycles list before API call and reload to prevent stale data
  Future<bool> deleteCycle(String cycleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // ✅ FIX: Remove the cycle from local state immediately
      _cycles.removeWhere((cycle) => 
        (cycle['id'] == cycleId) || (cycle['_id'] == cycleId)
      );
      notifyListeners();
      
      // Call API to delete
      await _apiService.deleteCycle(cycleId);
      
      // Force reload from server to get fresh data
      await loadCycles();
      await loadPeriodDays();
      await loadCurrentInsights();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error deleting cycle: $e';
      _isLoading = false;
      // Reload on error to ensure consistency
      await loadCycles();
      notifyListeners();
      print('❌ Error deleting cycle: $e');
      return false;
    }
  }

  /// Log symptoms for a specific date
  Future<bool> logSymptoms({
    required DateTime date,
    required Map<String, int> symptoms,
    required double sleepHours,
    required int stressLevel,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _apiService.logSymptoms(
        date: date.toIso8601String(),
        symptoms: symptoms,
        sleepHours: sleepHours,
        stressLevel: stressLevel,
        notes: notes,
      );
      
      await loadCurrentInsights();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error logging symptoms: $e';
      _isLoading = false;
      notifyListeners();
      print('❌ Error logging symptoms: $e');
      return false;
    }
  }

  /// Update symptoms for a specific log
  Future<bool> updateSymptoms({
    required String symptomId,
    Map<String, int>? symptoms,
    double? sleepHours,
    int? stressLevel,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _apiService.updateSymptoms(
        id: symptomId,
        symptoms: symptoms,
        sleepHours: sleepHours,
        stressLevel: stressLevel,
        notes: notes,
      );
      
      await loadCurrentInsights();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error updating symptoms: $e';
      _isLoading = false;
      notifyListeners();
      print('❌ Error updating symptoms: $e');
      return false;
    }
  }

  /// Delete a symptom log
  Future<bool> deleteSymptoms(String symptomId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _apiService.deleteSymptoms(symptomId);
      
      await loadCurrentInsights();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error deleting symptoms: $e';
      _isLoading = false;
      notifyListeners();
      print('❌ Error deleting symptoms: $e');
      return false;
    }
  }

  /// Load current cycle insights from AI service
  Future<void> loadCurrentInsights() async {
    try {
      _currentInsights = await _apiService.getCurrentInsights();
      notifyListeners();
    } catch (e) {
      _error = 'Error loading insights: $e';
      _currentInsights = null;
      print('❌ Error loading insights: $e');
      notifyListeners();
    }
  }

  /// ✅ FIX: Added clear method - Called by privacy_screen.dart
  void clearData() {
    _cycles = [];
    _periodDays = [];
    _currentInsights = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
    print('✅ Cycle data cleared');
  }
  
  /// ✅ ALIAS: For backwards compatibility
  void clear() {
    clearData();
  }

  /// Get period days for a specific date
  List<dynamic> getPeriodDaysForDate(DateTime date) {
    final dateStr = date.toIso8601String().split('T')[0];
    return _periodDays.where((day) {
      final dayDateStr = day['date'].toString().split('T')[0];
      return dayDateStr == dateStr;
    }).toList();
  }

  /// Check if a date has period logged
  bool hasPeriodOnDate(DateTime date) {
    return getPeriodDaysForDate(date).isNotEmpty;
  }
}