import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/health_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/metric_card.dart';

class HealthMetricsScreen extends StatefulWidget {
  @override
  _HealthMetricsScreenState createState() => _HealthMetricsScreenState();
}

class _HealthMetricsScreenState extends State<HealthMetricsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  
  bool _useMetric = true; // true = cm/kg, false = ft/lbs
  DateTime? _selectedBirthdate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<HealthProvider>(context, listen: false);
      provider.loadHealthMetrics();
      
      if (provider.healthMetrics != null) {
        _populateFields(provider.healthMetrics!);
      }
    });
  }

  void _populateFields(Map<String, dynamic> metrics) {
    if (metrics['birthdate'] != null) {
      _selectedBirthdate = DateTime.parse(metrics['birthdate']);
      _ageController.text = metrics['age']?.toString() ?? '';
    }
    
    if (metrics['height'] != null) {
      _heightController.text = metrics['height'].toString();
    }
    
    if (metrics['weight'] != null) {
      _weightController.text = metrics['weight'].toString();
    }
    
    _useMetric = metrics['useMetric'] ?? true;
  }

  Future<void> _selectBirthdate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthdate ?? DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryPink,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedBirthdate = picked;
        final age = _calculateAge(picked);
        _ageController.text = age.toString();
      });
    }
  }

  int _calculateAge(DateTime birthdate) {
    final now = DateTime.now();
    int age = now.year - birthdate.year;
    if (now.month < birthdate.month || 
        (now.month == birthdate.month && now.day < birthdate.day)) {
      age--;
    }
    return age;
  }

  double? _calculateBMI() {
    if (_heightController.text.isEmpty || _weightController.text.isEmpty) {
      return null;
    }
    
    double height = double.tryParse(_heightController.text) ?? 0;
    double weight = double.tryParse(_weightController.text) ?? 0;
    
    if (height == 0 || weight == 0) return null;
    
    // Convert to metric if needed
    if (!_useMetric) {
      // Convert ft/in to cm and lbs to kg
      height = height * 30.48; // feet to cm
      weight = weight * 0.453592; // lbs to kg
    }
    
    // BMI = weight(kg) / (height(m))^2
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return AppTheme.warningColor;
    if (bmi < 25) return AppTheme.successColor;
    if (bmi < 30) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  Future<void> _saveMetrics() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedBirthdate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select your birthdate'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    
    final provider = Provider.of<HealthProvider>(context, listen: false);
    
    final success = await provider.saveHealthMetrics(
      birthdate: _selectedBirthdate!,
      height: double.tryParse(_heightController.text) ?? 0,
      weight: double.tryParse(_weightController.text) ?? 0,
      useMetric: _useMetric,
    );
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Health metrics saved!'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save metrics'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bmi = _calculateBMI();
    
    return Scaffold(
      backgroundColor: AppTheme.almostWhite,
      appBar: AppBar(
        title: Text('Health Metrics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveMetrics,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Track Your Health',
                  style: Theme.of(context).textTheme.headlineMedium,
                ).animate().fadeIn().slideX(begin: -0.2),
                
                SizedBox(height: 8),
                
                Text(
                  'Monitor how your body changes',
                  style: Theme.of(context).textTheme.bodyMedium,
                ).animate().fadeIn(delay: 200.ms),
                
                SizedBox(height: 32),
                
                // Metric Toggle
                GlassCard(
                  margin: EdgeInsets.zero,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Units',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            _useMetric ? 'Metric (cm/kg)' : 'Imperial (ft/lbs)',
                            style: TextStyle(
                              color: AppTheme.textGray,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 8),
                          Switch(
                            value: _useMetric,
                            activeColor: AppTheme.primaryPink,
                            onChanged: (value) {
                              setState(() {
                                _useMetric = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                
                SizedBox(height: 20),
                
                // Age/Birthdate
                GlassCard(
                  margin: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.cake, color: AppTheme.primaryPink),
                          SizedBox(width: 12),
                          Text(
                            'Age',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 16),
                      
                      InkWell(
                        onTap: _selectBirthdate,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Birthdate',
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _selectedBirthdate != null
                                ? '${_selectedBirthdate!.day}/${_selectedBirthdate!.month}/${_selectedBirthdate!.year}'
                                : 'Select your birthdate',
                            style: TextStyle(
                              color: _selectedBirthdate != null
                                  ? AppTheme.textDark
                                  : AppTheme.textGray,
                            ),
                          ),
                        ),
                      ),
                      
                      if (_selectedBirthdate != null) ...[
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.blushPink.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'You are ',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                '${_calculateAge(_selectedBirthdate!)}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryPink,
                                ),
                              ),
                              Text(
                                ' years old',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
                
                SizedBox(height: 20),
                
                // Height & Weight
                Row(
                  children: [
                    Expanded(
                      child: GlassCard(
                        margin: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.height, color: AppTheme.primaryPink, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Height',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            TextFormField(
                              controller: _heightController,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: _useMetric ? 'cm' : 'ft',
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.5),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: GlassCard(
                        margin: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.monitor_weight, color: AppTheme.primaryPink, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Weight',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            TextFormField(
                              controller: _weightController,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: _useMetric ? 'kg' : 'lbs',
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.5),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),
                
                SizedBox(height: 20),
                
                // BMI Card
                if (bmi != null)
                  GlassCard(
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.favorite, color: _getBMIColor(bmi)),
                            SizedBox(width: 12),
                            Text(
                              'Body Mass Index (BMI)',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 24),
                        
                        Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: _getBMIColor(bmi).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _getBMIColor(bmi).withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                bmi.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: _getBMIColor(bmi),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                _getBMICategory(bmi),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: _getBMIColor(bmi),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: 16),
                        
                        // BMI Reference Chart
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BMI Categories:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 8),
                              _buildBMIRange('< 18.5', 'Underweight', Colors.orange),
                              _buildBMIRange('18.5 - 24.9', 'Normal', Colors.green),
                              _buildBMIRange('25 - 29.9', 'Overweight', Colors.orange),
                              _buildBMIRange('≥ 30', 'Obese', Colors.red),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 1000.ms).scale(),
                
                SizedBox(height: 32),
                
                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveMetrics,
                    icon: Icon(Icons.save),
                    label: Text('Save Health Metrics'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.primaryPink,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 1200.ms),
                
                SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBMIRange(String range, String category, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8),
          Text(
            '$range - ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          Text(
            category,
            style: TextStyle(
              color: AppTheme.textGray,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }
}