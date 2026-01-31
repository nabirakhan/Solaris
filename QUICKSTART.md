# 🚀 QUICK START GUIDE

## Open 3 Terminals and Run These Commands:

### Terminal 1 - Backend
```bash
cd period-tracker-app/backend
npm install
cp .env.example .env
# Edit .env and change JWT_SECRET
npm start
```

### Terminal 2 - AI Service
```bash
cd period-tracker-app/ai-service
python -m venv venv

# Windows:
venv\Scripts\activate

# Mac/Linux:
source venv/bin/activate

pip install -r requirements.txt
python app.py
```

### Terminal 3 - Frontend
```bash
cd period-tracker-app/frontend
flutter pub get
flutter run -d chrome
```

## ✅ That's It!

The app should now open in your browser.

## 📝 First Steps:
1. Click "Sign Up"
2. Create an account
3. Go to "Log" tab
4. Record your period
5. Add symptoms
6. View insights on "Today" tab

## 💡 Need Help?
Read the full README.md for detailed instructions.