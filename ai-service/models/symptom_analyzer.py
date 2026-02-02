# File: ai-service/models/symptom_analyzer.py
import numpy as np
import pandas as pd
from datetime import datetime, timedelta
from typing import List, Dict, Optional, Tuple
from scipy import stats
from sklearn.cluster import KMeans
from collections import Counter
import warnings
warnings.filterwarnings('ignore')

class AdvancedSymptomAnalyzer:
    """
    Advanced symptom analysis with pattern recognition and predictive modeling
    """
    
    def __init__(self):
        self.symptom_types = [
            'cramps', 'mood', 'energy', 'headache', 'bloating',
            'acne', 'breast_tenderness', 'cravings', 'sleep_quality',
            'anxiety', 'irritability', 'fatigue'
        ]
        
        self.phase_days = {
            'menstrual': (1, 5),
            'follicular': (6, 13),
            'ovulation': (14, 17),
            'luteal': (18, 28)
        }
        
        # Symptom severity thresholds
        self.severity_thresholds = {
            'minimal': (0, 2),
            'mild': (2, 4),
            'moderate': (4, 6),
            'significant': (6, 8),
            'severe': (8, 10)
        }
    
    def analyze_patterns(self, symptoms: List[Dict], cycles: List[Dict],
                        health_metrics: Optional[Dict] = None) -> Dict:
        """
        Comprehensive symptom pattern analysis with ML-enhanced insights
        """
        if not symptoms or len(symptoms) < 5:
            return {
                'hasData': False,
                'message': 'Log symptoms for at least 5 days to see patterns',
                'minRequired': 5,
                'current': len(symptoms)
            }
        
        # Prepare data
        df = self._prepare_symptom_dataframe(symptoms, cycles)
        
        if df is None or len(df) < 5:
            return {
                'hasData': False,
                'message': 'Insufficient valid symptom data'
            }
        
        # Comprehensive analysis
        symptom_insights = {}
        phase_correlations = {}
        temporal_patterns = {}
        severity_analysis = {}
        
        # Analyze each symptom type
        for s_type in self.symptom_types:
            if s_type in df.columns:
                values = df[s_type].dropna()
                if len(values) > 0 and not all(v == 0 for v in values):
                    symptom_insights[s_type] = self._analyze_symptom_comprehensive(
                        s_type, values, df
                    )
        
        # Phase correlation analysis
        if 'phase' in df.columns:
            phase_correlations = self._analyze_phase_correlations(df, symptom_insights.keys())
        
        # Temporal pattern detection
        temporal_patterns = self._detect_temporal_patterns(df, symptom_insights.keys())
        
        # Severity clustering
        severity_analysis = self._analyze_severity_patterns(df, symptom_insights.keys())
        
        # Symptom combinations
        combo_analysis = self._analyze_symptom_combinations(df, symptom_insights.keys())
        
        # Generate recommendations
        recommendations = self._generate_advanced_recommendations(
            symptom_insights,
            phase_correlations,
            temporal_patterns,
            health_metrics
        )
        
        # Risk assessment
        risk_assessment = self._assess_symptom_risk(symptom_insights, severity_analysis)
        
        return {
            'hasData': True,
            'symptoms': symptom_insights,
            'phaseCorrelation': phase_correlations,
            'temporalPatterns': temporal_patterns,
            'severityAnalysis': severity_analysis,
            'symptomCombinations': combo_analysis,
            'totalLogsAnalyzed': len(symptoms),
            'dateRange': {
                'start': df['date'].min().isoformat() if 'date' in df.columns else None,
                'end': df['date'].max().isoformat() if 'date' in df.columns else None,
                'daysTracked': len(df)
            },
            'recommendations': recommendations,
            'riskAssessment': risk_assessment,
            'overallPattern': self._summarize_overall_pattern(symptom_insights, phase_correlations)
        }
    
    def _prepare_symptom_dataframe(self, symptoms: List[Dict], 
                                   cycles: List[Dict]) -> Optional[pd.DataFrame]:
        """Prepare comprehensive symptom dataframe"""
        data = []
        
        for log in symptoms:
            if 'symptoms' not in log:
                continue
            
            row = {
                'date': pd.to_datetime(log.get('date', log.get('createdAt'))),
                'cycleDay': log.get('cycleDay', 0)
            }
            
            # Add all symptom values
            for s_type in self.symptom_types:
                row[s_type] = log['symptoms'].get(s_type, 0)
            
            # Determine phase
            row['phase'] = self._get_phase_from_day(row['cycleDay'])
            
            # Add temporal features
            row['dayOfWeek'] = row['date'].dayofweek
            row['isWeekend'] = row['dayOfWeek'] >= 5
            row['month'] = row['date'].month
            
            data.append(row)
        
        if not data:
            return None
        
        df = pd.DataFrame(data)
        df = df.sort_values('date')
        
        # Calculate rolling averages for smoothing
        for s_type in self.symptom_types:
            if s_type in df.columns:
                df[f'{s_type}_ma3'] = df[s_type].rolling(window=3, min_periods=1).mean()
                df[f'{s_type}_ma7'] = df[s_type].rolling(window=7, min_periods=1).mean()
        
        return df
    
    def _analyze_symptom_comprehensive(self, symptom_type: str, 
                                      values: pd.Series,
                                      df: pd.DataFrame) -> Dict:
        """Comprehensive analysis of a single symptom"""
        values_array = values.values
        
        # Basic statistics
        avg = np.mean(values_array)
        median = np.median(values_array)
        std = np.std(values_array)
        max_val = np.max(values_array)
        min_val = np.min(values_array)
        
        # Frequency analysis
        non_zero = values_array[values_array > 0]
        frequency = len(non_zero) / len(values_array) if len(values_array) > 0 else 0
        
        # Severity classification
        severity = self._classify_severity(avg)
        
        # Trend detection
        trend = self._detect_symptom_trend_advanced(values_array)
        
        # Variability analysis
        cv = std / avg if avg > 0 else 0
        variability_category = self._classify_variability(cv)
        
        # Peak detection
        peaks = self._detect_peaks(values_array)
        
        # Persistence analysis
        persistence = self._analyze_persistence(values_array)
        
        # Calculate percentiles
        percentiles = {
            '25th': float(np.percentile(values_array, 25)),
            '50th': float(np.percentile(values_array, 50)),
            '75th': float(np.percentile(values_array, 75)),
            '90th': float(np.percentile(values_array, 90))
        }
        
        return {
            'average': round(float(avg), 1),
            'median': round(float(median), 1),
            'standardDeviation': round(float(std), 2),
            'minimum': float(min_val),
            'maximum': float(max_val),
            'range': float(max_val - min_val),
            'frequency': round(frequency, 2),
            'frequencyPercent': round(frequency * 100, 1),
            'severity': severity,
            'isSignificant': avg > 3 or max_val > 6,
            'trend': trend,
            'variability': variability_category,
            'coefficientOfVariation': round(float(cv), 2),
            'peaks': peaks,
            'persistence': persistence,
            'percentiles': percentiles,
            'impactScore': self._calculate_impact_score(avg, frequency, max_val)
        }
    
    def _classify_severity(self, avg_value: float) -> str:
        """Classify symptom severity"""
        for severity, (low, high) in self.severity_thresholds.items():
            if low <= avg_value < high:
                return severity
        return 'severe' if avg_value >= 8 else 'minimal'
    
    def _classify_variability(self, cv: float) -> str:
        """Classify symptom variability"""
        if cv < 0.2:
            return 'very_stable'
        elif cv < 0.4:
            return 'stable'
        elif cv < 0.6:
            return 'moderate'
        elif cv < 0.8:
            return 'variable'
        else:
            return 'highly_variable'
    
    def _detect_symptom_trend_advanced(self, values: np.ndarray) -> Dict:
        """Advanced trend detection with statistical significance"""
        if len(values) < 4:
            return {
                'direction': 'insufficient_data',
                'strength': 0,
                'significance': 'unknown'
            }
        
        x = np.arange(len(values))
        slope, intercept, r_value, p_value, std_err = stats.linregress(x, values)
        
        # Determine direction
        if p_value > 0.05:
            direction = 'stable'
            strength = 'not_significant'
        elif slope > 0.1:
            direction = 'increasing'
            strength = 'strong' if abs(slope) > 0.3 else 'moderate'
        elif slope < -0.1:
            direction = 'decreasing'
            strength = 'strong' if abs(slope) > 0.3 else 'moderate'
        else:
            direction = 'stable'
            strength = 'weak'
        
        return {
            'direction': direction,
            'slope': round(float(slope), 3),
            'strength': strength,
            'rSquared': round(float(r_value ** 2), 3),
            'pValue': round(float(p_value), 4),
            'significance': 'significant' if p_value < 0.05 else 'not_significant',
            'interpretation': self._interpret_trend(direction, slope, p_value)
        }
    
    def _interpret_trend(self, direction: str, slope: float, p_value: float) -> str:
        """Generate human-readable trend interpretation"""
        if direction == 'stable':
            return 'Symptom intensity remains relatively constant'
        elif direction == 'increasing':
            if p_value < 0.01:
                return 'Symptom is significantly worsening over time - consider medical consultation'
            else:
                return 'Symptom shows a slight increasing trend'
        elif direction == 'decreasing':
            if p_value < 0.01:
                return 'Symptom is significantly improving - your management strategies may be working!'
            else:
                return 'Symptom shows a slight decreasing trend'
        return 'Insufficient data for trend analysis'
    
    def _detect_peaks(self, values: np.ndarray) -> Dict:
        """Detect symptom peaks"""
        if len(values) < 3:
            return {'count': 0, 'averageIntensity': 0}
        
        # Find local maxima
        peaks = []
        for i in range(1, len(values) - 1):
            if values[i] > values[i-1] and values[i] > values[i+1] and values[i] >= 6:
                peaks.append(values[i])
        
        return {
            'count': len(peaks),
            'averageIntensity': round(float(np.mean(peaks)), 1) if peaks else 0,
            'maxIntensity': float(max(peaks)) if peaks else 0,
            'frequency': round(len(peaks) / len(values), 2) if len(values) > 0 else 0
        }
    
    def _analyze_persistence(self, values: np.ndarray) -> Dict:
        """Analyze how long symptoms persist"""
        if len(values) == 0:
            return {'averageDuration': 0, 'longestStreak': 0}
        
        # Find consecutive days with symptoms (value > 0)
        streaks = []
        current_streak = 0
        
        for val in values:
            if val > 0:
                current_streak += 1
            else:
                if current_streak > 0:
                    streaks.append(current_streak)
                current_streak = 0
        
        if current_streak > 0:
            streaks.append(current_streak)
        
        return {
            'averageDuration': round(float(np.mean(streaks)), 1) if streaks else 0,
            'longestStreak': int(max(streaks)) if streaks else 0,
            'shortestStreak': int(min(streaks)) if streaks else 0,
            'totalEpisodes': len(streaks)
        }
    
    def _calculate_impact_score(self, avg: float, frequency: float, 
                               max_val: float) -> float:
        """Calculate overall impact score (0-10)"""
        # Weighted combination of severity and frequency
        impact = (0.4 * avg + 0.4 * (frequency * 10) + 0.2 * max_val)
        return round(float(min(impact, 10)), 1)
    
    def _analyze_phase_correlations(self, df: pd.DataFrame, 
                                   symptom_types: List[str]) -> Dict:
        """Analyze symptom correlations with menstrual phases"""
        phase_data = {}
        
        for phase in self.phase_days.keys():
            phase_df = df[df['phase'] == phase]
            if len(phase_df) == 0:
                continue
            
            phase_data[phase] = {}
            
            for s_type in symptom_types:
                if s_type in phase_df.columns:
                    values = phase_df[s_type].dropna()
                    if len(values) > 0:
                        phase_data[phase][s_type] = {
                            'average': round(float(values.mean()), 1),
                            'median': round(float(values.median()), 1),
                            'frequency': round(float(len(values[values > 0]) / len(values)), 2),
                            'maximum': float(values.max()),
                            'daysTracked': len(values),
                            'likelihood': self._calculate_symptom_likelihood(values)
                        }
        
        # Calculate phase with highest symptom burden
        phase_scores = {}
        for phase, symptoms in phase_data.items():
            avg_score = np.mean([s['average'] * s['frequency'] for s in symptoms.values()])
            phase_scores[phase] = round(float(avg_score), 2)
        
        return {
            'byPhase': phase_data,
            'phaseScores': phase_scores,
            'worstPhase': max(phase_scores, key=phase_scores.get) if phase_scores else None,
            'bestPhase': min(phase_scores, key=phase_scores.get) if phase_scores else None
        }
    
    def _calculate_symptom_likelihood(self, values: pd.Series) -> str:
        """Calculate likelihood category"""
        freq = len(values[values > 0]) / len(values) if len(values) > 0 else 0
        
        if freq >= 0.8:
            return 'very_high'
        elif freq >= 0.6:
            return 'high'
        elif freq >= 0.4:
            return 'moderate'
        elif freq >= 0.2:
            return 'low'
        else:
            return 'very_low'
    
    def _detect_temporal_patterns(self, df: pd.DataFrame, 
                                  symptom_types: List[str]) -> Dict:
        """Detect temporal patterns in symptoms"""
        patterns = {}
        
        # Day of week analysis
        if 'dayOfWeek' in df.columns:
            weekday_patterns = {}
            for s_type in symptom_types:
                if s_type in df.columns:
                    weekday_avg = df.groupby('dayOfWeek')[s_type].mean()
                    if len(weekday_avg) > 0:
                        weekday_patterns[s_type] = {
                            'worst_day': int(weekday_avg.idxmax()),
                            'worst_day_name': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][int(weekday_avg.idxmax())],
                            'worst_day_avg': round(float(weekday_avg.max()), 1),
                            'best_day': int(weekday_avg.idxmin()),
                            'best_day_name': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][int(weekday_avg.idxmin())],
                            'weekend_vs_weekday': self._compare_weekend_weekday(df, s_type)
                        }
            patterns['dayOfWeek'] = weekday_patterns
        
        # Time-based clustering
        patterns['clusters'] = self._cluster_symptom_days(df, symptom_types)
        
        return patterns
    
    def _compare_weekend_weekday(self, df: pd.DataFrame, symptom: str) -> Dict:
        """Compare symptom intensity on weekends vs weekdays"""
        if 'isWeekend' not in df.columns or symptom not in df.columns:
            return {}
        
        weekend = df[df['isWeekend'] == True][symptom].mean()
        weekday = df[df['isWeekend'] == False][symptom].mean()
        
        if weekend > weekday * 1.2:
            interpretation = 'Worse on weekends'
        elif weekday > weekend * 1.2:
            interpretation = 'Worse on weekdays'
        else:
            interpretation = 'Similar'
        
        return {
            'weekendAverage': round(float(weekend), 1) if not np.isnan(weekend) else 0,
            'weekdayAverage': round(float(weekday), 1) if not np.isnan(weekday) else 0,
            'interpretation': interpretation
        }
    
    def _cluster_symptom_days(self, df: pd.DataFrame, 
                             symptom_types: List[str]) -> Dict:
        """Cluster days based on symptom patterns"""
        if len(df) < 10:
            return {'status': 'insufficient_data'}
        
        # Prepare feature matrix
        features = []
        valid_symptoms = [s for s in symptom_types if s in df.columns]
        
        if len(valid_symptoms) < 2:
            return {'status': 'insufficient_symptoms'}
        
        for s in valid_symptoms:
            features.append(df[s].fillna(0).values)
        
        X = np.array(features).T
        
        # Determine optimal clusters (2-4)
        n_clusters = min(3, max(2, len(df) // 10))
        
        try:
            kmeans = KMeans(n_clusters=n_clusters, random_state=42, n_init=10)
            clusters = kmeans.fit_predict(X)
            
            # Analyze clusters
            cluster_profiles = {}
            for i in range(n_clusters):
                cluster_mask = clusters == i
                cluster_data = df[cluster_mask]
                
                symptom_profile = {}
                for s in valid_symptoms:
                    if s in cluster_data.columns:
                        symptom_profile[s] = round(float(cluster_data[s].mean()), 1)
                
                cluster_profiles[f'cluster_{i}'] = {
                    'size': int(cluster_mask.sum()),
                    'percentage': round(float(cluster_mask.sum() / len(df) * 100), 1),
                    'symptomProfile': symptom_profile,
                    'severity': self._classify_cluster_severity(symptom_profile)
                }
            
            return {
                'status': 'success',
                'numberOfClusters': n_clusters,
                'profiles': cluster_profiles
            }
        
        except Exception as e:
            return {'status': 'error', 'message': str(e)}
    
    def _classify_cluster_severity(self, profile: Dict) -> str:
        """Classify overall cluster severity"""
        avg_severity = np.mean(list(profile.values()))
        
        if avg_severity < 2:
            return 'minimal'
        elif avg_severity < 4:
            return 'mild'
        elif avg_severity < 6:
            return 'moderate'
        else:
            return 'significant'
    
    def _analyze_severity_patterns(self, df: pd.DataFrame, 
                                   symptom_types: List[str]) -> Dict:
        """Analyze overall severity patterns"""
        # Calculate daily total severity
        valid_symptoms = [s for s in symptom_types if s in df.columns]
        df['total_severity'] = df[valid_symptoms].sum(axis=1)
        
        severity_stats = {
            'average': round(float(df['total_severity'].mean()), 1),
            'maximum': float(df['total_severity'].max()),
            'minimum': float(df['total_severity'].min()),
            'standardDeviation': round(float(df['total_severity'].std()), 2)
        }
        
        # Categorize days
        high_severity_days = len(df[df['total_severity'] > df['total_severity'].quantile(0.75)])
        low_severity_days = len(df[df['total_severity'] < df['total_severity'].quantile(0.25)])
        
        return {
            'overallStats': severity_stats,
            'highSeverityDays': high_severity_days,
            'lowSeverityDays': low_severity_days,
            'moderateSeverityDays': len(df) - high_severity_days - low_severity_days,
            'percentHighSeverity': round(high_severity_days / len(df) * 100, 1) if len(df) > 0 else 0
        }
    
    def _analyze_symptom_combinations(self, df: pd.DataFrame, 
                                     symptom_types: List[str]) -> Dict:
        """Analyze which symptoms commonly occur together"""
        valid_symptoms = [s for s in symptom_types if s in df.columns]
        
        if len(valid_symptoms) < 2:
            return {'status': 'insufficient_symptoms'}
        
        # Find common combinations
        combinations = []
        
        for idx, row in df.iterrows():
            active_symptoms = [s for s in valid_symptoms if row[s] > 3]  # Threshold of 3
            if len(active_symptoms) >= 2:
                combinations.append(tuple(sorted(active_symptoms)))
        
        if not combinations:
            return {'status': 'no_combinations_found'}
        
        # Count combinations
        combo_counts = Counter(combinations)
        top_combos = combo_counts.most_common(5)
        
        return {
            'status': 'success',
            'topCombinations': [
                {
                    'symptoms': list(combo),
                    'frequency': count,
                    'percentage': round(count / len(df) * 100, 1)
                }
                for combo, count in top_combos
            ],
            'totalCombinations': len(combinations),
            'uniqueCombinations': len(combo_counts)
        }
    
    def _generate_advanced_recommendations(self, symptom_insights: Dict,
                                          phase_correlations: Dict,
                                          temporal_patterns: Dict,
                                          health_metrics: Optional[Dict]) -> List[Dict]:
        """Generate personalized recommendations based on comprehensive analysis"""
        recommendations = []
        
        # Symptom-specific recommendations
        for symptom, data in symptom_insights.items():
            if data.get('isSignificant'):
                rec = self._get_symptom_recommendation(symptom, data)
                if rec:
                    recommendations.append(rec)
        
        # Phase-based recommendations
        if 'worstPhase' in phase_correlations:
            worst_phase = phase_correlations['worstPhase']
            recommendations.append({
                'type': 'phase_management',
                'title': f'Focus on {worst_phase.title()} Phase',
                'description': f'Your symptoms peak during {worst_phase} phase. Plan self-care activities accordingly.',
                'priority': 'high',
                'phase': worst_phase
            })
        
        # Health-based recommendations
        if health_metrics:
            health_rec = self._get_health_based_recommendations(health_metrics, symptom_insights)
            recommendations.extend(health_rec)
        
        return recommendations[:10]  # Limit to top 10
    
    def _get_symptom_recommendation(self, symptom: str, data: Dict) -> Optional[Dict]:
        """Get specific recommendation for a symptom"""
        severity = data.get('severity')
        avg = data.get('average', 0)
        
        recommendations_map = {
            'cramps': {
                'title': 'Manage Cramps Effectively',
                'description': 'Try heat therapy, gentle exercise, and consider magnesium supplements',
                'priority': 'high' if avg > 6 else 'medium'
            },
            'mood': {
                'title': 'Support Emotional Wellbeing',
                'description': 'Practice mindfulness, maintain social connections, consider vitamin B6',
                'priority': 'high' if avg > 6 else 'medium'
            },
            'headache': {
                'title': 'Address Headaches',
                'description': 'Stay hydrated, manage stress, track triggers, ensure adequate sleep',
                'priority': 'high' if avg > 6 else 'medium'
            },
            'bloating': {
                'title': 'Reduce Bloating',
                'description': 'Reduce sodium intake, stay active, try peppermint tea, eat smaller meals',
                'priority': 'medium'
            },
            'fatigue': {
                'title': 'Boost Energy Levels',
                'description': 'Prioritize sleep, eat iron-rich foods, gentle exercise, B-complex vitamins',
                'priority': 'high' if avg > 6 else 'medium'
            }
        }
        
        if symptom in recommendations_map:
            rec = recommendations_map[symptom].copy()
            rec['type'] = f'{symptom}_management'
            rec['symptom'] = symptom
            rec['currentSeverity'] = severity
            return rec
        
        return None
    
    def _get_health_based_recommendations(self, health_metrics: Dict,
                                         symptom_insights: Dict) -> List[Dict]:
        """Generate recommendations based on health metrics and symptoms"""
        recommendations = []
        
        # Calculate BMI
        bmi = self._calculate_bmi(health_metrics)
        
        if bmi > 0:
            if bmi < 18.5 and 'fatigue' in symptom_insights:
                recommendations.append({
                    'type': 'nutrition',
                    'title': 'Increase Nutrient Intake',
                    'description': 'Low BMI may contribute to fatigue. Focus on nutrient-dense meals.',
                    'priority': 'high'
                })
            elif bmi > 30 and any(s in symptom_insights for s in ['bloating', 'fatigue']):
                recommendations.append({
                    'type': 'lifestyle',
                    'title': 'Gentle Physical Activity',
                    'description': 'Regular moderate exercise can help manage symptoms and support cycle health.',
                    'priority': 'medium'
                })
        
        return recommendations
    
    def _calculate_bmi(self, health_metrics: Dict) -> float:
        """Calculate BMI from health metrics"""
        height = health_metrics.get('height', 0)
        weight = health_metrics.get('weight', 0)
        use_metric = health_metrics.get('useMetric', True)
        
        if height <= 0 or weight <= 0:
            return 0
        
        if not use_metric:
            height_cm = height * 30.48
            weight_kg = weight * 0.453592
        else:
            height_cm = height
            weight_kg = weight
        
        height_m = height_cm / 100
        return weight_kg / (height_m ** 2) if height_m > 0 else 0
    
    def _assess_symptom_risk(self, symptom_insights: Dict, 
                            severity_analysis: Dict) -> Dict:
        """Assess overall symptom risk level"""
        # Count significant symptoms
        significant_count = sum(1 for s in symptom_insights.values() if s.get('isSignificant'))
        
        # Check for severe symptoms
        severe_count = sum(1 for s in symptom_insights.values() if s.get('severity') in ['significant', 'severe'])
        
        # Overall severity
        percent_high_severity = severity_analysis.get('percentHighSeverity', 0)
        
        # Determine risk level
        if severe_count >= 2 or percent_high_severity > 50:
            level = 'high'
            message = 'Consider consulting a healthcare provider about your symptoms'
            action = 'Schedule medical consultation'
        elif significant_count >= 3 or percent_high_severity > 30:
            level = 'moderate'
            message = 'Monitor symptoms and consider lifestyle adjustments'
            action = 'Continue tracking and implement recommendations'
        else:
            level = 'low'
            message = 'Symptoms are within manageable range'
            action = 'Continue current management strategies'
        
        return {
            'level': level,
            'significantSymptoms': significant_count,
            'severeSymptoms': severe_count,
            'message': message,
            'recommendedAction': action
        }
    
    def _summarize_overall_pattern(self, symptom_insights: Dict,
                                   phase_correlations: Dict) -> Dict:
        """Summarize overall symptom pattern"""
        total_symptoms_tracked = len(symptom_insights)
        significant_symptoms = [s for s, data in symptom_insights.items() if data.get('isSignificant')]
        
        # Calculate average impact
        avg_impact = np.mean([data.get('impactScore', 0) for data in symptom_insights.values()])
        
        # Determine pattern type
        if len(significant_symptoms) == 0:
            pattern_type = 'minimal_symptoms'
            description = 'You experience minimal symptoms overall'
        elif len(significant_symptoms) <= 2:
            pattern_type = 'mild_pattern'
            description = f'You typically experience {", ".join(significant_symptoms)}'
        else:
            pattern_type = 'moderate_pattern'
            description = f'You experience multiple symptoms including {", ".join(significant_symptoms[:3])}'
        
        return {
            'patternType': pattern_type,
            'description': description,
            'totalSymptomsTracked': total_symptoms_tracked,
            'significantSymptoms': significant_symptoms,
            'averageImpact': round(avg_impact, 1),
            'impactLevel': 'high' if avg_impact > 6 else 'moderate' if avg_impact > 3 else 'low'
        }
    
    def _get_phase_from_day(self, cycle_day: int) -> Optional[str]:
        """Determine cycle phase from day number"""
        for phase, (start, end) in self.phase_days.items():
            if start <= cycle_day <= end:
                return phase
        return None
    
    def predict_symptom_likelihood(self, symptoms: List[Dict], 
                                   current_cycle_day: int,
                                   cycles: List[Dict]) -> Dict:
        """
        Advanced symptom prediction with ML
        """
        if not symptoms or len(symptoms) < 10:
            return {
                'hasData': False,
                'message': 'Need at least 10 days of symptom history for predictions',
                'minRequired': 10,
                'current': len(symptoms)
            }
        
        df = self._prepare_symptom_dataframe(symptoms, cycles)
        if df is None:
            return {'hasData': False, 'message': 'Invalid symptom data'}
        
        current_phase = self._get_phase_from_day(current_cycle_day)
        if not current_phase:
            current_phase = 'unknown'
        
        predictions = {}
        
        for s_type in self.symptom_types:
            if s_type not in df.columns:
                continue
            
            # Get historical data for this phase
            phase_data = df[df['phase'] == current_phase][s_type].dropna()
            
            if len(phase_data) < 3:
                continue
            
            # Calculate prediction
            mean_val = phase_data.mean()
            std_val = phase_data.std()
            frequency = len(phase_data[phase_data > 0]) / len(phase_data)
            
            # Adjust for recent trend
            recent_data = df[s_type].tail(7).dropna()
            if len(recent_data) >= 3:
                recent_avg = recent_data.mean()
                trend_adjustment = (recent_avg - mean_val) * 0.3
                predicted_value = mean_val + trend_adjustment
            else:
                predicted_value = mean_val
            
            # Calculate confidence
            data_points = len(phase_data)
            confidence = min(0.5 + (data_points / 20), 0.85)
            
            # Generate probability ranges
            lower_bound = max(0, predicted_value - std_val)
            upper_bound = min(10, predicted_value + std_val)
            
            predictions[s_type] = {
                'predicted': round(float(predicted_value), 1),
                'probabilityRange': {
                    'lower': round(float(lower_bound), 1),
                    'upper': round(float(upper_bound), 1)
                },
                'frequency': round(frequency, 2),
                'likelihood': self._calculate_symptom_likelihood(phase_data),
                'confidence': round(confidence, 2),
                'severity': self._classify_severity(predicted_value),
                'description': self._generate_prediction_description(
                    s_type, predicted_value, frequency
                )
            }
        
        return {
            'hasData': True,
            'phase': current_phase,
            'cycleDay': current_cycle_day,
            'predictions': predictions,
            'dataPoints': len(symptoms),
            'overallOutlook': self._generate_overall_outlook(predictions, current_phase)
        }
    
    def _generate_prediction_description(self, symptom: str, 
                                        value: float, 
                                        frequency: float) -> str:
        """Generate user-friendly prediction description"""
        severity = self._classify_severity(value)
        
        freq_desc = (
            'rarely' if frequency < 0.2 else
            'occasionally' if frequency < 0.5 else
            'frequently' if frequency < 0.8 else
            'almost always'
        )
        
        return f"You {freq_desc} experience {severity} {symptom} during this phase"
    
    def _generate_overall_outlook(self, predictions: Dict, phase: str) -> Dict:
        """Generate overall symptom outlook"""
        if not predictions:
            return {'level': 'unknown', 'message': 'Insufficient data'}
        
        avg_predicted = np.mean([p['predicted'] for p in predictions.values()])
        high_severity_count = sum(1 for p in predictions.values() if p['predicted'] > 6)
        
        if avg_predicted > 5 or high_severity_count >= 2:
            level = 'challenging'
            message = f'Expect moderate-high symptoms during {phase} phase'
            advice = 'Plan self-care activities and reduce commitments if possible'
        elif avg_predicted > 3:
            level = 'moderate'
            message = f'Expect mild-moderate symptoms during {phase} phase'
            advice = 'Maintain your wellness routines'
        else:
            level = 'good'
            message = f'Expect minimal symptoms during {phase} phase'
            advice = 'Good time for activities requiring energy and focus'
        
        return {
            'level': level,
            'message': message,
            'advice': advice,
            'averageSeverity': round(float(avg_predicted), 1)
        }