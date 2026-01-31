# File: ai-service/models/health_tracker.py
from datetime import datetime
from typing import Dict, Optional

class HealthTracker:
    """
    Health metrics analysis and BMI calculations
    """
    
    def __init__(self):
        self.bmi_categories = {
            'underweight': (0, 18.5),
            'normal': (18.5, 25),
            'overweight': (25, 30),
            'obese': (30, 100)
        }
    
    def analyze_health_metrics(self, health_metrics: Dict) -> Dict:
        """
        Comprehensive health metrics analysis
        """
        age = self._calculate_age(health_metrics.get('birthdate'))
        height = health_metrics.get('height', 0)
        weight = health_metrics.get('weight', 0)
        use_metric = health_metrics.get('useMetric', True)
        
        # Convert to metric if needed
        if not use_metric:
            height_cm = height * 30.48  # feet to cm
            weight_kg = weight * 0.453592  # lbs to kg
        else:
            height_cm = height
            weight_kg = weight
        
        # Calculate BMI
        bmi = self._calculate_bmi(height_cm, weight_kg)
        bmi_category = self._get_bmi_category(bmi)
        
        # Health risk assessment
        health_risk = self._assess_health_risk(bmi, age)
        
        # Recommendations
        recommendations = self._generate_health_recommendations(
            bmi_category, age, bmi
        )
        
        return {
            'age': age,
            'bmi': round(bmi, 1),
            'bmiCategory': bmi_category,
            'healthRisk': health_risk,
            'idealWeightRange': self._calculate_ideal_weight_range(
                height_cm, use_metric
            ),
            'recommendations': recommendations,
            'metrics': {
                'height': height,
                'weight': weight,
                'useMetric': use_metric
            }
        }
    
    def _calculate_age(self, birthdate_str: Optional[str]) -> Optional[int]:
        """Calculate age from birthdate"""
        if not birthdate_str:
            return None
        
        try:
            birthdate = datetime.fromisoformat(birthdate_str.replace('Z', '+00:00'))
            today = datetime.now()
            age = today.year - birthdate.year
            if today.month < birthdate.month or (
                today.month == birthdate.month and today.day < birthdate.day
            ):
                age -= 1
            return age
        except:
            return None
    
    def _calculate_bmi(self, height_cm: float, weight_kg: float) -> float:
        """Calculate BMI"""
        if height_cm <= 0 or weight_kg <= 0:
            return 0
        
        height_m = height_cm / 100
        return weight_kg / (height_m ** 2)
    
    def _get_bmi_category(self, bmi: float) -> str:
        """Get BMI category"""
        for category, (min_bmi, max_bmi) in self.bmi_categories.items():
            if min_bmi <= bmi < max_bmi:
                return category
        return 'unknown'
    
    def _assess_health_risk(self, bmi: float, age: Optional[int]) -> Dict:
        """Assess health risk based on BMI and age"""
        category = self._get_bmi_category(bmi)
        
        risk_levels = {
            'underweight': 'moderate',
            'normal': 'low',
            'overweight': 'moderate',
            'obese': 'high'
        }
        
        risk = risk_levels.get(category, 'unknown')
        
        # Adjust for age
        if age and age >= 40 and category in ['overweight', 'obese']:
            risk = 'high'
        
        descriptions = {
            'low': 'Your BMI is in the healthy range',
            'moderate': 'Consider consulting a healthcare provider',
            'high': 'Recommend speaking with a healthcare professional'
        }
        
        return {
            'level': risk,
            'description': descriptions.get(risk, 'Unknown risk level')
        }
    
    def _calculate_ideal_weight_range(self, height_cm: float, 
                                     use_metric: bool) -> Dict:
        """Calculate ideal weight range"""
        if height_cm <= 0:
            return {}
        
        height_m = height_cm / 100
        
        # Healthy BMI range: 18.5 - 24.9
        min_weight_kg = 18.5 * (height_m ** 2)
        max_weight_kg = 24.9 * (height_m ** 2)
        
        if use_metric:
            return {
                'min': round(min_weight_kg, 1),
                'max': round(max_weight_kg, 1),
                'unit': 'kg'
            }
        else:
            # Convert to lbs
            min_weight_lbs = min_weight_kg / 0.453592
            max_weight_lbs = max_weight_kg / 0.453592
            return {
                'min': round(min_weight_lbs, 1),
                'max': round(max_weight_lbs, 1),
                'unit': 'lbs'
            }
    
    def _generate_health_recommendations(self, bmi_category: str, 
                                        age: Optional[int], 
                                        bmi: float) -> list:
        """Generate health recommendations"""
        recommendations = []
        
        if bmi_category == 'underweight':
            recommendations.extend([
                'Increase caloric intake with nutrient-dense foods',
                'Include protein-rich foods in every meal',
                'Consider consulting a nutritionist',
                'Adequate nutrition supports healthy cycles'
            ])
        
        elif bmi_category == 'overweight' or bmi_category == 'obese':
            recommendations.extend([
                'Aim for 30 minutes of moderate exercise daily',
                'Focus on whole foods and vegetables',
                'Practice portion control',
                'Maintaining healthy weight can improve cycle regularity'
            ])
        
        elif bmi_category == 'normal':
            recommendations.extend([
                'Maintain your healthy habits',
                'Continue regular physical activity',
                'Eat a balanced diet',
                'Your weight supports optimal cycle health'
            ])
        
        # Age-specific recommendations
        if age:
            if age >= 35:
                recommendations.append('Regular health screenings recommended')
            if age >= 40:
                recommendations.append('Bone density monitoring important')
        
        return recommendations
    
    def adjust_prediction_with_health(self, prediction: Dict, 
                                     health_metrics: Dict) -> Dict:
        """
        Adjust cycle predictions based on health metrics
        """
        analysis = self.analyze_health_metrics(health_metrics)
        
        bmi = analysis.get('bmi', 0)
        bmi_category = analysis.get('bmiCategory')
        
        # BMI extremes can affect cycle regularity
        if bmi_category in ['underweight', 'obese']:
            # Slightly reduce confidence for irregular patterns
            current_confidence = prediction.get('confidence', 0.5)
            adjusted_confidence = current_confidence * 0.95
            prediction['confidence'] = round(adjusted_confidence, 2)
            
            if 'note' not in prediction:
                prediction['note'] = ''
            
            if bmi_category == 'underweight':
                prediction['note'] += ' Low BMI may affect cycle regularity.'
            elif bmi_category == 'obese':
                prediction['note'] += ' High BMI may affect cycle regularity.'
        
        return prediction
    
    def get_health_recommendations(self, analysis: Dict) -> list:
        """
        Get formatted health recommendations
        """
        return analysis.get('recommendations', [])