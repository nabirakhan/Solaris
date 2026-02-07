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

// ✅ FIX: Changed to upsert logic - update if exists, insert if not
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
    
    let result;
    
    if (existing.rows.length > 0) {
      // ✅ FIX: Update existing instead of throwing error
      const updateQuery = `
        UPDATE period_days 
        SET flow = $1, notes = $2, updated_at = CURRENT_TIMESTAMP
        WHERE user_id = $3 AND date = $4
        RETURNING id, user_id, date, flow, notes, created_at, updated_at
      `;
      
      result = await pool.query(updateQuery, [
        flow,
        notes || null,
        req.userId,
        date
      ]);
      
      console.log(`✅ Updated existing period day for ${date}`);
    } else {
      // Insert new period day
      const insertQuery = `
        INSERT INTO period_days (user_id, date, flow, notes)
        VALUES ($1, $2, $3, $4)
        RETURNING id, user_id, date, flow, notes, created_at, updated_at
      `;
      
      result = await pool.query(insertQuery, [
        req.userId,
        date,
        flow,
        notes || null
      ]);
      
      console.log(`✅ Inserted new period day for ${date}`);
    }
    
    // Update or create cycle - ONLY for new period days
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
    
    // Update cycles - only if flow changed significantly
    if (flow !== undefined) {
      await updateCyclesFromPeriodDays(req.userId);
    }
    
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

// ✅ FIX: Modified to only recreate cycles when there are orphaned period_days
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
      // If no period days exist, delete all cycles
      await pool.query('DELETE FROM cycles WHERE user_id = $1', [userId]);
      console.log(`✅ No period days found, cleared all cycles for user ${userId}`);
      return;
    }
    
    // Get existing cycles
    const existingCyclesQuery = `
      SELECT id, start_date, end_date
      FROM cycles
      WHERE user_id = $1
      ORDER BY start_date ASC
    `;
    const existingCyclesResult = await pool.query(existingCyclesQuery, [userId]);
    const existingCycles = existingCyclesResult.rows;
    
    // Group consecutive period days into cycle date ranges
    const cycleRanges = [];
    let currentRange = {
      startDate: periodDays[0].date,
      periodDays: [periodDays[0]]
    };
    
    for (let i = 1; i < periodDays.length; i++) {
      const prevDate = new Date(periodDays[i - 1].date);
      const currDate = new Date(periodDays[i].date);
      const daysDiff = Math.floor((currDate - prevDate) / (1000 * 60 * 60 * 24));
      
      // If days are consecutive or within 1-2 days, they're part of same period
      if (daysDiff <= 2) {
        currentRange.periodDays.push(periodDays[i]);
      } else {
        // End current range and start new one
        currentRange.endDate = periodDays[i - 1].date;
        currentRange.periodLength = currentRange.periodDays.length;
        cycleRanges.push(currentRange);
        
        currentRange = {
          startDate: periodDays[i].date,
          periodDays: [periodDays[i]]
        };
      }
    }
    
    // Add the last range (ongoing if no end date)
    if (currentRange.periodDays.length > 0) {
      // Check if it's recent (within last 10 days) - if so, leave open
      const lastDate = new Date(currentRange.periodDays[currentRange.periodDays.length - 1].date);
      const today = new Date();
      const daysSinceLastPeriod = Math.floor((today - lastDate) / (1000 * 60 * 60 * 24));
      
      if (daysSinceLastPeriod > 10) {
        currentRange.endDate = lastDate;
        currentRange.periodLength = currentRange.periodDays.length;
      }
      
      cycleRanges.push(currentRange);
    }
    
    // ✅ FIX: Only delete cycles that don't have matching period days
    // Compare existing cycles with period day ranges
    const cyclesToDelete = [];
    const cyclesToKeep = new Set();
    
    for (const existingCycle of existingCycles) {
      let hasMatchingPeriodDays = false;
      
      for (const range of cycleRanges) {
        if (existingCycle.start_date === range.startDate) {
          hasMatchingPeriodDays = true;
          cyclesToKeep.add(existingCycle.id);
          break;
        }
      }
      
      if (!hasMatchingPeriodDays) {
        cyclesToDelete.push(existingCycle.id);
      }
    }
    
    // Delete cycles that don't have matching period days
    if (cyclesToDelete.length > 0) {
      await pool.query(
        'DELETE FROM cycles WHERE id = ANY($1::uuid[])',
        [cyclesToDelete]
      );
      console.log(`✅ Deleted ${cyclesToDelete.length} orphaned cycles`);
    }
    
    // Insert or update cycles
    for (let i = 0; i < cycleRanges.length; i++) {
      const range = cycleRanges[i];
      const nextRange = cycleRanges[i + 1];
      
      let cycleLength = null;
      if (nextRange) {
        const start = new Date(range.startDate);
        const nextStart = new Date(nextRange.startDate);
        cycleLength = Math.floor((nextStart - start) / (1000 * 60 * 60 * 24));
      }
      
      // Check if cycle already exists
      const existingCycle = existingCycles.find(c => c.start_date === range.startDate);
      
      if (existingCycle) {
        // Update existing cycle
        const updateQuery = `
          UPDATE cycles 
          SET end_date = $1, 
              cycle_length = $2, 
              period_length = $3,
              updated_at = CURRENT_TIMESTAMP
          WHERE id = $4
        `;
        
        await pool.query(updateQuery, [
          range.endDate || null,
          cycleLength,
          range.periodLength || null,
          existingCycle.id
        ]);
      } else {
        // Insert new cycle
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
          range.startDate,
          range.endDate || null,
          cycleLength,
          range.periodLength || null
        ]);
      }
    }
    
    console.log(`✅ Updated cycles for user ${userId}: ${cycleRanges.length} cycles managed`);
  } catch (error) {
    console.error('Error updating cycles from period days:', error);
    // Don't throw - this is a background operation
  }
}

module.exports = router;