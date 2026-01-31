// File: frontend/lib/screens/timeline_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/cycle_provider.dart';
import '../theme/app_theme.dart';

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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Consumer<CycleProvider>(
            builder: (context, cycleProvider, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Timeline',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  
                  SizedBox(height: 8),
                  
                  Text(
                    'View your cycle history',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  
                  SizedBox(height: 24),
                  
                  Card(
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
                          todayDecoration: BoxDecoration(
                            color: AppTheme.lightPink,
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: AppTheme.primaryPink,
                            shape: BoxShape.circle,
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
                            // Check if this date is a period start
                            if (cycleProvider.cycles.isEmpty) return null;

                            final isPeriodStart = cycleProvider.cycles.any((cycle) {
                              if (cycle == null || cycle is! Map) return false;
                              
                              // Safely get startDate with multiple possible field names
                              final startDateStr = cycle['startDate'] ?? 
                                                  cycle['start_date'] ??
                                                  cycle['StartDate'];
                              
                              if (startDateStr == null) return false;
                              
                              try {
                                // Ensure we have a string before parsing
                                final dateStr = startDateStr.toString();
                                final startDate = DateTime.parse(dateStr);
                                return isSameDay(startDate, date);
                              } catch (e) {
                                // If parsing fails, skip this cycle
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
                                  ),
                                ),
                              );
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  Text(
                    'Cycle History',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  
                  SizedBox(height: 16),
                  
                  if (cycleProvider.cycles.isEmpty)
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 60,
                              color: AppTheme.lightPink,
                            ),
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
                    )
                  else
                    ...cycleProvider.cycles.where((c) => c != null && c is Map).take(10).map((cycle) {
                      // Safely get startDate with multiple possible field names
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
                      
                      // Safely get endDate
                      DateTime? endDate;
                      final endDateStr = cycle['endDate'] ?? 
                                         cycle['end_date'] ??
                                         cycle['EndDate'];
                      if (endDateStr != null) {
                        try {
                          endDate = DateTime.parse(endDateStr.toString());
                        } catch (e) {
                          endDate = null;
                        }
                      }
                      
                      // Safely get cycleLength
                      final cycleLength = cycle['cycleLength'] ?? 
                                         cycle['cycle_length'] ??
                                         cycle['CycleLength'];
                      
                      // Safely get flow value with multiple fallbacks and ensure it's a String
                      String flowValue = 'Medium'; // Default value
                      final flow = cycle['flow'] ?? 
                                  cycle['Flow'] ?? 
                                  cycle['flowLevel'];
                      if (flow != null && flow.toString().isNotEmpty) {
                        flowValue = flow.toString();
                      }
                      
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppTheme.blushPink,
                                  borderRadius: BorderRadius.circular(12),
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
                              
                              // Always show the flow container
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.lightPink.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
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
                        ),
                      );
                    }).toList(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}