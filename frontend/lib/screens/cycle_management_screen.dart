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
          if (!isActive) ...[
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.event_available, size: 16, color: AppTheme.textGray),
                SizedBox(width: 8),
                Text(
                  'Ended: ${DateFormat('MMM dd, yyyy').format(endDateTime!)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textGray,
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: AppTheme.textGray),
              SizedBox(width: 8),
              Text(
                'Duration: $duration ${duration == 1 ? "day" : "days"}',
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
                color: AppTheme.lightPink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.note, size: 16, color: AppTheme.textGray),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notes,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textGray,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 12),
          _buildSymptomsSectionForCycle(startDateTime, endDateTime),
        ],
      ),
    );
  }

  Widget _buildSymptomsSectionForCycle(DateTime startDate, DateTime? endDate) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchSymptomsForDateRange(startDate, endDate),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: AppTheme.textGray),
                SizedBox(width: 8),
                Text(
                  'No symptoms logged for this cycle',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textGray,
                  ),
                ),
              ],
            ),
          );
        }

        final symptoms = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(),
            SizedBox(height: 8),
            Text(
              'Logged Symptoms & Notes',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            SizedBox(height: 8),
            ...symptoms.map((symptom) => _buildSymptomDayCard(symptom)),
          ],
        );
      },
    );
  }

  Widget _buildSymptomDayCard(Map<String, dynamic> symptom) {
    final date = DateTime.parse(symptom['date']);
    final symptoms = symptom['symptoms'] as Map<String, dynamic>? ?? {};
    final notes = symptom['notes'];
    final sleepHours = symptom['sleep_hours'] ?? symptom['sleepHours'];
    final stressLevel = symptom['stress_level'] ?? symptom['stressLevel'];

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.lightPink.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.textGray.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              Spacer(),
              IconButton(
                icon: Icon(Icons.edit, size: 18, color: AppTheme.primaryPink),
                onPressed: () => _showEditSymptomDialog(symptom),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ],
          ),
          if (symptoms.isNotEmpty) ...[
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: symptoms.entries.map((entry) {
                if (entry.value == 0) return SizedBox.shrink();
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_capitalizeFirst(entry.key)}: ${entry.value}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textDark,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          if (sleepHours != null) ...[
            SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.bedtime, size: 14, color: AppTheme.textGray),
                SizedBox(width: 6),
                Text(
                  'Sleep: ${sleepHours}h',
                  style: TextStyle(fontSize: 12, color: AppTheme.textGray),
                ),
              ],
            ),
          ],
          if (stressLevel != null) ...[
            SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.psychology, size: 14, color: AppTheme.textGray),
                SizedBox(width: 6),
                Text(
                  'Stress: $stressLevel/5',
                  style: TextStyle(fontSize: 12, color: AppTheme.textGray),
                ),
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

  Future<List<Map<String, dynamic>>> _fetchSymptomsForDateRange(DateTime startDate, DateTime? endDate) async {
    try {
      final allSymptoms = await _apiService.getSymptomLogs();
      final endDateToUse = endDate ?? DateTime.now();
      
      final filtered = allSymptoms.where((symptom) {
        final symptomDate = DateTime.parse(symptom['date']);
        return !symptomDate.isBefore(startDate) && !symptomDate.isAfter(endDateToUse);
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
      symptoms[key] = value.toDouble();
    });
    
    double sleepHours = (symptom['sleep_hours'] ?? symptom['sleepHours'] ?? 7.0).toDouble();
    int stressLevel = (symptom['stress_level'] ?? symptom['stressLevel'] ?? 0);
    String notes = symptom['notes'] ?? '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Edit Symptoms - ${DateFormat('MMM dd').format(date)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSymptomSlider('Cramps', 'cramps', symptoms, setState),
                _buildSymptomSlider('Bloating', 'bloating', symptoms, setState),
                _buildSymptomSlider('Headache', 'headache', symptoms, setState),
                _buildSymptomSlider('Mood', 'mood', symptoms, setState),
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
    final value = symptoms[key] ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        Slider(
          value: value,
          min: 0,
          max: 5,
          divisions: 5,
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