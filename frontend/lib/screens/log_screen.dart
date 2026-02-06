// File: frontend/lib/screens/log_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/cycle_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/animated_background.dart';
import 'package:intl/intl.dart';

class LogScreen extends StatefulWidget {
  @override
  _LogScreenState createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  // Period Tab State
  DateTime _selectedPeriodDate = DateTime.now();
  String _selectedFlow = 'medium';
  String _periodNotes = '';

  // Symptoms Tab State
  DateTime _selectedSymptomDate = DateTime.now();
  Map<String, double> _symptoms = {
    'cramps': 0,
    'headache': 0,
    'bloating': 0,
    'moodSwings': 0,
    'fatigue': 0,
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
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryPink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.edit_calendar, color: AppTheme.primaryPink, size: 28),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Log',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
                SizedBox(height: 4),
                Text(
                  'Track your period and symptoms',
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

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.primaryPink,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.textGray,
        labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        tabs: [
          Tab(
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
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms).scale(begin: Offset(0.95, 0.95));
  }

  Widget _buildPeriodTab() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),

          // Info Card
          GlassCard(
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.info_outline, color: AppTheme.primaryPink),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Log each day of your period. Track flow and symptoms daily.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textGray,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.2),

          SizedBox(height: 24),

          _buildDatePicker(
            'Period Date',
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
            'How are you feeling today?',
            _periodNotes,
            (value) => _periodNotes = value,
          ).animate().fadeIn(duration: 600.ms, delay: 500.ms).slideY(begin: 0.2),

          SizedBox(height: 32),

          _buildActionButton(
            'Log Period Day',
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
            'Any other symptoms or observations?',
            _symptomNotes,
            (value) => _symptomNotes = value,
          ).animate().fadeIn(duration: 600.ms, delay: 900.ms),

          SizedBox(height: 32),

          _buildActionButton(
            'Log Symptoms',
            Icons.check_circle,
            () => _handleSymptomLog(),
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 1000.ms)
              .scale(begin: Offset(0.9, 0.9)),

          SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime selectedDate,
    Function(DateTime) onDateChanged,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        SizedBox(height: 12),
        GlassCard(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime.now().subtract(Duration(days: 365)),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: AppTheme.primaryPink,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: AppTheme.textDark,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              onDateChanged(date);
            }
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
                      DateFormat('EEEE, MMMM d, yyyy').format(selectedDate),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textDark,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      DateFormat('h:mm a').format(selectedDate),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textGray,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppTheme.primaryPink),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFlowSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Flow Intensity',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            _buildFlowOption('Light', 'light', Icons.water_drop_outlined),
            SizedBox(width: 12),
            _buildFlowOption('Medium', 'medium', Icons.water_drop),
            SizedBox(width: 12),
            _buildFlowOption('Heavy', 'heavy', Icons.water_drop),
          ],
        ),
      ],
    );
  }

  Widget _buildFlowOption(String label, String value, IconData icon) {
    final isSelected = _selectedFlow == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFlow = value),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryPink
                : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryPink
                  : AppTheme.primaryPink.withOpacity(0.2),
              width: 2,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: AppTheme.primaryPink.withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppTheme.primaryPink,
                size: 32,
              ),
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppTheme.textDark,
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
      {'key': 'cramps', 'label': 'Cramps', 'icon': Icons.monitor_heart},
      {'key': 'headache', 'label': 'Headache', 'icon': Icons.psychology},
      {'key': 'bloating', 'label': 'Bloating', 'icon': Icons.circle},
      {'key': 'moodSwings', 'label': 'Mood Swings', 'icon': Icons.mood},
      {'key': 'fatigue', 'label': 'Fatigue', 'icon': Icons.battery_0_bar},
    ];

    return symptoms.asMap().entries.map((entry) {
      final index = entry.key;
      final symptom = entry.value;
      
      return Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: _buildSymptomSlider(
          symptom['label'] as String,
          symptom['key'] as String,
          symptom['icon'] as IconData,
        ),
      ).animate().fadeIn(
        duration: 600.ms,
        delay: (500 + (index * 50)).ms,
      ).slideX(begin: 0.2);
    }).toList();
  }

  Widget _buildSymptomSlider(String label, String key, IconData icon) {
    final value = _symptoms[key] ?? 0;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppTheme.primaryPink, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getIntensityColor(value).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${value.toInt()}/10',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _getIntensityColor(value),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _getIntensityColor(value),
              inactiveTrackColor: AppTheme.primaryPink.withOpacity(0.1),
              thumbColor: _getIntensityColor(value),
              overlayColor: _getIntensityColor(value).withOpacity(0.2),
              trackHeight: 6,
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 10,
              divisions: 10,
              onChanged: (newValue) {
                setState(() => _symptoms[key] = newValue);
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getIntensityColor(double value) {
    if (value <= 3) return AppTheme.successColor;
    if (value <= 6) return AppTheme.warning;
    return AppTheme.errorColor;
  }

  Widget _buildNotesField(
    String label,
    String hint,
    String value,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        SizedBox(height: 12),
        GlassCard(
          child: TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppTheme.textGray.withOpacity(0.6)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            style: TextStyle(color: AppTheme.textDark, fontSize: 15),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryPink, AppTheme.primaryPink.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withOpacity(0.4),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
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

    final success = await provider.logPeriodDay(
      _selectedPeriodDate,
      _selectedFlow,
      _periodNotes.isEmpty ? null : _periodNotes,
    );

    if (!mounted) return;
    Navigator.pop(context);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Period day logged successfully!'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      setState(() {
        _periodNotes = '';
        _selectedFlow = 'medium';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to log period day'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
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
      symptoms: _symptoms.map((key, value) => MapEntry(key, value.toInt())),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      setState(() {
        _symptomNotes = '';
        _symptoms = {
          'cramps': 0,
          'headache': 0,
          'bloating': 0,
          'moodSwings': 0,
          'fatigue': 0,
        };
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to log symptoms'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}