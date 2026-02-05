// File: backend/routes/cycles.js

const express = require('express');
const router = express.Router();
const Cycle = require('../models/Cycle');
const auth = require('../middleware/auth');

// Add this after imports
router.get('/', (req, res) => {
  res.json({
    service: 'Cycle Tracking API',
    endpoints: {
      list_cycles: { method: 'GET', path: '/api/cycles', description: 'Get all cycles', auth: true },
      create_cycle: { method: 'POST', path: '/api/cycles', description: 'Create new cycle', auth: true },
      get_cycle: { method: 'GET', path: '/api/cycles/:id', description: 'Get specific cycle', auth: true },
      update_cycle: { method: 'PUT', path: '/api/cycles/:id', description: 'Update cycle', auth: true },
      delete_cycle: { method: 'DELETE', path: '/api/cycles/:id', description: 'Delete cycle', auth: true },
      current_cycle: { method: 'GET', path: '/api/cycles/latest/current', description: 'Get current/latest cycle', auth: true },
      average_stats: { method: 'GET', path: '/api/cycles/stats/average', description: 'Get cycle statistics', auth: true }
    }
  });
});

router.post('/', auth, async (req, res) => {
  try {
    const { startDate, flow, notes } = req.body;

    if (!startDate) {
      return res.status(400).json({ error: 'Start date is required' });
    }

    const cycle = await Cycle.create({
      userId: req.userId,
      startDate,
      flow: flow || 'medium',
      notes
    });

    res.status(201).json({
      message: 'Cycle logged successfully',
      cycle
    });
  } catch (error) {
    console.error('Create cycle error:', error);
    res.status(500).json({ error: error.message });
  }
});

router.put('/:id', auth, async (req, res) => {
  try {
    const { endDate, flow, notes } = req.body;

    const updates = {};
    if (endDate !== undefined) updates.end_date = endDate;
    if (flow !== undefined) updates.flow = flow;
    if (notes !== undefined) updates.notes = notes;

    const cycle = await Cycle.update(req.params.id, req.userId, updates);

    if (!cycle) {
      return res.status(404).json({ error: 'Cycle not found' });
    }

    res.json({
      message: 'Cycle updated successfully',
      cycle
    });
  } catch (error) {
    console.error('Update cycle error:', error);
    res.status(500).json({ error: error.message });
  }
});

router.get('/', auth, async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 50;
    const cycles = await Cycle.findByUserId(req.userId, limit);

    res.json({ cycles });
  } catch (error) {
    console.error('Get cycles error:', error);
    res.status(500).json({ error: error.message });
  }
});

router.get('/:id', auth, async (req, res) => {
  try {
    const cycle = await Cycle.findById(req.params.id, req.userId);

    if (!cycle) {
      return res.status(404).json({ error: 'Cycle not found' });
    }

    res.json({ cycle });
  } catch (error) {
    console.error('Get cycle error:', error);
    res.status(500).json({ error: error.message });
  }
});

router.get('/latest/current', auth, async (req, res) => {
  try {
    const cycle = await Cycle.getLatest(req.userId);

    if (!cycle) {
      return res.json({ cycle: null, message: 'No cycles logged yet' });
    }

    res.json({ cycle });
  } catch (error) {
    console.error('Get latest cycle error:', error);
    res.status(500).json({ error: error.message });
  }
});

router.get('/stats/average', auth, async (req, res) => {
  try {
    const stats = await Cycle.getAverageCycleLength(req.userId);
    res.json({ stats });
  } catch (error) {
    console.error('Get cycle stats error:', error);
    res.status(500).json({ error: error.message });
  }
});

router.delete('/:id', auth, async (req, res) => {
  try {
    const cycle = await Cycle.delete(req.params.id, req.userId);

    if (!cycle) {
      return res.status(404).json({ error: 'Cycle not found' });
    }

    res.json({ message: 'Cycle deleted successfully' });
  } catch (error) {
    console.error('Delete cycle error:', error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;