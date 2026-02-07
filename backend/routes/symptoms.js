// File: backend/routes/symptoms.js
const express = require('express');
const router = express.Router();
const SymptomLog = require('../models/SymptomLog');
const auth = require('../middleware/auth');

router.post('/', auth, async (req, res) => {
  try {
    const { date, symptoms, sleepHours, stressLevel, notes } = req.body;

    if (!date) {
      return res.status(400).json({ error: 'Date is required' });
    }

    // Default symptoms if not provided
    const defaultSymptoms = {
      cramps: 0,
      mood: 3,
      energy: 3,
      headache: 0,
      bloating: 0
    };

    const log = await SymptomLog.upsert({
      userId: req.userId,
      date,
      symptoms: symptoms || defaultSymptoms,
      sleepHours,
      stressLevel,
      notes
    });

    res.status(201).json({
      message: 'Symptom log saved successfully',
      log
    });
  } catch (error) {
    console.error('Create symptom log error:', error);
    res.status(500).json({ error: error.message });
  }
});

router.get('/', auth, async (req, res) => {
  try {
    const { startDate, endDate, limit } = req.query;

    let logs;
    if (startDate && endDate) {
      logs = await SymptomLog.getByDateRange(req.userId, startDate, endDate);
    } else {
      const logLimit = parseInt(limit) || 90;
      logs = await SymptomLog.findByUserId(req.userId, logLimit);
    }

    res.json({ logs });
  } catch (error) {
    console.error('Get symptom logs error:', error);
    res.status(500).json({ error: error.message });
  }
});

router.get('/date/:date', auth, async (req, res) => {
  try {
    const log = await SymptomLog.findByDate(req.userId, req.params.date);
    res.json({ log });
  } catch (error) {
    console.error('Get symptom log by date error:', error);
    res.status(500).json({ error: error.message });
  }
});

router.get('/latest/current', auth, async (req, res) => {
  try {
    const log = await SymptomLog.getLatest(req.userId);
    res.json({ log });
  } catch (error) {
    console.error('Get latest symptom log error:', error);
    res.status(500).json({ error: error.message });
  }
});

router.get('/stats/summary', auth, async (req, res) => {
  try {
    const days = parseInt(req.query.days) || 30;
    const stats = await SymptomLog.getStats(req.userId, days);
    res.json({ stats });
  } catch (error) {
    console.error('Get symptom stats error:', error);
    res.status(500).json({ error: error.message });
  }
});

// ✅ FIX: Added PUT endpoint for updating symptoms
router.put('/:id', auth, async (req, res) => {
  try {
    const { symptoms, sleepHours, stressLevel, notes } = req.body;
    const { id } = req.params;

    // Build update object with only provided fields
    const updates = {};
    if (symptoms !== undefined) updates.symptoms = symptoms;
    if (sleepHours !== undefined) updates.sleepHours = sleepHours;
    if (stressLevel !== undefined) updates.stressLevel = stressLevel;
    if (notes !== undefined) updates.notes = notes;

    const log = await SymptomLog.update(id, req.userId, updates);

    if (!log) {
      return res.status(404).json({ error: 'Log not found' });
    }

    res.json({
      message: 'Symptom log updated successfully',
      log
    });
  } catch (error) {
    console.error('Update symptom log error:', error);
    res.status(500).json({ error: error.message });
  }
});

router.delete('/:id', auth, async (req, res) => {
  try {
    const log = await SymptomLog.delete(req.params.id, req.userId);

    if (!log) {
      return res.status(404).json({ error: 'Log not found' });
    }

    res.json({ message: 'Log deleted successfully' });
  } catch (error) {
    console.error('Delete symptom log error:', error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;