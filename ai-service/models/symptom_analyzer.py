# File: ai-service/models/symptom_analyzer.py
import numpy as np
from datetime import datetime
from typing import List, Dict, Optional

class SymptomAnalyzer:
    def __init__(self):
        self.symptom_types = ['cramps', 'mood', 'energy', 'headache', 'bloating']
        self.phase_days = {
            'menstrual': (1, 5),
            'follicular': (6, 13),
            'ovulation': (14, 17),
            'luteal': (18, 28)
        }
    
    def analyze_patterns(self, symptoms: List[Dict], cycles: List[Dict]) -> Dict:
        """
        Enhanced symptom pattern analysis with phase correlation
        """
        if not symptoms or len(symptoms) < 7:
            return {
                'hasData': False,
                'message': 'Log symptoms for at least a week to see patterns'
            }
        
        symptom_data = {s_type: [] for s_type in self.symptom_types}
        phase_symptom_data = {
            phase: {s_type: [] for s_type in self.symptom_types}
            for phase in self.phase_days.keys()
        }
        
        # Collect symptom data and organize by phase
        for log in symptoms:
            if 'symptoms' not in log:
                continue
            
            # Determine phase if cycle day is available
            cycle_day = log.get('cycleDay', 0)
            phase = self._get_phase_from_day(cycle_day)
            
            for s_type in self.symptom_types:
                value = log['symptoms'].get(s_type, 0)
                symptom_data[s_type].append(value)
                
                if phase:
                    phase_symptom_data[phase][s_type].append(value)
        
        # Analyze overall patterns
        insights = {}
        phase_insights = {}
        
        for s_type, values in symptom_data.items():
            if not values or all(v == 0 for v in values):
                continue
            
            insights[s_type] = self._analyze_symptom(s_type, values)
        
        # Analyze by phase
        for phase, symptoms_by_type in phase_symptom_data.items():
            phase_insights[phase] = {}
            for s_type, values in symptoms_by_type.items():
                if values and not all(v == 0 for v in values):
                    phase_insights[phase][s_type] = {
                        'average': round(np.mean(values), 1),
                        'frequency': len([v for v in values if v > 0]) / len(values)
                    }
        
        return {
            'hasData': True,
            'symptoms': insights,
            'phaseCorrelation': phase_insights,
            'totalLogsAnalyzed': len(symptoms),
            'recommendations': self._generate_symptom_recommendations(insights)
        }
    
    def _analyze_symptom(self, symptom_type: str, values: List[float]) -> Dict:
        """
        Detailed analysis of a single symptom
        """
        avg = np.mean(values)
        std = np.std(values)
        max_val = max(values)
        frequency = len([v for v in values if v > 0]) / len(values)
        
        # Determine severity
        if avg < 2:
            severity = 'minimal'
        elif avg < 4:
            severity = 'mild'
        elif avg < 6:
            severity = 'moderate'
        else:
            severity = 'significant'
        
        is_significant = avg > 3 or max_val > 6
        
        return {
            'average': round(float(avg), 1),
            'variability': round(float(std), 2),
            'maximum': int(max_val),
            'frequency': round(frequency, 2),
            'severity': severity,
            'isSignificant': is_significant,
            'trend': self._detect_symptom_trend(values)
        }
    
    def _detect_symptom_trend(self, values: List[float]) -> str:
        """
        Detect if symptom is increasing, decreasing, or stable
        """
        if len(values) < 4:
            return 'stable'
        
        # Compare recent vs older values
        recent = values[:len(values)//2]
        older = values[len(values)//2:]
        
        recent_avg = np.mean(recent)
        older_avg = np.mean(older)
        
        diff = recent_avg - older_avg
        
        if diff > 1:
            return 'increasing'
        elif diff < -1:
            return 'decreasing'
        else:
            return 'stable'
    
    def _get_phase_from_day(self, cycle_day: int) -> Optional[str]:
        """
        Determine cycle phase from day number
        """
        for phase, (start, end) in self.phase_days.items():
            if start <= cycle_day <= end:
                return phase
        return None
    
    def predict_symptom_likelihood(self, symptoms: List[Dict], 
                                   current_cycle_day: int) -> Dict:
        """
        Enhanced symptom prediction with better accuracy
        """
        if not symptoms or len(symptoms) < 14:
            return {
                'hasData': False,
                'message': 'Need more symptom history for predictions'
            }
        
        # Determine current phase
        phase = self._get_phase_from_day(current_cycle_day)
        if not phase:
            phase = 'unknown'
        
        # Collect historical data for this phase
        phase_symptoms = {s_type: [] for s_type in self.symptom_types}
        
        for log in symptoms:
            log_cycle_day = log.get('cycleDay', 0)
            log_phase = self._get_phase_from_day(log_cycle_day)
            
            if log_phase == phase and 'symptoms' in log:
                for s_type in self.symptom_types:
                    value = log['symptoms'].get(s_type, 0)
                    phase_symptoms[s_type].append(value)
        
        # Generate predictions
        predictions = {}
        for s_type, values in phase_symptoms.items():
            if not values:
                continue
            
            avg = np.mean(values)
            frequency = len([v for v in values if v > 0]) / len(values)
            
            # Apply phase multipliers
            multiplier = self._get_phase_multiplier(phase, s_type)
            predicted_value = avg * multiplier
            
            predictions[s_type] = {
                'likelihood': min(round(predicted_value, 1), 10),
                'probability': round(frequency, 2),
                'confidence': min(0.6 + (len(values) / 100), 0.9),
                'description': self._get_symptom_description(
                    s_type, 
                    predicted_value, 
                    frequency
                )
            }
        
        return {
            'hasData': True,
            'phase': phase,
            'cycleDay': current_cycle_day,
            'predictions': predictions,
            'dataPoints': len(symptoms)
        }
    
    def _get_phase_multiplier(self, phase: str, symptom: str) -> float:
        """
        Get symptom multiplier based on phase
        """
        multipliers = {
            'menstrual': {
                'cramps': 1.5,
                'headache': 1.3,
                'mood': 1.0,
                'energy': 0.8,
                'bloating': 1.2
            },
            'follicular': {
                'cramps': 0.5,
                'headache': 0.7,
                'mood': 1.2,
                'energy': 1.3,
                'bloating': 0.7
            },
            'ovulation': {
                'cramps': 0.8,
                'headache': 0.6,
                'mood': 1.3,
                'energy': 1.4,
                'bloating': 0.6
            },
            'luteal': {
                'cramps': 1.1,
                'headache': 1.2,
                'mood': 0.8,
                'energy': 0.9,
                'bloating': 1.4
            }
        }
        
        return multipliers.get(phase, {}).get(symptom, 1.0)
    
    def _get_symptom_description(self, symptom: str, 
                                 value: float, 
                                 frequency: float) -> str:
        """
        Generate user-friendly symptom description
        """
        if value < 2:
            severity = "minimal"
        elif value < 4:
            severity = "mild"
        elif value < 6:
            severity = "moderate"
        else:
            severity = "significant"
        
        if frequency < 0.2:
            freq_desc = "rarely"
        elif frequency < 0.5:
            freq_desc = "occasionally"
        elif frequency < 0.8:
            freq_desc = "frequently"
        else:
            freq_desc = "almost always"
        
        return f"You {freq_desc} experience {severity} {symptom}"
    
    def _generate_symptom_recommendations(self, insights: Dict) -> List[str]:
        """
        Generate personalized recommendations based on symptoms
        """
        recommendations = []
        
        for symptom, data in insights.items():
            if not data.get('isSignificant'):
                continue
            
            severity = data.get('severity', 'mild')
            
            if symptom == 'cramps' and severity in ['moderate', 'significant']:
                recommendations.append(
                    'Try heat therapy and gentle stretching for cramp relief'
                )
            
            if symptom == 'mood' and severity in ['moderate', 'significant']:
                recommendations.append(
                    'Consider stress-reduction techniques like meditation or yoga'
                )
            
            if symptom == 'energy' and data.get('average', 5) < 4:
                recommendations.append(
                    'Ensure adequate sleep and consider B-vitamin rich foods'
                )
            
            if symptom == 'headache' and severity in ['moderate', 'significant']:
                recommendations.append(
                    'Stay hydrated and track potential triggers'
                )
            
            if symptom == 'bloating' and severity in ['moderate', 'significant']:
                recommendations.append(
                    'Try reducing salt intake and staying active'
                )
        
        if not recommendations:
            recommendations.append('Your symptoms are generally mild - keep tracking!')
        
        return recommendations