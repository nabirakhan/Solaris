// File: lib/screens/timeline_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../providers/cycle_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/animated_background.dart';
import 'cycle_management_screen.dart'; // Add this import
import 'log_screen.dart';

class TimelineScreen extends StatefulWidget {
  @override
  _TimelineScreenState createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
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
          child: Column(
            children: [
              _buildSimpleHeader(),
              
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      
                      _buildMonthSelector()
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 200.ms)
                        .slideY(begin: -0.2),
                      
                      SizedBox(height: 24),
                      
                      _buildCalendar()
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 400.ms)
                        .scale(begin: Offset(0.95, 0.95)),
                      
                      SizedBox(height: 24),
                      
                      _buildCycleHistory()
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 600.ms)
                        .slideY(begin: 0.2),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Timeline',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
              SizedBox(height: 4),
              Text(
                'Track your journey over time',
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.textGray,
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 100.ms),
            ],
          ),
          Spacer(),
          // Add button to view all cycles
          IconButton(
            icon: Icon(Icons.list, color: AppTheme.primaryPink),
            onPressed: () {
              _navigateToCycleManagement(context);
            },
            tooltip: 'View All Cycles',
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: GlassCard(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildMonthButton(Icons.chevron_left, () {
              setState(() {
                _selectedMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month - 1,
                );
              });
            }),
            
            Expanded(
              child: Center(
                child: Text(
                  DateFormat('MMMM yyyy').format(_selectedMonth),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
            ),
            
            _buildMonthButton(Icons.chevron_right, () {
              setState(() {
                _selectedMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month + 1,
                );
              });
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthButton(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Consumer<CycleProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: GlassCard(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                _buildWeekDays(),
                SizedBox(height: 16),
                _buildCalendarDays(provider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeekDays() {
    final weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekDays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textGray,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarDays(CycleProvider provider) {
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final startWeekday = firstDayOfMonth.weekday % 7;
    
    List<Widget> dayWidgets = [];
    
    // Add empty cells for days before the month starts
    for (int i = 0; i < startWeekday; i++) {
      dayWidgets.add(Expanded(child: SizedBox()));
    }
    
    // Add day cells
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
      dayWidgets.add(_buildDayCell(day, date, provider));
    }
    
    // Build rows of 7 days
    List<Widget> rows = [];
    for (int i = 0; i < dayWidgets.length; i += 7) {
      rows.add(
        Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: dayWidgets.skip(i).take(7).toList(),
          ),
        ),
      );
    }
    
    return Column(children: rows);
  }

  Widget _buildDayCell(int day, DateTime date, CycleProvider provider) {
    final isPeriodDay = _isPeriodDay(provider, date);
    final isToday = _isToday(date);
    final index = day - 1;
    
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          margin: EdgeInsets.all(2),
          decoration: BoxDecoration(
            gradient: isPeriodDay
                ? LinearGradient(
                    colors: [
                      AppTheme.primaryPink,
                      AppTheme.primaryPink.withOpacity(0.8),
                    ],
                  )
                : null,
            color: isToday && !isPeriodDay
                ? AppTheme.primaryPink.withOpacity(0.1)
                : null,
            borderRadius: BorderRadius.circular(10),
            border: isToday
                ? Border.all(color: AppTheme.primaryPink, width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isPeriodDay || isToday ? FontWeight.bold : FontWeight.normal,
                color: isPeriodDay 
                  ? Colors.white 
                  : (isToday ? AppTheme.primaryPink : AppTheme.textDark),
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: index * 20));
  }

  Widget _buildCycleHistory() {
    return Consumer<CycleProvider>(
      builder: (context, provider, child) {
        print('Building cycle history, total cycles: ${provider.cycles.length}');
        
        if (provider.cycles.isEmpty) {
          return _buildEmptyState();
        }
        
        final validCycles = provider.cycles.where((cycle) {
          final startDate = cycle['start_date'] ?? cycle['startDate'];
          return startDate != null && startDate.toString().isNotEmpty;
        }).toList();
        
        print('Valid cycles: ${validCycles.length}');
        
        if (validCycles.isEmpty) {
          return _buildEmptyState();
        }
        
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cycle History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _navigateToCycleManagement(context);
                    },
                    icon: Icon(Icons.open_in_new, size: 16),
                    label: Text('Manage'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryPink,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ...validCycles.asMap().entries.map((entry) {
                return _buildCycleCard(entry.value, entry.key, provider);
              }).toList(),
              SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCycleCard(Map<String, dynamic> cycle, int index, CycleProvider cycleProvider) {
    // Handle both snake_case and camelCase field names
    final startDateString = (cycle['start_date'] ?? cycle['startDate'])?.toString();
    final endDateString = (cycle['end_date'] ?? cycle['endDate'])?.toString();
    final flow = cycle['flow']?.toString() ?? 'medium';
    final cycleId = cycle['_id'] ?? cycle['id'];
    
    if (startDateString == null || startDateString.isEmpty) {
      return SizedBox();
    }
    
    try {
      final startDate = DateTime.parse(startDateString);
      final endDate = endDateString != null && endDateString.isNotEmpty 
        ? DateTime.parse(endDateString) 
        : null;
      
      final length = cycle['cycle_length'] ?? cycle['cycleLength'] ?? (endDate != null 
        ? endDate.difference(startDate).inDays + 1 
        : null);
      
      return Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: GestureDetector(
          onTap: () {
            _navigateToCycleManagement(context);
          },
          child: GlassCard(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryPink.withOpacity(0.3),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      length != null ? '$length' : '?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cycle ${cycleProvider.cycles.length - index}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        DateFormat('MMM d, yyyy').format(startDate),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textGray,
                        ),
                      ),
                      if (endDate != null)
                        Text(
                          'to ${DateFormat('MMM d, yyyy').format(endDate)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textLight,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.follicularPhase.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    endDate != null ? Icons.check_circle : Icons.timelapse,
                    color: endDate != null ? AppTheme.follicularPhase : AppTheme.warning,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(duration: 600.ms, delay: Duration(milliseconds: 100 * index))
        .slideX(begin: 0.2);
    } catch (e) {
      print('Error building cycle card: $e');
      return SizedBox();
    }
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.blushPink.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today,
                size: 60,
                color: AppTheme.primaryPink.withOpacity(0.5),
              ),
            ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
            SizedBox(height: 24),
            Text(
              'No Cycles Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
            SizedBox(height: 8),
            Text(
              'Start logging your periods to see your timeline',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textGray,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
            SizedBox(height: 24),
            // Add a button to go to log screen
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to log screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LogScreen(),
                  ),
                );
              },
              icon: Icon(Icons.add),
              label: Text('Log Your First Period'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPink,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isPeriodDay(CycleProvider provider, DateTime date) {
    // Normalize the date to midnight for comparison
    final checkDate = DateTime(date.year, date.month, date.day);
    
    for (var cycle in provider.cycles) {
      final startDateString = (cycle['start_date'] ?? cycle['startDate'])?.toString();
      final endDateString = (cycle['end_date'] ?? cycle['endDate'])?.toString();
      
      if (startDateString == null || startDateString.isEmpty) {
        continue;
      }
      
      try {
        final startDate = DateTime.parse(startDateString);
        final normalizedStart = DateTime(startDate.year, startDate.month, startDate.day);
        
        if (endDateString != null && endDateString.isNotEmpty) {
          final endDate = DateTime.parse(endDateString);
          final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day);
          
          if (!checkDate.isBefore(normalizedStart) && !checkDate.isAfter(normalizedEnd)) {
            return true;
          }
        } else {
          // If no end date, assume period lasts 5 days
          final estimatedEnd = normalizedStart.add(Duration(days: 5));
          
          if (!checkDate.isBefore(normalizedStart) && checkDate.isBefore(estimatedEnd)) {
            return true;
          }
        }
      } catch (e) {
        print('Error parsing dates in _isPeriodDay: $e');
        continue;
      }
    }
    return false;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  // Navigation method to Cycle Management Screen
  void _navigateToCycleManagement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CycleManagementScreen(),
      ),
    );
  }
}