// File: frontend/lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../providers/cycle_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import 'login_screen.dart';
import 'settings/notification_settings_screen.dart';
import 'settings/privacy_screen.dart';
import 'settings/help_support_screen.dart';
import '../widgets/profile_picture_picker.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.almostWhite,
      body: Stack(
        children: [
          // Animated Background Blobs for Glass Effect
          Positioned(
            top: -100,
            right: -100,
            child: _buildBlob(AppTheme.primaryPink.withOpacity(0.3), 300),
          ),
          Positioned(
            bottom: 100,
            left: -50,
            child: _buildBlob(AppTheme.lightPurple.withOpacity(0.3), 250),
          ),
          Positioned(
            top: 200,
            left: 50,
            child: _buildBlob(AppTheme.lightPink.withOpacity(0.2), 150),
          ),

          SafeArea(
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
                      ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),

                      SizedBox(height: 24),

                      // Profile Card
                      GlassCard(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Row(
                            children: [
                            ProfilePicturePicker(
                              currentImageUrl: user?['photoUrl'] ?? user?['profilePicture'],
                              onImageSelected: (file) async {
                                try {
                                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                  final result = await authProvider.uploadProfilePicture(file);
                                  
                                  if (result != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Profile picture updated!'),
                                        backgroundColor: AppTheme.success,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to update profile picture'),
                                        backgroundColor: AppTheme.error,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: ${e.toString()}'),
                                      backgroundColor: AppTheme.error,
                                    ),
                                  );
                                }
                              },
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
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                      SizedBox(height: 32),

                      // Panda Mascot Section
                      Center(
                        child: Column(
                          children: [
                            Container(
                              height: 140,
                              width: 140,
                              decoration: BoxDecoration(
                                color: AppTheme.lightPink,
                                borderRadius: BorderRadius.circular(70),
                              ),
                              child: Icon(
                                Icons.pets,
                                color: AppTheme.primaryPink,
                                size: 80,
                              ),
                            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                             .moveY(begin: 0, end: -10, duration: 2.seconds, curve: Curves.easeInOut),
                            
                            SizedBox(height: 8),
                            GlassCard(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              borderRadius: 20,
                              color: Colors.white.withOpacity(0.4),
                              child: Text(
                                "I'm tracking your progress! 🐼",
                                style: TextStyle(
                                  color: AppTheme.primaryPink,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ).animate().fadeIn(delay: 1.seconds).scale(),
                          ],
                        ),
                      ),

                      SizedBox(height: 32),

                      Text(
                        'Your Stats',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ).animate().fadeIn(delay: 400.ms),

                      SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: GlassCard(
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
                            ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: GlassCard(
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
                            ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.2),
                          ),
                        ],
                      ),

                      SizedBox(height: 24),

                      Text(
                        'Settings',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ).animate().fadeIn(delay: 700.ms),

                      SizedBox(height: 16),

                      GlassCard(
                        child: Column(
                          children: [
                            _buildSettingTile(
                              context, 
                              Icons.analytics_outlined, 
                              'Request AI Analysis', 
                              'Get updated insights',
                              () async {
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
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                );
                              }
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Divider(height: 1, color: AppTheme.primaryPink.withOpacity(0.2)),
                            ),
                            _buildSettingTile(
                              context, 
                              Icons.notifications_outlined, 
                              'Notifications', 
                              'Manage reminders',
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => NotificationSettingsScreen()),
                                );
                              }
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Divider(height: 1, color: AppTheme.primaryPink.withOpacity(0.2)),
                            ),
                            _buildSettingTile(
                              context, 
                              Icons.privacy_tip_outlined, 
                              'Privacy', 
                              'Your data is secure',
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => PrivacyScreen()),
                                );
                              }
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),

                      SizedBox(height: 24),

                      Text(
                        'About',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ).animate().fadeIn(delay: 900.ms),

                      SizedBox(height: 16),

                      GlassCard(
                        child: Column(
                          children: [
                            _buildSettingTile(
                              context, 
                              Icons.info_outlined, 
                              'About This App', 
                              'Learn more',
                              () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: Colors.white.withOpacity(0.9),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    title: Text('Period Tracker', style: TextStyle(color: AppTheme.primaryPink)),
                                    content: Text(
                                      'AI-powered period tracking app for understanding your body\'s patterns.\n\nVersion 1.0.0',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('Close', style: TextStyle(color: AppTheme.primaryPink)),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Divider(height: 1, color: AppTheme.primaryPink.withOpacity(0.2)),
                            ),
                            _buildSettingTile(
                              context, 
                              Icons.help_outlined, 
                              'Help & Support', 
                              '',
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => HelpSupportScreen()),
                                );
                              }
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.2),

                      SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        child: GlassCard(
                          color: Colors.white.withOpacity(0.3),
                          onTap: () async {
                            await authProvider.logout();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => LoginScreen()),
                            );
                          },
                          child: Center(
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
                      ).animate().fadeIn(delay: 1200.ms),

                      SizedBox(height: 100), // Extra space for scrolling
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 50,
            spreadRadius: 20,
          ),
        ],
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
     .scaleXY(begin: 0.9, end: 1.1, duration: 4.seconds);
  }

  Widget _buildSettingTile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.blushPink.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryPink),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark),
      ),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      trailing: Icon(Icons.chevron_right, color: AppTheme.primaryPink),
      onTap: onTap,
    );
  }
}