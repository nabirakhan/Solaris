# File: ai-service/models/health_tracker_advanced.py
from datetime import datetime
from typing import Dict, Optional, List
import numpy as np

class AdvancedHealthTracker:
    """Advanced health metrics analysis with cycle correlation"""
    
    def __init__(self):
        self.bmi_categories = {
            'underweight': (0, 18.5),
            'normal': (18.5, 25),
            'overweight': (25, 30),
            'obese_class1': (30, 35),
            'obese_class2': (35, 40),
            'obese_class3': (40, 100)
        }
    
    def comprehensive_health_analysis(self, health_metrics: Dict,
                                     cycles: List[Dict],
                                     symptoms: List[Dict]) -> Dict:
        """Complete health analysis with cycle correlation"""
        age = self._calculate_age(health_metrics.get('birthdate'))
        bmi_data = self._comprehensive_bmi_analysis(health_metrics)
        
        # Correlation with cycle
        cycle_impact = self._analyze_health_cycle_correlation(
            bmi_data, cycles
        )
        
        # Symptom correlation
        symptom_correlation = None
        if symptoms and len(symptoms) >= 10:
            symptom_correlation = self._analyze_health_symptom_correlation(
                bmi_data, symptoms
            )
        
        # Risk assessment
        risk_assessment = self._comprehensive_risk_assessment(
            bmi_data, age, cycles
        )
        
        # Recommendations
        recommendations = self._generate_comprehensive_recommendations(
            bmi_data, age, risk_assessment, cycle_impact
        )
        
        # Goal setting
        goals = self._generate_health_goals(bmi_data, age)
        
        return {
            'age': age,
            'bmiAnalysis': bmi_data,
            'cycleImpact': cycle_impact,
            'symptomCorrelation': symptom_correlation,
            'riskAssessment': risk_assessment,
            'recommendations': recommendations,
            'healthGoals': goals,
            'overallScore': self._calculate_health_score(bmi_data, age, risk_assessment)
        }
    
    def _comprehensive_bmi_analysis(self, health_metrics: Dict) -> Dict:
        """Detailed BMI analysis"""
        height = health_metrics.get('height', 0)
        weight = health_metrics.get('weight', 0)
        use_metric = health_metrics.get('useMetric', True)
        
        if not use_metric:
            height_cm = height * 30.48
            weight_kg = weight * 0.453592
        else:
            height_cm = height
            weight_kg = weight
        
        if height_cm <= 0 or weight_kg <= 0:
            return {'status': 'incomplete_data'}
        
        bmi = weight_kg / ((height_cm / 100) ** 2)
        category = self._get_detailed_bmi_category(bmi)
        ideal_range = self._calculate_ideal_weight_range(height_cm, use_metric)
        
        return {
            'value': round(bmi, 1),
            'category': category,
            'isHealthy': 18.5 <= bmi < 25,
            'idealWeightRange': ideal_range,
            'deviationFromIdeal': self._calculate_deviation(bmi),
            'percentile': self._estimate_bmi_percentile(bmi),
            'healthImplications': self._get_health_implications(category)
        }
    
    def _get_detailed_bmi_category(self, bmi: float) -> str:
        """Get detailed BMI category"""
        for category, (low, high) in self.bmi_categories.items():
            if low <= bmi < high:
                return category
        return 'unknown'
    
    def _calculate_ideal_weight_range(self, height_cm: float, 
                                     use_metric: bool) -> Dict:
        """Calculate ideal weight range"""
        height_m = height_cm / 100
        min_kg = 18.5 * (height_m ** 2)
        max_kg = 24.9 * (height_m ** 2)
        
        if use_metric:
            return {
                'min': round(min_kg, 1),
                'max': round(max_kg, 1),
                'unit': 'kg'
            }
        else:
            return {
                'min': round(min_kg / 0.453592, 1),
                'max': round(max_kg / 0.453592, 1),
                'unit': 'lbs'
            }
    
    def _calculate_deviation(self, bmi: float) -> Dict:
        """Calculate deviation from ideal BMI"""
        ideal_mid = 21.7
        deviation = bmi - ideal_mid
        percentage = (deviation / ideal_mid) * 100
        
        return {
            'absolute': round(deviation, 1),
            'percentage': round(percentage, 1),
            'direction': 'above' if deviation > 0 else 'below' if deviation < 0 else 'optimal'
        }
    
    def _estimate_bmi_percentile(self, bmi: float) -> int:
        """Estimate BMI percentile (simplified)"""
        if bmi < 18.5:
            return int((bmi / 18.5) * 5)
        elif bmi < 25:
            return int(5 + ((bmi - 18.5) / 6.5) * 65)
        elif bmi < 30:
            return int(70 + ((bmi - 25) / 5) * 20)
        else:
            return min(95, int(90 + ((bmi - 30) / 10) * 10))
    
    def _get_health_implications(self, category: str) -> List[str]:
        """Get health implications for BMI category"""
        implications = {
            'underweight': [
                'Increased risk of nutrient deficiencies',
                'May affect menstrual regularity',
                'Potential immune system weakness'
            ],
            'normal': [
                'Optimal health range',
                'Lower risk of chronic diseases',
                'Supports regular menstrual cycles'
            ],
            'overweight': [
                'Slightly increased health risks',
                'May affect cycle regularity',
                'Monitor for metabolic changes'
            ],
            'obese_class1': [
                'Increased risk of metabolic syndrome',
                'May impact fertility and cycle',
                'Higher risk of PCOS'
            ],
            'obese_class2': [
                'Significant health risks',
                'Strong impact on hormonal balance',
                'Medical consultation recommended'
            ],
            'obese_class3': [
                'Very high health risks',
                'Severe impact on reproductive health',
                'Immediate medical attention advised'
            ]
        }
        return implications.get(category, ['Consult healthcare provider'])
    
    def _analyze_health_cycle_correlation(self, bmi_data: Dict,
                                         cycles: List[Dict]) -> Dict:
        """Analyze correlation between health metrics and cycle"""
        if not cycles or 'value' not in bmi_data:
            return {'status': 'insufficient_data'}
        
        bmi = bmi_data['value']
        cycle_lengths = [c['cycleLength'] for c in cycles if c.get('cycleLength')]
        
        if not cycle_lengths:
            return {'status': 'no_cycle_data'}
        
        variability = np.std(cycle_lengths) / np.mean(cycle_lengths) if len(cycle_lengths) > 1 else 0
        
        # Analyze impact
        impact_level = 'none'
        impact_description = 'BMI within healthy range - minimal cycle impact'
        
        if bmi < 18.5:
            impact_level = 'high' if variability > 0.15 else 'moderate'
            impact_description = 'Low BMI may contribute to cycle irregularity'
        elif bmi > 30:
            impact_level = 'high' if variability > 0.15 else 'moderate'
            impact_description = 'Elevated BMI may affect hormonal balance and cycle'
        elif variability > 0.2:
            impact_level = 'mild'
            impact_description = 'Cycle variability present but BMI is healthy'
        
        return {
            'status': 'analyzed',
            'impactLevel': impact_level,
            'description': impact_description,
            'cycleVariability': round(variability, 2),
            'bmiCategory': bmi_data['category'],
            'recommendation': self._get_cycle_health_recommendation(bmi, variability)
        }
    
    def _get_cycle_health_recommendation(self, bmi: float, variability: float) -> str:
        """Get recommendation based on BMI and cycle variability"""
        if bmi < 18.5 and variability > 0.15:
            return 'Consider increasing caloric intake to support regular cycles'
        elif bmi > 30 and variability > 0.15:
            return 'Weight management may help improve cycle regularity'
        elif variability > 0.2:
            return 'Continue tracking to identify other factors affecting your cycle'
        else:
            return 'Maintain current healthy habits'
    
    def _analyze_health_symptom_correlation(self, bmi_data: Dict,
                                           symptoms: List[Dict]) -> Dict:
        """Analyze correlation between health and symptoms"""
        if 'value' not in bmi_data:
            return {'status': 'insufficient_data'}
        
        # Aggregate symptom severity
        total_severity = []
        for log in symptoms:
            if 'symptoms' in log:
                severity = sum(log['symptoms'].values())
                total_severity.append(severity)
        
        if not total_severity:
            return {'status': 'no_symptom_data'}
        
        avg_severity = np.mean(total_severity)
        bmi = bmi_data['value']
        
        # Analyze correlation
        correlation_strength = 'none'
        description = 'No significant correlation detected'
        
        if bmi < 18.5 and avg_severity > 15:
            correlation_strength = 'moderate'
            description = 'Low BMI may contribute to increased symptom severity'
        elif bmi > 30 and avg_severity > 20:
            correlation_strength = 'strong'
            description = 'Elevated BMI associated with higher symptom burden'
        
        return {
            'status': 'analyzed',
            'correlationStrength': correlation_strength,
            'description': description,
            'averageSymptomSeverity': round(avg_severity, 1),
            'bmi': bmi
        }
    
    def _comprehensive_risk_assessment(self, bmi_data: Dict, age: Optional[int],
                                      cycles: List[Dict]) -> Dict:
        """Comprehensive health risk assessment"""
        if 'value' not in bmi_data:
            return {'level': 'unknown', 'factors': []}
        
        risk_factors = []
        risk_score = 0
        
        bmi = bmi_data['value']
        category = bmi_data['category']
        
        # BMI risk
        if category == 'underweight':
            risk_factors.append('Underweight: Nutrient deficiency risk')
            risk_score += 2
        elif category in ['obese_class1', 'obese_class2', 'obese_class3']:
            risk_factors.append('Obesity: Increased metabolic risk')
            risk_score += 3 if 'class3' in category else 2
        
        # Age risk
        if age and age >= 40:
            risk_factors.append('Age 40+: Monitor hormonal changes')
            risk_score += 1
        
        # Cycle variability
        if cycles:
            lengths = [c['cycleLength'] for c in cycles if c.get('cycleLength')]
            if lengths:
                var = np.std(lengths) / np.mean(lengths)
                if var > 0.2:
                    risk_factors.append('High cycle variability detected')
                    risk_score += 1
        
        # Determine overall level
        if risk_score == 0:
            level = 'low'
            message = 'Low health risk - maintain current habits'
        elif risk_score <= 2:
            level = 'moderate'
            message = 'Moderate risk - consider lifestyle adjustments'
        else:
            level = 'high'
            message = 'Elevated risk - recommend medical consultation'
        
        return {
            'level': level,
            'score': risk_score,
            'factors': risk_factors,
            'message': message,
            'requiresAttention': risk_score >= 3
        }
    
    def _generate_comprehensive_recommendations(self, bmi_data: Dict, age: Optional[int],
                                               risk_assessment: Dict,
                                               cycle_impact: Dict) -> List[Dict]:
        """Generate comprehensive health recommendations"""
        recommendations = []
        
        if 'value' not in bmi_data:
            return recommendations
        
        category = bmi_data['category']
        
        # BMI-based recommendations
        if category == 'underweight':
            recommendations.extend([
                {'type': 'nutrition', 'priority': 'high', 'title': 'Increase Caloric Intake',
                 'description': 'Focus on nutrient-dense foods to reach healthy weight'},
                {'type': 'medical', 'priority': 'medium', 'title': 'Consult Nutritionist',
                 'description': 'Professional guidance for healthy weight gain'}
            ])
        elif category in ['obese_class1', 'obese_class2', 'obese_class3']:
            recommendations.extend([
                {'type': 'exercise', 'priority': 'high', 'title': 'Regular Physical Activity',
                 'description': '150 minutes/week moderate exercise'},
                {'type': 'nutrition', 'priority': 'high', 'title': 'Balanced Diet',
                 'description': 'Focus on whole foods, portion control'},
                {'type': 'medical', 'priority': 'high' if 'class2' in category else 'medium',
                 'title': 'Medical Consultation', 'description': 'Discuss weight management plan'}
            ])
        
        # Cycle-specific recommendations
        if cycle_impact.get('impactLevel') in ['moderate', 'high']:
            recommendations.append({
                'type': 'cycle_health',
                'priority': 'high',
                'title': 'Address Cycle Irregularity',
                'description': cycle_impact.get('recommendation', '')
            })
        
        # Age-based recommendations
        if age and age >= 35:
            recommendations.append({
                'type': 'screening',
                'priority': 'medium',
                'title': 'Regular Health Screenings',
                'description': 'Annual check-ups recommended'
            })
        
        return recommendations[:8]
    
    def _generate_health_goals(self, bmi_data: Dict, age: Optional[int]) -> Dict:
        """Generate personalized health goals"""
        if 'value' not in bmi_data:
            return {'status': 'no_goals'}
        
        goals = []
        category = bmi_data['category']
        
        if category != 'normal':
            target_range = bmi_data['idealWeightRange']
            goals.append({
                'type': 'weight',
                'target': f"{target_range['min']}-{target_range['max']} {target_range['unit']}",
                'timeframe': '3-6 months',
                'priority': 'high'
            })
        
        goals.extend([
            {'type': 'activity', 'target': '30 min daily exercise', 'timeframe': 'ongoing', 'priority': 'medium'},
            {'type': 'nutrition', 'target': '5+ servings fruits/vegetables daily', 'timeframe': 'ongoing', 'priority': 'medium'}
        ])
        
        return {'status': 'generated', 'goals': goals}
    
    def _calculate_health_score(self, bmi_data: Dict, age: Optional[int],
                               risk_assessment: Dict) -> Dict:
        """Calculate overall health score"""
        if 'value' not in bmi_data:
            return {'score': 0, 'rating': 'unknown'}
        
        score = 100
        
        # BMI deduction
        category = bmi_data['category']
        if category == 'underweight':
            score -= 15
        elif category == 'overweight':
            score -= 10
        elif 'obese' in category:
            score -= 25 if 'class3' in category else 20 if 'class2' in category else 15
        
        # Risk deduction
        risk_level = risk_assessment.get('level', 'low')
        if risk_level == 'high':
            score -= 20
        elif risk_level == 'moderate':
            score -= 10
        
        score = max(0, min(100, score))
        
        rating = ('excellent' if score >= 85 else 'good' if score >= 70 else
                 'fair' if score >= 50 else 'needs_improvement')
        
        return {
            'score': score,
            'rating': rating,
            'interpretation': f"Your health score is {rating.replace('_', ' ')}"
        }
    
    def _calculate_age(self, birthdate_str: Optional[str]) -> Optional[int]:
        """Calculate age from birthdate"""
        if not birthdate_str:
            return None
        try:
            birthdate = datetime.fromisoformat(birthdate_str.replace('Z', '+00:00'))
            today = datetime.now()
            age = today.year - birthdate.year
            if today.month < birthdate.month or (today.month == birthdate.month and today.day < birthdate.day):
                age -= 1
            return age
        except:
            return None