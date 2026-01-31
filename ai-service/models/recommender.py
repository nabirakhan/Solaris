# File: ai-service/models/recommender.py
class RecommenderSystem:
    """
    Decides WHAT to show to users based on:
    - AI confidence levels
    - Anomaly scores
    - User engagement patterns
    - Data completeness
    """
    
    def __init__(self):
        self.confidence_threshold_high = 0.75
        self.confidence_threshold_medium = 0.50
        self.anomaly_threshold = 0.65
    
    def decide_display_strategy(self, prediction_data, anomaly_data, user_engagement):
        """
        Decides what UI elements to show and how to present information
        
        Args:
            prediction_data: Prediction results from CyclePredictor
            anomaly_data: Anomaly detection results
            user_engagement: Dict with user interaction metrics
        
        Returns:
            dict with display recommendations
        """
        recommendations = {
            'showPrediction': False,
            'showAnomalyAlert': False,
            'showConfidenceLevel': False,
            'uiMode': 'minimal',  # minimal, standard, detailed
            'promptForMoreData': False,
            'displayPriority': 0,
            'message': None
        }
        
        confidence = prediction_data.get('confidence', 0) if prediction_data else 0
        cycles_analyzed = prediction_data.get('cyclesAnalyzed', 0) if prediction_data else 0
        anomaly_detected = anomaly_data.get('detected', False)
        anomaly_score = anomaly_data.get('score', 0)
        
        # Decision 1: Should we show predictions?
        if confidence >= self.confidence_threshold_medium and cycles_analyzed >= 2:
            recommendations['showPrediction'] = True
            
            if confidence >= self.confidence_threshold_high:
                recommendations['uiMode'] = 'minimal'
                recommendations['message'] = 'Based on your past patterns'
            else:
                recommendations['uiMode'] = 'standard'
                recommendations['showConfidenceLevel'] = True
                recommendations['message'] = 'Predicted from your cycle history'
        
        # Decision 2: Should we show anomaly alerts?
        if anomaly_detected and anomaly_score >= self.anomaly_threshold:
            recommendations['showAnomalyAlert'] = True
            recommendations['uiMode'] = 'detailed'
            recommendations['displayPriority'] = 2
            recommendations['message'] = 'We noticed a change compared to your usual cycle'
        
        # Decision 3: Should we ask for more data?
        if cycles_analyzed < 3:
            recommendations['promptForMoreData'] = True
            recommendations['message'] = 'Log a few more cycles to improve predictions'
        
        # Decision 4: Adjust based on user engagement
        days_since_last_log = user_engagement.get('daysSinceLastLog', 0)
        
        if days_since_last_log > 7:
            recommendations['uiMode'] = 'gentle_reentry'
            recommendations['message'] = 'Welcome back! Log your current state'
        
        # Decision 5: Set display priority
        if anomaly_detected:
            recommendations['displayPriority'] = 3
        elif recommendations['showPrediction'] and confidence >= self.confidence_threshold_high:
            recommendations['displayPriority'] = 2
        elif recommendations['promptForMoreData']:
            recommendations['displayPriority'] = 1
        
        return recommendations
    
    def generate_insight_text(self, prediction_data, anomaly_data, recommendations):
        """
        Generates user-friendly insight text based on data and recommendations
        
        Returns:
            List of insight strings to display
        """
        insights = []
        
        if not prediction_data:
            return ['Start logging your cycle to see personalized insights']
        
        if recommendations['showPrediction']:
            confidence = prediction_data.get('confidence', 0)
            cycles = prediction_data.get('cyclesAnalyzed', 0)
            
            if confidence >= 0.75:
                insights.append('Your cycle patterns are becoming clear')
            elif confidence >= 0.5:
                insights.append(f'Based on {cycles} cycles logged')
            else:
                insights.append('Early predictions - keep logging for better accuracy')
        
        if recommendations['showAnomalyAlert']:
            description = anomaly_data.get('description', '')
            insights.append(description)
        
        variability = prediction_data.get('variability', 0)
        if variability < 0.1 and prediction_data.get('cyclesAnalyzed', 0) >= 3:
            insights.append('Your cycle length is very consistent')
        elif variability > 0.2:
            insights.append('Your cycle length varies - this is normal for many people')
        
        return insights
    
    def should_request_symptom_log(self, last_symptom_log_date, current_cycle_day):
        """
        Decides if app should prompt user to log symptoms
        
        Returns:
            bool and reason
        """
        if not last_symptom_log_date:
            return True, 'How are you feeling today?'
        
        from datetime import datetime, timedelta
        
        last_log = datetime.fromisoformat(last_symptom_log_date.replace('Z', '+00:00'))
        days_since_log = (datetime.now() - last_log).days
        
        # Always ask during menstrual phase
        if 1 <= current_cycle_day <= 5 and days_since_log >= 1:
            return True, 'Track your symptoms during your period'
        
        # Ask less frequently during other phases
        if days_since_log >= 3:
            return True, 'Log your symptoms to spot patterns'
        
        return False, None