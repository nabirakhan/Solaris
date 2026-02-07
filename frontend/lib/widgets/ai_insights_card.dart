// File: lib/widgets/ai_insights_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class AIInsightsCard extends StatelessWidget {
  final Map<String, dynamic>? insights;
  final VoidCallback? onRefresh;
  final bool isLoading;

  const AIInsightsCard({
    Key? key,
    this.insights,
    this.onRefresh,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return GlassCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPink),
            ),
          ),
        ),
      );
    }

    if (insights == null || insights!.isEmpty) {
      return GlassCard(
        child: Column(
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 48,
              color: AppTheme.textLight,
            ),
            const SizedBox(height: 16),
            Text(
              'No AI Insights Yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Log more cycles to get personalized insights',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (onRefresh != null)
              ElevatedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Generate Insights'),
              ),
          ],
        ),
      );
    }

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Insights',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      'Powered by Machine Learning',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (onRefresh != null)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: onRefresh,
                  color: AppTheme.primaryPink,
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Prediction Section
          if (_getPredictionData() != null) ...[
            _buildPredictionSection(context, _getPredictionData()!),
            const SizedBox(height: 20),
          ],

          // Anomaly Section
          if (_getAnomalyData() != null) ...[
            _buildAnomalySection(context, _getAnomalyData()!),
            const SizedBox(height: 20),
          ],

          // Cycle Insights
          if (_getCycleInsightsData() != null) ...[
            _buildCycleInsightsSection(context, _getCycleInsightsData()!),
            const SizedBox(height: 20),
          ],

          // Recommendations
          if (_getRecommendationsData() != null) ...[
            _buildRecommendationsSection(context, _getRecommendationsData()!),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2);
  }

  Map<String, dynamic>? _getPredictionData() {
    if (insights == null) return null;
    final prediction = insights!['prediction'];
    if (prediction is Map<String, dynamic>) {
      return prediction;
    }
    return null;
  }

  Map<String, dynamic>? _getAnomalyData() {
    if (insights == null) return null;
    final anomaly = insights!['anomaly'];
    if (anomaly is Map<String, dynamic> && anomaly['detected'] == true) {
      return anomaly;
    }
    return null;
  }

  Map<String, dynamic>? _getCycleInsightsData() {
    if (insights == null) return null;
    final cycleInsights = insights!['cycleInsights'];
    if (cycleInsights is Map<String, dynamic>) {
      return cycleInsights;
    }
    return null;
  }

  Map<String, dynamic>? _getRecommendationsData() {
    if (insights == null) return null;
    final recommendations = insights!['recommendations'];
    if (recommendations is Map<String, dynamic>) {
      return recommendations;
    }
    return null;
  }

  Widget _buildPredictionSection(BuildContext context, Map<String, dynamic> prediction) {
    final nextPeriodDate = prediction['nextPeriodDate'];
    final confidence = (prediction['confidence'] ?? 0.0) * 100;
    final quality = prediction['predictionQuality'] ?? 'Unknown';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today, color: AppTheme.primaryPink, size: 20),
            const SizedBox(width: 8),
            Text(
              'Next Period Prediction',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.blushPink.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              if (nextPeriodDate != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Expected Date:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      _formatDate(nextPeriodDate.toString()),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryPink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Confidence:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 100,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppTheme.lightPink,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: confidence / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${confidence.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quality:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getQualityColor(quality.toString()).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getQualityColor(quality.toString()),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      quality.toString(),
                      style: TextStyle(
                        color: _getQualityColor(quality.toString()),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnomalySection(BuildContext context, Map<String, dynamic> anomaly) {
    final description = anomaly['description'] ?? 'Cycle pattern anomaly detected';
    final severity = anomaly['severity'] ?? 'moderate';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.warning.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppTheme.warning, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cycle Anomaly Detected',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getSeverityColor(severity.toString()).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  severity.toString().toUpperCase(),
                  style: TextStyle(
                    color: _getSeverityColor(severity.toString()),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description.toString(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (severity.toString() == 'significant') ...[
            const SizedBox(height: 12),
            Text(
              '💡 Tip: Consider consulting with a healthcare provider if this pattern continues.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCycleInsightsSection(BuildContext context, Map<String, dynamic> cycleInsights) {
    final avgLength = cycleInsights['averageCycleLength'];
    final regularity = cycleInsights['regularityScore'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.insights, color: AppTheme.primaryPink, size: 20),
            const SizedBox(width: 8),
            Text(
              'Cycle Statistics',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Avg Length',
                avgLength != null ? '${avgLength.toStringAsFixed(1)} days' : 'N/A',
                Icons.calendar_month,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Regularity',
                regularity != null ? '${(regularity * 100).toStringAsFixed(0)}%' : 'N/A',
                Icons.check_circle,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.blushPink.withOpacity(0.3),
            AppTheme.lightPurple.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryPink, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryPink,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(BuildContext context, Map<String, dynamic> recommendations) {
    final priority = recommendations['priority'];
    
    List<dynamic> priorityList = [];
    if (priority is List) {
      priorityList = priority;
    } else if (priority is Map) {
      priorityList = [priority];
    }
    
    if (priorityList.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.recommend, color: AppTheme.primaryPink, size: 20),
            const SizedBox(width: 8),
            Text(
              'Recommendations',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...priorityList.take(3).map((rec) => _buildRecommendationItem(context, rec)).toList(),
      ],
    );
  }

  Widget _buildRecommendationItem(BuildContext context, dynamic recommendation) {
    String title = '';
    String description = '';
    String priorityLevel = 'medium';
    
    if (recommendation is Map<String, dynamic>) {
      title = recommendation['title']?.toString() ?? '';
      description = recommendation['description']?.toString() ?? '';
      priorityLevel = recommendation['priority']?.toString() ?? 'medium';
    } else if (recommendation is String) {
      title = recommendation;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getPriorityColor(priorityLevel).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: _getPriorityColor(priorityLevel),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Color _getQualityColor(String quality) {
    if (quality.toLowerCase().contains('excellent') || quality.toLowerCase().contains('high')) {
      return AppTheme.success;
    } else if (quality.toLowerCase().contains('good') || quality.toLowerCase().contains('moderate')) {
      return AppTheme.info;
    } else {
      return AppTheme.warning;
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'significant':
        return AppTheme.error;
      case 'moderate':
        return AppTheme.warning;
      case 'mild':
        return AppTheme.info;
      default:
        return AppTheme.textGray;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppTheme.error;
      case 'medium':
        return AppTheme.warning;
      case 'low':
        return AppTheme.info;
      default:
        return AppTheme.textGray;
    }
  }
}