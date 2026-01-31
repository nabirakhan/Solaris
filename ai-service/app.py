# File: ai-service/app.py
from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv
import os
import traceback

from models.cycle_predictor import CyclePredictor
from models.symptom_analyzer import SymptomAnalyzer
from models.recommender import RecommenderSystem
from models.health_tracker import HealthTracker

load_dotenv()

app = Flask(__name__)
CORS(app)

# Initialize AI models
cycle_predictor = CyclePredictor()
symptom_analyzer = SymptomAnalyzer()
recommender = RecommenderSystem()
health_tracker = HealthTracker()

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'ok',
        'message': 'AI Service is running',
        'version': '2.0.0'
    })

@app.route('/predict', methods=['POST'])
def predict_cycle():
    """
    Predict next period date based on cycle history
    Enhanced with health metrics integration
    """
    try:
        data = request.json
        cycles = data.get('cycles', [])
        health_metrics = data.get('healthMetrics')
        
        if not cycles:
            return jsonify({'error': 'No cycle data provided'}), 400
        
        # Get prediction
        prediction = cycle_predictor.predict_next_period(cycles)
        
        # Enhance with health-based adjustments if available
        if health_metrics and prediction:
            prediction = health_tracker.adjust_prediction_with_health(
                prediction, 
                health_metrics
            )
        
        return jsonify(prediction)
    
    except Exception as e:
        print(f"Error in predict_cycle: {str(e)}")
        traceback.print_exc()
        return jsonify({'error': str(e)}), 500

@app.route('/analyze', methods=['POST'])
def full_analysis():
    """
    Comprehensive analysis including prediction, anomaly detection, 
    health metrics, and recommendations
    """
    try:
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
        
        # 1. Cycle prediction
        prediction = cycle_predictor.predict_next_period(cycles)
        
        # 2. Anomaly detection
        anomaly = cycle_predictor.detect_anomaly(cycles)
        
        # 3. Symptom analysis
        symptom_insights = symptom_analyzer.analyze_patterns(symptoms, cycles)
        
        # 4. Health metrics analysis
        health_insights = None
        if health_metrics:
            health_insights = health_tracker.analyze_health_metrics(health_metrics)
        
        # 5. User engagement metrics
        user_engagement = {
            'daysSinceLastLog': 0,
            'totalLogs': len(symptoms),
            'consistencyScore': min(len(symptoms) / 30, 1.0)
        }
        
        # 6. Get recommendations from RS
        recommendations = recommender.decide_display_strategy(
            prediction,
            anomaly,
            user_engagement
        )
        
        # 7. Generate insight text
        insight_texts = recommender.generate_insight_text(
            prediction,
            anomaly,
            recommendations
        )
        
        # 8. Health-based recommendations
        health_recommendations = []
        if health_insights:
            health_recommendations = recommender.get_health_recommendations(
                health_insights
            )
        
        # Combine all results
        result = {
            'userId': user_id,
            'prediction': prediction,
            'anomaly': anomaly,
            'symptomInsights': symptom_insights,
            'healthInsights': health_insights,
            'recommendations': recommendations,
            'insightTexts': insight_texts,
            'healthRecommendations': health_recommendations,
            'cycleData': {
                'averageLength': prediction.get('averageCycleLength') if prediction else None,
                'variability': prediction.get('variability') if prediction else None,
                'totalCyclesAnalyzed': len(cycles)
            },
            'shouldDisplay': recommendations['showPrediction'] or recommendations['showAnomalyAlert'],
            'displayPriority': recommendations['displayPriority']
        }
        
        return jsonify(result)
    
    except Exception as e:
        print(f"Error in full_analysis: {str(e)}")
        traceback.print_exc()
        return jsonify({'error': str(e)}), 500

@app.route('/symptom-prediction', methods=['POST'])
def predict_symptoms():
    """
    Predict symptom likelihood based on current cycle day
    """
    try:
        data = request.json
        symptoms = data.get('symptoms', [])
        current_cycle_day = data.get('currentCycleDay', 1)
        
        prediction = symptom_analyzer.predict_symptom_likelihood(
            symptoms,
            current_cycle_day
        )
        
        return jsonify(prediction)
    
    except Exception as e:
        print(f"Error in predict_symptoms: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/should-prompt-log', methods=['POST'])
def should_prompt_log():
    """
    Decide if user should be prompted to log symptoms
    """
    try:
        data = request.json
        last_log_date = data.get('lastSymptomLogDate')
        current_cycle_day = data.get('currentCycleDay', 1)
        
        should_prompt, reason = recommender.should_request_symptom_log(
            last_log_date,
            current_cycle_day
        )
        
        return jsonify({
            'shouldPrompt': should_prompt,
            'reason': reason
        })
    
    except Exception as e:
        print(f"Error in should_prompt_log: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/health-analysis', methods=['POST'])
def analyze_health():
    """
    Analyze health metrics and provide insights
    NEW ENDPOINT
    """
    try:
        data = request.json
        health_metrics = data.get('healthMetrics')
        
        if not health_metrics:
            return jsonify({'error': 'No health metrics provided'}), 400
        
        analysis = health_tracker.analyze_health_metrics(health_metrics)
        recommendations = health_tracker.get_health_recommendations(analysis)
        
        return jsonify({
            'analysis': analysis,
            'recommendations': recommendations
        })
    
    except Exception as e:
        print(f"Error in analyze_health: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/cycle-insights', methods=['POST'])
def get_cycle_insights():
    """
    Get detailed cycle insights and patterns
    NEW ENDPOINT
    """
    try:
        data = request.json
        cycles = data.get('cycles', [])
        
        if not cycles:
            return jsonify({'error': 'No cycle data provided'}), 400
        
        insights = cycle_predictor.get_detailed_insights(cycles)
        
        return jsonify(insights)
    
    except Exception as e:
        print(f"Error in get_cycle_insights: {str(e)}")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    port = int(os.getenv('FLASK_PORT', 5000))
    debug = os.getenv('FLASK_DEBUG', 'True').lower() == 'true'
    app.run(host='0.0.0.0', port=port, debug=debug)