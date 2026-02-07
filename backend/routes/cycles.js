// File: backend/routes/cycles.js
const express = require('express');
const router = express.Router();
const Cycle = require('../models/Cycle');
const auth = require('../middleware/auth');
const { pool } = require('../config/database');

// Create new cycle
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

// Update cycle
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

// Get all cycles
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

// Get single cycle
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

// Get latest cycle
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

// Get cycle stats
router.get('/stats/average', auth, async (req, res) => {
  try {
    const stats = await Cycle.getAverageCycleLength(req.userId);
    res.json({ stats });
  } catch (error) {
    console.error('Get cycle stats error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Delete cycle - FIX: Also delete associated period_days
router.delete('/:id', auth, async (req, res) => {
  try {
    // First, get the cycle to find its date range
    const cycle = await Cycle.findById(req.params.id, req.userId);

    if (!cycle) {
      return res.status(404).json({ error: 'Cycle not found' });
    }

    // Delete all period_days within this cycle's date range
    const startDate = cycle.start_date;
    const endDate = cycle.end_date || new Date().toISOString().split('T')[0];
    
    // If cycle has no end date, delete period days from start date onwards
    // that are close together (within 2 days of each other)
    await pool.query(
      `DELETE FROM period_days 
       WHERE user_id = $1 
       AND date >= $2 
       AND date <= $3`,
      [req.userId, startDate, endDate]
    );

    // Now delete the cycle
    await Cycle.delete(req.params.id, req.userId);

    console.log(`✅ Deleted cycle ${req.params.id} and associated period days`);

    res.json({ message: 'Cycle deleted successfully' });
  } catch (error) {
    console.error('Delete cycle error:', error);
    res.status(500).json({ error: error.message });
  }
});

// ============================================================================
// CYCLE DAY MANAGEMENT (NEW)
// ============================================================================

// Add a day to a cycle
router.post('/:id/days', auth, async (req, res) => {
  try {
    const { date, flow, notes } = req.body;
    const cycleId = req.params.id;

    if (!date) {
      return res.status(400).json({ error: 'Date is required' });
    }

    // Verify the cycle belongs to the user
    const cycle = await Cycle.findById(cycleId, req.userId);
    if (!cycle) {
      return res.status(404).json({ error: 'Cycle not found' });
    }

    const day = await Cycle.addDay({
      cycleId,
      date,
      flow: flow || 'medium',
      notes
    });

    res.status(201).json({
      message: 'Day added successfully',
      day
    });
  } catch (error) {
    console.error('Add cycle day error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Update a specific day in a cycle
router.put('/:id/days/:dayId', auth, async (req, res) => {
  try {
    const { flow, notes } = req.body;
    const { id: cycleId, dayId } = req.params;

    // Verify the cycle belongs to the user
    const cycle = await Cycle.findById(cycleId, req.userId);
    if (!cycle) {
      return res.status(404).json({ error: 'Cycle not found' });
    }

    const updates = {};
    if (flow !== undefined) updates.flow = flow;
    if (notes !== undefined) updates.notes = notes;

    const day = await Cycle.updateDay(dayId, updates);

    if (!day) {
      return res.status(404).json({ error: 'Day not found' });
    }

    res.json({
      message: 'Day updated successfully',
      day
    });
  } catch (error) {
    console.error('Update cycle day error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Delete a specific day from a cycle
router.delete('/:id/days/:dayId', auth, async (req, res) => {
  try {
    const { id: cycleId, dayId } = req.params;

    // Verify the cycle belongs to the user
    const cycle = await Cycle.findById(cycleId, req.userId);
    if (!cycle) {
      return res.status(404).json({ error: 'Cycle not found' });
    }

    const result = await Cycle.deleteDay(dayId);

    if (!result) {
      return res.status(404).json({ error: 'Day not found' });
    }

    res.json({ message: 'Day deleted successfully' });
  } catch (error) {
    console.error('Delete cycle day error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get all days for a specific cycle
router.get('/:id/days', auth, async (req, res) => {
  try {
    const cycleId = req.params.id;

    // Verify the cycle belongs to the user
    const cycle = await Cycle.findById(cycleId, req.userId);
    if (!cycle) {
      return res.status(404).json({ error: 'Cycle not found' });
    }

    const days = await Cycle.getDays(cycleId);

    res.json({ days });
  } catch (error) {
    console.error('Get cycle days error:', error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;