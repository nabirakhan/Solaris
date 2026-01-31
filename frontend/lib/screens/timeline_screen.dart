// File: frontend/lib/screens/timeline_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/cycle_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class TimelineScreen extends StatefulWidget {
  @override
  _TimelineScreenState createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.almostWhite,
      body: Stack(
        children: [
          // Animated Background Blobs
          Positioned(
            top: -50,
            left: -50,
            child: _buildBlob(AppTheme.primaryPink.withOpacity(0.2), 250),
          ),
          Positioned(
            bottom: 200,
            right: -100,
            child: _buildBlob(AppTheme.lightPink.withOpacity(0.2), 300),
          ),
          Positioned(
            bottom: -50,
            left: 50,
            child: _buildBlob(AppTheme.lightPurple.withOpacity(0.2), 200),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Consumer<CycleProvider>(
                builder: (context, cycleProvider, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Timeline',
                                style: Theme.of(context).textTheme.displayLarge,
                              ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
                              
                              SizedBox(height: 8),
                              
                              Text(
                                'View your cycle history',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ).animate().fadeIn(delay: 200.ms),
                            ],
                          ),
                          // Peek-a-boo Panda
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              color: AppTheme.lightPink,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Icon(
                              Icons.pets,
                              color: AppTheme.primaryPink,
                              size: 30,
                            ),
                          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                           .rotate(begin: -0.1, end: 0.1, duration: 2.seconds)
                           .scaleXY(begin: 0.9, end: 1.1),
                        ],
                      ),
                      
                      SizedBox(height: 24),
                      
                      GlassCard(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: TableCalendar(
                            firstDay: DateTime.utc(2020, 1, 1),
                            lastDay: DateTime.utc(2030, 12, 31),
                            focusedDay: _focusedDay,
                            calendarFormat: _calendarFormat,
                            selectedDayPredicate: (day) {
                              return isSameDay(_selectedDay, day);
                            },
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                              });
                            },
                            onFormatChanged: (format) {
                              setState(() {
                                _calendarFormat = format;
                              });
                            },
                            onPageChanged: (focusedDay) {
                              _focusedDay = focusedDay;
                            },
                            calendarStyle: CalendarStyle(
                              outsideDaysVisible: false,
                              defaultTextStyle: TextStyle(color: AppTheme.textDark),
                              weekendTextStyle: TextStyle(color: AppTheme.textDark),
                              todayDecoration: BoxDecoration(
                                color: AppTheme.lightPink,
                                shape: BoxShape.circle,
                              ),
                              selectedDecoration: BoxDecoration(
                                color: AppTheme.primaryPink,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryPink.withOpacity(0.4),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  )
                                ]
                              ),
                              markerDecoration: BoxDecoration(
                                color: AppTheme.primaryPink,
                                shape: BoxShape.circle,
                              ),
                            ),
                            headerStyle: HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                              titleTextStyle: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textDark,
                              ),
                              leftChevronIcon: Icon(
                                Icons.chevron_left,
                                color: AppTheme.primaryPink,
                              ),
                              rightChevronIcon: Icon(
                                Icons.chevron_right,
                                color: AppTheme.primaryPink,
                              ),
                            ),
                            calendarBuilders: CalendarBuilders(
                              markerBuilder: (context, date, events) {
                                if (cycleProvider.cycles.isEmpty) return null;

                                final isPeriodStart = cycleProvider.cycles.any((cycle) {
                                  if (cycle == null || cycle is! Map) return false;
                                  final startDateStr = cycle['startDate'] ?? 
                                                      cycle['start_date'] ??
                                                      cycle['StartDate'];
                                  if (startDateStr == null) return false;
                                  try {
                                    final dateStr = startDateStr.toString();
                                    final startDate = DateTime.parse(dateStr);
                                    return isSameDay(startDate, date);
                                  } catch (e) {
                                    return false;
                                  }
                                });
                                
                                if (isPeriodStart) {
                                  return Positioned(
                                    bottom: 1,
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryPink,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.primaryPink.withOpacity(0.5),
                                            blurRadius: 4,
                                          )
                                        ]
                                      ),
                                    ),
                                  );
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                      
                      SizedBox(height: 24),
                      
                      Text(
                        'Cycle History',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ).animate().fadeIn(delay: 500.ms),
                      
                      SizedBox(height: 16),
                      
                      if (cycleProvider.cycles.isEmpty)
                        GlassCard(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 60,
                                  color: AppTheme.lightPink,
                                ).animate(onPlay: (controller) => controller.repeat()).shake(hz: 0.5),
                                SizedBox(height: 16),
                                Text(
                                  'No cycles logged yet',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Start logging to see your history',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(delay: 600.ms)
                      else
                        ...cycleProvider.cycles.where((c) => c != null && c is Map).take(10).toList().asMap().entries.map((entry) {
                          int index = entry.key;
                          var cycle = entry.value;
                          
                          // Safely get startDate
                          final startDateStr = cycle['startDate'] ?? 
                                              cycle['start_date'] ??
                                              cycle['StartDate'] ??
                                              DateTime.now().toString();
                          
                          DateTime startDate;
                          try {
                            startDate = DateTime.parse(startDateStr.toString());
                          } catch (e) {
                            startDate = DateTime.now();
                          }
                          
                          // Safely get cycleLength
                          final cycleLength = cycle['cycleLength'] ?? 
                                             cycle['cycle_length'] ??
                                             cycle['CycleLength'];
                          
                          // Safely get flow
                          String flowValue = 'Medium';
                          final flow = cycle['flow'] ?? 
                                      cycle['Flow'] ?? 
                                      cycle['flowLevel'];
                          if (flow != null && flow.toString().isNotEmpty) {
                            flowValue = flow.toString();
                          }
                          
                          return GlassCard(
                            margin: EdgeInsets.only(bottom: 12),
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: AppTheme.blushPink.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                                  ),
                                  child: Icon(
                                    Icons.water_drop,
                                    color: AppTheme.primaryPink,
                                  ),
                                ),
                                
                                SizedBox(width: 16),
                                
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat('MMMM d, yyyy').format(startDate),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textDark,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        cycleLength != null
                                            ? '$cycleLength days'
                                            : 'Ongoing',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.lightPink.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppTheme.primaryPink.withOpacity(0.2)),
                                  ),
                                  child: Text(
                                    flowValue,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.primaryPink,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: (600 + (index * 100)).ms).slideX(begin: 0.1);
                        }).toList(),
                        
                      SizedBox(height: 100), // Extra scroll space
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
}