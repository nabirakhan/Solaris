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
                Icon(Icons.event_available, size: 16, color: AppTheme.textGray),
                SizedBox(width: 8),
                Text(
                  'Ended: ${DateFormat('MMM dd, yyyy').format(endDateTime)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textGray,
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 12),
          // Display period days with individual flow data
          _buildPeriodDaysList(startDate, endDate, duration),
          if (notes != null && notes.isNotEmpty) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.textGray.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note, size: 16, color: AppTheme.textGray),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notes,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textGray,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 16),
          Divider(height: 1),
          SizedBox(height: 12),
          _buildSymptomsList(startDate, endDate),
        ],
      ),
    );
  }

  // NEW: Widget to display period days with individual flow data
  Widget _buildPeriodDaysList(String startDate, String? endDate, int duration) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchPeriodDays(startDate, endDate),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryPink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppTheme.primaryPink),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Loading flow data...',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryPink,
                  ),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // Fallback to showing generic info
          return Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryPink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.water_drop, size: 20, color: AppTheme.primaryPink),
                SizedBox(width: 8),
                Text(
                  'Flow: Medium (default)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryPink,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$duration days',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryPink,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final periodDays = snapshot.data!;
        
        // Show individual flow days
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryPink.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.water_drop, size: 18, color: AppTheme.primaryPink),
                  SizedBox(width: 8),
                  Text(
                    'Flow Details (${periodDays.length} days)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: periodDays.map((day) => _buildFlowDayChip(day)).toList(),
            ),
          ],
        );
      },
    );
  }

  // NEW: Widget to show individual day with flow
  Widget _buildFlowDayChip(Map<String, dynamic> day) {
    final date = DateTime.parse(day['date']);
    final flow = day['flow'] ?? 'medium';
    final flowColor = _getFlowColor(flow);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: flowColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: flowColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.water_drop,
            size: 14,
            color: flowColor,
          ),
          SizedBox(width: 4),
          Text(
            DateFormat('MMM dd').format(date),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(width: 4),
          Text(
            _capitalizeFirst(flow),
            style: TextStyle(
              fontSize: 11,
              color: flowColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // NEW: Fetch period days for a specific cycle date range
  Future<List<Map<String, dynamic>>> _fetchPeriodDays(String startDate, String? endDate) async {
    try {
      final response = await _apiService.getPeriodDays();
      final allPeriodDays = response['periodDays'] as List<dynamic>;
      
      final startDateTime = DateTime.parse(startDate);
      final endDateToUse = endDate != null 
          ? DateTime.parse(endDate) 
          : DateTime.now().add(Duration(days: 1));
      
      final filtered = allPeriodDays.where((day) {
        final dayDate = DateTime.parse(day['date']);
        return !dayDate.isBefore(startDateTime) && !dayDate.isAfter(endDateToUse);
      }).toList();
      
      filtered.sort((a, b) => DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));
      
      return filtered.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching period days: $e');
      return [];
    }
  }

  Widget _buildSymptomsList(String startDate, String? endDate) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchSymptoms(startDate, endDate),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppTheme.primaryPink),
                strokeWidth: 2,
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No symptoms logged for this cycle',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textGray.withOpacity(0.6),
                fontStyle: FontStyle.italic,
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
                Icon(Icons.favorite, size: 16, color: AppTheme.primaryPink),
                SizedBox(width: 8),
                Text(
                  'Symptoms (${symptoms.length})',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            ...symptoms.map((symptom) => _buildSymptomItem(symptom)).toList(),
          ],
        );
      },
    );
  }

  Widget _buildSymptomItem(Map<String, dynamic> symptom) {
    final date = DateTime.parse(symptom['date']);
    final symptoms = symptom['symptoms'] as Map<String, dynamic>?;
    final sleepHours = symptom['sleepHours'];
    final stressLevel = symptom['stressLevel'];
    final notes = symptom['notes'];
    final symptomId = symptom['_id'] ?? symptom['id'];
    
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryPink.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryPink.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMM dd, yyyy').format(date),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, size: 18, color: AppTheme.primaryPink),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                onPressed: () => _showEditSymptomDialog(symptomId, symptom),
              ),
            ],
          ),
          if (symptoms != null && symptoms.isNotEmpty) ...[
            SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: symptoms.entries.map((entry) {
                if (entry.value > 0) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPink.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_capitalizeFirst(entry.key)}: ${entry.value}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textDark,
                      ),
                    ),
                  );
                }
                return SizedBox.shrink();
              }).toList(),
            ),
          ],
          if (sleepHours != null || stressLevel != null) ...[
            SizedBox(height: 6),
            Row(
              children: [
                if (sleepHours != null) ...[
                  Icon(Icons.bedtime, size: 14, color: AppTheme.textGray),
                  SizedBox(width: 4),
                  Text(
                    '${sleepHours}h',
                    style: TextStyle(fontSize: 11, color: AppTheme.textGray),
                  ),
                  SizedBox(width: 12),
                ],
                if (stressLevel != null) ...[
                  Icon(Icons.psychology, size: 14, color: AppTheme.textGray),
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
            SizedBox(height: 6),
            Text(
              notes,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textGray,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchSymptoms(String startDate, String? endDate) async {
    try {
      final allSymptoms = await _apiService.getSymptomLogs();
      
      final startDateTime = DateTime.parse(startDate);
      final endDateToUse = endDate != null 
          ? DateTime.parse(endDate) 
          : DateTime.now().add(Duration(days: 1));
      
      final filtered = allSymptoms.where((symptom) {
        final symptomDate = DateTime.parse(symptom['date']);
        return !symptomDate.isBefore(startDateTime) && !symptomDate.isAfter(endDateToUse);
      }).toList();
      
      filtered.sort((a, b) => DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));
      
      return filtered.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching symptoms: $e');
      return [];
    }
  }

  void _showEditSymptomDialog(String symptomId, Map<String, dynamic> symptomData) {
    Map<String, double> symptoms = {};
    
    if (symptomData['symptoms'] != null) {
      final rawSymptoms = symptomData['symptoms'] as Map<String, dynamic>;
      rawSymptoms.forEach((key, value) {
        symptoms[key] = (value is int) ? value.toDouble() : (value as num).toDouble();
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

    double sleepHours = (symptomData['sleepHours'] ?? 7.0) is int 
        ? (symptomData['sleepHours'] as int).toDouble() 
        : (symptomData['sleepHours'] ?? 7.0) as double;
    
    int stressLevel = (symptomData['stressLevel'] ?? 0) is int 
        ? symptomData['stressLevel'] as int 
        : ((symptomData['stressLevel'] ?? 0) as num).toInt();
    
    String notes = symptomData['notes'] ?? '';

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
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Symptoms updated'), backgroundColor: Colors.green),
                  );
                }
              },
              child: Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    ).then((_) => setState(() {}));
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
            Text('${value.toInt()}/10', style: TextStyle(fontSize: 12, color: AppTheme.textGray)),
          ],
        ),
        Slider(
          value: value,
          min: 0,
          max: 10,
          divisions: 10,
          label: value.toInt().toString(),
          onChanged: (newValue) => setState(() => symptoms[key] = newValue),
        ),
        SizedBox(height: 8),
      ],
    );
  }

  // NEW: Show dialog to edit individual flow days
  void _showEditFlowDaysDialog(String cycleId, String startDate, String? endDate, String? cycleNotes, CycleProvider cycleProvider) async {
    // Fetch period days first
    final periodDays = await _fetchPeriodDays(startDate, endDate);
    
    if (periodDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No flow days found for this cycle'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Create a map to track flow changes
    Map<String, String> flowChanges = {};
    periodDays.forEach((day) {
      flowChanges[day['_id'] ?? day['id']] = day['flow'] ?? 'medium';
    });

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
                  if (notes != cycleNotes) {
                    await _apiService.updateCycle(
                      id: cycleId,
                      notes: notes.isEmpty ? null : notes,
                    );
                  }
                  
                  // Reload cycles to reflect changes
                  await cycleProvider.loadCycles();
                  
                  setState(() {});
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Flow days updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update flow days'),
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