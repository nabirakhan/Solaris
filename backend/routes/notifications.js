// File: backend/routes/notifications.js
const express = require('express');
const router = express.Router();
const { pool } = require('../config/database');
const auth = require('../middleware/auth');

// Get notification settings
router.get('/settings', auth, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT period_reminders, ovulation_reminders, daily_reminders, 
              insights_reminders, anomaly_reminders
       FROM user_notification_settings
       WHERE user_id = $1`,
      [req.userId]
    );

    if (result.rows.length === 0) {
      // Return defaults if no settings exist
      return res.json({
        periodReminders: false,
        ovulationReminders: false,
        dailyReminders: false,
        insightsReminders: false,
        anomalyReminders: false,
      });
    }

    const settings = result.rows[0];
    res.json({
      periodReminders: settings.period_reminders,
      ovulationReminders: settings.ovulation_reminders,
      dailyReminders: settings.daily_reminders,
      insightsReminders: settings.insights_reminders,
      anomalyReminders: settings.anomaly_reminders,
    });
  } catch (error) {
    console.error('Get notification settings error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Update notification settings
router.post('/settings', auth, async (req, res) => {
  try {
    const {
      periodReminders,
      ovulationReminders,
      dailyReminders,
      insightsReminders,
      anomalyReminders,
    } = req.body;

    // Check if settings exist
    const existing = await pool.query(
      'SELECT id FROM user_notification_settings WHERE user_id = $1',
      [req.userId]
    );

    if (existing.rows.length > 0) {
      // Update existing settings
      await pool.query(
        `UPDATE user_notification_settings
         SET period_reminders = $1,
             ovulation_reminders = $2,
             daily_reminders = $3,
             insights_reminders = $4,
             anomaly_reminders = $5,
             updated_at = NOW()
         WHERE user_id = $6`,
        [
          periodReminders,
          ovulationReminders,
          dailyReminders,
          insightsReminders,
          anomalyReminders,
          req.userId,
        ]
      );
    } else {
      // Insert new settings
      await pool.query(
        `INSERT INTO user_notification_settings 
         (user_id, period_reminders, ovulation_reminders, daily_reminders, 
          insights_reminders, anomaly_reminders)
         VALUES ($1, $2, $3, $4, $5, $6)`,
        [
          req.userId,
          periodReminders,
          ovulationReminders,
          dailyReminders,
          insightsReminders,
          anomalyReminders,
        ]
      );
    }

    res.json({
      message: 'Notification settings updated successfully',
      settings: {
        periodReminders,
        ovulationReminders,
        dailyReminders,
        insightsReminders,
        anomalyReminders,
      },
    });
  } catch (error) {
    console.error('Update notification settings error:', error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;