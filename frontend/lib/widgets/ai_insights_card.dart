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
          if (insights!['prediction'] != null) ...[
            _buildPredictionSection(context, insights!['prediction']),
            const SizedBox(height: 20),
          ],

          // Anomaly Section
          if (insights!['anomaly'] != null && insights!['anomaly']['detected'] == true) ...[
            _buildAnomalySection(context, insights!['anomaly']),
            const SizedBox(height: 20),
          ],

          // Cycle Insights
          if (insights!['cycleInsights'] != null) ...[
            _buildCycleInsightsSection(context, insights!['cycleInsights']),
            const SizedBox(height: 20),
          ],

          // Recommendations
          if (insights!['recommendations'] != null) ...[
            _buildRecommendationsSection(context, insights!['recommendations']),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2);
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
                      _formatDate(nextPeriodDate),
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
                      color: _getQualityColor(quality).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getQualityColor(quality),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      quality,
                      style: TextStyle(
                        color: _getQualityColor(quality),
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
    final severity = anomaly['severity'] ?? 'none';
    final description = anomaly['description'] ?? 'Unusual pattern detected';

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
              Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.warning,
                size: 24,
              ),
              const SizedBox(width: 12),
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
                  color: _getSeverityColor(severity).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  severity.toUpperCase(),
                  style: TextStyle(
                    color: _getSeverityColor(severity),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (severity == 'significant') ...[
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
    final variability = cycleInsights['variability'];

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
    final priority = recommendations['priority'] as List<dynamic>? ?? [];
    
    if (priority.isEmpty) return const SizedBox.shrink();

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
        ...priority.take(3).map((rec) => _buildRecommendationItem(context, rec)).toList(),
      ],
    );
  }

  Widget _buildRecommendationItem(BuildContext context, dynamic recommendation) {
    final title = recommendation['title'] ?? '';
    final description = recommendation['description'] ?? '';
    final priorityLevel = recommendation['priority'] ?? 'medium';

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