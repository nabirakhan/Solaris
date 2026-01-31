// File: frontend/lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cycle_provider.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.almostWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Consumer2<AuthProvider, CycleProvider>(
            builder: (context, authProvider, cycleProvider, child) {
              final user = authProvider.user;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  
                  SizedBox(height: 24),
                  
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppTheme.blushPink,
                            child: Text(
                              user?['name']?[0].toUpperCase() ?? 'U',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryPink,
                              ),
                            ),
                          ),
                          
                          SizedBox(width: 20),
                          
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?['name'] ?? 'User',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  user?['email'] ?? '',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  Text(
                    'Your Stats',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  
                  SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Text(
                                  '${cycleProvider.totalCycles}',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryPink,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Cycles Logged',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Text(
                                  '${cycleProvider.currentInsights?['avgCycleLength'] ?? 28}',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryPink,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Avg Cycle',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 24),
                  
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  
                  SizedBox(height: 16),
                  
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.analytics_outlined, color: AppTheme.primaryPink),
                          title: Text('Request AI Analysis'),
                          subtitle: Text('Get updated insights'),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () async {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPink),
                                ),
                              ),
                            );
                            
                            await cycleProvider.requestAIAnalysis();
                            
                            Navigator.of(context).pop();
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Analysis complete!'),
                                backgroundColor: AppTheme.primaryPink,
                              ),
                            );
                          },
                        ),
                        Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.notifications_outlined, color: AppTheme.primaryPink),
                          title: Text('Notifications'),
                          subtitle: Text('Manage reminders'),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () {
                            // TODO: Implement notifications settings
                          },
                        ),
                        Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.privacy_tip_outlined, color: AppTheme.primaryPink),
                          title: Text('Privacy'),
                          subtitle: Text('Your data is secure'),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () {
                            // TODO: Implement privacy settings
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  
                  SizedBox(height: 16),
                  
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.info_outlined, color: AppTheme.primaryPink),
                          title: Text('About This App'),
                          subtitle: Text('Learn more'),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Period Tracker'),
                                content: Text(
                                  'AI-powered period tracking app for understanding your body\'s patterns.\n\nVersion 1.0.0',
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
                        ),
                        Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.help_outlined, color: AppTheme.primaryPink),
                          title: Text('Help & Support'),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () {
                            // TODO: Implement help
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        await authProvider.logout();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.primaryPink),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Log Out',
                        style: TextStyle(
                          color: AppTheme.primaryPink,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}