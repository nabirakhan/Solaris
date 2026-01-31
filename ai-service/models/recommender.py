# File: ai-service/models/recommender.py
from typing import Dict, List, Optional
from datetime import datetime

class RecommenderSystem:
    """
    Enhanced recommender with health-based suggestions
    """
    
    def __init__(self):
        self.confidence_threshold_high = 0.75
        self.confidence_threshold_medium = 0.50
        self.anomaly_threshold = 0.65
    
    def decide_display_strategy(self, prediction_data: Optional[Dict], 
                               anomaly_data: Dict, 
                               user_engagement: Dict) -> Dict:
        """
        Enhanced display strategy decision
        """
        recommendations = {
            'showPrediction': False,
            'showAnomalyAlert': False,
            'showConfidenceLevel': False,
            'uiMode': 'minimal',
            'promptForMoreData': False,
            'displayPriority': 0,
            'message': None,
            'encouragement': None
        }
        
        confidence = prediction_data.get('confidence', 0) if prediction_data else 0
        cycles_analyzed = prediction_data.get('cyclesAnalyzed', 0) if prediction_data else 0
        anomaly_detected = anomaly_data.get('detected', False)
        anomaly_score = anomaly_data.get('score', 0)
        anomaly_severity = anomaly_data.get('severity', 'none')
        
        # Decision 1: Show predictions
        if confidence >= self.confidence_threshold_medium and cycles_analyzed >= 2:
            recommendations['showPrediction'] = True
            
            if confidence >= self.confidence_threshold_high:
                recommendations['uiMode'] = 'minimal'
                recommendations['message'] = 'Based on your consistent patterns'
                recommendations['encouragement'] = 'Great tracking!'
            else:
                recommendations['uiMode'] = 'standard'
                recommendations['showConfidenceLevel'] = True
                recommendations['message'] = 'Predicted from your cycle history'
        
        # Decision 2: Anomaly alerts
        if anomaly_detected:
            if anomaly_severity == 'significant':
                recommendations['showAnomalyAlert'] = True
                recommendations['uiMode'] = 'detailed'
                recommendations['displayPriority'] = 3
                recommendations['message'] = 'Significant change detected in your cycle'
            elif anomaly_severity == 'moderate':
                recommendations['showAnomalyAlert'] = True
                recommendations['displayPriority'] = 2
                recommendations['message'] = 'We noticed a change in your cycle pattern'
        
        # Decision 3: Request more data
        if cycles_analyzed < 3:
            recommendations['promptForMoreData'] = True
            recommendations['message'] = 'Log a few more cycles for better predictions'
            recommendations['encouragement'] = 'You\'re making great progress!'
        elif cycles_analyzed >= 6:
            recommendations['encouragement'] = 'Excellent tracking consistency!'
        
        # Decision 4: User engagement
        days_since_last_log = user_engagement.get('daysSinceLastLog', 0)
        consistency_score = user_engagement.get('consistencyScore', 0)
        
        if days_since_last_log > 7:
            recommendations['uiMode'] = 'gentle_reentry'
            recommendations['message'] = 'Welcome back! Continue your journey'
        elif consistency_score > 0.8:
            recommendations['encouragement'] = 'Your consistency is impressive!'
        
        # Decision 5: Display priority
        if anomaly_detected and anomaly_severity == 'significant':
            recommendations['displayPriority'] = 3
        elif recommendations['showPrediction'] and confidence >= self.confidence_threshold_high:
            recommendations['displayPriority'] = 2
        elif recommendations['promptForMoreData']:
            recommendations['displayPriority'] = 1
        
        return recommendations
    
    def generate_insight_text(self, prediction_data: Optional[Dict], 
                             anomaly_data: Dict, 
                             recommendations: Dict) -> List[str]:
        """
        Enhanced insight generation
        """
        insights = []
        
        if not prediction_data:
            return ['Start logging your cycle to see personalized insights']
        
        if recommendations['showPrediction']:
            confidence = prediction_data.get('confidence', 0)
            cycles = prediction_data.get('cyclesAnalyzed', 0)
            quality = prediction_data.get('predictionQuality', '')
            
            if confidence >= 0.85:
                insights.append(f'Your cycle patterns are very clear ({int(confidence*100)}% confidence)')
            elif confidence >= 0.7:
                insights.append(f'Your patterns are becoming clearer - {cycles} cycles analyzed')
            elif confidence >= 0.5:
                insights.append(f'Early predictions based on {cycles} cycles')
            
            if quality:
                insights.append(f'Prediction quality: {quality}')
        
        if recommendations['showAnomalyAlert']:
            description = anomaly_data.get('description', '')
            recommendation = anomaly_data.get('recommendation', '')
            insights.append(description)
            if recommendation:
                insights.append(recommendation)
        
        # Add variability insights
        variability = prediction_data.get('variability', 0)
        regularity_score = prediction_data.get('regularityScore', 0)
        
        if regularity_score > 0.9:
            insights.append('Your cycle is remarkably consistent')
        elif regularity_score > 0.7:
            insights.append('Your cycle shows good regularity')
        elif variability > 0.2:
            insights.append('Your cycle length varies - this is normal for many people')
        
        # Encouragement
        if recommendations.get('encouragement'):
            insights.append(recommendations['encouragement'])
        
        return insights
    
    def should_request_symptom_log(self, last_symptom_log_date: Optional[str], 
                                   current_cycle_day: int) -> tuple:
        """
        Enhanced symptom logging prompts
        """
        if not last_symptom_log_date:
            return True, 'How are you feeling today?'
        
        try:
            last_log = datetime.fromisoformat(last_symptom_log_date.replace('Z', '+00:00'))
            days_since_log = (datetime.now() - last_log).days
        except:
            return True, 'Log your symptoms to track patterns'
        
        # Menstrual phase - log daily
        if 1 <= current_cycle_day <= 5 and days_since_log >= 1:
            return True, 'Track your period symptoms today'
        
        # Ovulation phase - important to track
        if 13 <= current_cycle_day <= 17 and days_since_log >= 1:
            return True, 'You\'re in your fertile window - log any symptoms'
        
        # Luteal phase - watch for PMS
        if current_cycle_day >= 20 and days_since_log >= 2:
            return True, 'Track PMS symptoms if any'
        
        # General reminder
        if days_since_log >= 3:
            return True, 'Time to log your symptoms'
        
        return False, None
    
    def get_health_recommendations(self, health_insights: Dict) -> List[Dict]:
        """
        Generate health-based recommendations
        NEW METHOD
        """
        recommendations = []
        
        if not health_insights:
            return recommendations
        
        bmi_category = health_insights.get('bmiCategory')
        bmi_value = health_insights.get('bmi')
        
        if bmi_category == 'underweight':
            recommendations.append({
                'type': 'nutrition',
                'title': 'Increase Nutrient Intake',
                'description': 'Focus on nutrient-dense foods to support your cycle',
                'priority': 'high'
            })
        elif bmi_category == 'overweight' or bmi_category == 'obese':
            recommendations.append({
                'type': 'exercise',
                'title': 'Regular Physical Activity',
                'description': '30 minutes of moderate exercise most days',
                'priority': 'medium'
            })
            recommendations.append({
                'type': 'nutrition',
                'title': 'Balanced Diet',
                'description': 'Focus on whole foods and portion control',
                'priority': 'medium'
            })
        
        # Age-based recommendations
        age = health_insights.get('age')
        if age and age >= 35:
            recommendations.append({
                'type': 'health',
                'title': 'Regular Check-ups',
                'description': 'Annual health screenings are important',
                'priority': 'medium'
            })
        
        return recommendations