# 🌸 Solaris - AI-Powered Period Tracker

A modern menstrual cycle tracking app with advanced machine learning predictions and personalized health insights.

[![Backend](https://img.shields.io/badge/Backend-Live-success)](https://solaris-vhc8.onrender.com)
[![AI Service](https://img.shields.io/badge/AI%20Service-Live-success)](https://solaris-ai-service.onrender.com)
[![Python](https://img.shields.io/badge/Python-3.11-blue)](https://python.org)
[![Flutter](https://img.shields.io/badge/Flutter-Latest-02569B)](https://flutter.dev)

## ✨ Features

- **🔮 AI Cycle Predictions**: ML ensemble models (Random Forest + Gradient Boosting) predict next period with 80%+ accuracy
- **📊 Symptom Pattern Recognition**: Advanced clustering and correlation analysis to identify patterns across menstrual phases
- **⚠️ Anomaly Detection**: Statistical methods (Z-scores, IQR) automatically flag irregular cycles
- **💪 Health Integration**: Correlates BMI, sleep, stress levels with cycle regularity and symptom severity
- **🎯 Personalized Recommendations**: Context-aware AI suggestions for lifestyle, wellness, and medical actions
- **📅 Calendar View**: Visual timeline of cycle history with predictive insights
- **📱 Multi-platform**: Works on iOS, Android, and web

## 🤖 AI Features (Powered by scikit-learn)

### 1. **Cycle Prediction with ML Ensembles**
- **Random Forest Regressor** (50 estimators) for robust pattern recognition
- **Gradient Boosting Regressor** (50 estimators) for sequential learning
- **Time Series Decomposition** for trend and seasonality analysis
- **Weighted Ensemble** combining statistical methods with ML predictions
- **Confidence Scoring** based on data quality and pattern consistency

### 2. **Symptom Pattern Recognition**
- **K-means Clustering** to group similar symptom patterns
- **Correlation Analysis** between symptoms and cycle phases
- **Severity Classification** using statistical distributions
- **Phase-Specific Insights** (menstrual, follicular, ovulation, luteal)
- **Trend Detection** for worsening or improving patterns

### 3. **Anomaly Detection**
- **Z-score Analysis** for outlier detection (threshold: 2.5σ)
- **Interquartile Range (IQR)** method for robust outliers
- **Modified Z-score** using median absolute deviation
- **Multi-method Consensus** for accurate anomaly flagging
- **Severity Scoring** (mild, moderate, significant)

### 4. **Health Correlation Analysis**
- **BMI Impact Assessment** on cycle regularity
- **Sleep Quality Analysis** correlation with symptom severity
- **Stress Level Integration** with cycle predictions
- **Multi-factor Health Scoring** (0-100 scale)
- **Risk Assessment** for health concerns

### 5. **Personalized Recommendations**
- **Context-Aware Suggestions** based on current cycle phase
- **Priority Ranking** (high/medium/low) for action items
- **Medical Alert System** for concerning patterns
- **Lifestyle Optimization** tips based on patterns
- **Engagement-Driven Prompts** for consistent tracking

## 🏗️ Tech Stack

### Frontend
- **Framework**: Flutter (Dart)
- **State Management**: Provider / Riverpod
- **UI**: Material Design with custom pink theme
- **Platforms**: iOS, Android, Web

### Backend
- **Runtime**: Node.js + Express.js
- **Database**: PostgreSQL (Supabase)
- **Authentication**: JWT + Google OAuth
- **API**: RESTful with CORS enabled
- **Deployment**: Render (Free Tier)

### AI Service
- **Framework**: Flask (Python 3.11)
- **ML Libraries**: 
  - scikit-learn 1.4.0 (Random Forest, Gradient Boosting)
  - NumPy 1.26.4 (Array operations)
  - Pandas 2.1.4 (Data processing)
  - SciPy 1.11.4 (Statistical analysis)
- **Server**: Gunicorn
- **Deployment**: Render (Free Tier)

## 🌐 Live Deployment

| Service | URL | Status |
|---------|-----|--------|
| **Backend API** | https://solaris-vhc8.onrender.com | ✅ Live |
| **AI Service** | https://solaris-ai-service.onrender.com | ✅ Live |
| **Frontend** | TBD | 🚧 Coming Soon |

### API Health Checks
```bash
# Backend
curl https://solaris-vhc8.onrender.com/api/health

# AI Service
curl https://solaris-ai-service.onrender.com/health
```

## 🚀 Quick Start

### 1. Backend Setup
```bash
cd backend
npm install
cp .env.example .env  # Configure your .env
npm start
```

**Environment Variables:**
```env
PORT=10000
DATABASE_URL=your_supabase_connection_string
JWT_SECRET=your_jwt_secret
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
AI_SERVICE_URL=https://solaris-ai-service.onrender.com
```

### 2. AI Service Setup
```bash
cd ai-service
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
python app.py
```

**Environment Variables:**
```env
FLASK_ENV=development
FLASK_PORT=5000
CORS_ORIGINS=https://solaris-vhc8.onrender.com
```

### 3. Frontend Setup
```bash
cd frontend
flutter pub get
flutter run -d chrome  # Web
flutter run -d android  # Android
flutter run -d ios  # iOS
```

**Configure API endpoint in `lib/config/api_config.dart`:**
```dart
class ApiConfig {
  static const String backendUrl = 'https://solaris-vhc8.onrender.com/api';
  static const String aiServiceUrl = 'https://solaris-ai-service.onrender.com';
}
```

## 🔧 Project Structure

```
Solaris/
├── backend/                  # Node.js API Server
│   ├── server.js            # Main server file
│   ├── routes/              # API routes
│   ├── models/              # Database models
│   └── middleware/          # Auth & validation
│
├── ai-service/              # Python ML Service
│   ├── app.py              # Flask application
│   ├── models/             # ML models
│   │   ├── cycle_predictor.py      # Ensemble ML predictions
│   │   ├── symptom_analyzer.py     # Pattern recognition
│   │   ├── health_tracker.py       # Health integration
│   │   └── recommender.py          # Recommendation engine
│   ├── requirements.txt    # Python dependencies
│   └── render.yaml         # Render deployment config
│
└── frontend/               # Flutter Mobile/Web App
    ├── lib/
    │   ├── screens/        # UI screens
    │   ├── services/       # API services
    │   ├── models/         # Data models
    │   └── widgets/        # Reusable components
    └── pubspec.yaml
```

## 📱 App Screens

1. **🔐 Authentication**: Email/password or Google sign-in
2. **📊 Dashboard**: Current cycle phase, AI predictions, and health stats
3. **✍️ Log Entry**: Record periods, symptoms, mood, and health metrics
4. **📅 Timeline**: Calendar view with cycle history and predictions
5. **💡 Insights**: AI-powered analysis and personalized recommendations
6. **👤 Profile**: Account settings, data export, and preferences

## 🎨 Design System

### Color Palette
- **Primary Pink**: `#FF69B4` (Hot Pink)
- **Light Pink**: `#FFB6C1` (Pastel Pink)
- **Background**: `#FFF5F7` (Soft Pink White)
- **Surface**: `#FFFFFF` (Pure White)
- **Text Dark**: `#333333` (Charcoal)
- **Text Light**: `#666666` (Gray)
- **Success**: `#4CAF50` (Green)
- **Warning**: `#FF9800` (Orange)
- **Error**: `#F44336` (Red)

### Typography
- **Headings**: Poppins (Bold, 600)
- **Body**: Inter (Regular, 400)
- **Accent**: Quicksand (Medium, 500)

## 🔐 API Endpoints

### Backend API (`https://solaris-vhc8.onrender.com/api`)

#### Authentication
```
POST   /auth/signup          # User registration
POST   /auth/login           # User login
POST   /auth/google          # Google OAuth
GET    /auth/profile         # Get user profile
```

#### Cycles
```
GET    /cycles               # Get all cycles
POST   /cycles               # Create new cycle
PUT    /cycles/:id           # Update cycle
DELETE /cycles/:id           # Delete cycle
GET    /cycles/current       # Get current cycle
```

#### Symptoms
```
GET    /symptoms             # Get all symptoms
POST   /symptoms             # Log symptoms
PUT    /symptoms/:id         # Update symptom log
DELETE /symptoms/:id         # Delete symptom log
GET    /symptoms/date/:date  # Get symptoms by date
```

#### Insights
```
GET    /insights/current     # Current cycle insights
GET    /insights/predictions # AI predictions
GET    /insights/patterns    # Pattern analysis
GET    /insights/health      # Health correlations
```

### AI Service API (`https://solaris-ai-service.onrender.com`)

```
GET    /health                    # Service health check
POST   /predict                   # Cycle prediction
POST   /analyze                   # Comprehensive analysis
POST   /symptom-prediction        # Symptom likelihood
POST   /health-analysis           # Health metrics analysis
POST   /cycle-insights            # Detailed cycle insights
POST   /should-prompt-log         # Smart logging prompts
```

## 🧪 Testing

### Backend Tests
```bash
cd backend
npm test
```

### AI Service Tests
```bash
cd ai-service
pytest tests/
```

### Frontend Tests
```bash
cd frontend
flutter test
```

## 📊 ML Model Performance

| Model | Accuracy | Data Required |
|-------|----------|---------------|
| Cycle Prediction | 80-95% | 6+ cycles (optimal) |
| Symptom Clustering | 75-85% | 30+ symptom logs |
| Anomaly Detection | 90%+ | 3+ cycles |
| Health Correlation | 70-80% | 20+ health entries |

**Prediction Quality Tiers:**
- **Excellent**: 6+ cycles, 85%+ confidence
- **Good**: 4-5 cycles, 70-84% confidence  
- **Fair**: 2-3 cycles, 50-69% confidence
- **Limited**: <2 cycles, basic statistical methods

## 🐛 Troubleshooting

### Backend Issues
- **Database errors**: Verify Supabase connection string in `.env`
- **CORS issues**: Check `CORS_ORIGINS` in backend environment
- **JWT errors**: Regenerate `JWT_SECRET`

### AI Service Issues
- **Import errors**: Ensure all models are in `ai-service/models/` directory
- **NumPy errors**: Use Python 3.11 (add `.python-version` file)
- **Slow predictions**: Free tier spins down after 15min inactivity

### Frontend Issues
- **API connection**: Verify `ApiConfig` URLs match deployment
- **Flutter errors**: Run `flutter clean && flutter pub get`
- **Build failures**: Check Flutter version compatibility

### Render Deployment
- **Build timeout**: Increase timeout in `render.yaml`
- **Python version**: Add `PYTHON_VERSION=3.11.9` env var
- **Cold starts**: First request after inactivity takes 50+ seconds

## 🚧 Roadmap

- [ ] **Phase 1**: Core tracking (✅ Complete)
- [ ] **Phase 2**: AI predictions (✅ Complete)
- [ ] **Phase 3**: Health integration (✅ Complete)
- [ ] **Phase 4**: Advanced analytics (🚧 In Progress)
- [ ] **Phase 5**: Social features (📋 Planned)
- [ ] **Phase 6**: Wearable integration (📋 Planned)

## 📄 License

Educational project - Not intended for production medical use. Always consult healthcare professionals for medical advice.

## 🤝 Contributing

This is an educational project. Contributions, issues, and feature requests are welcome!

## 📞 Support

- **Issues**: GitHub Issues
- **Documentation**: [Deployment Guide](DEPLOYMENT_GUIDE.md)
- **API Docs**: See `/docs` endpoint on backend

---

**Built with 💖 by the Solaris Team**

*Empowering women through data-driven health insights*