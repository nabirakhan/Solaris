# Period Tracker - AI-Powered Cycle Tracking App

A complete, production-ready period tracking application with AI-powered predictions, built with Flutter, Node.js, and Python.

## 🎨 Features

- **Beautiful Pink UI**: Clean, user-friendly interface with pink and pastel pink color palette
- **Period Logging**: Track period start/end dates and flow
- **Symptom Tracking**: Log daily symptoms (cramps, mood, energy, headache, bloating)
- **AI Predictions**: Machine learning-powered cycle predictions
- **Adaptive UI**: Smart interface that adjusts based on data confidence
- **Timeline View**: Calendar visualization of cycle history
- **Insights Dashboard**: Personalized cycle insights and patterns

## 📁 Project Structure

```
period-tracker-app/
├── backend/          # Node.js + Express API
├── ai-service/       # Python Flask AI service
└── frontend/         # Flutter mobile/web app
```

## 🚀 Complete Setup Guide

### Prerequisites

Before starting, install:

1. **Node.js** (v16 or higher) - [Download](https://nodejs.org/)
2. **Python** (3.8 or higher) - [Download](https://www.python.org/)
3. **MongoDB** - [Download](https://www.mongodb.com/try/download/community)
4. **Flutter** (3.0 or higher) - [Install Guide](https://docs.flutter.dev/get-started/install)
5. **Git** (optional) - [Download](https://git-scm.com/)

---

## STEP 1: Setup Backend (Node.js)

### 1.1 Navigate to backend directory
```bash
cd period-tracker-app/backend
```

### 1.2 Install dependencies
```bash
npm install
```

### 1.3 Create environment file
```bash
cp .env.example .env
```

### 1.4 Edit .env file
Open `.env` and configure:
```env
PORT=5000
MONGODB_URI=mongodb://localhost:27017/period-tracker
JWT_SECRET=your-super-secret-jwt-key-CHANGE-THIS
AI_SERVICE_URL=http://localhost:5001
```

**Important**: Change `JWT_SECRET` to a random string for security!

### 1.5 Start MongoDB
In a new terminal:
```bash
# Windows
"C:\Program Files\MongoDB\Server\7.0\bin\mongod.exe"

# Mac
brew services start mongodb-community

# Linux
sudo systemctl start mongod
```

### 1.6 Start the backend server
```bash
npm start
```

You should see:
```
✅ MongoDB connected successfully
🚀 Server running on port 5000
```

**Keep this terminal open!**

---

## STEP 2: Setup AI Service (Python)

### 2.1 Open a NEW terminal and navigate to ai-service
```bash
cd period-tracker-app/ai-service
```

### 2.2 Create Python virtual environment
```bash
# Windows
python -m venv venv
venv\Scripts\activate

# Mac/Linux
python3 -m venv venv
source venv/bin/activate
```

### 2.3 Install Python dependencies
```bash
pip install -r requirements.txt
```

This might take a few minutes as it installs TensorFlow and other libraries.

### 2.4 Create environment file
```bash
cp .env.example .env
```

### 2.5 Start the AI service
```bash
python app.py
```

You should see:
```
 * Running on http://0.0.0.0:5001
```

**Keep this terminal open!**

---

## STEP 3: Setup Frontend (Flutter)

### 3.1 Open a NEW terminal and navigate to frontend
```bash
cd period-tracker-app/frontend
```

### 3.2 Get Flutter dependencies
```bash
flutter pub get
```

### 3.3 Update API URL (if needed)

Open `lib/services/api_service.dart` and verify the baseUrl:
```dart
static const String baseUrl = 'http://localhost:5000/api';
```

**For mobile devices on same network, use your computer's IP address:**
```dart
static const String baseUrl = 'http://192.168.1.XXX:5000/api';
```

### 3.4 Run the app

**For Web:**
```bash
flutter run -d chrome
```

**For Android Emulator:**
```bash
flutter run -d android
```

**For iOS Simulator:**
```bash
flutter run -d ios
```

---

## ✅ Verification Steps

### Test Backend (http://localhost:5000)
```bash
curl http://localhost:5000/health
```
Should return: `{"status":"ok","message":"Period Tracker API is running"}`

### Test AI Service (http://localhost:5001)
```bash
curl http://localhost:5001/health
```
Should return: `{"status":"ok","message":"AI Service is running"}`

---

## 📱 Using the App

### First Time Setup:

1. **Launch the app** - You'll see the splash screen
2. **Sign Up** - Click "Sign Up" and create an account
3. **Log Your First Period** - Click the "Log" tab and record your period start
4. **Add Symptoms** - Switch to "Symptoms" tab and log how you're feeling
5. **View Insights** - Go to "Today" tab to see your cycle phase and predictions

### Daily Use:

1. **Today Tab** - View current cycle phase and predictions
2. **Log Tab** - Record period starts/ends and daily symptoms
3. **Timeline Tab** - See calendar view of your cycle history
4. **Profile Tab** - View stats and request AI analysis

---

## 🎨 Color Palette

The app uses a beautiful pink theme:

- **Primary Pink**: #FF69B4 (Hot Pink)
- **Light Pink**: #FFB6C1
- **Pale Pink**: #FFC0CB
- **Blush Pink**: #FFE4E1
- **White**: #FFFFFF

---

## 🔧 Troubleshooting

### Backend won't start
- Make sure MongoDB is running
- Check if port 5000 is available
- Verify `.env` file exists

### AI Service errors
- Make sure virtual environment is activated
- Reinstall dependencies: `pip install -r requirements.txt --upgrade`
- Check if port 5001 is available

### Flutter build errors
- Run `flutter clean` then `flutter pub get`
- Make sure Flutter SDK is properly installed
- Check `flutter doctor` for issues

### Can't connect from mobile device
- Make sure your phone and computer are on the same network
- Update API URL to use computer's IP address instead of localhost
- Disable firewall or allow ports 5000 and 5001

### MongoDB connection errors
- Verify MongoDB is running
- Check connection string in backend `.env`
- Try: `mongodb://127.0.0.1:27017/period-tracker`

---

## 📊 Project Architecture

### Backend (Node.js)
- **Express.js** - Web framework
- **MongoDB** - Database
- **JWT** - Authentication
- **bcrypt** - Password hashing

### AI Service (Python)
- **Flask** - Web framework
- **NumPy** - Numerical computing
- **Scikit-learn** - Machine learning
- **TensorFlow** - Deep learning (future use)

### Frontend (Flutter)
- **Provider** - State management
- **HTTP** - API communication
- **Material Design** - UI components
- **Custom pink theme** - Beautiful styling

---

## 🚀 Deployment

### Backend Deployment (Heroku/Railway)
1. Push code to GitHub
2. Connect to deployment service
3. Add MongoDB Atlas connection string
4. Set environment variables

### AI Service Deployment (Python Anywhere/Heroku)
1. Push code to GitHub
2. Deploy Python app
3. Update backend `AI_SERVICE_URL`

### Frontend Deployment
**Web:** Deploy to Vercel/Netlify
**Mobile:** Build APK/IPA and distribute

---

## 📝 API Endpoints

### Auth
- `POST /api/auth/signup` - Create account
- `POST /api/auth/login` - Login
- `GET /api/auth/me` - Get current user

### Cycles
- `POST /api/cycles` - Log period start
- `PUT /api/cycles/:id` - Update cycle
- `GET /api/cycles` - Get all cycles

### Symptoms
- `POST /api/symptoms` - Log symptoms
- `GET /api/symptoms` - Get symptom logs

### Insights
- `GET /api/insights/current` - Get current cycle state
- `POST /api/insights/analyze` - Request AI analysis

---

## 🔐 Security Notes

- Always change `JWT_SECRET` in production
- Use HTTPS in production
- Never commit `.env` files
- Use MongoDB Atlas for production database
- Enable rate limiting for API endpoints

---

## 📄 License

This project is created for educational purposes.

---

## 🤝 Support

If you encounter issues:
1. Check the troubleshooting section
2. Verify all services are running
3. Check terminal logs for errors
4. Make sure all prerequisites are installed

---

## 🎉 You're Ready!

Your AI-powered period tracking app is now running! Start logging cycles and let the AI learn your patterns.

**Happy tracking! 💗**