import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/api_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  final ApiService _apiService = ApiService();
  
  bool _periodRemindersEnabled = false;
  bool _ovulationRemindersEnabled = false;
  bool _dailyRemindersEnabled = false;
  bool _insightsRemindersEnabled = false;
  bool _anomalyRemindersEnabled = false;
  bool _isLoading = false;
  
  bool get periodRemindersEnabled => _periodRemindersEnabled;
  bool get ovulationRemindersEnabled => _ovulationRemindersEnabled;
  bool get dailyRemindersEnabled => _dailyRemindersEnabled;
  bool get insightsRemindersEnabled => _insightsRemindersEnabled;
  bool get anomalyRemindersEnabled => _anomalyRemindersEnabled;
  bool get isLoading => _isLoading;
  
  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final settings = await _apiService.getNotificationSettings();
      
      _periodRemindersEnabled = settings['periodReminders'] ?? false;
      _ovulationRemindersEnabled = settings['ovulationReminders'] ?? false;
      _dailyRemindersEnabled = settings['dailyReminders'] ?? false;
      _insightsRemindersEnabled = settings['insightsReminders'] ?? false;
      _anomalyRemindersEnabled = settings['anomalyReminders'] ?? false;
    } catch (e) {
      print('Error loading notification settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> togglePeriodReminders(bool value) async {
    _periodRemindersEnabled = value;
    notifyListeners();
    await _saveSettings();
  }
  
  Future<void> toggleOvulationReminders(bool value) async {
    _ovulationRemindersEnabled = value;
    notifyListeners();
    await _saveSettings();
  }
  
  Future<void> toggleDailyReminders(bool value) async {
    _dailyRemindersEnabled = value;
    notifyListeners();
    await _saveSettings();
  }
  
  Future<void> toggleInsightsReminders(bool value) async {
    _insightsRemindersEnabled = value;
    notifyListeners();
    await _saveSettings();
  }
  
  Future<void> toggleAnomalyReminders(bool value) async {
    _anomalyRemindersEnabled = value;
    notifyListeners();
    await _saveSettings();
  }
  
  Future<void> setDailyReminderTime(TimeOfDay time) async {
    await _notificationService.scheduleDailyReminder(time);
    await _saveSettings();
  }
  
  Future<void> _saveSettings() async {
    try {
      await _apiService.updateNotificationSettings(
        periodReminders: _periodRemindersEnabled,
        ovulationReminders: _ovulationRemindersEnabled,
        dailyReminders: _dailyRemindersEnabled,
        insightsReminders: _insightsRemindersEnabled,
        anomalyReminders: _anomalyRemindersEnabled,
      );
    } catch (e) {
      print('Error saving notification settings: $e');
    }
  }
  
  Future<void> sendTestNotification() async {
    await _notificationService.showTestNotification();
  }
}