// File: lib/screens/settings/help_support_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';

class HelpSupportScreen extends StatelessWidget {
  final List<Map<String, dynamic>> _faqs = [
    {
      'question': 'How accurate are the period predictions?',
      'answer': 'Our AI analyzes your cycle history to provide predictions. Accuracy improves with more logged cycles (3+ cycles recommended). Average accuracy is 85-90% after 3 months of tracking.',
    },
    {
      'question': 'Is my data private and secure?',
      'answer': 'Yes! All your data is encrypted and stored securely. We never share your personal information with third parties. You can export or delete your data anytime.',
    },
    {
      'question': 'How do I log my period?',
      'answer': 'Tap the "Log" tab at the bottom, select "Log Period", choose the start date and flow level, then tap Save. Update the end date when your period ends.',
    },
    {
      'question': 'What are the cycle phases?',
      'answer': 'There are 4 phases:\n\n• Menstrual (Days 1-5): Your period\n• Follicular (Days 6-13): Energy building\n• Ovulation (Days 14-17): Peak fertility\n• Luteal (Days 18-28): Body preparing',
    },
    {
      'question': 'How does the cuterus companion work?',
      'answer': 'The custerus mascot changes expressions based on your cycle phase and shows your progress. It provides motivational/emotional messages and makes tracking more fun!',
    },
    {
      'question': 'Can I track symptoms?',
      'answer': 'Yes! In the Log tab, switch to "Log Symptoms" to record cramps, mood, energy, headache, bloating, sleep, and stress levels.',
    },
    {
      'question': 'What is BMI and why track it?',
      'answer': 'BMI (Body Mass Index) is a measure of body fat based on height and weight. Tracking it can help you understand how your body changes and affects your cycle.',
    },
    {
      'question': 'How do I enable notifications?',
      'answer': 'Go to Profile → Settings → Notifications. You can enable period reminders, ovulation alerts, and daily log reminders.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.almostWhite,
      appBar: AppBar(
        title: Text('Help & Support'),
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
                'We\'re Here to Help',
                style: Theme.of(context).textTheme.headlineMedium,
              ).animate().fadeIn().slideX(begin: -0.2),
              
              SizedBox(height: 8),
              
              Text(
                'Find answers and get support',
                style: Theme.of(context).textTheme.bodyMedium,
              ).animate().fadeIn(delay: 200.ms),
              
              SizedBox(height: 32),
              
              // Contact Support
              GlassCard(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.blushPink.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.email, color: AppTheme.primaryPink),
                      ),
                      title: Text('Email Support'),
                      subtitle: Text('support@solaris.com'),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () async {
                        final Uri emailUri = Uri(
                          scheme: 'mailto',
                          path: 'support@solaris.com',
                          query: 'subject=Solaris Support Request',
                        );
                        if (await canLaunchUrl(emailUri)) {
                          await launchUrl(emailUri);
                        }
                      },
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.blushPink.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.chat, color: AppTheme.primaryPink),
                      ),
                      title: Text('Live Chat'),
                      subtitle: Text('Available 9 AM - 5 PM PST'),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Live chat coming soon!'),
                            backgroundColor: AppTheme.primaryPink,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
              
              SizedBox(height: 24),
              
              // FAQ Section
              Text(
                'Frequently Asked Questions',
                style: Theme.of(context).textTheme.titleLarge,
              ).animate().fadeIn(delay: 600.ms),
              
              SizedBox(height: 16),
              
              ..._faqs.asMap().entries.map((entry) {
                final index = entry.key;
                final faq = entry.value;
                
                return GlassCard(
                  margin: EdgeInsets.only(bottom: 16),
                  child: ExpansionTile(
                    title: Text(
                      faq['question'],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.blushPink.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.help_outline,
                        color: AppTheme.primaryPink,
                        size: 20,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          faq['answer'],
                          style: TextStyle(
                            color: AppTheme.textGray,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: Duration(milliseconds: 700 + (index * 100)))
                  .fadeIn()
                  .slideY(begin: 0.2);
              }).toList(),
              
              SizedBox(height: 24),
              
              // Tutorial Videos
              Text(
                'Tutorial Videos',
                style: Theme.of(context).textTheme.titleLarge,
              ).animate().fadeIn(delay: 1000.ms),
              
              SizedBox(height: 16),
              
              GlassCard(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildTutorialTile(
                      'Getting Started',
                      'Learn the basics of Solaris',
                      Icons.play_circle_outline,
                      () => _showTutorialPlaceholder(context, 'Getting Started'),
                    ),
                    Divider(height: 1),
                    _buildTutorialTile(
                      'Understanding Your Cycle',
                      'Deep dive into cycle phases',
                      Icons.play_circle_outline,
                      () => _showTutorialPlaceholder(context, 'Understanding Your Cycle'),
                    ),
                    Divider(height: 1),
                    _buildTutorialTile(
                      'Using AI Insights',
                      'Make the most of predictions',
                      Icons.play_circle_outline,
                      () => _showTutorialPlaceholder(context, 'Using AI Insights'),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.2),
              
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTutorialTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.blushPink.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primaryPink),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showTutorialPlaceholder(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Coming Soon', style: TextStyle(color: AppTheme.primaryPink)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.video_library_outlined, size: 60, color: AppTheme.blushPink),
            SizedBox(height: 16),
            Text(
              'The video "$title" is currently in production. Check back later!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textGray),
            ),
          ],
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
}