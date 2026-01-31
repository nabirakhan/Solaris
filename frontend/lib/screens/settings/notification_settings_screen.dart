import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/notification_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';

class NotificationSettingsScreen extends StatefulWidget {
  @override
  _NotificationSettingsScreenState createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  TimeOfDay _selectedTime = TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).loadSettings();
    });
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryPink,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
      
      Provider.of<NotificationProvider>(context, listen: false)
          .setDailyReminderTime(_selectedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.almostWhite,
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPink),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manage Your Reminders',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ).animate().fadeIn().slideX(begin: -0.2),
                  
                  SizedBox(height: 8),
                  
                  Text(
                    'Stay on track with timely notifications',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ).animate().fadeIn(delay: 200.ms),
                  
                  SizedBox(height: 32),
                  
                  // Period Reminders
                  GlassCard(
                    margin: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today, color: AppTheme.primaryPink),
                            SizedBox(width: 12),
                            Text(
                              'Period Reminders',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 16),
                        
                        SwitchListTile(
                          title: Text('Upcoming Period'),
                          subtitle: Text('3 days before predicted date'),
                          value: provider.periodRemindersEnabled,
                          activeColor: AppTheme.primaryPink,
                          onChanged: (value) {
                            provider.togglePeriodReminders(value);
                          },
                        ),
                        
                        SwitchListTile(
                          title: Text('Ovulation Alert'),
                          subtitle: Text('When you enter fertile window'),
                          value: provider.ovulationRemindersEnabled,
                          activeColor: AppTheme.primaryPink,
                          onChanged: (value) {
                            provider.toggleOvulationReminders(value);
                          },
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                  
                  SizedBox(height: 20),
                  
                  // Daily Logging Reminder
                  GlassCard(
                    margin: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.edit_notifications, color: AppTheme.primaryPink),
                            SizedBox(width: 12),
                            Text(
                              'Daily Log Reminder',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 16),
                        
                        SwitchListTile(
                          title: Text('Daily Reminder'),
                          subtitle: Text('Log symptoms and mood'),
                          value: provider.dailyRemindersEnabled,
                          activeColor: AppTheme.primaryPink,
                          onChanged: (value) {
                            provider.toggleDailyReminders(value);
                          },
                        ),
                        
                        if (provider.dailyRemindersEnabled)
                          ListTile(
                            leading: Icon(Icons.access_time, color: AppTheme.primaryPink),
                            title: Text('Reminder Time'),
                            subtitle: Text(_selectedTime.format(context)),
                            trailing: Icon(Icons.chevron_right),
                            onTap: _selectTime,
                          ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
                  
                  SizedBox(height: 20),
                  
                  // Insights & Analysis
                  GlassCard(
                    margin: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.insights, color: AppTheme.primaryPink),
                            SizedBox(width: 12),
                            Text(
                              'Insights & Analysis',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 16),
                        
                        SwitchListTile(
                          title: Text('Weekly Insights'),
                          subtitle: Text('AI-powered pattern analysis'),
                          value: provider.insightsRemindersEnabled,
                          activeColor: AppTheme.primaryPink,
                          onChanged: (value) {
                            provider.toggleInsightsReminders(value);
                          },
                        ),
                        
                        SwitchListTile(
                          title: Text('Anomaly Alerts'),
                          subtitle: Text('Unusual cycle changes'),
                          value: provider.anomalyRemindersEnabled,
                          activeColor: AppTheme.primaryPink,
                          onChanged: (value) {
                            provider.toggleAnomalyReminders(value);
                          },
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),
                  
                  SizedBox(height: 32),
                  
                  // Test Notification Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await provider.sendTestNotification();
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Test notification sent!'),
                            backgroundColor: AppTheme.primaryPink,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.send),
                      label: Text('Send Test Notification'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppTheme.primaryPink,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 1000.ms),
                  
                  SizedBox(height: 100),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}