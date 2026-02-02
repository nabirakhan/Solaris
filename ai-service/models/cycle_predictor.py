# File: ai-service/models/cycle_predictor.py
import numpy as np
import pandas as pd
from datetime import datetime, timedelta
from typing import List, Dict, Optional, Tuple
from scipy import stats
from sklearn.ensemble import RandomForestRegressor, GradientBoostingRegressor
from sklearn.preprocessing import StandardScaler
import warnings
warnings.filterwarnings('ignore')

class AdvancedCyclePredictor:
    """
    Advanced cycle prediction using ensemble ML models and time series analysis
    """
    
    def __init__(self):
        self.min_cycles_for_prediction = 2
        self.ideal_cycles_for_ml = 6
        self.ensemble_threshold = 8  # Use ensemble when we have enough data
        
        # ML models
        self.rf_model = RandomForestRegressor(n_estimators=50, random_state=42)
        self.gb_model = GradientBoostingRegressor(n_estimators=50, random_state=42)
        self.scaler = StandardScaler()
        
        # Model trained flag
        self.models_trained = False
        
    def predict_next_period(self, cycles: List[Dict], 
                           health_metrics: Optional[Dict] = None) -> Optional[Dict]:
        """
        Advanced prediction with ensemble ML models and health integration
        
        Uses multiple prediction strategies:
        1. Statistical methods (mean, median, weighted average)
        2. Time series decomposition
        3. Ensemble ML (Random Forest + Gradient Boosting)
        4. Health-adjusted predictions
        """
        if len(cycles) < self.min_cycles_for_prediction:
            return self._baseline_prediction(cycles)
        
        # Prepare data
        df = self._prepare_dataframe(cycles, health_metrics)
        
        if df is None or len(df) < 2:
            return self._baseline_prediction(cycles)
        
        # Get predictions from multiple methods
        predictions = {}
        
        # Method 1: Statistical prediction
        predictions['statistical'] = self._statistical_prediction(df, cycles)
        
        # Method 2: Time series prediction
        predictions['time_series'] = self._time_series_prediction(df)
        
        # Method 3: ML ensemble (if enough data)
        if len(cycles) >= self.ensemble_threshold:
            predictions['ml_ensemble'] = self._ml_ensemble_prediction(df, health_metrics)
        
        # Method 4: Weighted ensemble of all methods
        final_prediction = self._ensemble_predictions(
            predictions, 
            df, 
            health_metrics
        )
        
        return final_prediction
    
    def _prepare_dataframe(self, cycles: List[Dict], 
                          health_metrics: Optional[Dict] = None) -> Optional[pd.DataFrame]:
        """
        Prepare pandas DataFrame from cycle data with feature engineering
        """
        if not cycles:
            return None
        
        data = []
        for i, cycle in enumerate(cycles):
            if not cycle.get('cycleLength'):
                continue
            
            row = {
                'cycle_number': len(cycles) - i,
                'cycle_length': cycle['cycleLength'],
                'start_date': pd.to_datetime(cycle['startDate']),
            }
            
            # Add temporal features
            row['month'] = row['start_date'].month
            row['season'] = (row['start_date'].month % 12 + 3) // 3
            row['day_of_year'] = row['start_date'].dayofyear
            
            # Add health metrics if available
            if health_metrics:
                row['bmi'] = self._calculate_bmi(health_metrics)
                row['age'] = self._calculate_age(health_metrics.get('birthdate'))
            
            data.append(row)
        
        if not data:
            return None
        
        df = pd.DataFrame(data)
        df = df.sort_values('start_date')
        
        # Feature engineering
        df['cycle_length_ma3'] = df['cycle_length'].rolling(window=3, min_periods=1).mean()
        df['cycle_length_ma5'] = df['cycle_length'].rolling(window=5, min_periods=1).mean()
        df['cycle_length_std3'] = df['cycle_length'].rolling(window=3, min_periods=1).std()
        df['days_since_start'] = (df['start_date'] - df['start_date'].min()).dt.days
        
        # Lag features
        df['prev_cycle_length'] = df['cycle_length'].shift(1)
        df['prev_2_cycle_length'] = df['cycle_length'].shift(2)
        
        return df
    
    def _statistical_prediction(self, df: pd.DataFrame, 
                               cycles: List[Dict]) -> Dict:
        """
        Statistical prediction using robust statistics
        """
        cycle_lengths = df['cycle_length'].values
        
        # Calculate various statistics
        mean_length = np.mean(cycle_lengths)
        median_length = np.median(cycle_lengths)
        std_length = np.std(cycle_lengths)
        
        # Weighted average (recent cycles have more weight)
        weights = np.exp(np.linspace(-1, 0, len(cycle_lengths)))
        weighted_avg = np.average(cycle_lengths, weights=weights)
        
        # Use trimmed mean to reduce outlier impact
        trimmed_mean = stats.trim_mean(cycle_lengths, 0.1)
        
        # Combine methods with confidence-based weighting
        if len(cycle_lengths) >= 6:
            predicted_length = 0.4 * weighted_avg + 0.3 * median_length + 0.3 * trimmed_mean
        elif len(cycle_lengths) >= 4:
            predicted_length = 0.5 * weighted_avg + 0.5 * median_length
        else:
            predicted_length = 0.6 * weighted_avg + 0.4 * median_length
        
        # Calculate confidence
        cv = std_length / mean_length if mean_length > 0 else 1
        confidence = max(0.3, min(0.95, 1.0 - (cv * 1.5)))
        
        # Adjust confidence based on data quantity
        data_factor = min(len(cycle_lengths) / 10, 1.0)
        confidence *= (0.7 + 0.3 * data_factor)
        
        # Get last cycle date
        last_cycle = cycles[0]
        last_start = pd.to_datetime(last_cycle['startDate'])
        predicted_date = last_start + timedelta(days=int(predicted_length))
        
        # Calculate probability window
        window_days = max(2, int(std_length * 1.96))  # 95% confidence interval
        
        return {
            'method': 'statistical',
            'predicted_date': predicted_date,
            'predicted_length': predicted_length,
            'confidence': confidence,
            'window_days': window_days,
            'statistics': {
                'mean': mean_length,
                'median': median_length,
                'std': std_length,
                'weighted_avg': weighted_avg
            }
        }
    
    def _time_series_prediction(self, df: pd.DataFrame) -> Dict:
        """
        Time series analysis using decomposition and trend detection
        """
        cycle_lengths = df['cycle_length'].values
        
        # Detect trend using linear regression
        x = np.arange(len(cycle_lengths))
        slope, intercept, r_value, p_value, std_err = stats.linregress(x, cycle_lengths)
        
        # Predict next value
        next_x = len(cycle_lengths)
        trend_prediction = slope * next_x + intercept
        
        # Check for seasonality (if enough data)
        seasonality = 0
        if len(cycle_lengths) >= 12:
            # Simple seasonal decomposition
            seasonal_component = self._detect_seasonality(df)
            if seasonal_component is not None:
                seasonality = seasonal_component
        
        predicted_length = trend_prediction + seasonality
        
        # Bound the prediction to reasonable range
        predicted_length = np.clip(predicted_length, 21, 40)
        
        # Confidence based on R-squared and data points
        confidence = max(0.4, min(0.9, abs(r_value) * min(len(cycle_lengths) / 10, 1.0)))
        
        return {
            'method': 'time_series',
            'predicted_length': predicted_length,
            'confidence': confidence,
            'trend_slope': slope,
            'trend_strength': abs(r_value),
            'p_value': p_value
        }
    
    def _detect_seasonality(self, df: pd.DataFrame) -> Optional[float]:
        """
        Detect seasonal patterns in cycle data
        """
        if 'month' not in df.columns or len(df) < 12:
            return None
        
        # Group by month and check for patterns
        monthly_avg = df.groupby('month')['cycle_length'].mean()
        
        if len(monthly_avg) < 6:
            return None
        
        # Check if variation is significant
        overall_std = df['cycle_length'].std()
        monthly_std = monthly_avg.std()
        
        if monthly_std > overall_std * 0.5:
            # Get current month's adjustment
            current_month = df['start_date'].iloc[-1].month
            if current_month in monthly_avg.index:
                overall_mean = df['cycle_length'].mean()
                return monthly_avg[current_month] - overall_mean
        
        return 0
    
    def _ml_ensemble_prediction(self, df: pd.DataFrame, 
                               health_metrics: Optional[Dict]) -> Dict:
        """
        Machine learning ensemble prediction using Random Forest and Gradient Boosting
        """
        if len(df) < 6:
            return {'method': 'ml_ensemble', 'confidence': 0, 'note': 'Insufficient data for ML'}
        
        # Prepare features
        feature_cols = ['cycle_number', 'cycle_length_ma3', 'cycle_length_ma5']
        
        if 'bmi' in df.columns:
            feature_cols.extend(['bmi', 'age'])
        
        if 'month' in df.columns:
            feature_cols.extend(['month', 'season'])
        
        # Remove rows with NaN
        df_clean = df[feature_cols + ['cycle_length']].dropna()
        
        if len(df_clean) < 4:
            return {'method': 'ml_ensemble', 'confidence': 0, 'note': 'Insufficient clean data'}
        
        # Prepare train data
        X = df_clean[feature_cols].values[:-1]  # All but last
        y = df_clean['cycle_length'].values[1:]  # Shifted by 1 (predicting next)
        
        if len(X) < 3:
            return {'method': 'ml_ensemble', 'confidence': 0, 'note': 'Need more data'}
        
        try:
            # Scale features
            X_scaled = self.scaler.fit_transform(X)
            
            # Train models
            self.rf_model.fit(X_scaled, y)
            self.gb_model.fit(X_scaled, y)
            
            # Prepare prediction features
            last_row = df_clean[feature_cols].iloc[-1:].values
            last_row[0] += 1  # Increment cycle number
            X_pred = self.scaler.transform(last_row)
            
            # Get predictions
            rf_pred = self.rf_model.predict(X_pred)[0]
            gb_pred = self.gb_model.predict(X_pred)[0]
            
            # Ensemble prediction (weighted average)
            predicted_length = 0.6 * rf_pred + 0.4 * gb_pred
            
            # Calculate confidence based on model agreement
            agreement = 1 - abs(rf_pred - gb_pred) / max(rf_pred, gb_pred)
            confidence = 0.6 + 0.3 * agreement + 0.1 * min(len(X) / 10, 1.0)
            
            return {
                'method': 'ml_ensemble',
                'predicted_length': predicted_length,
                'confidence': min(confidence, 0.92),
                'rf_prediction': rf_pred,
                'gb_prediction': gb_pred,
                'model_agreement': agreement
            }
        
        except Exception as e:
            return {
                'method': 'ml_ensemble',
                'confidence': 0,
                'error': str(e)
            }
    
    def _ensemble_predictions(self, predictions: Dict, 
                             df: pd.DataFrame,
                             health_metrics: Optional[Dict]) -> Dict:
        """
        Combine all prediction methods into final ensemble prediction
        """
        valid_predictions = []
        weights = []
        
        # Weight predictions by confidence
        for method, pred_data in predictions.items():
            if pred_data.get('confidence', 0) > 0.3:
                valid_predictions.append(pred_data)
                weights.append(pred_data['confidence'])
        
        if not valid_predictions:
            # Fallback to statistical if available
            if 'statistical' in predictions:
                pred_data = predictions['statistical']
            else:
                return self._baseline_prediction([])
        else:
            # Weighted average of predictions
            weights = np.array(weights) / sum(weights)
            predicted_lengths = [p.get('predicted_length', p.get('statistics', {}).get('weighted_avg', 28)) 
                               for p in valid_predictions]
            predicted_length = np.average(predicted_lengths, weights=weights)
        
        # Get base prediction data
        stat_pred = predictions.get('statistical', {})
        last_start = df['start_date'].iloc[-1]
        predicted_date = last_start + timedelta(days=int(predicted_length))
        
        # Calculate final confidence
        confidences = [p['confidence'] for p in valid_predictions]
        final_confidence = np.average(confidences, weights=weights)
        
        # Adjust for health metrics
        if health_metrics:
            health_adjustment = self._health_adjustment_factor(health_metrics)
            final_confidence *= health_adjustment
        
        # Calculate statistics
        cycle_lengths = df['cycle_length'].values
        mean_length = np.mean(cycle_lengths)
        std_length = np.std(cycle_lengths)
        median_length = np.median(cycle_lengths)
        variability = std_length / mean_length if mean_length > 0 else 0
        
        # Probability window
        window_days = max(2, int(std_length * 1.96))
        window_start = predicted_date - timedelta(days=window_days)
        window_end = predicted_date + timedelta(days=window_days)
        
        # Regularity score
        regularity_score = 1.0 - min(variability, 1.0)
        
        # Prediction quality
        quality = self._get_prediction_quality(len(cycle_lengths), final_confidence)
        
        # Build comprehensive result
        result = {
            'nextPeriodDate': predicted_date.isoformat(),
            'confidence': round(float(final_confidence), 2),
            'probabilityWindow': {
                'start': window_start.isoformat(),
                'end': window_end.isoformat(),
                'daysRange': window_days * 2,
                'confidence95': True
            },
            'predictedCycleLength': round(float(predicted_length), 1),
            'averageCycleLength': round(float(mean_length), 1),
            'medianCycleLength': round(float(median_length), 1),
            'variability': round(float(variability), 2),
            'standardDeviation': round(float(std_length), 2),
            'regularityScore': round(float(regularity_score), 2),
            'cyclesAnalyzed': len(cycle_lengths),
            'predictionQuality': quality,
            'methodsUsed': list(predictions.keys()),
            'ensembleWeight': {
                method: round(float(w), 2) 
                for method, w in zip([p.get('method') for p in valid_predictions], weights)
            }
        }
        
        # Add health impact if available
        if health_metrics:
            result['healthImpact'] = self._assess_health_impact(health_metrics, variability)
        
        # Add insights
        result['insights'] = self._generate_insights(
            predicted_length, mean_length, regularity_score, len(cycle_lengths)
        )
        
        return result
    
    def _health_adjustment_factor(self, health_metrics: Dict) -> float:
        """
        Calculate confidence adjustment based on health metrics
        """
        bmi = self._calculate_bmi(health_metrics)
        
        if bmi == 0:
            return 1.0
        
        # Extreme BMI can affect cycle regularity
        if bmi < 18.5:
            return 0.92  # Underweight - slightly less predictable
        elif 18.5 <= bmi < 25:
            return 1.0  # Normal - no adjustment
        elif 25 <= bmi < 30:
            return 0.96  # Overweight - slight adjustment
        else:
            return 0.90  # Obese - more adjustment
    
    def _assess_health_impact(self, health_metrics: Dict, variability: float) -> Dict:
        """
        Assess how health metrics might impact cycle
        """
        bmi = self._calculate_bmi(health_metrics)
        age = self._calculate_age(health_metrics.get('birthdate'))
        
        impacts = []
        severity = 'none'
        
        if bmi < 18.5:
            impacts.append('Low BMI may contribute to cycle irregularity')
            severity = 'moderate' if variability > 0.15 else 'mild'
        elif bmi > 30:
            impacts.append('High BMI may affect cycle regularity')
            severity = 'moderate' if variability > 0.15 else 'mild'
        
        if age and age >= 40:
            impacts.append('Hormonal changes may increase variability')
            if variability > 0.2:
                severity = 'moderate'
        
        if not impacts:
            impacts.append('Health metrics within normal range')
        
        return {
            'severity': severity,
            'factors': impacts,
            'bmi': round(bmi, 1) if bmi > 0 else None,
            'age': age
        }
    
    def _calculate_bmi(self, health_metrics: Dict) -> float:
        """Calculate BMI from health metrics"""
        if not health_metrics:
            return 0
        
        height = health_metrics.get('height', 0)
        weight = health_metrics.get('weight', 0)
        use_metric = health_metrics.get('useMetric', True)
        
        if height <= 0 or weight <= 0:
            return 0
        
        if not use_metric:
            height_cm = height * 30.48
            weight_kg = weight * 0.453592
        else:
            height_cm = height
            weight_kg = weight
        
        height_m = height_cm / 100
        return weight_kg / (height_m ** 2) if height_m > 0 else 0
    
    def _calculate_age(self, birthdate_str: Optional[str]) -> Optional[int]:
        """Calculate age from birthdate"""
        if not birthdate_str:
            return None
        
        try:
            birthdate = pd.to_datetime(birthdate_str)
            today = pd.Timestamp.now()
            age = today.year - birthdate.year
            if today.month < birthdate.month or (
                today.month == birthdate.month and today.day < birthdate.day
            ):
                age -= 1
            return age
        except:
            return None
    
    def _baseline_prediction(self, cycles: List[Dict]) -> Optional[Dict]:
        """Fallback baseline prediction"""
        if not cycles:
            return None
        
        last_cycle = cycles[0]
        last_start = pd.to_datetime(last_cycle['startDate'])
        predicted_date = last_start + timedelta(days=28)
        
        return {
            'nextPeriodDate': predicted_date.isoformat(),
            'confidence': 0.35,
            'probabilityWindow': {
                'start': (predicted_date - timedelta(days=4)).isoformat(),
                'end': (predicted_date + timedelta(days=4)).isoformat(),
                'daysRange': 8
            },
            'predictedCycleLength': 28,
            'averageCycleLength': 28,
            'medianCycleLength': 28,
            'variability': 0,
            'regularityScore': 0.5,
            'cyclesAnalyzed': len(cycles),
            'predictionQuality': 'Baseline - Need More Data',
            'methodsUsed': ['baseline'],
            'note': 'Using standard 28-day cycle - log more cycles for personalized predictions',
            'insights': ['Start tracking to get personalized predictions']
        }
    
    def _get_prediction_quality(self, num_cycles: int, confidence: float) -> str:
        """Categorize prediction quality"""
        if num_cycles < 3:
            return 'Limited - Log More Cycles'
        elif num_cycles >= 8 and confidence >= 0.85:
            return 'Excellent - ML Enhanced'
        elif confidence >= 0.80:
            return 'Excellent - Very Reliable'
        elif confidence >= 0.70:
            return 'Very Good - Reliable'
        elif confidence >= 0.60:
            return 'Good - Mostly Reliable'
        elif confidence >= 0.50:
            return 'Fair - Moderate Confidence'
        else:
            return 'Low - More Data Recommended'
    
    def _generate_insights(self, predicted_length: float, mean_length: float,
                          regularity_score: float, num_cycles: int) -> List[str]:
        """Generate user-friendly insights"""
        insights = []
        
        if regularity_score > 0.9:
            insights.append('Your cycle is remarkably consistent! 🎯')
        elif regularity_score > 0.75:
            insights.append('Your cycle shows good regularity')
        elif regularity_score > 0.6:
            insights.append('Your cycle has moderate variability')
        else:
            insights.append('Your cycle shows notable variation - this is normal for many people')
        
        # Cycle length insights
        if predicted_length < 24:
            insights.append('Your cycles tend to be shorter than average')
        elif predicted_length > 32:
            insights.append('Your cycles tend to be longer than average')
        else:
            insights.append('Your cycle length is within typical range')
        
        # Data quality insights
        if num_cycles >= 10:
            insights.append('Excellent data history - predictions are highly personalized')
        elif num_cycles >= 6:
            insights.append('Good tracking history - predictions improving')
        elif num_cycles >= 3:
            insights.append('Building prediction accuracy - keep tracking!')
        
        return insights
    
    def detect_anomaly(self, cycles: List[Dict]) -> Dict:
        """
        Advanced anomaly detection with multiple statistical methods
        """
        if len(cycles) < 3:
            return {
                'detected': False,
                'score': 0,
                'severity': 'none',
                'description': 'Need at least 3 cycles for anomaly detection'
            }
        
        df = self._prepare_dataframe(cycles, None)
        if df is None or len(df) < 3:
            return {'detected': False, 'score': 0, 'severity': 'none'}
        
        cycle_lengths = df['cycle_length'].values
        current_length = cycle_lengths[-1]
        historical = cycle_lengths[:-1]
        
        # Method 1: Z-score
        mean_hist = np.mean(historical)
        std_hist = np.std(historical)
        z_score = abs((current_length - mean_hist) / std_hist) if std_hist > 0 else 0
        
        # Method 2: IQR method
        q1, q3 = np.percentile(historical, [25, 75])
        iqr = q3 - q1
        lower_bound = q1 - 1.5 * iqr
        upper_bound = q3 + 1.5 * iqr
        is_outlier_iqr = current_length < lower_bound or current_length > upper_bound
        
        # Method 3: Modified Z-score (more robust)
        median_hist = np.median(historical)
        mad = np.median(np.abs(historical - median_hist))
        modified_z = 0.6745 * (current_length - median_hist) / mad if mad > 0 else 0
        
        # Combine methods
        anomaly_score = (z_score / 3 + abs(modified_z) / 3.5 + (0.5 if is_outlier_iqr else 0)) / 2.5
        anomaly_score = min(anomaly_score, 1.0)
        
        # Determine severity
        if z_score < 1.5 and not is_outlier_iqr:
            severity = 'none'
            is_anomalous = False
        elif z_score < 2.0:
            severity = 'mild'
            is_anomalous = True
        elif z_score < 2.5:
            severity = 'moderate'
            is_anomalous = True
        else:
            severity = 'significant'
            is_anomalous = True
        
        # Generate description
        difference = int(abs(current_length - mean_hist))
        if is_anomalous:
            if current_length > mean_hist:
                description = f'This cycle was {difference} days longer than your average'
                recommendation = 'Consider tracking any unusual stress, diet changes, or symptoms'
                concern_level = 'Monitor if pattern continues'
            else:
                description = f'This cycle was {difference} days shorter than your average'
                recommendation = 'Note any changes in lifestyle or health'
                concern_level = 'Monitor if pattern continues'
        else:
            description = 'This cycle length is within your normal range'
            recommendation = 'Keep up your consistent tracking!'
            concern_level = 'No concerns'
        
        return {
            'detected': bool(is_anomalous),
            'score': round(float(anomaly_score), 2),
            'severity': severity,
            'description': description,
            'recommendation': recommendation,
            'concernLevel': concern_level,
            'currentLength': int(current_length),
            'averageLength': round(float(mean_hist), 1),
            'medianLength': round(float(median_hist), 1),
            'zScore': round(float(z_score), 2),
            'modifiedZScore': round(float(abs(modified_z)), 2),
            'isOutlier': is_outlier_iqr,
            'normalRange': {
                'lower': round(float(mean_hist - 2 * std_hist), 1),
                'upper': round(float(mean_hist + 2 * std_hist), 1)
            }
        }
    
    def get_detailed_insights(self, cycles: List[Dict]) -> Dict:
        """
        Comprehensive cycle analysis with advanced metrics
        """
        if not cycles:
            return {'hasData': False, 'message': 'No cycle data available'}
        
        df = self._prepare_dataframe(cycles, None)
        if df is None:
            return {'hasData': False, 'message': 'Invalid cycle data'}
        
        cycle_lengths = df['cycle_length'].dropna().values
        
        if len(cycle_lengths) == 0:
            return {'hasData': False, 'message': 'No completed cycles'}
        
        # Basic statistics
        stats_dict = {
            'average': round(float(np.mean(cycle_lengths)), 1),
            'median': round(float(np.median(cycle_lengths)), 1),
            'mode': int(stats.mode(cycle_lengths.round())[0]) if len(cycle_lengths) > 2 else None,
            'shortest': int(min(cycle_lengths)),
            'longest': int(max(cycle_lengths)),
            'range': int(max(cycle_lengths) - min(cycle_lengths)),
            'standardDeviation': round(float(np.std(cycle_lengths)), 2),
            'variance': round(float(np.var(cycle_lengths)), 2),
            'coefficientOfVariation': round(float(np.std(cycle_lengths) / np.mean(cycle_lengths)), 3)
        }
        
        # Regularity assessment
        regularity = self._assess_regularity(cycle_lengths)
        
        # Trend detection
        trends = self._detect_comprehensive_trends(df)
        
        # Consistency metrics
        consistency = self._calculate_advanced_consistency(cycle_lengths)
        
        # Phase predictions
        phase_insights = self._analyze_phases(df)
        
        # Predictability score
        predictability = self._calculate_predictability(cycle_lengths, regularity['score'])
        
        return {
            'hasData': True,
            'totalCycles': len(cycles),
            'completedCycles': len(cycle_lengths),
            'statistics': stats_dict,
            'regularity': regularity,
            'trends': trends,
            'consistency': consistency,
            'phaseInsights': phase_insights,
            'predictability': predictability,
            'dataQuality': self._assess_data_quality(len(cycle_lengths), stats_dict['coefficientOfVariation'])
        }
    
    def _assess_regularity(self, cycle_lengths: np.ndarray) -> Dict:
        """Enhanced regularity assessment"""
        mean_val = np.mean(cycle_lengths)
        std_val = np.std(cycle_lengths)
        cv = std_val / mean_val if mean_val > 0 else 1
        
        # Calculate consistency percentage
        within_one_day = np.sum(np.abs(cycle_lengths - mean_val) <= 1) / len(cycle_lengths)
        within_two_days = np.sum(np.abs(cycle_lengths - mean_val) <= 2) / len(cycle_lengths)
        
        if cv < 0.03:
            category = 'Extremely Regular'
            description = 'Your cycles are exceptionally consistent'
            score = 0.98
        elif cv < 0.05:
            category = 'Very Regular'
            description = 'Your cycles are very consistent'
            score = 0.92
        elif cv < 0.08:
            category = 'Regular'
            description = 'Your cycles show good consistency'
            score = 0.85
        elif cv < 0.12:
            category = 'Fairly Regular'
            description = 'Your cycles are fairly consistent with some variation'
            score = 0.72
        elif cv < 0.18:
            category = 'Moderately Irregular'
            description = 'Your cycles show moderate variation'
            score = 0.55
        else:
            category = 'Irregular'
            description = 'Your cycles vary significantly'
            score = 0.35
        
        return {
            'category': category,
            'score': score,
            'description': description,
            'coefficientOfVariation': round(float(cv), 3),
            'withinOneDayPercent': round(float(within_one_day * 100), 1),
            'withinTwoDaysPercent': round(float(within_two_days * 100), 1)
        }
    
    def _detect_comprehensive_trends(self, df: pd.DataFrame) -> Dict:
        """Advanced trend detection"""
        if len(df) < 4:
            return {'hasTrend': False, 'description': 'Need more data for trend analysis'}
        
        cycle_lengths = df['cycle_length'].values
        x = np.arange(len(cycle_lengths))
        
        # Linear trend
        slope, intercept, r_value, p_value, std_err = stats.linregress(x, cycle_lengths)
        
        # Polynomial trend (2nd degree)
        poly_coeffs = np.polyfit(x, cycle_lengths, 2) if len(cycle_lengths) >= 6 else None
        
        # Determine trend direction and significance
        if p_value > 0.05:
            trend = 'stable'
            description = 'No significant trend detected'
            is_significant = False
        elif slope > 0.15:
            trend = 'increasing'
            description = 'Cycles are gradually getting longer'
            is_significant = True
        elif slope < -0.15:
            trend = 'decreasing'
            description = 'Cycles are gradually getting shorter'
            is_significant = True
        else:
            trend = 'stable'
            description = 'Cycles are relatively stable'
            is_significant = False
        
        return {
            'hasTrend': is_significant,
            'direction': trend,
            'description': description,
            'slope': round(float(slope), 3),
            'rSquared': round(float(r_value ** 2), 3),
            'pValue': round(float(p_value), 4),
            'significance': 'significant' if p_value < 0.05 else 'not significant',
            'trendStrength': 'strong' if abs(r_value) > 0.7 else 'moderate' if abs(r_value) > 0.4 else 'weak'
        }
    
    def _calculate_advanced_consistency(self, cycle_lengths: np.ndarray) -> Dict:
        """Advanced consistency calculations"""
        if len(cycle_lengths) < 2:
            return {'score': 0, 'description': 'Insufficient data'}
        
        # Consecutive differences
        diffs = np.abs(np.diff(cycle_lengths))
        avg_diff = np.mean(diffs)
        max_diff = np.max(diffs)
        
        # Calculate score
        if avg_diff < 1:
            score = 1.0
            description = 'Extremely consistent - cycles vary by <1 day'
        elif avg_diff < 2:
            score = 0.90
            description = 'Very consistent - minimal variation'
        elif avg_diff < 3:
            score = 0.75
            description = 'Moderately consistent'
        elif avg_diff < 5:
            score = 0.55
            description = 'Somewhat variable'
        else:
            score = 0.35
            description = 'Highly variable'
        
        return {
            'score': score,
            'description': description,
            'averageDifference': round(float(avg_diff), 1),
            'maxDifference': int(max_diff),
            'consecutiveVariability': round(float(np.std(diffs)), 2) if len(diffs) > 1 else 0
        }
    
    def _analyze_phases(self, df: pd.DataFrame) -> Dict:
        """Analyze cycle phases"""
        avg_length = df['cycle_length'].mean()
        
        # Calculate typical phase lengths
        menstrual_days = 5
        follicular_days = int(avg_length * 0.35)
        ovulation_days = 4
        luteal_days = int(avg_length - menstrual_days - follicular_days - ovulation_days)
        
        return {
            'averageCycleLength': round(float(avg_length), 1),
            'typicalPhases': {
                'menstrual': {'start': 1, 'end': menstrual_days, 'duration': menstrual_days},
                'follicular': {'start': menstrual_days + 1, 'end': menstrual_days + follicular_days, 'duration': follicular_days},
                'ovulation': {'start': menstrual_days + follicular_days + 1, 'end': menstrual_days + follicular_days + ovulation_days, 'duration': ovulation_days},
                'luteal': {'start': menstrual_days + follicular_days + ovulation_days + 1, 'end': int(avg_length), 'duration': luteal_days}
            }
        }
    
    def _calculate_predictability(self, cycle_lengths: np.ndarray, regularity_score: float) -> Dict:
        """Calculate overall predictability score"""
        data_quantity_score = min(len(cycle_lengths) / 10, 1.0)
        
        # Combine regularity and data quantity
        overall_score = 0.7 * regularity_score + 0.3 * data_quantity_score
        
        if overall_score >= 0.85:
            rating = 'Excellent'
            description = 'Your cycle is highly predictable'
        elif overall_score >= 0.70:
            rating = 'Very Good'
            description = 'Your cycle is quite predictable'
        elif overall_score >= 0.55:
            rating = 'Good'
            description = 'Your cycle shows moderate predictability'
        elif overall_score >= 0.40:
            rating = 'Fair'
            description = 'Your cycle has some predictability'
        else:
            rating = 'Low'
            description = 'Your cycle is less predictable - continue tracking'
        
        return {
            'score': round(overall_score, 2),
            'rating': rating,
            'description': description,
            'regularityComponent': round(regularity_score, 2),
            'dataQuantityComponent': round(data_quantity_score, 2)
        }
    
    def _assess_data_quality(self, num_cycles: int, cv: float) -> Dict:
        """Assess overall data quality"""
        # Quantity score
        if num_cycles >= 10:
            quantity = 'excellent'
            quantity_score = 1.0
        elif num_cycles >= 6:
            quantity = 'good'
            quantity_score = 0.8
        elif num_cycles >= 3:
            quantity = 'fair'
            quantity_score = 0.6
        else:
            quantity = 'limited'
            quantity_score = 0.4
        
        # Quality score based on variability
        if cv < 0.08:
            quality = 'excellent'
            quality_score = 1.0
        elif cv < 0.15:
            quality = 'good'
            quality_score = 0.8
        elif cv < 0.25:
            quality = 'fair'
            quality_score = 0.6
        else:
            quality = 'variable'
            quality_score = 0.4
        
        overall_score = 0.5 * quantity_score + 0.5 * quality_score
        
        return {
            'overall': round(overall_score, 2),
            'quantity': quantity,
            'quality': quality,
            'recommendation': self._get_data_quality_recommendation(num_cycles, cv)
        }
    
    def _get_data_quality_recommendation(self, num_cycles: int, cv: float) -> str:
        """Get recommendation for improving data quality"""
        if num_cycles < 6:
            return 'Continue tracking for at least 6 cycles to improve prediction accuracy'
        elif cv > 0.2:
            return 'Your cycles vary significantly - consider tracking symptoms to identify patterns'
        else:
            return 'Excellent tracking! Your data enables highly accurate predictions'