// File: frontend/lib/screens/log_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/cycle_provider.dart';
import '../theme/app_theme.dart';

class LogScreen extends StatefulWidget {
  @override
  _LogScreenState createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen>
    with SingleTickerProviderStateMixin {
  
  DateTime _selectedDate = DateTime.now();
  String _selectedFlow = 'medium';
  
  double _cramps = 0;
  double _mood = 5;
  double _energy = 5;
  double _headache = 0;
  double _bloating = 0;
  double _sleepHours = 7;
  int _stressLevel = 5;
  
  bool _isLoggingPeriod = true;
  bool _isLoading = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: AppTheme.normal,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0.05, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _switchTab(bool isPeriod) {
    setState(() {
      _isLoggingPeriod = isPeriod;
    });
    _animationController.reset();
    _animationController.forward();
  }
  
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(Duration(days: 90)),
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
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  Future<void> _logPeriod() async {
    setState(() {
      _isLoading = true;
    });
    
    final cycleProvider = Provider.of<CycleProvider>(context, listen: false);
    final success = await cycleProvider.startNewCycle(
      _selectedDate,
      _selectedFlow,
      null,
    );
    
    setState(() {
      _isLoading = false;
    });
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Period logged successfully!')),
            ],
          ),
          backgroundColor: AppTheme.primaryPink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          duration: Duration(seconds: 2),
        ),
      );
      
      await cycleProvider.loadCycles();
      await cycleProvider.loadCurrentInsights();
      
      // Auto-switch to symptoms tab after a delay
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          _switchTab(false);
        }
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Failed to log period. Please try again.')),
            ],
          ),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
      );
    }
  }
  
  Future<void> _logSymptoms() async {
    setState(() {
      _isLoading = true;
    });
    
    final cycleProvider = Provider.of<CycleProvider>(context, listen: false);
    
    final success = await cycleProvider.logSymptoms(
      date: _selectedDate,
      symptoms: {
        'cramps': _cramps.toInt(),
        'mood': _mood.toInt(),
        'energy': _energy.toInt(),
        'headache': _headache.toInt(),
        'bloating': _bloating.toInt(),
      },
      sleepHours: _sleepHours,
      stressLevel: _stressLevel,
      notes: null,
    );
    
    setState(() {
      _isLoading = false;
    });
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Symptoms logged successfully!')),
            ],
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
      );
      
      setState(() {
        _cramps = 0;
        _mood = 5;
        _energy = 5;
        _headache = 0;
        _bloating = 0;
        _sleepHours = 7;
        _stressLevel = 5;
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Failed to log symptoms. Please try again.')),
            ],
          ),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.almostWhite,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(AppTheme.spaceL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Log',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  SizedBox(height: AppTheme.spaceS),
                  Text(
                    'Track your cycle and symptoms',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppTheme.spaceL),
              child: _buildToggleButtons(),
            ),
            
            SizedBox(height: AppTheme.spaceL),
            
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: AppTheme.spaceL),
                    child: _isLoggingPeriod
                        ? _buildPeriodLogging()
                        : _buildSymptomLogging(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildToggleButtons() {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: AppTheme.fast,
              curve: Curves.easeInOut,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _switchTab(true),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: _isLoggingPeriod
                          ? AppTheme.primaryGradient
                          : null,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.water_drop,
                          color: _isLoggingPeriod
                              ? Colors.white
                              : AppTheme.textGray,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Period',
                          style: TextStyle(
                            color: _isLoggingPeriod
                                ? Colors.white
                                : AppTheme.textGray,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: AnimatedContainer(
              duration: AppTheme.fast,
              curve: Curves.easeInOut,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _switchTab(false),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: !_isLoggingPeriod
                          ? AppTheme.primaryGradient
                          : null,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.healing,
                          color: !_isLoggingPeriod
                              ? Colors.white
                              : AppTheme.textGray,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Symptoms',
                          style: TextStyle(
                            color: !_isLoggingPeriod
                                ? Colors.white
                                : AppTheme.textGray,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPeriodLogging() {
    return Column(
      children: [
        Card(
          child: InkWell(
            onTap: _selectDate,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spaceL),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.blushPink,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: Icon(
                      Icons.calendar_today,
                      color: AppTheme.primaryPink,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: AppTheme.spaceM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        SizedBox(height: 4),
                        Text(
                          DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppTheme.textLight),
                ],
              ),
            ),
          ),
        ),
        
        SizedBox(height: AppTheme.spaceM),
        
        Card(
          child: Padding(
            padding: EdgeInsets.all(AppTheme.spaceL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Flow Intensity',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: AppTheme.spaceM),
                Row(
                  children: [
                    Expanded(child: _buildFlowOption('light', '💧', 'Light')),
                    SizedBox(width: AppTheme.spaceM),
                    Expanded(child: _buildFlowOption('medium', '💧💧', 'Medium')),
                    SizedBox(width: AppTheme.spaceM),
                    Expanded(child: _buildFlowOption('heavy', '💧💧💧', 'Heavy')),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        SizedBox(height: AppTheme.spaceXL),
        
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _logPeriod,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPink,
              disabledBackgroundColor: AppTheme.textLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              elevation: 4,
            ),
            child: _isLoading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Log Period Start',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        
        SizedBox(height: AppTheme.spaceL),
      ],
    );
  }
  
  Widget _buildSymptomLogging() {
    return Column(
      children: [
        _buildSymptomSlider(
          'Cramps',
          _cramps,
          (val) => setState(() => _cramps = val),
          Icons.healing,
          Colors.red,
        ),
        
        _buildSymptomSlider(
          'Mood',
          _mood,
          (val) => setState(() => _mood = val),
          Icons.sentiment_satisfied,
          Colors.orange,
        ),
        
        _buildSymptomSlider(
          'Energy',
          _energy,
          (val) => setState(() => _energy = val),
          Icons.battery_charging_full,
          Colors.green,
        ),
        
        _buildSymptomSlider(
          'Headache',
          _headache,
          (val) => setState(() => _headache = val),
          Icons.local_hospital,
          Colors.purple,
        ),
        
        _buildSymptomSlider(
          'Bloating',
          _bloating,
          (val) => setState(() => _bloating = val),
          Icons.circle,
          Colors.blue,
        ),
        
        Card(
          child: Padding(
            padding: EdgeInsets.all(AppTheme.spaceL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.bedtime, color: AppTheme.primaryPink, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Sleep Hours',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.spaceS),
                Slider(
                  value: _sleepHours,
                  min: 0,
                  max: 12,
                  divisions: 24,
                  activeColor: AppTheme.primaryPink,
                  inactiveColor: AppTheme.blushPink,
                  label: '${_sleepHours.toStringAsFixed(1)}h',
                  onChanged: (val) => setState(() => _sleepHours = val),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0h', style: Theme.of(context).textTheme.bodyMedium),
                    Text(
                      '${_sleepHours.toStringAsFixed(1)} hours',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryPink,
                      ),
                    ),
                    Text('12h', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        SizedBox(height: AppTheme.spaceXL),
        
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _logSymptoms,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPink,
              disabledBackgroundColor: AppTheme.textLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              elevation: 4,
            ),
            child: _isLoading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Log Symptoms',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        
        SizedBox(height: AppTheme.spaceL),
      ],
    );
  }
  
  Widget _buildFlowOption(String value, String emoji, String label) {
    final isSelected = _selectedFlow == value;
    
    return AnimatedContainer(
      duration: AppTheme.fast,
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedFlow = value),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: isSelected ? AppTheme.primaryGradient : null,
              color: isSelected ? null : AppTheme.blushPink,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(
                color: isSelected ? Colors.transparent : AppTheme.divider,
                width: 1,
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
                Text(
                  emoji,
                  style: TextStyle(fontSize: isSelected ? 28 : 24),
                ),
                SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSymptomSlider(
    String label,
    double value,
    Function(double) onChanged,
    IconData icon,
    Color accentColor,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: AppTheme.spaceM),
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spaceL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Icon(icon, color: accentColor, size: 20),
                ),
                SizedBox(width: 12),
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            SizedBox(height: AppTheme.spaceS),
            Slider(
              value: value,
              min: 0,
              max: 10,
              divisions: 10,
              activeColor: accentColor,
              inactiveColor: accentColor.withOpacity(0.2),
              label: value.toInt().toString(),
              onChanged: onChanged,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('None', style: Theme.of(context).textTheme.bodyMedium),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
                Text('Severe', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}