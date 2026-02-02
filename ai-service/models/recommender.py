# File: ai-service/models/recommender_advanced.py
from typing import Dict, List, Optional, Tuple
from datetime import datetime, timedelta
import numpy as np

class AdvancedRecommenderSystem:
    """AI-powered recommendation system with personalization"""
    
    def __init__(self):
        self.confidence_thresholds = {'high': 0.75, 'medium': 0.50, 'low': 0.35}
        self.anomaly_thresholds = {'significant': 0.75, 'moderate': 0.50, 'mild': 0.30}
    
    def generate_comprehensive_recommendations(self, prediction: Optional[Dict],
                                              anomaly: Dict, symptom_insights: Optional[Dict],
                                              health_insights: Optional[Dict],
                                              user_engagement: Dict,
                                              cycles: List[Dict]) -> Dict:
        """Generate comprehensive personalized recommendations"""
        recommendations = {
            'lifestyle': [],
            'medical': [],
            'tracking': [],
            'wellness': [],
            'priority': [],
            'displayStrategy': self._determine_display_strategy(prediction, anomaly, user_engagement)
        }
        
        # Cycle-based recommendations
        if prediction:
            recommendations['lifestyle'].extend(self._get_cycle_recommendations(prediction))
        
        # Anomaly-based
        if anomaly.get('detected'):
            recommendations['medical'].extend(self._get_anomaly_recommendations(anomaly))
        
        # Symptom-based
        if symptom_insights and symptom_insights.get('hasData'):
            recommendations['wellness'].extend(self._get_symptom_recommendations(symptom_insights))
        
        # Health-based
        if health_insights:
            recommendations['lifestyle'].extend(self._get_health_recommendations(health_insights))
        
        # Engagement-based
        recommendations['tracking'].extend(self._get_engagement_recommendations(user_engagement))
        
        # Prioritize recommendations
        recommendations['priority'] = self._prioritize_recommendations(recommendations, anomaly, health_insights)
        
        return recommendations
    
    def _get_cycle_recommendations(self, prediction: Dict) -> List[Dict]:
        """Generate cycle-specific recommendations"""
        recs = []
        confidence = prediction.get('confidence', 0)
        cycles_analyzed = prediction.get('cyclesAnalyzed', 0)
        
        if confidence >= 0.80:
            recs.append({
                'title': 'Plan Ahead with Confidence',
                'description': 'Your cycles are predictable - schedule important events accordingly',
                'action': 'Use predictions for planning',
                'priority': 'medium'
            })
        elif cycles_analyzed < 6:
            recs.append({
                'title': 'Build Prediction Accuracy',
                'description': f'Log {6 - cycles_analyzed} more cycles for better predictions',
                'action': 'Continue consistent tracking',
                'priority': 'high'
            })
        
        return recs
    
    def _get_anomaly_recommendations(self, anomaly: Dict) -> List[Dict]:
        """Generate anomaly-based recommendations"""
        recs = []
        severity = anomaly.get('severity', 'none')
        
        if severity == 'significant':
            recs.append({
                'title': 'Monitor Cycle Changes',
                'description': anomaly.get('description', ''),
                'action': 'Consider medical consultation if pattern continues',
                'priority': 'high'
            })
        elif severity == 'moderate':
            recs.append({
                'title': 'Track Unusual Changes',
                'description': anomaly.get('description', ''),
                'action': 'Log symptoms to identify causes',
                'priority': 'medium'
            })
        
        return recs
    
    def _get_symptom_recommendations(self, symptom_insights: Dict) -> List[Dict]:
        """Generate symptom-based recommendations"""
        return symptom_insights.get('recommendations', [])[:5]
    
    def _get_health_recommendations(self, health_insights: Dict) -> List[Dict]:
        """Generate health-based recommendations"""
        return health_insights.get('recommendations', [])[:5]
    
    def _get_engagement_recommendations(self, engagement: Dict) -> List[Dict]:
        """Generate engagement recommendations"""
        recs = []
        consistency = engagement.get('consistencyScore', 0)
        streak = engagement.get('trackingStreak', 0)
        
        if consistency < 0.5:
            recs.append({
                'title': 'Build Tracking Consistency',
                'description': 'Regular logging improves prediction accuracy',
                'action': 'Set daily reminder for tracking',
                'priority': 'high'
            })
        elif streak >= 7:
            recs.append({
                'title': f'{streak}-Day Streak! 🎉',
                'description': 'Amazing consistency - keep it up!',
                'action': 'Continue your tracking habit',
                'priority': 'low'
            })
        
        return recs
    
    def _prioritize_recommendations(self, recommendations: Dict, anomaly: Dict,
                                   health_insights: Optional[Dict]) -> List[Dict]:
        """Prioritize all recommendations"""
        all_recs = []
        for category, recs in recommendations.items():
            if category != 'priority' and isinstance(recs, list):
                all_recs.extend(recs)
        
        # Sort by priority
        priority_order = {'high': 3, 'medium': 2, 'low': 1}
        all_recs.sort(key=lambda x: priority_order.get(x.get('priority', 'low'), 0), reverse=True)
        
        return all_recs[:10]
    
    def _determine_display_strategy(self, prediction: Optional[Dict], anomaly: Dict,
                                   engagement: Dict) -> Dict:
        """Determine UI display strategy"""
        strategy = {
            'mode': 'standard',
            'showPrediction': False,
            'showAnomalyAlert': False,
            'showEncouragement': False,
            'highlightPriority': None
        }
        
        if prediction and prediction.get('confidence', 0) >= 0.6:
            strategy['showPrediction'] = True
        
        if anomaly.get('severity') in ['significant', 'moderate']:
            strategy['showAnomalyAlert'] = True
            strategy['highlightPriority'] = 'anomaly'
        
        if engagement.get('trackingStreak', 0) >= 7:
            strategy['showEncouragement'] = True
        
        return strategy
    
    def assess_overall_risk(self, anomaly: Dict, symptom_insights: Optional[Dict],
                           health_insights: Optional[Dict]) -> Dict:
        """Assess overall health risk"""
        risk_score = 0
        risk_factors = []
        
        # Anomaly risk
        if anomaly.get('severity') == 'significant':
            risk_score += 3
            risk_factors.append('Significant cycle anomaly detected')
        elif anomaly.get('severity') == 'moderate':
            risk_score += 2
            risk_factors.append('Moderate cycle variation')
        
        # Symptom risk
        if symptom_insights and symptom_insights.get('riskAssessment'):
            symptom_risk = symptom_insights['riskAssessment']
            if symptom_risk.get('level') == 'high':
                risk_score += 3
                risk_factors.append('High symptom severity')
            elif symptom_risk.get('level') == 'moderate':
                risk_score += 2
                risk_factors.append('Moderate symptom burden')
        
        # Health risk
        if health_insights and health_insights.get('riskAssessment'):
            health_risk = health_insights['riskAssessment']
            if health_risk.get('level') == 'high':
                risk_score += 3
                risk_factors.extend(health_risk.get('factors', []))
            elif health_risk.get('level') == 'moderate':
                risk_score += 2
        
        # Determine overall level
        if risk_score >= 6:
            level = 'high'
            action = 'Medical consultation recommended'
        elif risk_score >= 3:
            level = 'moderate'
            action = 'Monitor closely and consider consultation'
        else:
            level = 'low'
            action = 'Continue regular tracking'
        
        return {
            'level': level,
            'score': risk_score,
            'factors': risk_factors,
            'recommendedAction': action,
            'requiresAttention': risk_score >= 4
        }
    
    def generate_personalized_insights(self, prediction: Optional[Dict], anomaly: Dict,
                                      symptom_insights: Optional[Dict],
                                      health_insights: Optional[Dict],
                                      recommendations: Dict) -> List[str]:
        """Generate personalized insights"""
        insights = []
        
        # Prediction insights
        if prediction:
            quality = prediction.get('predictionQuality', '')
            if 'Excellent' in quality:
                insights.append('Your cycle patterns are highly predictable! 🎯')
            
            regularity = prediction.get('regularityScore', 0)
            if regularity > 0.9:
                insights.append('Your cycle is remarkably consistent')
        
        # Anomaly insights
        if anomaly.get('detected'):
            insights.append(anomaly.get('description', ''))
        
        # Symptom insights
        if symptom_insights and symptom_insights.get('overallPattern'):
            pattern = symptom_insights['overallPattern']
            insights.append(pattern.get('description', ''))
        
        # Health insights
        if health_insights and health_insights.get('overallScore'):
            score_data = health_insights['overallScore']
            insights.append(f"Health score: {score_data.get('score', 0)}/100 - {score_data.get('rating', 'good')}")
        
        return insights[:5]
    
    def should_request_symptom_log(self, last_log_date: Optional[str],
                                   current_cycle_day: int,
                                   symptoms: List[Dict]) -> Tuple[bool, Optional[str]]:
        """Intelligent symptom logging prompts"""
        if not last_log_date:
            return True, 'Start tracking your symptoms today'
        
        try:
            last_log = datetime.fromisoformat(last_log_date.replace('Z', '+00:00'))
            days_since = (datetime.now() - last_log).days
        except:
            return True, 'Log your symptoms regularly'
        
        # Critical days during menstrual phase
        if 1 <= current_cycle_day <= 5 and days_since >= 1:
            return True, 'Track your period symptoms'
        
        # Ovulation window
        if 13 <= current_cycle_day <= 17 and days_since >= 1:
            return True, 'You\'re in your fertile window'
        
        # PMS tracking
        if current_cycle_day >= 20 and days_since >= 2:
            return True, 'Monitor for PMS symptoms'
        
        # General reminder
        if days_since >= 3:
            return True, 'Time to log your symptoms'
        
        return False, None