# File: ai-service/models/symptom_analyzer.py
import numpy as np
from datetime import datetime

class SymptomAnalyzer:
    def __init__(self):
        self.symptom_types = ['cramps', 'mood', 'energy', 'headache', 'bloating']
    
    def analyze_patterns(self, symptoms, cycles):
        """
        Analyzes symptom patterns across cycles
        
        Args:
            symptoms: List of symptom logs
            cycles: List of cycle data for reference
        
        Returns:
            dict with symptom insights
        """
        if not symptoms or len(symptoms) < 7:
            return {
                'hasData': False,
                'message': 'Log symptoms for at least a week to see patterns'
            }
        
        symptom_data = {s_type: [] for s_type in self.symptom_types}
        
        for log in symptoms:
            if 'symptoms' in log:
                for s_type in self.symptom_types:
                    value = log['symptoms'].get(s_type, 0)
                    symptom_data[s_type].append(value)
        
        insights = {}
        
        for s_type, values in symptom_data.items():
            if not values or all(v == 0 for v in values):
                continue
            
            avg = np.mean(values)
            std = np.std(values)
            max_val = max(values)
            
            is_significant = avg > 3 or max_val > 6
            
            insights[s_type] = {
                'average': round(float(avg), 1),
                'variability': round(float(std), 2),
                'maximum': int(max_val),
                'isSignificant': is_significant
            }
        
        return {
            'hasData': True,
            'symptoms': insights,
            'totalLogsAnalyzed': len(symptoms)
        }
    
    def predict_symptom_likelihood(self, symptoms, current_cycle_day):
        """
        Predicts likelihood of symptoms based on cycle day
        
        Args:
            symptoms: Historical symptom data
            current_cycle_day: Current day in cycle
        
        Returns:
            dict with predicted symptom likelihoods
        """
        if not symptoms or len(symptoms) < 14:
            return {
                'hasData': False,
                'message': 'Need more symptom history for predictions'
            }
        
        # Group symptoms by cycle phase
        # Day 1-5: menstrual, 6-13: follicular, 14-17: ovulation, 18+: luteal
        
        if 1 <= current_cycle_day <= 5:
            phase = 'menstrual'
        elif 6 <= current_cycle_day <= 13:
            phase = 'follicular'
        elif 14 <= current_cycle_day <= 17:
            phase = 'ovulation'
        else:
            phase = 'luteal'
        
        # Calculate average symptom intensity for this phase
        # This is a simplified version - a real model would use historical cycle day data
        
        predictions = {}
        for s_type in self.symptom_types:
            values = [s['symptoms'].get(s_type, 0) for s in symptoms if 'symptoms' in s]
            
            if values:
                avg = np.mean(values)
                
                # Adjust based on phase (simplified heuristic)
                if phase == 'menstrual' and s_type in ['cramps', 'headache']:
                    avg *= 1.3  # Higher during period
                elif phase == 'ovulation' and s_type == 'energy':
                    avg *= 1.2  # Higher energy during ovulation
                elif phase == 'luteal' and s_type in ['mood', 'bloating']:
                    avg *= 1.2  # More common in luteal phase
                
                predictions[s_type] = {
                    'likelihood': min(round(float(avg), 1), 10),
                    'confidence': 0.6 if len(values) > 20 else 0.4
                }
        
        return {
            'hasData': True,
            'phase': phase,
            'cycleDay': current_cycle_day,
            'predictions': predictions
        }