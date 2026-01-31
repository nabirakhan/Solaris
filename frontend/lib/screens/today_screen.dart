// File: lib/screens/today_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/cycle_provider.dart';
import '../providers/health_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/panda_mascot.dart';
import '../widgets/glass_card.dart';
import '../widgets/recommendation_card.dart';
import 'home_screen.dart';

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
        return 'Energy is building. Great time for new activities!';
      case 'ovulation':
        return 'Peak energy and confidence. Make the most of it!';
      case 'luteal':
        return 'Body is preparing. Practice self-care.';
      default:
        return 'Start logging to see insights about your cycle.';
    }
  }
  
  List<Map<String, dynamic>> _getRecommendations(String phase, Map<String, dynamic>? healthData) {
    final baseRecommendations = _getPhaseRecommendations(phase);
    final healthRecommendations = _getHealthBasedRecommendations(healthData);
    
    return [...baseRecommendations, ...healthRecommendations];
  }
  
  List<Map<String, dynamic>> _getPhaseRecommendations(String phase) {
    switch (phase) {
      case 'menstrual':
        return [
          {
            'icon': Icons.water_drop,
            'title': 'Stay Hydrated',
            'description': 'Drink 8-10 glasses of water to reduce bloating',
            'color': const Color(0xFF64B5F6),
          },
          {
            'icon': Icons.self_improvement,
            'title': 'Gentle Yoga',
            'description': 'Try restorative poses to ease cramps',
            'color': const Color(0xFF81C784),
          },
          {
            'icon': Icons.local_fire_department,
            'title': 'Heat Therapy',
            'description': 'Use a heating pad for 15-20 minutes',
            'color': const Color(0xFFFFB74D),
          },
          {
            'icon': Icons.restaurant,
            'title': 'Iron-Rich Foods',
            'description': 'Eat spinach, lentils, and lean meats',
            'color': const Color(0xFFE57373),
          },
        ];
        
      case 'follicular':
        return [
          {
            'icon': Icons.fitness_center,
            'title': 'High-Intensity Workouts',
            'description': 'Perfect time for HIIT and strength training',
            'color': const Color(0xFFFF7043),
          },
          {
            'icon': Icons.lightbulb,
            'title': 'Start New Projects',
            'description': 'Your focus and creativity are peaking',
            'color': const Color(0xFFFFCA28),
          },
          {
            'icon': Icons.group,
            'title': 'Social Activities',
            'description': 'Great energy for meeting friends',
            'color': const Color(0xFF9575CD),
          },
          {
            'icon': Icons.apple,
            'title': 'Balanced Nutrition',
            'description': 'Focus on complex carbs and lean proteins',
            'color': const Color(0xFF66BB6A),
          },
        ];
        
      case 'ovulation':
        return [
          {
            'icon': Icons.psychology,
            'title': 'Important Meetings',
            'description': 'Peak confidence and communication skills',
            'color': const Color(0xFF5C6BC0),
          },
          {
            'icon': Icons.favorite,
            'title': 'Romantic Time',
            'description': 'Natural peak in libido and connection',
            'color': const Color(0xFFEC407A),
          },
          {
            'icon': Icons.directions_run,
            'title': 'Cardio Workouts',
            'description': 'Maximum energy and stamina',
            'color': const Color(0xFFFF7043),
          },
          {
            'icon': Icons.emoji_people,
            'title': 'Be Social',
            'description': 'You\'re naturally more outgoing now',
            'color': const Color(0xFF26A69A),
          },
        ];
        
      case 'luteal':
        return [
          {
            'icon': Icons.spa,
            'title': 'Extra Self-Care',
            'description': 'Prioritize rest and relaxation',
            'color': const Color(0xFF9575CD),
          },
          {
            'icon': Icons.restaurant_menu,
            'title': 'Healthy Snacks',
            'description': 'Choose complex carbs to stabilize mood',
            'color': const Color(0xFF66BB6A),
          },
          {
            'icon': Icons.bed,
            'title': 'Quality Sleep',
            'description': 'Aim for 8-9 hours of sleep',
            'color': const Color(0xFF5C6BC0),
          },
          {
            'icon': Icons.sentiment_satisfied,
            'title': 'Be Patient',
            'description': 'PMS symptoms are normal and temporary',
            'color': const Color(0xFFFFCA28),
          },
        ];
        
      default:
        return [];
    }
  }
  
  List<Map<String, dynamic>> _getHealthBasedRecommendations(Map<String, dynamic>? healthData) {
    final List<Map<String, dynamic>> recommendations = [];
    
    if (healthData != null) {
      final bmi = healthData['bmi'] as double?;
      
      if (bmi != null) {
        if (bmi < 18.5) {
          recommendations.add({
            'icon': Icons.trending_up,
            'title': 'Increase Caloric Intake',
            'description': 'Consider nutrient-dense foods',
            'color': const Color(0xFF26A69A),
          });
        } else if (bmi > 25) {
          recommendations.add({
            'icon': Icons.directions_walk,
            'title': 'Regular Exercise',
            'description': '30 minutes daily walking recommended',
            'color': const Color(0xFF66BB6A),
          });
        }
      }
    }
    
    return recommendations;
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
          child: Consumer2<CycleProvider, HealthProvider>(
            builder: (context, cycleProvider, healthProvider, child) {
              final insights = cycleProvider.currentInsights;
              final hasData = insights?['hasData'] ?? false;
              final phase = cycleProvider.currentPhase;
              final daysSinceStart = cycleProvider.daysSinceStart;
              
              if (cycleProvider.isLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPink),
                      ),
                      const SizedBox(height: 16),
                      const Text('Loading your insights...'),
                    ],
                  ),
                );
              }
              
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppTheme.spaceL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        
                        const SizedBox(height: AppTheme.spaceXL),
                        
                        if (hasData) ...[
                          // Panda Mascot
                          _buildPandaSection(phase, daysSinceStart),
                          
                          const SizedBox(height: AppTheme.spaceL),
                          
                          _buildPhaseCard(cycleProvider),
                          
                          const SizedBox(height: AppTheme.spaceL),
                          
                          _buildRecommendationsSection(phase, healthProvider.healthMetrics),
                          
                          const SizedBox(height: AppTheme.spaceL),
                          
                          if (insights?['prediction'] != null)
                            _buildPredictionCard(insights!),
                          
                          const SizedBox(height: AppTheme.spaceL),
                          
                          _buildCycleStats(insights),
                        ] else ...[
                          _buildWelcomeCard(),
                        ],
                        
                        const SizedBox(height: AppTheme.spaceXXL),
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
        ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
        const SizedBox(height: AppTheme.spaceS),
        Text(
          DateFormat('EEEE, MMMM d').format(DateTime.now()),
          style: Theme.of(context).textTheme.bodyMedium,
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }
  
  Widget _buildPandaSection(String phase, int daysSinceStart) {
    final totalCycleDays = 28;
    final progress = (daysSinceStart / totalCycleDays).clamp(0.0, 1.0);
    
    return GlassCard(
      margin: EdgeInsets.zero,
      child: Container(
        height: 200,
        child: PandaMascot(
          phase: phase,
          cycleDay: daysSinceStart,
          progressPercentage: progress,
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2);
  }
  
  Widget _buildPhaseCard(CycleProvider provider) {
    final phase = provider.currentPhase;
    final daysSinceStart = provider.daysSinceStart;
    
    return Hero(
      tag: 'phase_card',
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTheme.spaceL),
          decoration: BoxDecoration(
            gradient: AppTheme.phaseGradient(phase),
            borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryPink.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
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
              
              const SizedBox(height: AppTheme.spaceM),
              
              Text(
                _getPhaseName(phase),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppTheme.spaceS),
              
              Text(
                'Day $daysSinceStart of your cycle',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              
              const SizedBox(height: AppTheme.spaceM),
              
              Text(
                _getPhaseDescription(phase),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 600.ms).scale();
  }
  
  Widget _buildRecommendationsSection(String phase, Map<String, dynamic>? healthData) {
    final recommendations = _getRecommendations(phase, healthData);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.lightbulb, color: AppTheme.primaryPink),
            const SizedBox(width: AppTheme.spaceS),
            Text(
              'Recommendations for You',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ).animate().fadeIn(delay: 800.ms),
        
        const SizedBox(height: AppTheme.spaceM),
        
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final rec = recommendations[index];
              return Container(
                width: 280,
                margin: EdgeInsets.only(
                  right: index < recommendations.length - 1 ? AppTheme.spaceM : 0,
                ),
                child: RecommendationCard(
                  icon: rec['icon'],
                  title: rec['title'],
                  description: rec['description'],
                  color: rec['color'],
                ),
              ).animate(delay: Duration(milliseconds: 900 + (index * 100)))
                .fadeIn()
                .slideX(begin: 0.2);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildPredictionCard(Map<String, dynamic> insights) {
    final prediction = insights['prediction'];
    if (prediction == null) return const SizedBox.shrink();
    
    return GlassCard(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, color: AppTheme.primaryPink),
                const SizedBox(width: AppTheme.spaceS),
                Text(
                  'Next Period Prediction',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spaceM),
            
            Text(
              'Expected around',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            
            const SizedBox(height: AppTheme.spaceXS),
            
            Text(
              DateFormat('MMMM d, yyyy').format(
                DateTime.parse(prediction['nextPeriodDate']),
              ),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryPink,
              ),
            ),
            
            const SizedBox(height: AppTheme.spaceM),
            
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    child: LinearProgressIndicator(
                      value: (prediction['confidence'] as num?)?.toDouble() ?? 0.5,
                      backgroundColor: AppTheme.blushPink,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryPink),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spaceM),
                Text(
                  '${((prediction['confidence'] as num) * 100).toInt()}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryPink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spaceS),
            
            Text(
              'Based on your past ${insights['totalCycles'] ?? 0} cycles',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.2);
  }
  
  Widget _buildCycleStats(Map<String, dynamic>? insights) {
    return GlassCard(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Cycle Stats',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            
            const SizedBox(height: AppTheme.spaceL),
            
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
    ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.2);
  }
  
  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryPink, size: 28),
        const SizedBox(height: AppTheme.spaceS),
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryPink,
          ),
        ),
        const SizedBox(height: AppTheme.spaceXS),
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
      padding: const EdgeInsets.all(AppTheme.spaceXL),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.white,
          ),
          
          const SizedBox(height: AppTheme.spaceL),
          
          const Text(
            'Welcome to Solaris!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppTheme.spaceM),
          
          Text(
            'Start logging your cycle to see personalized insights, predictions, and meet your panda companion!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppTheme.spaceXL),
          
          ElevatedButton.icon(
            onPressed: () {
              // Simple navigation - no HomeScreen.of(context)
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => HomeScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryPink,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceXL,
                vertical: AppTheme.spaceM,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text(
              'Log Your First Period',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }
}