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
                onPressed: () => _showEditCycleDialog(cycle, cycleProvider),
                tooltip: 'Edit Cycle',
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
          _buildSymptomsList(cycleId, startDate, endDate),
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

  Widget _buildSymptomsList(String cycleId, String startDate, String? endDate) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchSymptoms(cycleId, startDate, endDate),
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
            SizedBox(height: 12),
            ...symptoms.take(3).map((symptom) => _buildSymptomItem(symptom)).toList(),
            if (symptoms.length > 3)
              TextButton.icon(
                onPressed: () => _showAllSymptoms(symptoms),
                icon: Icon(Icons.expand_more, size: 16),
                label: Text('View all ${symptoms.length} entries'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryPink,
                  padding: EdgeInsets.zero,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSymptomItem(Map<String, dynamic> symptom) {
    final date = DateTime.parse(symptom['date']);
    final symptoms = symptom['symptoms'] as Map<String, dynamic>?;
    
    return InkWell(
      onTap: () => _showEditSymptomDialog(symptom),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.primaryPink.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.primaryPink.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 14, color: AppTheme.textGray),
            SizedBox(width: 8),
            Text(
              DateFormat('MMM dd').format(date),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            SizedBox(width: 12),
            if (symptoms != null && symptoms.isNotEmpty) ...[
              Expanded(
                child: Text(
                  _getSymptomSummary(symptoms),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textGray,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            Icon(Icons.edit, size: 14, color: AppTheme.primaryPink),
          ],
        ),
      ),
    );
  }

  String _getSymptomSummary(Map<String, dynamic> symptoms) {
    final active = <String>[];
    symptoms.forEach((key, value) {
      if (value != null && (value is num && value > 0)) {
        active.add(_capitalizeFirst(key));
      }
    });
    return active.isEmpty ? 'No symptoms' : active.join(', ');
  }

  void _showAllSymptoms(List<Map<String, dynamic>> symptoms) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.favorite, color: AppTheme.primaryPink),
                    SizedBox(width: 12),
                    Text(
                      'All Symptom Entries',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Divider(),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.all(20),
                  itemCount: symptoms.length,
                  itemBuilder: (context, index) => _buildSymptomItem(symptoms[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchSymptoms(String cycleId, String startDate, String? endDate) async {
    try {
      final allSymptoms = await _apiService.getSymptoms();
      final startDateTime = DateTime.parse(startDate);
      final endDateToUse = endDate != null ? DateTime.parse(endDate) : DateTime.now().add(Duration(days: 1));
      
      final filtered = allSymptoms.where((symptom) {
        final symptomDate = DateTime.parse(symptom['date']);
        return !symptomDate.isBefore(startDateTime) && !symptomDate.isAfter(endDateToUse);
      }).toList();
      
      filtered.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
      
      return filtered.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching symptoms: $e');
      return [];
    }
  }

  void _showEditSymptomDialog(Map<String, dynamic> symptom) {
    final symptomId = symptom['_id'] ?? symptom['id'];
    final date = DateTime.parse(symptom['date']);
    Map<String, double> symptoms = {};
    
    (symptom['symptoms'] as Map<String, dynamic>?)?.forEach((key, value) {
      double parsedValue = (value is num) ? value.toDouble() : double.tryParse(value.toString()) ?? 0.0;
      symptoms[key] = parsedValue.clamp(0.0, 10.0);
    });
    
    final sleepHoursValue = symptom['sleep_hours'] ?? symptom['sleepHours'] ?? 7.0;
    double sleepHours = (sleepHoursValue is num) ? sleepHoursValue.toDouble() : double.tryParse(sleepHoursValue.toString()) ?? 7.0;
    sleepHours = sleepHours.clamp(0.0, 12.0);
    
    final stressLevelValue = symptom['stress_level'] ?? symptom['stressLevel'] ?? 0;
    int stressLevel = (stressLevelValue is num) ? stressLevelValue.toInt() : int.tryParse(stressLevelValue.toString()) ?? 0;
    stressLevel = stressLevel.clamp(0, 5);
    
    String notes = symptom['notes']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Symptoms', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              SizedBox(height: 4),
              Text(
                DateFormat('MMMM dd, yyyy').format(date),
                style: TextStyle(fontSize: 14, color: AppTheme.textGray, fontWeight: FontWeight.normal),
              ),
            ],
          ),
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

  void _showEditCycleDialog(Map<String, dynamic> cycle, CycleProvider cycleProvider) {
    final cycleId = cycle['_id'] ?? cycle['id'];
    String flow = cycle['flow'] ?? 'medium';
    String notes = cycle['notes'] ?? '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Edit Cycle', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Flow', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: flow,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: ['light', 'medium', 'heavy'].map((f) => DropdownMenuItem(value: f, child: Text(_capitalizeFirst(f)))).toList(),
                onChanged: (value) => setState(() => flow = value!),
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
                  await _apiService.updateCycle(id: cycleId, flow: flow, notes: notes.isEmpty ? null : notes);
                  await cycleProvider.loadCycles();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Cycle updated'), backgroundColor: Colors.green),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update cycle'), backgroundColor: Colors.red),
                  );
                }
              },
              child: Text('Save', style: TextStyle(color: Colors.white)),
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