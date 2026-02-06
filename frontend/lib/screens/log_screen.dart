// File: lib/screens/log_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/cycle_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/animated_background.dart';

class LogScreen extends StatefulWidget {
  @override
  _LogScreenState createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  DateTime _selectedPeriodDate = DateTime.now();
  String _selectedFlow = 'medium';
  String _periodNotes = '';

  DateTime _selectedSymptomDate = DateTime.now();
  Map<String, double> _symptoms = {
    'cramps': 0,
    'irritability': 5,
    'energy': 5,
    'headache': 0,
    'bloating': 0,
  };
  double _sleepHours = 7;
  double _stressLevel = 5;
  String _symptomNotes = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _fabController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _fabController.forward(from: 0);
      }
    });

    _fabController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fabController.dispose();
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
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: BouncingScrollPhysics(),
                  children: [
                    _buildPeriodTab(),
                    _buildSymptomsTab(),
                  ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Log Your Data',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
          SizedBox(height: 8),
          Text(
            'Track your journey, understand your body',
            style: TextStyle(
              fontSize: 15,
              color: AppTheme.textGray,
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 100.ms),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: GlassCard(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.all(4),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryPink.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          labelColor: Colors.white,
          unselectedLabelColor: AppTheme.textGray,
          labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          tabs: [
            // Explicit height constrains the Tab so its Row child
            // cannot overflow the indicator box.
            Tab(
              height: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.water_drop, size: 18),
                  SizedBox(width: 8),
                  Text('Period'),
                ],
              ),
            ),
            Tab(
              height: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite, size: 18),
                  SizedBox(width: 8),
                  Text('Symptoms'),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate()
        .fadeIn(duration: 600.ms, delay: 200.ms)
        .scale(begin: Offset(0.95, 0.95));
  }

  Widget _buildPeriodTab() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),

          _buildDatePicker(
            'Period Start Date',
            _selectedPeriodDate,
            (date) => setState(() => _selectedPeriodDate = date),
            Icons.calendar_today,
          ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideY(begin: 0.2),

          SizedBox(height: 24),

          _buildFlowSelector()
              .animate()
              .fadeIn(duration: 600.ms, delay: 400.ms)
              .slideY(begin: 0.2),

          SizedBox(height: 24),

          _buildNotesField(
            'Notes (Optional)',
            'How are you feeling?',
            _periodNotes,
            (value) => _periodNotes = value,
          ).animate().fadeIn(duration: 600.ms, delay: 500.ms).slideY(begin: 0.2),

          SizedBox(height: 32),

          _buildActionButton(
            'Log Period',
            Icons.check_circle,
            () => _handlePeriodLog(),
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 600.ms)
              .scale(begin: Offset(0.9, 0.9)),

          SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSymptomsTab() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),

          _buildDatePicker(
            'Symptom Date',
            _selectedSymptomDate,
            (date) => setState(() => _selectedSymptomDate = date),
            Icons.calendar_today,
          ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideY(begin: 0.2),

          SizedBox(height: 24),

          Text(
            'How are you feeling?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 400.ms),

          SizedBox(height: 16),

          ..._buildSymptomSliders(),

          SizedBox(height: 24),

          _buildNotesField(
            'Additional Notes',
            'Anything else to track?',
            _symptomNotes,
            (value) => _symptomNotes = value,
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 1000.ms)
              .slideY(begin: 0.2),

          SizedBox(height: 32),

          _buildActionButton(
            'Log Symptoms',
            Icons.favorite,
            () => _handleSymptomLog(),
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 1100.ms)
              .scale(begin: Offset(0.9, 0.9)),

          SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime selectedDate,
      Function(DateTime) onDateSelected, IconData icon) {
    return GlassCard(
      margin: EdgeInsets.zero,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime.now().subtract(Duration(days: 365)),
          lastDate: DateTime.now().add(Duration(days: 30)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme:
                    ColorScheme.light(primary: AppTheme.primaryPink),
              ),
              child: child!,
            );
          },
        );
        if (date != null) onDateSelected(date);
      },
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryPink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryPink),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppTheme.primaryPink),
        ],
      ),
    );
  }

  Widget _buildFlowSelector() {
    return GlassCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.water_drop, color: AppTheme.primaryPink, size: 20),
              SizedBox(width: 8),
              Text(
                'Flow Intensity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _buildFlowOption('light', 'Light', Icons.water_drop_outlined),
              SizedBox(width: 12),
              _buildFlowOption('medium', 'Medium', Icons.water_drop),
              SizedBox(width: 12),
              _buildFlowOption('heavy', 'Heavy', Icons.waves),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFlowOption(String value, String label, IconData icon) {
    final isSelected = _selectedFlow == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFlow = value),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: isSelected ? AppTheme.primaryGradient : null,
            color: isSelected ? null : AppTheme.almostWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.transparent : AppTheme.divider,
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryPink.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppTheme.textGray,
                size: 28,
              ),
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppTheme.textGray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSymptomSliders() {
    final symptoms = [
      {
        'key': 'cramps',
        'label': 'Cramps',
        'icon': Icons.warning_amber,
        'color': AppTheme.menstrualPhase
      },
      {
        'key': 'irritability',
        'label': 'Irritability',
        'icon': Icons.sentiment_very_dissatisfied,
        'color': AppTheme.ovulationPhase
      },
      {
        'key': 'energy',
        'label': 'Energy',
        'icon': Icons.battery_charging_full,
        'color': AppTheme.follicularPhase
      },
      {
        'key': 'headache',
        'label': 'Headache',
        'icon': Icons.psychology,
        'color': AppTheme.lutealPhase
      },
      {
        'key': 'bloating',
        'label': 'Bloating',
        'icon': Icons.air,
        'color': AppTheme.primaryPurple
      },
    ];

    return symptoms.asMap().entries.map((entry) {
      final index = entry.key;
      final symptom = entry.value;
      return _buildSymptomSlider(
        symptom['label'] as String,
        symptom['key'] as String,
        symptom['icon'] as IconData,
        symptom['color'] as Color,
        index,
      );
    }).toList();
  }

  Widget _buildSymptomSlider(
      String label, String key, IconData icon, Color color, int index) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: GlassCard(
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_symptoms[key]!.toInt()}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 6,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 20),
                activeTrackColor: color,
                inactiveTrackColor: color.withOpacity(0.2),
                thumbColor: color,
                overlayColor: color.withOpacity(0.2),
              ),
              child: Slider(
                value: _symptoms[key]!,
                min: 0,
                max: 10,
                divisions: 10,
                onChanged: (value) =>
                    setState(() => _symptoms[key] = value),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('None',
                    style: TextStyle(fontSize: 12, color: AppTheme.textGray)),
                Text('Severe',
                    style: TextStyle(fontSize: 12, color: AppTheme.textGray)),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
            duration: 600.ms,
            delay: Duration(milliseconds: 500 + (index * 100)))
        .slideX(begin: -0.2);
  }

  Widget _buildNotesField(String label, String hint, String value,
      Function(String) onChanged) {
    return GlassCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: 12),
          TextField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: AppTheme.almostWhite,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, VoidCallback onTap) {
    return ScaleTransition(
      scale: _fabAnimation,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryPink.withOpacity(0.4),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handlePeriodLog() async {
    final provider = Provider.of<CycleProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(AppTheme.primaryPink),
        ),
      ),
    );

    final success = await provider.startNewCycle(
      _selectedPeriodDate,
      _selectedFlow,
      _periodNotes.isEmpty ? null : _periodNotes,
    );

    if (!mounted) return;
    Navigator.pop(context);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Period logged successfully!'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );

      setState(() {
        _periodNotes = '';
        _selectedFlow = 'medium';
      });
    }
  }

  Future<void> _handleSymptomLog() async {
    final provider = Provider.of<CycleProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(AppTheme.primaryPink),
        ),
      ),
    );

    final success = await provider.logSymptoms(
      date: _selectedSymptomDate,
      symptoms:
          _symptoms.map((key, value) => MapEntry(key, value.toInt())),
      sleepHours: _sleepHours,
      stressLevel: _stressLevel.toInt(),
      notes: _symptomNotes.isEmpty ? null : _symptomNotes,
    );

    if (!mounted) return;
    Navigator.pop(context);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Symptoms logged successfully!'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );

      setState(() {
        _symptomNotes = '';
        _symptoms = {
          'cramps': 0,
          'irritability': 5,
          'energy': 5,
          'headache': 0,
          'bloating': 0,
        };
      });
    }
  }
}