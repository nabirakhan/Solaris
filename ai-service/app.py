# File: ai-service/app.py
from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv
import os
import traceback
import logging
from functools import wraps
from datetime import datetime

# Import enhanced models
from models.cycle_predictor_advanced import AdvancedCyclePredictor
from models.symptom_analyzer_advanced import AdvancedSymptomAnalyzer
from models.health_tracker_advanced import AdvancedHealthTracker
from models.recommender_advanced import AdvancedRecommenderSystem

load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)

# Initialize enhanced AI models
cycle_predictor = AdvancedCyclePredictor()
symptom_analyzer = AdvancedSymptomAnalyzer()
health_tracker = AdvancedHealthTracker()
recommender = AdvancedRecommenderSystem()

# Error handling decorator
def handle_errors(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        try:
            return f(*args, **kwargs)
        except Exception as e:
            logger.error(f"Error in {f.__name__}: {str(e)}")
            logger.error(traceback.format_exc())
            return jsonify({
                'error': str(e),
                'endpoint': f.__name__,
                'timestamp': datetime.now().isoformat()
            }), 500
    return decorated_function

@app.route('/health', methods=['GET'])
def health_check():
    """Enhanced health check with model status"""
    return jsonify({
        'status': 'ok',
        'message': 'Enhanced AI Service Running',
        'version': '3.0.0',
        'features': [
            'ML-Enhanced Predictions',
            'Advanced Symptom Analysis',
            'Comprehensive Health Integration',
            'Pattern Recognition',
            'Risk Assessment'
        ],
        'models': {
            'cycle_predictor': 'AdvancedCyclePredictor v3.0',
            'symptom_analyzer': 'AdvancedSymptomAnalyzer v3.0',
            'health_tracker': 'AdvancedHealthTracker v3.0',
            'recommender': 'AdvancedRecommenderSystem v3.0'
        }
    })

@app.route('/predict', methods=['POST'])
@handle_errors
def predict_cycle():
    """
    ML-enhanced cycle prediction
    """
    data = request.json
    cycles = data.get('cycles', [])
    health_metrics = data.get('healthMetrics')
    
    if not cycles:
        return jsonify({'error': 'No cycle data provided'}), 400
    
    prediction = cycle_predictor.predict_next_period(cycles, health_metrics)
    
    return jsonify(prediction)

@app.route('/analyze', methods=['POST'])
@handle_errors
def comprehensive_analysis():
    """
    Complete AI-powered analysis with all enhancements
    """
    data = request.json
    user_id = data.get('userId')
    cycles = data.get('cycles', [])
    symptoms = data.get('symptoms', [])
    health_metrics = data.get('healthMetrics')
    
    if not cycles:
        return jsonify({
            'hasData': False,
            'message': 'No cycle data to analyze'
        }), 200
    
    # 1. Advanced cycle prediction
    prediction = cycle_predictor.predict_next_period(cycles, health_metrics)
    
    # 2. Enhanced anomaly detection
    anomaly = cycle_predictor.detect_anomaly(cycles)
    
    # 3. Comprehensive cycle insights
    cycle_insights = cycle_predictor.get_detailed_insights(cycles)
    
    # 4. Advanced symptom analysis
    symptom_insights = None
    if symptoms and len(symptoms) >= 5:
        symptom_insights = symptom_analyzer.analyze_patterns(
            symptoms, cycles, health_metrics
        )
    
    # 5. Health metrics analysis
    health_insights = None
    if health_metrics:
        health_insights = health_tracker.comprehensive_health_analysis(
            health_metrics, cycles, symptoms
        )
    
    # 6. User engagement metrics
    user_engagement = {
        'daysSinceLastLog': _calculate_days_since_last_log(symptoms),
        'totalLogs': len(symptoms),
        'consistencyScore': min(len(symptoms) / 30, 1.0),
        'trackingStreak': _calculate_tracking_streak(symptoms)
    }
    
    # 7. Advanced recommendations
    recommendations = recommender.generate_comprehensive_recommendations(
        prediction,
        anomaly,
        symptom_insights,
        health_insights,
        user_engagement,
        cycles
    )
    
    # 8. Risk assessment
    risk_assessment = recommender.assess_overall_risk(
        anomaly,
        symptom_insights,
        health_insights
    )
    
    # 9. Personalized insights
    insights = recommender.generate_personalized_insights(
        prediction,
        anomaly,
        symptom_insights,
        health_insights,
        recommendations
    )
    
    # Comprehensive result
    result = {
        'userId': user_id,
        'timestamp': datetime.now().isoformat(),
        'prediction': prediction,
        'anomaly': anomaly,
        'cycleInsights': cycle_insights,
        'symptomInsights': symptom_insights,
        'healthInsights': health_insights,
        'userEngagement': user_engagement,
        'recommendations': recommendations,
        'riskAssessment': risk_assessment,
        'personalizedInsights': insights,
        'metadata': {
            'cyclesAnalyzed': len(cycles),
            'symptomsAnalyzed': len(symptoms) if symptoms else 0,
            'hasHealthData': health_metrics is not None,
            'predictionQuality': prediction.get('predictionQuality') if prediction else None
        }
    }
    
    return jsonify(result)

@app.route('/symptom-prediction', methods=['POST'])
@handle_errors
def predict_symptoms():
    """Advanced symptom prediction"""
    data = request.json
    symptoms = data.get('symptoms', [])
    current_cycle_day = data.get('currentCycleDay', 1)
    cycles = data.get('cycles', [])
    
    prediction = symptom_analyzer.predict_symptom_likelihood(
        symptoms, current_cycle_day, cycles
    )
    
    return jsonify(prediction)

@app.route('/health-analysis', methods=['POST'])
@handle_errors
def analyze_health():
    """Comprehensive health analysis"""
    data = request.json
    health_metrics = data.get('healthMetrics')
    cycles = data.get('cycles', [])
    symptoms = data.get('symptoms', [])
    
    if not health_metrics:
        return jsonify({'error': 'No health metrics provided'}), 400
    
    analysis = health_tracker.comprehensive_health_analysis(
        health_metrics, cycles, symptoms
    )
    
    return jsonify(analysis)

@app.route('/cycle-insights', methods=['POST'])
@handle_errors
def get_cycle_insights():
    """Detailed cycle insights"""
    data = request.json
    cycles = data.get('cycles', [])
    
    if not cycles:
        return jsonify({'error': 'No cycle data provided'}), 400
    
    insights = cycle_predictor.get_detailed_insights(cycles)
    
    return jsonify(insights)

@app.route('/should-prompt-log', methods=['POST'])
@handle_errors
def should_prompt_log():
    """Intelligent logging prompts"""
    data = request.json
    last_log_date = data.get('lastSymptomLogDate')
    current_cycle_day = data.get('currentCycleDay', 1)
    symptoms = data.get('symptoms', [])
    
    should_prompt, reason = recommender.should_request_symptom_log(
        last_log_date, current_cycle_day, symptoms
    )
    
    return jsonify({
        'shouldPrompt': should_prompt,
        'reason': reason,
        'priority': 'high' if current_cycle_day <= 5 else 'medium'
    })

def _calculate_days_since_last_log(symptoms):
    """Calculate days since last symptom log"""
    if not symptoms:
        return 999
    
    try:
        last_log = symptoms[0]
        last_date = datetime.fromisoformat(
            last_log.get('date', last_log.get('createdAt')).replace('Z', '+00:00')
        )
        return (datetime.now() - last_date).days
    except:
        return 999

def _calculate_tracking_streak(symptoms):
    """Calculate current tracking streak"""
    if not symptoms:
        return 0
    
    try:
        dates = []
        for log in symptoms:
            date_str = log.get('date', log.get('createdAt'))
            dates.append(datetime.fromisoformat(date_str.replace('Z', '+00:00')).date())
        
        dates = sorted(set(dates), reverse=True)
        streak = 1
        
        for i in range(len(dates) - 1):
            diff = (dates[i] - dates[i+1]).days
            if diff == 1:
                streak += 1
            else:
                break
        
        return streak
    except:
        return 0

if __name__ == '__main__':
    port = int(os.getenv('FLASK_PORT', 5000))
    debug = os.getenv('FLASK_DEBUG', 'True').lower() == 'true'
    app.run(host='0.0.0.0', port=port, debug=debug)