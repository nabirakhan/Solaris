// File: lib/screens/today_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/cycle_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/cuterus_mascot.dart';
import '../widgets/animated_background.dart';
import '../widgets/ai_insights_card.dart';

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
  bool _isRefreshing = false;
  
  // ✅ FIX #1: Track expanded state for each recommendation card
  Map<int, bool> _expandedCards = {};

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

    // Load data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _recommendationsController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final cycleProvider = Provider.of<CycleProvider>(context, listen: false);
    await cycleProvider.loadCycles();
    await cycleProvider.loadCurrentInsights();
  }

  Future<void> _refreshInsights() async {
    setState(() => _isRefreshing = true);
    
    final cycleProvider = Provider.of<CycleProvider>(context, listen: false);
    final success = await cycleProvider.requestAIAnalysis();
    
    setState(() => _isRefreshing = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('AI insights updated successfully! ✨'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cycleProvider.error ?? 'Failed to update insights'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

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
          child: RefreshIndicator(
            onRefresh: _loadData,
            color: AppTheme.primaryPink,
            child: CustomScrollView(
              physics: BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
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
                            user != null ? 'Hi, ${user['name']}!' : 'Today\'s Overview',
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

                      // AI Insights Card
                      _buildAIInsightsSection()
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 300.ms)
                          .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),

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
      ),
    );
  }

  Widget _buildAIInsightsSection() {
    return Consumer<CycleProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: AIInsightsCard(
            insights: provider.currentInsights,
            onRefresh: _refreshInsights,
            isLoading: _isRefreshing,
          ),
        );
      },
    );
  }

  Widget _buildPhaseCard() {
    return Consumer<CycleProvider>(
      builder: (context, provider, child) {
        final phase = provider.currentPhase;
        // ✅ FIX #4: Calculate days since start properly, default to 1 instead of 0
        int daysSinceStart = provider.daysSinceStart;
        
        // If daysSinceStart is 0 and we have an active cycle, calculate manually
        if (daysSinceStart == 0 && provider.hasActiveCycle) {
          try {
            final currentCycle = provider.currentCycle;
            if (currentCycle != null) {
              final startDate = currentCycle['startDate'] ?? currentCycle['start_date'];
              if (startDate != null) {
                final start = DateTime.parse(startDate.toString());
                final now = DateTime.now();
                daysSinceStart = now.difference(start).inDays + 1; // +1 because day 1 is the start day
              }
            }
          } catch (e) {
            daysSinceStart = 1; // Default to day 1 if calculation fails
          }
        }
        
        // Ensure minimum day is 1 if there's an active cycle
        if (provider.hasActiveCycle && daysSinceStart < 1) {
          daysSinceStart = 1;
        }

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
              padding: EdgeInsets.zero,
              child: Container(
                decoration: BoxDecoration(
                  gradient: _getPhaseGradient(phase),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),
                padding: EdgeInsets.all(24),
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
                                  fontSize: 20,
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
                    SizedBox(height: 16),
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
        );
      },
    );
  }

  Widget _buildPandaSection() {
    return Consumer<CycleProvider>(
      builder: (context, provider, child) {
        final phase = provider.currentPhase;
        
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: GlassCard(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // ✅ FIX #1: Reduced vertical padding
            child: Column(
              mainAxisSize: MainAxisSize.min, // ✅ FIX #1: Don't take more space than needed
              children: [
                // ✅ FIX #2: Use adorable Cuterus mascot
                CuterusMascot(phase: phase),
                SizedBox(height: 8), // ✅ FIX #1: Reduced spacing
                Text(
                  'Meet Cuterus! 💖',
                  style: TextStyle(
                    fontSize: 16, // ✅ FIX #1: Slightly smaller font
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                SizedBox(height: 4), // ✅ FIX #1: Reduced spacing
                Text(
                  'Your personal uterus companion',
                  style: TextStyle(
                    fontSize: 13, // ✅ FIX #1: Smaller font
                    color: AppTheme.textGray,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
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
                  '${provider.totalCycles}',
                  'Cycles Tracked',
                  Icons.calendar_today,
                  AppTheme.primaryPink,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  provider.averageCycleLength != null
                      ? '${provider.averageCycleLength!.toStringAsFixed(0)} days'
                      : 'N/A',
                  'Avg Length',
                  Icons.trending_up,
                  AppTheme.follicularPhase,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  provider.regularityScore != null
                      ? '${(provider.regularityScore! * 100).toStringAsFixed(0)}%'
                      : 'N/A',
                  'Regularity',
                  Icons.check_circle,
                  AppTheme.ovulationPhase,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return GlassCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textGray,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCarousel() {
    return Consumer<CycleProvider>(
      builder: (context, provider, child) {
        final phase = provider.currentPhase;
        final recommendations = _getRecommendations(phase);

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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    '${_currentRecommendationPage + 1}/${recommendations.length}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textGray,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 165, // ✅ FIX #1: Reduced from 200 to 165 for more compact cards
              child: PageView.builder(
                controller: _recommendationsController,
                itemCount: recommendations.length,
                itemBuilder: (context, index) {
                  return _buildRecommendationCard(
                    recommendations[index],
                    index,
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                recommendations.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: _currentRecommendationPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentRecommendationPage == index
                        ? AppTheme.primaryPink
                        : AppTheme.textGray.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecommendationCard(
    Map<String, dynamic> recommendation,
    int index,
  ) {
    // ✅ FIX #1: Check if card is expanded
    final isExpanded = _expandedCards[index] ?? false;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        // ✅ FIX #1: Make card tappable to expand/collapse
        onTap: () {
          setState(() {
            _expandedCards[index] = !isExpanded;
          });
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: GlassCard(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.all(16), // ✅ FIX #1: Reduced from 20 to 16
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (recommendation['color'] as Color).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        recommendation['icon'] as IconData,
                        color: recommendation['color'] as Color,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recommendation['title'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          // ✅ FIX #1: Show description conditionally
                          SizedBox(height: 8),
                          AnimatedCrossFade(
                            firstChild: Text(
                              recommendation['description'],
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textGray,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            secondChild: Text(
                              recommendation['description'],
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textGray,
                                height: 1.4,
                              ),
                            ),
                            crossFadeState: isExpanded 
                                ? CrossFadeState.showSecond 
                                : CrossFadeState.showFirst,
                            duration: Duration(milliseconds: 200),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // ✅ FIX #1: Add tap hint icon
                SizedBox(height: 8),
                Center(
                  child: Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 20,
                    color: AppTheme.textGray.withOpacity(0.5),
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