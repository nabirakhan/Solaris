const express = require('express');
const cors = require('cors');
const passport = require('passport');
require('dotenv').config();

const { pool } = require('./config/database');

const app = express();


// ============================================================================
// MIDDLEWARE
// ============================================================================

// CORS configuration
app.use(cors({
  origin: (origin, callback) => {
    // Allow requests with no origin
    if (!origin) return callback(null, true);

    // Define allowed origins
    const allowedOrigins = [
      'http://localhost:3000',
      'http://127.0.0.1:3000',
      'http://192.168.100.9:3000',
      process.env.FRONTEND_URL
    ].filter(Boolean);

    // Allow Flutter web (localhost) during development
    const isLocalhost = origin.startsWith('http://localhost:') ||
      origin.startsWith('http://127.0.0.1:');

    if (allowedOrigins.includes(origin) || isLocalhost) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Body parsers
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

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
// ROUTES
// ============================================================================

app.use('/api/auth', require('./routes/auth'));
app.use('/api/cycles', require('./routes/cycles'));
app.use('/api/symptoms', require('./routes/symptoms'));
app.use('/api/insights', require('./routes/insights'));
app.use('/api/health', require('./routes/healthRoutes'));
app.use('/api/notifications', require('./routes/notifications'));

// ============================================================================
// HEALTH & TEST ENDPOINTS
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

app.get('/api/test', (req, res) => {
  res.json({ message: 'API is working!' });
});

// ============================================================================
// ERROR HANDLING
// ============================================================================

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Not found',
    message: `Cannot ${req.method} ${req.path}`
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

  const PORT = process.env.PORT || 5000;
  const server = app.listen(PORT, '0.0.0.0', () => {
    console.log('\n🌟 ========================================');
    console.log('🌟 SOLARIS - Period Tracker API');
    console.log('🌟 ========================================');
    console.log(`🚀 Server running on port ${PORT}`);
    console.log(`🔗 http://localhost:${PORT}`);
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