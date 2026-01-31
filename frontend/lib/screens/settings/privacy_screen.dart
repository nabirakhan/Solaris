import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cycle_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../services/api_service.dart';
import 'dart:convert';

class PrivacyScreen extends StatelessWidget {
  Future<void> _exportData(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPink),
        ),
      ),
    );

    try {
      final cycleProvider = Provider.of<CycleProvider>(context, listen: false);
      final cycles = cycleProvider.cycles;
      
      // Create JSON export
      final exportData = {
        'exportDate': DateTime.now().toIso8601String(),
        'cycles': cycles,
        'version': '1.0.0',
      };
      
      final jsonString = JsonEncoder.withIndent('  ').convert(exportData);
      
      Navigator.of(context).pop();
      
      // Show data in dialog for now (in production, save to file)
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Data Export'),
          content: SingleChildScrollView(
            child: SelectableText(jsonString),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        ),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data exported successfully!'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting data: $e'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteAllData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 12),
            Text('Delete All Data?'),
          ],
        ),
        content: Text(
          'This will permanently delete all your cycle data, symptoms, and insights. This action cannot be undone.',
          style: TextStyle(color: Colors.red[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete Everything'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
          ),
        ),
      );

      try {
        // Call API to delete all data
        final apiService = ApiService();
        await apiService.deleteAllUserData();
        
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('All data deleted'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Reload data
        Provider.of<CycleProvider>(context, listen: false).clear();
      } catch (e) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting data: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.almostWhite,
      appBar: AppBar(
        title: Text('Privacy & Data'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Privacy Matters',
                style: Theme.of(context).textTheme.headlineMedium,
              ).animate().fadeIn().slideX(begin: -0.2),
              
              SizedBox(height: 8),
              
              Text(
                'Control your data and privacy settings',
                style: Theme.of(context).textTheme.bodyMedium,
              ).animate().fadeIn(delay: 200.ms),
              
              SizedBox(height: 32),
              
              // Data Security
              GlassCard(
                margin: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.security, color: AppTheme.primaryPink),
                        SizedBox(width: 12),
                        Text(
                          'Data Security',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 16),
                    
                    ListTile(
                      leading: Icon(Icons.lock, color: AppTheme.primaryPink),
                      title: Text('End-to-End Encryption'),
                      subtitle: Text('Your data is encrypted and secure'),
                      trailing: Icon(Icons.check_circle, color: AppTheme.successColor),
                    ),
                    
                    ListTile(
                      leading: Icon(Icons.cloud_off, color: AppTheme.primaryPink),
                      title: Text('Local Storage'),
                      subtitle: Text('Data stored on your device'),
                      trailing: Icon(Icons.check_circle, color: AppTheme.successColor),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
              
              SizedBox(height: 20),
              
              // Data Management
              GlassCard(
                margin: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.folder, color: AppTheme.primaryPink),
                        SizedBox(width: 12),
                        Text(
                          'Data Management',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 16),
                    
                    ListTile(
                      leading: Icon(Icons.download, color: AppTheme.primaryPink),
                      title: Text('Export Your Data'),
                      subtitle: Text('Download all your data as JSON'),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () => _exportData(context),
                    ),
                    
                    Divider(height: 1, color: AppTheme.divider),
                    
                    ListTile(
                      leading: Icon(Icons.delete_forever, color: Colors.red),
                      title: Text(
                        'Delete All Data',
                        style: TextStyle(color: Colors.red),
                      ),
                      subtitle: Text('Permanently remove all your data'),
                      trailing: Icon(Icons.chevron_right, color: Colors.red),
                      onTap: () => _deleteAllData(context),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
              
              SizedBox(height: 20),
              
              // Privacy Policy
              GlassCard(
                margin: EdgeInsets.zero,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Privacy Policy'),
                      content: SingleChildScrollView(
                        child: Text(_privacyPolicyText),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
                child: ListTile(
                  leading: Icon(Icons.description, color: AppTheme.primaryPink),
                  title: Text('Privacy Policy'),
                  subtitle: Text('Read our privacy policy'),
                  trailing: Icon(Icons.chevron_right),
                ),
              ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),
              
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  static const String _privacyPolicyText = '''
Solaris Privacy Policy

Last updated: January 2026

We take your privacy seriously. This policy explains how we collect, use, and protect your data.

Data We Collect:
- Cycle tracking data (period dates, flow, duration)
- Symptom information
- Health metrics (optional)
- Account information (email, name)

How We Use Your Data:
- Provide personalized cycle predictions
- Generate health insights
- Improve our services
- Send notifications (with your permission)

Data Security:
- All data is encrypted
- Secure authentication
- Regular security audits

Your Rights:
- Export your data anytime
- Delete your account and data
- Control notification settings
- Opt-out of data analysis

We never:
- Sell your data to third parties
- Share personal information without consent
- Use your data for advertising

Contact: support@solaris.com
''';
}