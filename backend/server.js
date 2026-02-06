const express = require('express');
const cors = require('cors');
const passport = require('passport');
const path = require('path');
require('dotenv').config();

const { pool } = require('./config/database');

const app = express();

// ============================================================================
// MIDDLEWARE
// ============================================================================

// ✅ Simplified CORS for mobile app
app.use(cors({
  origin: '*', // Allow all origins (safe for mobile apps)
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Body parsers
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ✅ NEW: Serve static files from uploads directory
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Passport
app.use(passport.initialize());

// ============================================================================
// DATABASE CONNECTION
// ============================================================================

const testDatabaseConnection = async () => {
  try {
    const result = await pool.query('SELECT NOW()');
    console.log('✅ Database connected successfully');
    console.log(`⏰ Server time: ${result.rows[0].now}`);
  } catch (error) {
    console.error('❌ Database connection failed:', error.message);
    console.error('💡 Check your DATABASE_URL in .env file');
    process.exit(1);
  }
};

// ============================================================================
// TEST ROUTE (ADD THIS FIRST!)
// ============================================================================

app.get('/test-simple', (req, res) => {
  res.json({ 
    message: 'Simple test route works!',
    timestamp: new Date().toISOString(),
    port: process.env.PORT
  });
});

// ============================================================================
// BASIC ENDPOINTS (MUST COME BEFORE API ROUTES)
// ============================================================================

app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    message: 'Solaris API is running',
    timestamp: new Date().toISOString(),
    features: [
      'User Authentication',
      'Cycle Tracking',
      'Symptom Logging',
      'AI Insights',
      'Health Metrics',
      'Notifications',
    ]
  });
});

app.get('/', (req, res) => {
  res.json({
    message: '🌟 SOLARIS - Period Tracker API',
    description: 'Backend API for menstrual cycle tracking and health insights',
    status: 'operational',
    version: '1.0.0',
    environment: process.env.NODE_ENV || 'production',
    server_time: new Date().toISOString(),
    internal_port: process.env.PORT || 5000,
    external_url: 'https://solaris-vhc8.onrender.com',
    api_base: '/api/*',
    available_endpoints: {
      auth: '/api/auth',
      cycles: '/api/cycles',
      symptoms: '/api/symptoms',
      insights: '/api/insights',
      health_api: '/api/health',
      notifications: '/api/notifications'
    },
    note: 'Backend API for mobile applications. Connect your Flutter/React Native app to https://solaris-vhc8.onrender.com'
  });
});

app.get('/api/test', (req, res) => {
  res.json({ message: 'API is working!' });
});

// ============================================================================
// API ROUTES (COMES AFTER BASIC ENDPOINTS)
// ============================================================================

app.use('/api/auth', require('./routes/auth'));
app.use('/api/cycles', require('./routes/cycles'));
app.use('/api/symptoms', require('./routes/symptoms'));
app.use('/api/insights', require('./routes/insights'));
app.use('/api/health', require('./routes/healthRoutes'));
app.use('/api/notifications', require('./routes/notifications'));

// ============================================================================
// ERROR HANDLING (MUST COME LAST)
// ============================================================================

// 404 handler - for undefined routes
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Endpoint not found',
    requested: `${req.method} ${req.originalUrl}`,
    suggestion: 'Visit / for available endpoints',
    available_endpoints: [
      'GET /',
      'GET /health',
      'GET /api/test',
      'POST /api/auth/signup',
      'POST /api/auth/login',
      'GET /api/auth/me',
      'POST /api/auth/profile/picture',
      'GET /api/cycles',
      'POST /api/cycles',
      'GET /api/symptoms',
      'POST /api/symptoms',
      'GET /api/insights/current',
      'GET /api/health/metrics',
      'POST /api/health/metrics',
      'GET /api/notifications/settings',
      'POST /api/notifications/settings'
    ]
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error('❌ Error:', err.stack);

  const isDevelopment = process.env.NODE_ENV === 'development';

  res.status(err.status || 500).json({
    error: err.message || 'Internal server error',
    ...(isDevelopment && { stack: err.stack })
  });
});

// ============================================================================
// SERVER STARTUP
// ============================================================================

const startServer = async () => {
  await testDatabaseConnection();

  // ✅ CRITICAL: Use the port Render provides
  const PORT = process.env.PORT || 5000;
  
  const server = app.listen(PORT, '0.0.0.0', () => {
    console.log('\n🌟 ========================================');
    console.log('🌟 SOLARIS - Period Tracker API');
    console.log('🌟 ========================================');
    console.log(`🚀 Server running on port ${PORT}`);
    console.log(`🔗 http://localhost:${PORT}`);
    console.log(`🔗 External: https://solaris-vhc8.onrender.com`);
    console.log(`📝 Environment: ${process.env.NODE_ENV || 'development'}`);
    console.log('🤖 AI Service:', process.env.AI_SERVICE_URL || 'Not configured');
    console.log('🌟 ========================================\n');
  });

  return server;
};

// ============================================================================
// PROCESS HANDLERS
// ============================================================================

process.on('unhandledRejection', (error) => {
  console.error('❌ Unhandled Promise Rejection:', error);
});

process.on('SIGTERM', async () => {
  console.log('👋 SIGTERM received. Shutting down gracefully...');

  try {
    await pool.end();
    console.log('✅ Database connections closed');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error during shutdown:', error);
    process.exit(1);
  }
});

// ============================================================================
// START THE SERVER
// ============================================================================

if (require.main === module) {
  startServer().catch((error) => {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  });
}

module.exports = { app, startServer };