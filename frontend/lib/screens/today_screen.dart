// File: frontend/lib/screens/today_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/cycle_provider.dart';
import '../theme/app_theme.dart';

class TodayScreen extends StatefulWidget {
  @override
  _TodayScreenState createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: AppTheme.slow,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  String _getPhaseEmoji(String phase) {
    switch (phase) {
      case 'menstrual':
        return '🌙';
      case 'follicular':
        return '🌱';
      case 'ovulation':
        return '🌸';
      case 'luteal':
        return '🍂';
      default:
        return '💫';
    }
  }
  
  String _getPhaseName(String phase) {
    switch (phase) {
      case 'menstrual':
        return 'Menstrual Phase';
      case 'follicular':
        return 'Follicular Phase';
      case 'ovulation':
        return 'Ovulation Phase';
      case 'luteal':
        return 'Luteal Phase';
      default:
        return 'Getting Started';
    }
  }
  
  String _getPhaseDescription(String phase) {
    switch (phase) {
      case 'menstrual':
        return 'Your period is here. Take it easy and rest when needed.';
      case 'follicular':
        return 'Energy is building. Great time for new activities.';
      case 'ovulation':
        return 'Peak energy and confidence. Make the most of it!';
      case 'luteal':
        return 'Body is preparing. Practice self-care.';
      default:
        return 'Start logging to see insights about your cycle.';
    }
  }
  
  List<String> _getPhaseTips(String phase) {
    switch (phase) {
      case 'menstrual':
        return [
          '💧 Stay hydrated',
          '🧘 Try gentle yoga',
          '🔥 Use heat for cramps',
        ];
      case 'follicular':
        return [
          '⚡ Perfect for workouts',
          '🎯 Start new projects',
          '👥 Social time!',
        ];
      case 'ovulation':
        return [
          '💪 Peak performance',
          '🗣️ Great for meetings',
          '✨ Feeling confident',
        ];
      case 'luteal':
        return [
          '🛀 Extra self-care',
          '🥗 Healthy eating',
          '😌 Be patient with yourself',
        ];
      default:
        return [];
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.almostWhite,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final provider = Provider.of<CycleProvider>(context, listen: false);
            await provider.loadCurrentInsights();
            await provider.loadCycles();
            
            _animationController.reset();
            _animationController.forward();
          },
          color: AppTheme.primaryPink,
          child: Consumer<CycleProvider>(
            builder: (context, cycleProvider, child) {
              final insights = cycleProvider.currentInsights;
              final hasData = insights?['hasData'] ?? false;
              
              if (cycleProvider.isLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPink),
                  ),
                );
              }
              
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(AppTheme.spaceL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        
                        SizedBox(height: AppTheme.spaceXL),
                        
                        if (hasData) ...[
                          _buildPhaseCard(cycleProvider),
                          
                          SizedBox(height: AppTheme.spaceL),
                          
                          _buildPhaseTips(cycleProvider.currentPhase),
                          
                          SizedBox(height: AppTheme.spaceL),
                          
                          if (insights?['prediction'] != null)
                            _buildPredictionCard(insights!),
                          
                          SizedBox(height: AppTheme.spaceL),
                          
                          _buildCycleStats(insights),
                        ] else ...[
                          _buildWelcomeCard(),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today',
          style: Theme.of(context).textTheme.displayLarge,
        ),
        SizedBox(height: AppTheme.spaceS),
        Text(
          DateFormat('EEEE, MMMM d').format(DateTime.now()),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
  
  Widget _buildPhaseCard(CycleProvider provider) {
    final phase = provider.currentPhase;
    
    return Hero(
      tag: 'phase_card',
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppTheme.spaceL),
          decoration: BoxDecoration(
            gradient: AppTheme.phaseGradient(phase),
            borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryPink.withOpacity(0.3),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: AppTheme.slow,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Text(
                      _getPhaseEmoji(phase),
                      style: TextStyle(fontSize: 80 * value),
                    ),
                  );
                },
              ),
              
              SizedBox(height: AppTheme.spaceM),
              
              Text(
                _getPhaseName(phase),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: AppTheme.spaceS),
              
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceM,
                  vertical: AppTheme.spaceS,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Text(
                  'Day ${provider.daysSinceStart} of your cycle',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              SizedBox(height: AppTheme.spaceM),
              
              Text(
                _getPhaseDescription(phase),
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.95),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPhaseTips(String phase) {
    final tips = _getPhaseTips(phase);
    
    if (tips.isEmpty) return SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spaceL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tips_and_updates, color: AppTheme.primaryPink),
                SizedBox(width: AppTheme.spaceS),
                Text(
                  'Tips for Today',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            SizedBox(height: AppTheme.spaceM),
            ...tips.map((tip) => Padding(
              padding: EdgeInsets.only(bottom: AppTheme.spaceS),
              child: Row(
                children: [
                  SizedBox(width: AppTheme.spaceS),
                  Expanded(
                    child: Text(
                      tip,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPredictionCard(Map<String, dynamic> insights) {
    final prediction = insights['prediction'];
    if (prediction == null) return SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spaceL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: AppTheme.primaryPink),
                SizedBox(width: AppTheme.spaceS),
                Text(
                  'Next Period Prediction',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            
            SizedBox(height: AppTheme.spaceM),
            
            Text(
              'Expected around',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            
            SizedBox(height: AppTheme.spaceXS),
            
            Text(
              DateFormat('MMMM d, yyyy').format(
                DateTime.parse(prediction['nextPeriodDate']),
              ),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryPink,
              ),
            ),
            
            SizedBox(height: AppTheme.spaceM),
            
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    child: LinearProgressIndicator(
                      value: (prediction['confidence'] as num?)?.toDouble() ?? 0.5,
                      backgroundColor: AppTheme.blushPink,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPink),
                      minHeight: 8,
                    ),
                  ),
                ),
                SizedBox(width: AppTheme.spaceM),
                Text(
                  '${((prediction['confidence'] as num) * 100).toInt()}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryPink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: AppTheme.spaceS),
            
            Text(
              'Based on your past ${insights['totalCycles'] ?? 0} cycles',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCycleStats(Map<String, dynamic>? insights) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spaceL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Cycle Stats',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            
            SizedBox(height: AppTheme.spaceL),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '${insights?['avgCycleLength'] ?? 28}',
                    'Avg Length',
                    Icons.calendar_month,
                  ),
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: AppTheme.divider,
                ),
                Expanded(
                  child: _buildStatItem(
                    '${insights?['totalCycles'] ?? 0}',
                    'Cycles Logged',
                    Icons.trending_up,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryPink, size: 28),
        SizedBox(height: AppTheme.spaceS),
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryPink,
          ),
        ),
        SizedBox(height: AppTheme.spaceXS),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.spaceXL),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.white,
          ),
          
          SizedBox(height: AppTheme.spaceL),
          
          Text(
            'Welcome to Solaris!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: AppTheme.spaceM),
          
          Text(
            'Start logging your cycle to see personalized insights and predictions.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: AppTheme.spaceXL),
          
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to log screen (index 1)
              if (context.findAncestorStateOfType<State>() != null) {
                // This will be handled by the home screen's bottom navigation
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryPink,
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.spaceXL,
                vertical: AppTheme.spaceM,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
            icon: Icon(Icons.add_circle_outline),
            label: Text(
              'Log Your First Period',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}