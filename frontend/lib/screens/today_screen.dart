// File: lib/screens/today_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../providers/cycle_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/panda_mascot.dart';
import '../widgets/animated_background.dart';

class TodayScreen extends StatefulWidget {
  @override
  _TodayScreenState createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;
  final PageController _recommendationsController =
      PageController(viewportFraction: 0.85);
  int _currentRecommendationPage = 0;

  @override
  void initState() {
    super.initState();

    _floatingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(
      begin: -8.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _recommendationsController.addListener(() {
      int page = _recommendationsController.page?.round() ?? 0;
      if (page != _currentRecommendationPage) {
        setState(() => _currentRecommendationPage = page);
      }
    });
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _recommendationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.almostWhite,
      body: AnimatedGradientBackground(
        duration: Duration(seconds: 4),
        colors: [
          AppTheme.blushPink,
          AppTheme.lightPink,
          AppTheme.lightPurple,
          AppTheme.almostWhite,
        ],
        child: SafeArea(
          child: CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.primaryPink.withOpacity(0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          _getGreeting(),
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textGray,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Today\'s Overview',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(height: 20),

                    _buildPhaseCard()
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 200.ms)
                        .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic)
                        .shimmer(duration: 1500.ms, delay: 400.ms),

                    SizedBox(height: 24),

                    _buildPandaSection()
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 400.ms)
                        .scale(begin: Offset(0.8, 0.8), curve: Curves.elasticOut),

                    SizedBox(height: 24),

                    _buildStatsGrid()
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 600.ms)
                        .slideX(begin: -0.2, curve: Curves.easeOutCubic),

                    SizedBox(height: 32),

                    _buildRecommendationsCarousel(),

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

  Widget _buildPhaseCard() {
    return Consumer<CycleProvider>(
      builder: (context, provider, child) {
        final phase = provider.currentPhase;
        final daysSinceStart = provider.daysSinceStart;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: AnimatedBuilder(
            animation: _floatingAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatingAnimation.value),
                child: child,
              );
            },
            child: GlassCard(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.all(24),
              child: Container(
                decoration: BoxDecoration(
                  gradient: _getPhaseGradient(phase),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getPhaseIcon(phase),
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getPhaseTitle(phase),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Day $daysSinceStart of cycle',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text(
                        _getPhaseDescription(phase),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.95),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPandaSection() {
    // No padding or wrapper - panda travels across full screen width
    return const EnhancedPandaMascot();
  }

  Widget _buildStatsGrid() {
    return Consumer<CycleProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Cycles Tracked',
                  '${provider.totalCycles}',
                  Icons.calendar_today,
                  AppTheme.primaryPink,
                  0,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Avg Length',
                  provider.averageCycleLength != null
                      ? '${provider.averageCycleLength!.toStringAsFixed(0)} days'
                      : 'N/A',
                  Icons.trending_up,
                  AppTheme.primaryPurple,
                  100,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Regularity',
                  provider.regularityScore != null
                      ? '${(provider.regularityScore! * 100).toStringAsFixed(0)}%'
                      : 'N/A',
                  Icons.check_circle,
                  AppTheme.follicularPhase,
                  200,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color, int delayMs) {
    return GlassCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate()
        .fadeIn(duration: 600.ms, delay: Duration(milliseconds: delayMs));
  }

  Widget _buildRecommendationsCarousel() {
    return Consumer<CycleProvider>(
      builder: (context, provider, child) {
        final recommendations = _getRecommendations(provider.currentPhase);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recommendations for You',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPink.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${(_currentRecommendationPage % recommendations.length) + 1}/${recommendations.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryPink,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 800.ms),

            SizedBox(height: 16),

            SizedBox(
              height: 160,
              child: PageView.builder(
                controller: _recommendationsController,
                physics: BouncingScrollPhysics(),
                itemCount: recommendations.length * 1000,
                itemBuilder: (context, index) {
                  final actualIndex = index % recommendations.length;
                  final recommendation = recommendations[actualIndex];

                  return AnimatedBuilder(
                    animation: _recommendationsController,
                    builder: (context, child) {
                      double value = 1.0;
                      if (_recommendationsController.position.haveDimensions) {
                        value =
                            (_recommendationsController.page ?? 0) - index;
                        value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                      }

                      return Transform.scale(
                        scale: Curves.easeOut.transform(value),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: _buildRecommendationCard(
                      recommendation['title']!,
                      recommendation['description']!,
                      recommendation['icon'] as IconData,
                      recommendation['color'] as Color,
                    ),
                  );
                },
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 900.ms),

            SizedBox(height: 16),

            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  recommendations.length,
                  (index) => AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    width:
                        (_currentRecommendationPage % recommendations.length) ==
                                index
                            ? 24
                            : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color:
                          (_currentRecommendationPage % recommendations.length) ==
                                  index
                              ? AppTheme.primaryPink
                              : AppTheme.primaryPink.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 1000.ms),
          ],
        );
      },
    );
  }

  Widget _buildRecommendationCard(
      String title, String description, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: GlassCard(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.15),
                color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 36),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textGray,
                          height: 1.5,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  LinearGradient _getPhaseGradient(String phase) {
    switch (phase) {
      case 'menstrual':
        return LinearGradient(
          colors: [
            AppTheme.menstrualPhase,
            AppTheme.menstrualPhase.withOpacity(0.7)
          ],
        );
      case 'follicular':
        return LinearGradient(
          colors: [
            AppTheme.follicularPhase,
            AppTheme.follicularPhase.withOpacity(0.7)
          ],
        );
      case 'ovulation':
        return LinearGradient(
          colors: [
            AppTheme.ovulationPhase,
            AppTheme.ovulationPhase.withOpacity(0.7)
          ],
        );
      case 'luteal':
        return LinearGradient(
          colors: [
            AppTheme.lutealPhase,
            AppTheme.lutealPhase.withOpacity(0.7)
          ],
        );
      default:
        return LinearGradient(
          colors: [AppTheme.primaryPink, AppTheme.primaryPurple],
        );
    }
  }

  IconData _getPhaseIcon(String phase) {
    switch (phase) {
      case 'menstrual':
        return Icons.water_drop;
      case 'follicular':
        return Icons.eco;
      case 'ovulation':
        return Icons.wb_sunny;
      case 'luteal':
        return Icons.nightlight;
      default:
        return Icons.favorite;
    }
  }

  String _getPhaseTitle(String phase) {
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
        return 'Current Phase';
    }
  }

  String _getPhaseDescription(String phase) {
    switch (phase) {
      case 'menstrual':
        return 'Your body is shedding the uterine lining. Rest, stay hydrated, and be gentle with yourself.';
      case 'follicular':
        return 'Energy is building! Great time for new projects and physical activity.';
      case 'ovulation':
        return 'You\'re at your peak! Confidence and energy are high. Perfect for important tasks.';
      case 'luteal':
        return 'Your body is preparing. Focus on self-care and listen to your needs.';
      default:
        return 'Track your cycle to see personalized insights here.';
    }
  }

  List<Map<String, dynamic>> _getRecommendations(String phase) {
    switch (phase) {
      case 'menstrual':
        return [
          {
            'title': 'Rest & Recovery',
            'description':
                'Your body is working hard. Prioritize sleep and gentle movement like yoga or walking.',
            'icon': Icons.bed,
            'color': AppTheme.menstrualPhase,
          },
          {
            'title': 'Warm Comfort',
            'description':
                'Use a heating pad for cramps. Warm baths with Epsom salt can help relax muscles.',
            'icon': Icons.hot_tub,
            'color': AppTheme.menstrualPhase,
          },
          {
            'title': 'Iron-Rich Foods',
            'description':
                'Replenish iron with spinach, red meat, or lentils to combat fatigue.',
            'icon': Icons.restaurant,
            'color': AppTheme.menstrualPhase,
          },
          {
            'title': 'Hydration Boost',
            'description':
                'Drink plenty of water and herbal teas to reduce bloating and support your body.',
            'icon': Icons.local_drink,
            'color': AppTheme.menstrualPhase,
          },
        ];

      case 'follicular':
        return [
          {
            'title': 'High Energy Workouts',
            'description':
                'Your energy is rising! Perfect time for cardio, strength training, or trying new classes.',
            'icon': Icons.fitness_center,
            'color': AppTheme.follicularPhase,
          },
          {
            'title': 'Creative Projects',
            'description':
                'Mental clarity is peaking. Start new projects, brainstorm, and tackle challenges.',
            'icon': Icons.lightbulb,
            'color': AppTheme.follicularPhase,
          },
          {
            'title': 'Social Connections',
            'description':
                'You\'re feeling outgoing! Great time to connect with friends and network.',
            'icon': Icons.people,
            'color': AppTheme.follicularPhase,
          },
          {
            'title': 'Fresh Foods',
            'description':
                'Focus on fresh vegetables, fruits, and lean proteins to support your energy.',
            'icon': Icons.eco,
            'color': AppTheme.follicularPhase,
          },
        ];

      case 'ovulation':
        return [
          {
            'title': 'Peak Performance',
            'description':
                'You\'re at your strongest! Schedule important meetings, presentations, or workouts.',
            'icon': Icons.star,
            'color': AppTheme.ovulationPhase,
          },
          {
            'title': 'Communication',
            'description':
                'Confidence is high. Perfect for difficult conversations and expressing yourself.',
            'icon': Icons.chat_bubble,
            'color': AppTheme.ovulationPhase,
          },
          {
            'title': 'Intense Workouts',
            'description':
                'Push your limits with HIIT, running, or challenging strength sessions.',
            'icon': Icons.directions_run,
            'color': AppTheme.ovulationPhase,
          },
          {
            'title': 'Colorful Meals',
            'description':
                'Enjoy vibrant salads, smoothies, and nutrient-dense foods to match your energy.',
            'icon': Icons.food_bank,
            'color': AppTheme.ovulationPhase,
          },
        ];

      case 'luteal':
        return [
          {
            'title': 'Gentle Exercise',
            'description':
                'Switch to yoga, pilates, or walks. Your body needs less intensity now.',
            'icon': Icons.self_improvement,
            'color': AppTheme.lutealPhase,
          },
          {
            'title': 'Comfort Foods',
            'description':
                'It\'s okay to indulge mindfully. Dark chocolate and complex carbs can help mood.',
            'icon': Icons.cookie,
            'color': AppTheme.lutealPhase,
          },
          {
            'title': 'Self-Care Rituals',
            'description':
                'Face masks, relaxing baths, and quiet time. Nurture yourself this week.',
            'icon': Icons.spa,
            'color': AppTheme.lutealPhase,
          },
          {
            'title': 'Journal & Reflect',
            'description':
                'Process emotions through writing. This phase brings introspection and insight.',
            'icon': Icons.book,
            'color': AppTheme.lutealPhase,
          },
        ];

      default:
        return [
          {
            'title': 'Start Tracking',
            'description':
                'Log your cycle to get personalized recommendations based on your phase.',
            'icon': Icons.calendar_today,
            'color': AppTheme.primaryPink,
          },
        ];
    }
  }
}