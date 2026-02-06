// File: lib/screens/profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../providers/health_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/profile_picture_picker.dart';
import '../widgets/animated_background.dart';
import 'health_metrics_screen.dart';
import 'settings/notification_settings_screen.dart';
import 'settings/privacy_screen.dart';
import 'settings/help_support_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    
    _shimmerController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    )..repeat();
    
    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HealthProvider>(context, listen: false).loadHealthMetrics();
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.almostWhite,
      body: AnimatedGradientBackground(
        duration: Duration(seconds: 5),
        colors: [
          AppTheme.blushPink,
          AppTheme.lightPurple,
          AppTheme.lightPink,
          AppTheme.almostWhite,
        ],
        child: SafeArea(
          child: CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              _buildHeader(),
              
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    
                    _buildProfileCard()
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 200.ms)
                      .slideY(begin: -0.3, curve: Curves.easeOutCubic),
                    
                    SizedBox(height: 24),
                    
                    _buildHealthStats()
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 400.ms)
                      .scale(begin: Offset(0.9, 0.9)),
                    
                    SizedBox(height: 24),
                    
                    _buildSettingsSection()
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 600.ms)
                      .slideX(begin: -0.2),
                    
                    SizedBox(height: 24),
                    
                    _buildActionButtons()
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 800.ms)
                      .slideY(begin: 0.2),
                    
                    SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 60,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryPink.withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileCard() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        final user = auth.user;
        
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: GlassCard(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.all(24),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryPink.withOpacity(0.1),
                    AppTheme.lightPurple.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    // ✅ FIX #2: Use key to force widget rebuild when photoUrl changes
                    ProfilePicturePicker(
                      key: ValueKey(user?['photoUrl'] ?? 'no-photo'),
                      currentImageUrl: user?['photoUrl'],
                      onImageSelected: (File imageFile) async {
                        print('📸 Profile picture selected');
                        
                        // Show loading indicator
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPink),
                            ),
                          ),
                        );
                        
                        final result = await auth.uploadProfilePicture(imageFile);
                        
                        // Close loading dialog
                        if (mounted) Navigator.of(context).pop();
                        
                        if (result != null && mounted) {
                          print('✅ Profile picture uploaded successfully');
                          
                          // ✅ FIX #2: Refresh user data to ensure we have the latest photoUrl
                          await auth.refreshUserData();
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Profile picture updated! ✨'),
                              backgroundColor: AppTheme.successColor,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        } else if (mounted) {
                          print('❌ Profile picture upload failed');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to update profile picture'),
                              backgroundColor: AppTheme.errorColor,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      },
                      size: 120,
                    ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
                    
                    SizedBox(height: 20),
                    
                    Text(
                      user?['name'] ?? 'User',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
                    
                    SizedBox(height: 6),
                    
                    Text(
                      user?['email'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textGray,
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHealthStats() {
    return Consumer<HealthProvider>(
      builder: (context, health, child) {
        final metrics = health.healthMetrics;
        
        if (metrics == null || metrics.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: GlassCard(
              margin: EdgeInsets.zero,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => HealthMetricsScreen()),
                );
              },
              child: Column(
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 48,
                    color: AppTheme.primaryPink.withOpacity(0.5),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Add Health Metrics',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Track your health to get better insights',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Icon(
                    Icons.add_circle,
                    color: AppTheme.primaryPink,
                    size: 32,
                  ),
                ],
              ),
            ),
          );
        }
        
        final bmi = _calculateBMI(metrics);
        final age = _calculateAge(metrics['birthdate']);
        
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Health Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => HealthMetricsScreen()),
                      );
                    },
                    icon: Icon(Icons.edit, size: 16),
                    label: Text('Edit'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryPink,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildHealthStatCard(
                      _formatHeight(metrics),
                      'Height',
                      Icons.height,
                      AppTheme.follicularPhase,
                      0,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildHealthStatCard(
                      metrics['useMetric'] == true 
                          ? '${metrics['weight']?.toInt() ?? 'N/A'} kg'
                          : '${metrics['weight']?.toInt() ?? 'N/A'} lb',
                      'Weight',
                      Icons.monitor_weight,
                      AppTheme.ovulationPhase,
                      100,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildHealthStatCard(
                      bmi != null ? bmi.toStringAsFixed(1) : 'N/A',
                      'BMI',
                      Icons.analytics,
                      _getBMIColor(bmi),
                      200,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHealthStatCard(String value, String label, IconData icon, Color color, int delayMs) {
    return GlassCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textGray,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: Duration(milliseconds: delayMs));
  }

  Widget _buildSettingsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: 16),
          GlassCard(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildSettingsTile(
                  'Notifications',
                  Icons.notifications_outlined,
                  AppTheme.primaryPink,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => NotificationSettingsScreen()),
                    );
                  },
                  0,
                ),
                Divider(height: 1, color: AppTheme.divider),
                _buildSettingsTile(
                  'Privacy & Data',
                  Icons.lock_outlined,
                  AppTheme.primaryPurple,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PrivacyScreen()),
                    );
                  },
                  50,
                ),
                Divider(height: 1, color: AppTheme.divider),
                _buildSettingsTile(
                  'Help & Support',
                  Icons.help_outline,
                  AppTheme.follicularPhase,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => HelpSupportScreen()),
                    );
                  },
                  100,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(String title, IconData icon, Color color, VoidCallback onTap, int delayMs) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppTheme.textDark,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: AppTheme.textGray),
    ).animate().fadeIn(duration: 600.ms, delay: Duration(milliseconds: delayMs));
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildActionButton(
            'Sign Out',
            Icons.logout,
            AppTheme.error,
            () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Text(
                    'Sign Out',
                    style: TextStyle(color: AppTheme.error),
                  ),
                  content: Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: AppTheme.error),
                      child: Text('Sign Out'),
                    ),
                  ],
                ),
              );
              
              if (confirmed == true) {
                await Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 22),
              SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double? _calculateBMI(Map<String, dynamic> metrics) {
    final height = metrics['height'];
    final weight = metrics['weight'];
    final useMetric = metrics['useMetric'] ?? true;
    
    if (height == null || weight == null) return null;
    
    double heightM = useMetric ? height / 100 : height * 30.48 / 100;
    double weightKg = useMetric ? weight.toDouble() : weight * 0.453592;
    
    return weightKg / (heightM * heightM);
  }

  int? _calculateAge(String? birthdate) {
    if (birthdate == null) return null;
    
    try {
      final birth = DateTime.parse(birthdate);
      final now = DateTime.now();
      int age = now.year - birth.year;
      if (now.month < birth.month || (now.month == birth.month && now.day < birth.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return null;
    }
  }

  String _formatHeight(Map<String, dynamic> metrics) {
    final height = metrics['height'];
    final useMetric = metrics['useMetric'] ?? true;
    
    if (height == null) return 'N/A';
    
    if (useMetric) {
      return '${height.toInt()} cm';
    } else {
      return '${height.toStringAsFixed(1)} ft';
    }
  }

  Color _getBMIColor(double? bmi) {
    if (bmi == null) return AppTheme.textGray;
    if (bmi < 18.5) return AppTheme.warning;
    if (bmi < 25) return AppTheme.follicularPhase;
    if (bmi < 30) return AppTheme.warning;
    return AppTheme.error;
  }
}