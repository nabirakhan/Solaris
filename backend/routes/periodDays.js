// File: backend/routes/periodDays.js
const express = require('express');
const router = express.Router();
const { pool } = require('../config/database');
const auth = require('../middleware/auth');

// Get all period days for a user
router.get('/', auth, async (req, res) => {
  try {
    const query = `
      SELECT 
        id, 
        user_id, 
        date, 
        flow, 
        notes,
        created_at,
        updated_at
      FROM period_days 
      WHERE user_id = $1
      ORDER BY date DESC
    `;
    
    const result = await pool.query(query, [req.userId]);
    
    res.json({
      periodDays: result.rows,
      count: result.rows.length
    });
  } catch (error) {
    console.error('Error getting period days:', error);
    res.status(500).json({ error: error.message });
  }
});

// Log a single period day
router.post('/', auth, async (req, res) => {
  try {
    const { date, flow, notes } = req.body;
    
    if (!date || !flow) {
      return res.status(400).json({ 
        error: 'Date and flow are required' 
      });
    }
    
    // Check if period day already exists for this date
    const checkQuery = `
      SELECT id FROM period_days 
      WHERE user_id = $1 AND date = $2
    `;
    const existing = await pool.query(checkQuery, [req.userId, date]);
    
    if (existing.rows.length > 0) {
      return res.status(400).json({ 
        error: 'Period day already logged for this date. Use update instead.' 
      });
    }
    
    // Insert new period day
    const insertQuery = `
      INSERT INTO period_days (user_id, date, flow, notes)
      VALUES ($1, $2, $3, $4)
      RETURNING id, user_id, date, flow, notes, created_at, updated_at
    `;
    
    const result = await pool.query(insertQuery, [
      req.userId,
      date,
      flow,
      notes || null
    ]);
    
    // Update or create cycle
    await updateCyclesFromPeriodDays(req.userId);
    
    res.status(201).json({
      message: 'Period day logged successfully',
      periodDay: result.rows[0]
    });
  } catch (error) {
    console.error('Error logging period day:', error);
    res.status(500).json({ error: error.message });
  }
});

// Update a period day
router.put('/:id', auth, async (req, res) => {
  try {
    const { id } = req.params;
    const { flow, notes } = req.body;
    
    // Check if period day exists and belongs to user
    const checkQuery = `
      SELECT id FROM period_days 
      WHERE id = $1 AND user_id = $2
    `;
    const existing = await pool.query(checkQuery, [id, req.userId]);
    
    if (existing.rows.length === 0) {
      return res.status(404).json({ 
        error: 'Period day not found' 
      });
    }
    
    // Build update query dynamically
    const updates = [];
    const values = [];
    let paramCount = 1;
    
    if (flow !== undefined) {
      updates.push(`flow = $${paramCount}`);
      values.push(flow);
      paramCount++;
    }
    
    if (notes !== undefined) {
      updates.push(`notes = $${paramCount}`);
      values.push(notes);
      paramCount++;
    }
    
    if (updates.length === 0) {
      return res.status(400).json({ 
        error: 'No fields to update' 
      });
    }
    
    values.push(id);
    values.push(req.userId);
    
    const updateQuery = `
      UPDATE period_days 
      SET ${updates.join(', ')}, updated_at = CURRENT_TIMESTAMP
      WHERE id = $${paramCount} AND user_id = $${paramCount + 1}
      RETURNING id, user_id, date, flow, notes, created_at, updated_at
    `;
    
    const result = await pool.query(updateQuery, values);
    
    // Update cycles
    await updateCyclesFromPeriodDays(req.userId);
    
    res.json({
      message: 'Period day updated successfully',
      periodDay: result.rows[0]
    });
  } catch (error) {
    console.error('Error updating period day:', error);
    res.status(500).json({ error: error.message });
  }
});

// Delete a period day
router.delete('/:id', auth, async (req, res) => {
  try {
    const { id } = req.params;
    
    // Check if period day exists and belongs to user
    const checkQuery = `
      SELECT id FROM period_days 
      WHERE id = $1 AND user_id = $2
    `;
    const existing = await pool.query(checkQuery, [id, req.userId]);
    
    if (existing.rows.length === 0) {
      return res.status(404).json({ 
        error: 'Period day not found' 
      });
    }
    
    // Delete the period day
    const deleteQuery = `
      DELETE FROM period_days 
      WHERE id = $1 AND user_id = $2
    `;
    
    await pool.query(deleteQuery, [id, req.userId]);
    
    // Update cycles after deletion
    await updateCyclesFromPeriodDays(req.userId);
    
    res.json({
      message: 'Period day deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting period day:', error);
    res.status(500).json({ error: error.message });
  }
});

// Helper function to automatically create/update cycles from period days
async function updateCyclesFromPeriodDays(userId) {
  try {
    // Get all period days for user, ordered by date
    const periodDaysQuery = `
      SELECT date, flow, notes
      FROM period_days
      WHERE user_id = $1
      ORDER BY date ASC
    `;
    const periodDaysResult = await pool.query(periodDaysQuery, [userId]);
    const periodDays = periodDaysResult.rows;
    
    if (periodDays.length === 0) {
      return;
    }
    
    // Group consecutive period days into cycles
    const cycles = [];
    let currentCycle = {
      startDate: periodDays[0].date,
      periodDays: [periodDays[0]]
    };
    
    for (let i = 1; i < periodDays.length; i++) {
      const prevDate = new Date(periodDays[i - 1].date);
      const currDate = new Date(periodDays[i].date);
      const daysDiff = Math.floor((currDate - prevDate) / (1000 * 60 * 60 * 24));
      
      // If days are consecutive or within 1-2 days, they're part of same period
      if (daysDiff <= 2) {
        currentCycle.periodDays.push(periodDays[i]);
      } else {
        // End current cycle and start new one
        currentCycle.endDate = periodDays[i - 1].date;
        currentCycle.periodLength = currentCycle.periodDays.length;
        cycles.push(currentCycle);
        
        currentCycle = {
          startDate: periodDays[i].date,
          periodDays: [periodDays[i]]
        };
      }
    }
    
    // Add the last cycle (ongoing if no end date)
    if (currentCycle.periodDays.length > 0) {
      // Check if it's recent (within last 10 days) - if so, leave open
      const lastDate = new Date(currentCycle.periodDays[currentCycle.periodDays.length - 1].date);
      const today = new Date();
      const daysSinceLastPeriod = Math.floor((today - lastDate) / (1000 * 60 * 60 * 24));
      
      if (daysSinceLastPeriod > 10) {
        currentCycle.endDate = lastDate;
        currentCycle.periodLength = currentCycle.periodDays.length;
      }
      
      cycles.push(currentCycle);
    }
    
    // Delete existing auto-generated cycles
    await pool.query('DELETE FROM cycles WHERE user_id = $1', [userId]);
    
    // Insert new cycles with calculated cycle lengths
    for (let i = 0; i < cycles.length; i++) {
      const cycle = cycles[i];
      const nextCycle = cycles[i + 1];
      
      let cycleLength = null;
      if (nextCycle) {
        const start = new Date(cycle.startDate);
        const nextStart = new Date(nextCycle.startDate);
        cycleLength = Math.floor((nextStart - start) / (1000 * 60 * 60 * 24));
      }
      
      const insertQuery = `
        INSERT INTO cycles (
          user_id, 
          start_date, 
          end_date, 
          cycle_length, 
          period_length
        )
        VALUES ($1, $2, $3, $4, $5)
      `;
      
      await pool.query(insertQuery, [
        userId,
        cycle.startDate,
        cycle.endDate || null,
        cycleLength,
        cycle.periodLength || null
      ]);
    }
    
    console.log(`✅ Updated cycles for user ${userId}: ${cycles.length} cycles created`);
  } catch (error) {
    console.error('Error updating cycles from period days:', error);
    // Don't throw - this is a background operation
  }
}

module.exports = router;