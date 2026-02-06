import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/cycle_provider.dart';
import '../theme/app_theme.dart';
import 'today_screen.dart';
import 'log_screen.dart';
import 'timeline_screen.dart';
import 'profile_screen.dart';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  static HomeScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<HomeScreenState>();

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  final List<Widget> _screens = [
    TodayScreen(),
    LogScreen(),
    TimelineScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    _fabController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );

    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeOutCubic,
    );

    _fabController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CycleProvider>(context, listen: false).loadCycles();
      Provider.of<CycleProvider>(context, listen: false).loadCurrentInsights();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void goToTab(int index) {
    setState(() {
      _currentIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );

    _fabController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        physics: BouncingScrollPhysics(),
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
          _fabController.forward(from: 0);
        },
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 0, 20, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withOpacity(0.2),
            blurRadius: 25,
            offset: Offset(0, 10),
            spreadRadius: -5,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 20,
            offset: Offset(-5, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 75,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0x70FFFFFF),
                  Color(0x40FFFFFF),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'Today'),
                _buildNavItem(1, Icons.add_circle_rounded, 'Log'),
                _buildNavItem(2, Icons.calendar_today_rounded, 'Timeline'),
                _buildNavItem(3, Icons.person_rounded, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 400.ms).slideY(begin: 0.5);
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => goToTab(index),
        behavior: HitTestBehavior.opaque,
        // Hard-clamp to bar height so the Column can never overflow.
        child: SizedBox(
          height: 75,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.primaryGradient : null,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryPink.withOpacity(0.4),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : AppTheme.textGray,
                    size: 22,
                  ),
                ),
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppTheme.primaryPink : AppTheme.textGray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
