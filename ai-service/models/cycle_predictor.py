# File: ai-service/models/cycle_predictor.py
import numpy as np
from datetime import datetime, timedelta

class CyclePredictor:
    def __init__(self):
        self.min_cycles_for_prediction = 2
        
    def predict_next_period(self, cycles):
        """
        Predicts next period date based on cycle history
        
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
        
        avg_length = np.mean(cycle_lengths)
        std_length = np.std(cycle_lengths)
        variability = std_length / avg_length if avg_length > 0 else 0
        
        last_cycle = cycles[0]
        last_start = datetime.fromisoformat(last_cycle['startDate'].replace('Z', '+00:00'))
        
        predicted_date = last_start + timedelta(days=int(avg_length))
        
        # Calculate confidence based on variability
        # Lower variability = higher confidence
        confidence = max(0.3, 1.0 - (variability * 2))
        confidence = min(confidence, 0.95)  # Cap at 95%
        
        if len(cycle_lengths) < 3:
            confidence *= 0.7
        elif len(cycle_lengths) < 5:
            confidence *= 0.85
        
        window_start = predicted_date - timedelta(days=int(std_length))
        window_end = predicted_date + timedelta(days=int(std_length))
        
        return {
            'nextPeriodDate': predicted_date.isoformat(),
            'confidence': round(confidence, 2),
            'probabilityWindow': {
                'start': window_start.isoformat(),
                'end': window_end.isoformat()
            },
            'averageCycleLength': round(avg_length, 1),
            'variability': round(variability, 2),
            'cyclesAnalyzed': len(cycle_lengths)
        }
    
    def _baseline_prediction(self, cycles):
        """Fallback prediction for insufficient data"""
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
                'end': (predicted_date + timedelta(days=3)).isoformat()
            },
            'averageCycleLength': 28,
            'variability': 0,
            'cyclesAnalyzed': len(cycles),
            'note': 'Using baseline prediction - log more cycles for better accuracy'
        }
    
    def detect_anomaly(self, cycles):
        """
        Detects if current cycle is anomalous compared to history
        
        Returns:
            dict with anomaly detection results
        """
        if len(cycles) < 3:
            return {
                'detected': False,
                'score': 0,
                'description': 'Not enough data for anomaly detection'
            }
        
        cycle_lengths = [c['cycleLength'] for c in cycles if c.get('cycleLength')]
        
        if len(cycle_lengths) < 3:
            return {
                'detected': False,
                'score': 0,
                'description': 'Need completed cycle data'
            }
        
        current_length = cycle_lengths[0]
        
        historical = cycle_lengths[1:]
        mean_length = np.mean(historical)
        std_length = np.std(historical)
        
        if std_length > 0:
            z_score = abs((current_length - mean_length) / std_length)
        else:
            z_score = 0
        
        anomaly_score = min(z_score / 3, 1.0)  # Normalize to 0-1
        
        # Detect anomaly if z-score > 2 (2 standard deviations)
        is_anomalous = z_score > 2
        
        description = ''
        if is_anomalous:
            if current_length > mean_length:
                description = f'This cycle was {int(current_length - mean_length)} days longer than your usual pattern'
            else:
                description = f'This cycle was {int(mean_length - current_length)} days shorter than your usual pattern'
        else:
            description = 'This cycle length is within your normal range'
        
        return {
            'detected': bool(is_anomalous),
            'score': round(float(anomaly_score), 2),
            'description': description,
            'currentLength': int(current_length),
            'averageLength': round(float(mean_length), 1)
        }