import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../providers/cycle_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/animated_background.dart';
import '../services/api_service.dart';

class CycleManagementScreen extends StatefulWidget {
  @override
  _CycleManagementScreenState createState() => _CycleManagementScreenState();
}

class _CycleManagementScreenState extends State<CycleManagementScreen> {
  final ApiService _apiService = ApiService();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CycleProvider>(context, listen: false).loadCycles();
    });
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
              _buildHeader(),
              Expanded(
                child: Consumer<CycleProvider>(
                  builder: (context, cycleProvider, child) {
                    if (cycleProvider.isLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(AppTheme.primaryPink),
                        ),
                      );
                    }

                    if (cycleProvider.cycles.isEmpty) {
                      return _buildEmptyState();
                    }

                    return _buildCyclesList(cycleProvider);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: AppTheme.textDark),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage Cycles',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
                SizedBox(height: 4),
                Text(
                  'View, edit, and organize your cycles',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textGray,
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 100.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 80,
            color: AppTheme.textGray.withOpacity(0.3),
          ),
          SizedBox(height: 20),
          Text(
            'No cycles logged yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textGray,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start tracking your cycle in the Log tab',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textGray.withOpacity(0.7),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 800.ms).scale(),
    );
  }

  Widget _buildCyclesList(CycleProvider cycleProvider) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: cycleProvider.cycles.length,
      itemBuilder: (context, index) {
        final cycle = cycleProvider.cycles[index];
        return _buildCycleCard(cycle, cycleProvider)
            .animate(delay: (index * 100).ms)
            .fadeIn(duration: 400.ms)
            .slideX(begin: -0.1);
      },
    );
  }

  Widget _buildCycleCard(Map<String, dynamic> cycle, CycleProvider cycleProvider) {
    final cycleId = cycle['_id'] ?? cycle['id'];
    final startDate = cycle['startDate'] ?? cycle['start_date'];
    final endDate = cycle['endDate'] ?? cycle['end_date'];
    final flow = cycle['flow'] ?? 'medium';
    final notes = cycle['notes'];
    
    final startDateTime = DateTime.parse(startDate);
    final endDateTime = endDate != null ? DateTime.parse(endDate) : null;
    
    final isActive = endDateTime == null;
    final duration = endDateTime != null 
        ? endDateTime.difference(startDateTime).inDays + 1
        : DateTime.now().difference(startDateTime).inDays + 1;

    return GlassCard(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: isActive ? AppTheme.primaryGradient : LinearGradient(
                    colors: [Colors.grey.shade400, Colors.grey.shade500],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isActive ? 'Active' : 'Ended',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.edit_note, color: AppTheme.primaryPink),
                onPressed: () => _showEditFlowDaysDialog(cycleId, startDate, endDate, notes, cycleProvider),
                tooltip: 'Edit Flow Days',
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                onPressed: () => _showDeleteCycleDialog(cycleId, cycleProvider),
                tooltip: 'Delete Cycle',
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: AppTheme.primaryPink),
              SizedBox(width: 8),
              Text(
                'Started: ${DateFormat('MMM dd, yyyy').format(startDateTime)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          if (endDateTime != null) ...[
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.event_available, size: 16, color: AppTheme.primaryPink),
                SizedBox(width: 8),
                Text(
                  'Ended: ${DateFormat('MMM dd, yyyy').format(endDateTime)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.timelapse, size: 16, color: AppTheme.primaryPink),
              SizedBox(width: 8),
              Text(
                'Duration: $duration day${duration > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textGray,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.water_drop, size: 16, color: _getFlowColor(flow)),
              SizedBox(width: 8),
              Text(
                'Flow: ${_capitalizeFirst(flow)}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textGray,
                ),
              ),
            ],
          ),
          if (notes != null && notes.isNotEmpty) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryPink.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.primaryPink.withOpacity(0.1)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note_outlined, size: 16, color: AppTheme.primaryPink),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notes,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textDark,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 16),
          Divider(height: 1, color: AppTheme.textGray.withOpacity(0.2)),
          SizedBox(height: 12),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchSymptoms(cycleId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppTheme.primaryPink),
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      'No symptoms logged for this cycle',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textGray.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                );
              }

              final symptoms = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.favorite_border, size: 16, color: AppTheme.primaryPink),
                      SizedBox(width: 8),
                      Text(
                        'Symptoms',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  ...symptoms.map((symptom) => _buildSymptomItem(symptom)).toList(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomItem(Map<String, dynamic> symptom) {
    final date = DateTime.parse(symptom['date']);
    final symptomId = symptom['_id'] ?? symptom['id'];
    final symptomsData = symptom['symptoms'];
    final sleepHours = symptom['sleepHours'] ?? symptom['sleep_hours'];
    final stressLevel = symptom['stressLevel'] ?? symptom['stress_level'];
    final notes = symptom['notes'];

    // Convert symptoms to Map<String, dynamic> if it exists
    Map<String, dynamic> symptoms = {};
    if (symptomsData != null && symptomsData is Map) {
      symptoms = Map<String, dynamic>.from(symptomsData);
    }

    return InkWell(
      onTap: () => _showEditSymptomDialog(symptomId, symptom),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.almostWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primaryPink.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: AppTheme.primaryPink),
                    SizedBox(width: 6),
                    Text(
                      DateFormat('MMM dd, yyyy').format(date),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.edit, size: 16, color: AppTheme.textGray),
              ],
            ),
            if (symptoms.isNotEmpty) ...[
              SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: symptoms.entries
                    .where((entry) => entry.value != null && entry.value > 0)
                    .map((entry) => Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryPink.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_capitalizeFirst(entry.key)}: ${entry.value}',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.primaryPink,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
            if (sleepHours != null || stressLevel != null) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  if (sleepHours != null) ...[
                    Icon(Icons.bedtime, size: 12, color: AppTheme.textGray),
                    SizedBox(width: 4),
                    Text(
                      '${sleepHours}h sleep',
                      style: TextStyle(fontSize: 11, color: AppTheme.textGray),
                    ),
                    SizedBox(width: 12),
                  ],
                  if (stressLevel != null) ...[
                    Icon(Icons.psychology, size: 12, color: AppTheme.textGray),
                    SizedBox(width: 4),
                    Text(
                      'Stress: $stressLevel/5',
                      style: TextStyle(fontSize: 11, color: AppTheme.textGray),
                    ),
                  ],
                ],
              ),
            ],
            if (notes != null && notes.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                notes,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textDark.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchSymptoms(String cycleId) async {
    try {
      final data = await _apiService.getSymptoms();
      
      if (data == null) {
        return [];
      }
      
      // Extract the actual list from the response
      List<dynamic> symptomsList;
      
      if (data is Map) {
        final dataMap = data as Map<String, dynamic>;
        // API might return {symptoms: [...]} or similar structure
        final symptomsData = dataMap['symptoms'] ?? dataMap['symptomLogs'] ?? dataMap['symptom_logs'];
        if (symptomsData == null) {
          // If no wrapper key, return empty
          return [];
        }
        if (symptomsData is! List) {
          return [];
        }
        symptomsList = List<dynamic>.from(symptomsData as List);
      } else if (data is List) {
        symptomsList = List<dynamic>.from(data as List);
      } else {
        return [];
      }
      
      if (symptomsList.isEmpty) {
        return [];
      }
      
      // Get cycle dates
      final cycle = Provider.of<CycleProvider>(context, listen: false)
          .cycles
          .firstWhere(
            (c) => (c['_id'] ?? c['id']) == cycleId,
            orElse: () => {},
          );
      
      if (cycle.isEmpty) return [];
      
      final startDateStr = cycle['startDate'] ?? cycle['start_date'];
      if (startDateStr == null) return [];
      
      final startDate = DateTime.parse(startDateStr);
      final endDateStr = cycle['endDate'] ?? cycle['end_date'];
      final endDate = endDateStr != null 
          ? DateTime.parse(endDateStr) 
          : DateTime.now().add(Duration(days: 30));
      
      // Filter symptoms within cycle date range (more lenient)
      final filtered = symptomsList.where((symptom) {
        if (symptom == null || symptom['date'] == null) return false;
        try {
          final symptomDate = DateTime.parse(symptom['date']);
          return symptomDate.isAfter(startDate.subtract(Duration(days: 7))) &&
                 symptomDate.isBefore(endDate.add(Duration(days: 7)));
        } catch (e) {
          return false;
        }
      }).toList();
      
      return filtered.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching symptoms: $e');
      return [];
    }
  }

  void _showEditSymptomDialog(String symptomId, Map<String, dynamic> symptomData) {
    Map<String, double> symptoms = {};
    
    // Safely parse symptoms from the data
    if (symptomData['symptoms'] != null) {
      final rawSymptoms = symptomData['symptoms'] as Map<String, dynamic>;
      rawSymptoms.forEach((key, value) {
        if (value != null) {
          symptoms[key] = (value is int) ? value.toDouble() : (value is double ? value : (value as num).toDouble());
        }
      });
    } else {
      symptoms = {
        'mood': 3.0,
        'cramps': 0.0,
        'energy': 3.0,
        'bloating': 0.0,
        'headache': 0.0,
      };
    }

    // Safely parse sleepHours with proper null handling
    double sleepHours = 7.0;
    if (symptomData['sleepHours'] != null || symptomData['sleep_hours'] != null) {
      final rawSleepHours = symptomData['sleepHours'] ?? symptomData['sleep_hours'];
      if (rawSleepHours != null) {
        if (rawSleepHours is int) {
          sleepHours = rawSleepHours.toDouble();
        } else if (rawSleepHours is double) {
          sleepHours = rawSleepHours;
        } else if (rawSleepHours is String) {
          sleepHours = double.tryParse(rawSleepHours) ?? 7.0;
        } else if (rawSleepHours is num) {
          sleepHours = rawSleepHours.toDouble();
        }
      }
    }
    
    // Safely parse stressLevel with proper null handling
    int stressLevel = 0;
    if (symptomData['stressLevel'] != null || symptomData['stress_level'] != null) {
      final rawStressLevel = symptomData['stressLevel'] ?? symptomData['stress_level'];
      if (rawStressLevel != null) {
        if (rawStressLevel is int) {
          stressLevel = rawStressLevel;
        } else if (rawStressLevel is String) {
          stressLevel = int.tryParse(rawStressLevel) ?? 0;
        } else if (rawStressLevel is num) {
          stressLevel = rawStressLevel.toInt();
        }
      }
    }
    
    String notes = symptomData['notes']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Edit Symptoms', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSymptomSlider('Mood', 'mood', symptoms, setState),
                _buildSymptomSlider('Cramps', 'cramps', symptoms, setState),
                _buildSymptomSlider('Bloating', 'bloating', symptoms, setState),
                _buildSymptomSlider('Headache', 'headache', symptoms, setState),
                _buildSymptomSlider('Energy', 'energy', symptoms, setState),
                SizedBox(height: 16),
                Text('Sleep Hours', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                Slider(
                  value: sleepHours,
                  min: 0,
                  max: 12,
                  divisions: 24,
                  label: '${sleepHours.toStringAsFixed(1)}h',
                  onChanged: (value) => setState(() => sleepHours = value),
                ),
                SizedBox(height: 8),
                Text('Stress Level', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                Slider(
                  value: stressLevel.toDouble(),
                  min: 0,
                  max: 5,
                  divisions: 5,
                  label: '$stressLevel',
                  onChanged: (value) => setState(() => stressLevel = value.toInt()),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: TextEditingController(text: notes),
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (value) => notes = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: AppTheme.textGray)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPink,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                final cycleProvider = Provider.of<CycleProvider>(context, listen: false);
                final success = await cycleProvider.updateSymptoms(
                  symptomId: symptomId,
                  symptoms: symptoms.map((key, value) => MapEntry(key, value.toInt())),
                  sleepHours: sleepHours,
                  stressLevel: stressLevel,
                  notes: notes.isEmpty ? null : notes,
                );
                
                if (success) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Symptoms updated'), backgroundColor: Colors.green),
                  );
                }
              },
              child: Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  Widget _buildSymptomSlider(String label, String key, Map<String, double> symptoms, StateSetter setState) {
    double value = (symptoms[key] ?? 0.0).clamp(0.0, 10.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            Text('${value.toInt()}', style: TextStyle(fontSize: 14, color: AppTheme.primaryPink, fontWeight: FontWeight.w600)),
          ],
        ),
        Slider(
          value: value,
          min: 0,
          max: 10,
          divisions: 10,
          activeColor: AppTheme.primaryPink,
          onChanged: (newValue) {
            setState(() {
              symptoms[key] = newValue;
            });
          },
        ),
        SizedBox(height: 8),
      ],
    );
  }

  void _showEditFlowDaysDialog(String cycleId, String startDateStr, String? endDateStr, String? cycleNotes, CycleProvider cycleProvider) async {
    // Fetch period days for this cycle
    final periodDays = await _fetchPeriodDays(cycleId);
    
    if (periodDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No period days found for this cycle'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Initialize flow changes map with current flows
    Map<String, String> flowChanges = {};
    for (var day in periodDays) {
      final dayId = day['_id'] ?? day['id'];
      flowChanges[dayId] = day['flow'] ?? 'medium';
    }
    
    String notes = cycleNotes ?? '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Edit Flow Days', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select flow intensity for each day:',
                  style: TextStyle(fontSize: 14, color: AppTheme.textGray, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 16),
                ...periodDays.map((day) {
                  final dayId = day['_id'] ?? day['id'];
                  final date = DateTime.parse(day['date']);
                  final currentFlow = flowChanges[dayId] ?? 'medium';
                  
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPink.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primaryPink.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16, color: AppTheme.primaryPink),
                            SizedBox(width: 8),
                            Text(
                              DateFormat('MMM dd, yyyy').format(date),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        SegmentedButton<String>(
                          segments: [
                            ButtonSegment(
                              value: 'light',
                              label: Text('Light', style: TextStyle(fontSize: 12)),
                              icon: Icon(Icons.water_drop_outlined, size: 16),
                            ),
                            ButtonSegment(
                              value: 'medium',
                              label: Text('Medium', style: TextStyle(fontSize: 12)),
                              icon: Icon(Icons.water_drop, size: 16),
                            ),
                            ButtonSegment(
                              value: 'heavy',
                              label: Text('Heavy', style: TextStyle(fontSize: 12)),
                              icon: Icon(Icons.water_drop, size: 18),
                            ),
                          ],
                          selected: {currentFlow},
                          onSelectionChanged: (Set<String> newSelection) {
                            setState(() {
                              flowChanges[dayId] = newSelection.first;
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith((states) {
                              if (states.contains(MaterialState.selected)) {
                                return AppTheme.primaryPink.withOpacity(0.2);
                              }
                              return null;
                            }),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                SizedBox(height: 16),
                TextField(
                  controller: TextEditingController(text: notes),
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Cycle Notes',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    hintText: 'Add notes about this cycle...',
                  ),
                  onChanged: (value) => notes = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: AppTheme.textGray)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPink,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                
                try {
                  // Update each period day's flow
                  for (var entry in flowChanges.entries) {
                    final dayId = entry.key;
                    final newFlow = entry.value;
                    
                    // Find the original day to see if flow changed
                    final originalDay = periodDays.firstWhere(
                      (day) => (day['_id'] ?? day['id']) == dayId,
                      orElse: () => {},
                    );
                    
                    if (originalDay.isNotEmpty && originalDay['flow'] != newFlow) {
                      await _apiService.updatePeriodDay(
                        id: dayId,
                        flow: newFlow,
                      );
                    }
                  }
                  
                  // Update cycle notes if changed
                  final oldNotes = cycleNotes ?? '';
                  final newNotes = notes ?? '';
                  if (oldNotes != newNotes) {
                    await _apiService.updateCycle(
                      id: cycleId,
                      notes: notes.isEmpty ? null : notes,
                    );
                  }
                  
                  // Reload cycles to reflect changes
                  await cycleProvider.loadCycles();
                  
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Flow days updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e, stackTrace) {
                  print('❌ Error updating flow days: $e');
                  print('Stack trace: $stackTrace');
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Failed to update flow days: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Save Changes', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchPeriodDays(String cycleId) async {
    try {
      final data = await _apiService.getPeriodDays();
      
      if (data == null) {
        return [];
      }
      
      // Extract the actual list from the response
      List<dynamic> periodDaysList;
      
      if (data is Map) {
        final dataMap = data as Map<String, dynamic>;
        // API returns {periodDays: [...]}
        final periodDaysData = dataMap['periodDays'] ?? dataMap['period_days'];
        if (periodDaysData == null) {
          return [];
        }
        if (periodDaysData is! List) {
          return [];
        }
        periodDaysList = List<dynamic>.from(periodDaysData as List);
      } else if (data is List) {
        periodDaysList = List<dynamic>.from(data as List);
      } else {
        return [];
      }
      
      if (periodDaysList.isEmpty) {
        return [];
      }
      
      // Get cycle dates
      final cycle = Provider.of<CycleProvider>(context, listen: false)
          .cycles
          .firstWhere(
            (c) => (c['_id'] ?? c['id']) == cycleId,
            orElse: () => {},
          );
      
      if (cycle.isEmpty) {
        return [];
      }
      
      final startDateStr = cycle['startDate'] ?? cycle['start_date'];
      final endDateStr = cycle['endDate'] ?? cycle['end_date'];
      
      if (startDateStr == null) {
        return [];
      }
      
      final startDate = DateTime.parse(startDateStr);
      final endDate = endDateStr != null 
          ? DateTime.parse(endDateStr) 
          : DateTime.now().add(Duration(days: 30)); // Extended range for active cycles
      
      // More lenient filtering - include days within a wider range
      final filtered = periodDaysList.where((day) {
        if (day == null) {
          return false;
        }
        
        final dayDateStr = day['date'];
        if (dayDateStr == null) {
          return false;
        }
        
        try {
          final dayDate = DateTime.parse(dayDateStr);
          // More lenient: within 7 days before start to 7 days after end
          final isInRange = dayDate.isAfter(startDate.subtract(Duration(days: 7))) &&
                            dayDate.isBefore(endDate.add(Duration(days: 7)));
          
          return isInRange;
        } catch (e) {
          return false;
        }
      }).toList();
      
      // Sort by date
      filtered.sort((a, b) {
        try {
          return DateTime.parse(a['date']).compareTo(DateTime.parse(b['date']));
        } catch (e) {
          return 0;
        }
      });
      
      return filtered.cast<Map<String, dynamic>>();
    } catch (e, stackTrace) {
      print('Error fetching period days: $e');
      return [];
    }
  }

  Color _getFlowColor(String flow) {
    switch (flow.toLowerCase()) {
      case 'light':
        return Colors.pink.shade200;
      case 'medium':
        return Colors.pink.shade400;
      case 'heavy':
        return Colors.red.shade600;
      default:
        return AppTheme.primaryPink;
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  void _showDeleteCycleDialog(String cycleId, CycleProvider cycleProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Cycle?', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        content: Text('Are you sure you want to delete this cycle? This action cannot be undone.', style: TextStyle(color: AppTheme.textGray)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textGray)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await cycleProvider.deleteCycle(cycleId);
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Cycle deleted successfully'), backgroundColor: Colors.green),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete cycle'), backgroundColor: Colors.red),
                );
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}