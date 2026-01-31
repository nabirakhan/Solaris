
# 🌸 Solaris - AI-Powered Period Tracker

A modern menstrual cycle tracking app with AI predictions and personalized insights.

## ✨ Features

- **Cycle Tracking**: Log period start/end dates with flow levels
- **Symptom Monitoring**: Track daily symptoms and mood patterns  
- **AI Predictions**: Machine learning-powered cycle forecasts
- **Calendar View**: Visual timeline of cycle history
- **Insights Dashboard**: Personalized health analytics
- **Multi-platform**: Works on mobile (iOS/Android) and web

## 🏗️ Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Node.js + Express.js + PostgreSQL
- **AI Service**: Python + Flask + scikit-learn
- **Database**: Supabase (PostgreSQL)
- **Auth**: JWT + Google OAuth

## 🚀 Quick Start

### 1. Backend Setup
```bash
cd backend
npm install
cp .env.example .env  # Configure your .env file
npm start
```

### 2. AI Service Setup
```bash
cd ai-service
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -r requirements.txt
python app.py
```

### 3. Frontend Setup
```bash
cd frontend
flutter pub get
flutter run -d chrome  # for web
# or
flutter run -d android  # for Android
```

## 🔧 Configuration

### Backend (.env)
```env
PORT=5000
DATABASE_URL=your_supabase_connection_string
JWT_SECRET=your_jwt_secret
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
```

### AI Service (.env)
```env
FLASK_ENV=development
PORT=5001
```

### Frontend
Update `lib/services/api_service.dart` with your backend URL:
```dart
static const String baseUrl = 'http://localhost:5000/api';
```

## 📱 App Screens

1. **Authentication**: Email/password or Google sign-in
2. **Dashboard**: Current cycle phase, predictions, and stats
3. **Log**: Record periods and daily symptoms
4. **Timeline**: Calendar view of cycle history
5. **Profile**: Account settings and AI insights

## 🎨 UI Theme

- **Primary Pink**: `#FF69B4`
- **Light Pink**: `#FFB6C1`
- **Background**: `#FFF5F7`
- **Text Dark**: `#333333`

## 🔐 API Endpoints

- `POST /api/auth/signup` - User registration
- `POST /api/auth/login` - User login
- `GET /api/cycles` - Get cycle history
- `POST /api/cycles` - Log new cycle
- `POST /api/symptoms` - Log daily symptoms
- `GET /api/insights/current` - Get predictions

## 🐛 Troubleshooting

- **Database errors**: Verify Supabase connection string
- **CORS issues**: Check allowed origins in server.js
- **Flutter errors**: Run `flutter clean` and `flutter pub get`
- **AI service down**: Ensure Python dependencies are installed

## 📄 License

Educational project - Not for production use

---
