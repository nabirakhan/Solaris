// File: backend/routes/healthRoutes.js
// Add this after imports, before other routes
router.get('/', (req, res) => {
  res.json({
    service: 'Health Metrics API',
    endpoints: {
      get_metrics: { method: 'GET', path: '/api/health/metrics', description: 'Get health metrics', auth: true },
      save_metrics: { method: 'POST', path: '/api/health/metrics', description: 'Save/update health metrics', auth: true },
      delete_metrics: { method: 'DELETE', path: '/api/health/metrics', description: 'Delete health metrics', auth: true }
    }
  });
});

const express = require('express');
const router = express.Router();
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

// Middleware to verify authentication (you should already have this)
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Access denied' });
  }

  const jwt = require('jsonwebtoken');
  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid token' });
    }
    req.user = user;
    next();
  });
};

// GET /api/health/metrics - Get user's health metrics
router.get('/metrics', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;

    const result = await pool.query(
      `SELECT id, user_id, birthdate, height, weight, use_metric, 
              created_at, updated_at
       FROM health_metrics
       WHERE user_id = $1
       ORDER BY created_at DESC
       LIMIT 1`,
      [userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'No health metrics found' });
    }

    const metrics = result.rows[0];
    
    // Calculate age
    const birthdate = new Date(metrics.birthdate);
    const today = new Date();
    let age = today.getFullYear() - birthdate.getFullYear();
    const monthDiff = today.getMonth() - birthdate.getMonth();
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthdate.getDate())) {
      age--;
    }

    res.json({
      id: metrics.id,
      birthdate: metrics.birthdate,
      height: parseFloat(metrics.height),
      weight: parseFloat(metrics.weight),
      useMetric: metrics.use_metric,
      age: age,
      createdAt: metrics.created_at,
      updatedAt: metrics.updated_at,
    });
  } catch (error) {
    console.error('Error getting health metrics:', error);
    res.status(500).json({ error: 'Failed to get health metrics' });
  }
});

// POST /api/health/metrics - Save/update user's health metrics
router.post('/metrics', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { birthdate, height, weight, useMetric } = req.body;

    console.log('Saving health metrics for user:', userId);
    console.log('Data:', { birthdate, height, weight, useMetric });

    // Validate input
    if (!birthdate || !height || !weight) {
      return res.status(400).json({ 
        error: 'Missing required fields',
        required: ['birthdate', 'height', 'weight']
      });
    }

    // Check if user already has health metrics
    const existingMetrics = await pool.query(
      'SELECT id FROM health_metrics WHERE user_id = $1',
      [userId]
    );

    let result;
    
    if (existingMetrics.rows.length > 0) {
      // Update existing metrics
      result = await pool.query(
        `UPDATE health_metrics 
         SET birthdate = $1, height = $2, weight = $3, use_metric = $4, updated_at = NOW()
         WHERE user_id = $5
         RETURNING id, user_id, birthdate, height, weight, use_metric, created_at, updated_at`,
        [birthdate, height, weight, useMetric !== false, userId]
      );
    } else {
      // Insert new metrics
      result = await pool.query(
        `INSERT INTO health_metrics (user_id, birthdate, height, weight, use_metric)
         VALUES ($1, $2, $3, $4, $5)
         RETURNING id, user_id, birthdate, height, weight, use_metric, created_at, updated_at`,
        [userId, birthdate, height, weight, useMetric !== false]
      );
    }

    const metrics = result.rows[0];
    
    // Calculate age
    const birthdateObj = new Date(metrics.birthdate);
    const today = new Date();
    let age = today.getFullYear() - birthdateObj.getFullYear();
    const monthDiff = today.getMonth() - birthdateObj.getMonth();
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthdateObj.getDate())) {
      age--;
    }

    console.log('Health metrics saved successfully');

    res.status(201).json({
      message: 'Health metrics saved successfully',
      metrics: {
        id: metrics.id,
        birthdate: metrics.birthdate,
        height: parseFloat(metrics.height),
        weight: parseFloat(metrics.weight),
        useMetric: metrics.use_metric,
        age: age,
        createdAt: metrics.created_at,
        updatedAt: metrics.updated_at,
      }
    });
  } catch (error) {
    console.error('Error saving health metrics:', error);
    res.status(500).json({ error: 'Failed to save health metrics', details: error.message });
  }
});

// DELETE /api/health/metrics - Delete user's health metrics
router.delete('/metrics', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;

    await pool.query(
      'DELETE FROM health_metrics WHERE user_id = $1',
      [userId]
    );

    res.json({ message: 'Health metrics deleted successfully' });
  } catch (error) {
    console.error('Error deleting health metrics:', error);
    res.status(500).json({ error: 'Failed to delete health metrics' });
  }
});

module.exports = router;