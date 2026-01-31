# File: ai-service/app.py
from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv
import os

from models.cycle_predictor import CyclePredictor
from models.symptom_analyzer import SymptomAnalyzer
from models.recommender import RecommenderSystem

load_dotenv()

app = Flask(__name__)
CORS(app)

cycle_predictor = CyclePredictor()
symptom_analyzer = SymptomAnalyzer()
recommender = RecommenderSystem()

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'ok',
        'message': 'AI Service is running'
    })

@app.route('/predict', methods=['POST'])
def predict_cycle():
    """
    Predict next period date based on cycle history
    """
    try:
        data = request.json
        cycles = data.get('cycles', [])
        
        if not cycles:
            return jsonify({'error': 'No cycle data provided'}), 400
        
        # Get prediction
        prediction = cycle_predictor.predict_next_period(cycles)
        
        return jsonify(prediction)
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/analyze', methods=['POST'])
def full_analysis():
    """
    Comprehensive analysis including prediction, anomaly detection, and recommendations
    """
    try:
        data = request.json
        user_id = data.get('userId')
        cycles = data.get('cycles', [])
        symptoms = data.get('symptoms', [])
        
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
        
        # 4. User engagement metrics (simplified - would come from backend in real app)
        user_engagement = {
            'daysSinceLastLog': 0,  # Would be calculated from actual data
            'totalLogs': len(symptoms),
            'consistencyScore': min(len(symptoms) / 30, 1.0)
        }
        
        # 5. Get recommendations from RS
        recommendations = recommender.decide_display_strategy(
            prediction,
            anomaly,
            user_engagement
        )
        
        # 6. Generate insight text
        insight_texts = recommender.generate_insight_text(
            prediction,
            anomaly,
            recommendations
        )
        
        # Combine all results
        result = {
            'userId': user_id,
            'prediction': prediction,
            'anomaly': anomaly,
            'symptomInsights': symptom_insights,
            'recommendations': recommendations,
            'insightTexts': insight_texts,
            'cycleData': {
                'averageLength': prediction.get('averageCycleLength'),
                'variability': prediction.get('variability'),
                'totalCyclesAnalyzed': len(cycles)
            },
            'shouldDisplay': recommendations['showPrediction'] or recommendations['showAnomalyAlert'],
            'displayPriority': recommendations['displayPriority']
        }
        
        return jsonify(result)
    
    except Exception as e:
        print(f"Error in full_analysis: {str(e)}")
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
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    port = int(os.getenv('FLASK_PORT', 5001))
    app.run(host='0.0.0.0', port=port, debug=True)