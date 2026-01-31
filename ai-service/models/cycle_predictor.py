# File: ai-service/models/cycle_predictor.py
import numpy as np
from datetime import datetime, timedelta
from typing import List, Dict, Optional

class CyclePredictor:
    def __init__(self):
        self.min_cycles_for_prediction = 2
        self.ideal_cycles_for_accuracy = 6
        
    def predict_next_period(self, cycles: List[Dict]) -> Optional[Dict]:
        """
        Enhanced prediction with better accuracy calculations
        
        Args:
            cycles: List of dicts with 'startDate' and 'cycleLength'
        
        Returns:
            dict with prediction, confidence, and probability window
        """
        if len(cycles) < self.min_cycles_for_prediction:
            return self._baseline_prediction(cycles)
        
        cycle_lengths = [c['cycleLength'] for c in cycles if c.get('cycleLength')]
        
        if len(cycle_lengths) < 2:
            return self._baseline_prediction(cycles)
        
        # Calculate statistics
        avg_length = np.mean(cycle_lengths)
        std_length = np.std(cycle_lengths)
        median_length = np.median(cycle_lengths)
        variability = std_length / avg_length if avg_length > 0 else 0
        
        # Use median for more robust prediction
        predicted_length = median_length if len(cycle_lengths) >= 4 else avg_length
        
        # Get last cycle
        last_cycle = cycles[0]
        last_start = datetime.fromisoformat(last_cycle['startDate'].replace('Z', '+00:00'))
        
        # Predict next period date
        predicted_date = last_start + timedelta(days=int(predicted_length))
        
        # Calculate confidence based on multiple factors
        confidence = self._calculate_confidence(
            cycle_lengths, 
            variability, 
            len(cycles)
        )
        
        # Calculate probability window
        window_days = max(2, int(std_length * 1.5))
        window_start = predicted_date - timedelta(days=window_days)
        window_end = predicted_date + timedelta(days=window_days)
        
        # Calculate cycle regularity score
        regularity_score = 1.0 - min(variability, 1.0)
        
        return {
            'nextPeriodDate': predicted_date.isoformat(),
            'confidence': round(confidence, 2),
            'probabilityWindow': {
                'start': window_start.isoformat(),
                'end': window_end.isoformat(),
                'daysRange': window_days * 2
            },
            'averageCycleLength': round(avg_length, 1),
            'medianCycleLength': round(median_length, 1),
            'variability': round(variability, 2),
            'regularityScore': round(regularity_score, 2),
            'cyclesAnalyzed': len(cycle_lengths),
            'predictionQuality': self._get_prediction_quality(len(cycle_lengths), confidence)
        }
    
    def _calculate_confidence(self, cycle_lengths: List[float], 
                             variability: float, 
                             num_cycles: int) -> float:
        """
        Calculate prediction confidence based on multiple factors
        """
        # Base confidence from variability
        # Lower variability = higher confidence
        variability_confidence = max(0.3, 1.0 - (variability * 2))
        variability_confidence = min(variability_confidence, 0.95)
        
        # Adjust based on number of cycles
        if num_cycles < 3:
            cycle_factor = 0.6
        elif num_cycles < 5:
            cycle_factor = 0.8
        elif num_cycles < self.ideal_cycles_for_accuracy:
            cycle_factor = 0.9
        else:
            cycle_factor = 1.0
        
        # Check for recent stability
        if len(cycle_lengths) >= 3:
            recent_three = cycle_lengths[:3]
            recent_variability = np.std(recent_three) / np.mean(recent_three)
            stability_bonus = max(0, 0.1 - recent_variability)
        else:
            stability_bonus = 0
        
        confidence = variability_confidence * cycle_factor + stability_bonus
        return min(confidence, 0.95)
    
    def _get_prediction_quality(self, num_cycles: int, confidence: float) -> str:
        """
        Categorize prediction quality
        """
        if num_cycles < 3:
            return 'Limited Data - Log More Cycles'
        elif confidence >= 0.8:
            return 'Excellent - Very Reliable'
        elif confidence >= 0.65:
            return 'Good - Mostly Reliable'
        elif confidence >= 0.5:
            return 'Fair - Moderately Reliable'
        else:
            return 'Low - More Data Needed'
    
    def _baseline_prediction(self, cycles: List[Dict]) -> Optional[Dict]:
        """
        Fallback prediction for insufficient data
        """
        if not cycles:
            return None
        
        last_cycle = cycles[0]
        last_start = datetime.fromisoformat(last_cycle['startDate'].replace('Z', '+00:00'))
        predicted_date = last_start + timedelta(days=28)
        
        return {
            'nextPeriodDate': predicted_date.isoformat(),
            'confidence': 0.4,
            'probabilityWindow': {
                'start': (predicted_date - timedelta(days=3)).isoformat(),
                'end': (predicted_date + timedelta(days=3)).isoformat(),
                'daysRange': 6
            },
            'averageCycleLength': 28,
            'medianCycleLength': 28,
            'variability': 0,
            'regularityScore': 0.5,
            'cyclesAnalyzed': len(cycles),
            'predictionQuality': 'Baseline - More Data Needed',
            'note': 'Using baseline prediction - log more cycles for better accuracy'
        }
    
    def detect_anomaly(self, cycles: List[Dict]) -> Dict:
        """
        Enhanced anomaly detection with better categorization
        
        Returns:
            dict with anomaly detection results
        """
        if len(cycles) < 3:
            return {
                'detected': False,
                'score': 0,
                'severity': 'none',
                'description': 'Not enough data for anomaly detection'
            }
        
        cycle_lengths = [c['cycleLength'] for c in cycles if c.get('cycleLength')]
        
        if len(cycle_lengths) < 3:
            return {
                'detected': False,
                'score': 0,
                'severity': 'none',
                'description': 'Need completed cycle data'
            }
        
        current_length = cycle_lengths[0]
        historical = cycle_lengths[1:]
        mean_length = np.mean(historical)
        std_length = np.std(historical)
        
        # Calculate z-score
        if std_length > 0:
            z_score = abs((current_length - mean_length) / std_length)
        else:
            z_score = 0
        
        # Normalize to 0-1 score
        anomaly_score = min(z_score / 3, 1.0)
        
        # Determine severity
        if z_score < 1.5:
            severity = 'none'
            is_anomalous = False
        elif z_score < 2.0:
            severity = 'mild'
            is_anomalous = True
        elif z_score < 2.5:
            severity = 'moderate'
            is_anomalous = True
        else:
            severity = 'significant'
            is_anomalous = True
        
        # Generate description
        if is_anomalous:
            difference = int(abs(current_length - mean_length))
            if current_length > mean_length:
                description = f'This cycle was {difference} days longer than usual'
                recommendation = 'Consider logging any unusual symptoms or stress'
            else:
                description = f'This cycle was {difference} days shorter than usual'
                recommendation = 'Monitor for any recurring patterns'
        else:
            description = 'This cycle length is within your normal range'
            recommendation = 'Keep tracking consistently'
        
        return {
            'detected': bool(is_anomalous),
            'score': round(float(anomaly_score), 2),
            'severity': severity,
            'description': description,
            'recommendation': recommendation,
            'currentLength': int(current_length),
            'averageLength': round(float(mean_length), 1),
            'zScore': round(float(z_score), 2)
        }
    
    def get_detailed_insights(self, cycles: List[Dict]) -> Dict:
        """
        Get comprehensive cycle insights
        NEW METHOD
        """
        if not cycles:
            return {'hasData': False}
        
        cycle_lengths = [c['cycleLength'] for c in cycles if c.get('cycleLength')]
        
        if not cycle_lengths:
            return {'hasData': False}
        
        insights = {
            'hasData': True,
            'totalCycles': len(cycles),
            'completedCycles': len(cycle_lengths),
            'statistics': {
                'average': round(np.mean(cycle_lengths), 1),
                'median': round(np.median(cycle_lengths), 1),
                'shortest': int(min(cycle_lengths)),
                'longest': int(max(cycle_lengths)),
                'standardDeviation': round(np.std(cycle_lengths), 2)
            },
            'regularity': self._assess_regularity(cycle_lengths),
            'trends': self._detect_trends(cycle_lengths),
            'consistency': self._calculate_consistency(cycle_lengths)
        }
        
        return insights
    
    def _assess_regularity(self, cycle_lengths: List[float]) -> Dict:
        """
        Assess cycle regularity
        """
        std = np.std(cycle_lengths)
        mean = np.mean(cycle_lengths)
        cv = std / mean if mean > 0 else 0
        
        if cv < 0.05:
            category = 'Very Regular'
            description = 'Your cycles are very consistent'
        elif cv < 0.1:
            category = 'Regular'
            description = 'Your cycles are fairly consistent'
        elif cv < 0.15:
            category = 'Moderately Irregular'
            description = 'Your cycles show some variation'
        else:
            category = 'Irregular'
            description = 'Your cycles vary significantly'
        
        return {
            'category': category,
            'score': round(1.0 - min(cv, 1.0), 2),
            'description': description,
            'coefficientOfVariation': round(cv, 3)
        }
    
    def _detect_trends(self, cycle_lengths: List[float]) -> Dict:
        """
        Detect trends in cycle lengths
        """
        if len(cycle_lengths) < 4:
            return {'hasTrend': False, 'description': 'Insufficient data'}
        
        # Simple linear regression
        x = np.arange(len(cycle_lengths))
        y = np.array(cycle_lengths)
        
        # Calculate slope
        slope = np.polyfit(x, y, 1)[0]
        
        if abs(slope) < 0.1:
            trend = 'stable'
            description = 'Cycle lengths are stable'
        elif slope > 0.1:
            trend = 'increasing'
            description = 'Cycles are getting slightly longer'
        else:
            trend = 'decreasing'
            description = 'Cycles are getting slightly shorter'
        
        return {
            'hasTrend': abs(slope) >= 0.1,
            'direction': trend,
            'description': description,
            'slope': round(float(slope), 3)
        }
    
    def _calculate_consistency(self, cycle_lengths: List[float]) -> Dict:
        """
        Calculate consistency metrics
        """
        if len(cycle_lengths) < 2:
            return {'score': 0, 'description': 'Insufficient data'}
        
        # Calculate differences between consecutive cycles
        differences = [abs(cycle_lengths[i] - cycle_lengths[i+1]) 
                      for i in range(len(cycle_lengths)-1)]
        
        avg_difference = np.mean(differences)
        
        # Score based on average difference
        if avg_difference < 1:
            score = 1.0
            description = 'Extremely consistent'
        elif avg_difference < 2:
            score = 0.9
            description = 'Very consistent'
        elif avg_difference < 3:
            score = 0.7
            description = 'Moderately consistent'
        elif avg_difference < 5:
            score = 0.5
            description = 'Somewhat variable'
        else:
            score = 0.3
            description = 'Highly variable'
        
        return {
            'score': score,
            'description': description,
            'averageDifference': round(avg_difference, 1)
        }