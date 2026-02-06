// File: backend/models/SymptomLog.js
const { query } = require('../config/database');

class SymptomLog {
  static async upsert({ userId, date, symptoms, sleepHours, stressLevel, notes }) {
    try {
      // First, try to find existing log for this date
      const findSql = `
        SELECT id FROM symptom_logs
        WHERE user_id = $1 AND date = $2
      `;
      
      const existing = await query(findSql, [userId, date]);
      
      if (existing.rows.length > 0) {
        // Update existing
        const updateSql = `
          UPDATE symptom_logs
          SET symptoms = $1,
              sleep_hours = $2,
              stress_level = $3,
              notes = $4,
              updated_at = CURRENT_TIMESTAMP
          WHERE user_id = $5 AND date = $6
          RETURNING id, user_id, date, symptoms, sleep_hours, stress_level, 
                    notes, created_at, updated_at
        `;
        
        const values = [
          JSON.stringify(symptoms),
          sleepHours || null,
          stressLevel || null,
          notes || null,
          userId,
          date
        ];
        
        const result = await query(updateSql, values);
        return result.rows[0];
      } else {
        // Insert new
        const insertSql = `
          INSERT INTO symptom_logs (user_id, date, symptoms, sleep_hours, stress_level, notes)
          VALUES ($1, $2, $3, $4, $5, $6)
          RETURNING id, user_id, date, symptoms, sleep_hours, stress_level, 
                    notes, created_at, updated_at
        `;
        
        const values = [
          userId,
          date,
          JSON.stringify(symptoms),
          sleepHours || null,
          stressLevel || null,
          notes || null
        ];
        
        const result = await query(insertSql, values);
        return result.rows[0];
      }
    } catch (error) {
      throw error;
    }
  }

  static async findByUserId(userId, limit = 90) {
    try {
      const sql = `
        SELECT id, user_id, date, symptoms, sleep_hours, stress_level, 
               notes, created_at, updated_at
        FROM symptom_logs
        WHERE user_id = $1
        ORDER BY date DESC
        LIMIT $2
      `;

      const result = await query(sql, [userId, limit]);
      return result.rows;
    } catch (error) {
      throw error;
    }
  }

  static async findByDate(userId, date) {
    try {
      const sql = `
        SELECT id, user_id, date, symptoms, sleep_hours, stress_level, 
               notes, created_at, updated_at
        FROM symptom_logs
        WHERE user_id = $1 AND date = $2
      `;

      const result = await query(sql, [userId, date]);
      return result.rows[0];
    } catch (error) {
      throw error;
    }
  }

  static async getByDateRange(userId, startDate, endDate) {
    try {
      const sql = `
        SELECT id, user_id, date, symptoms, sleep_hours, stress_level, 
               notes, created_at, updated_at
        FROM symptom_logs
        WHERE user_id = $1 AND date BETWEEN $2 AND $3
        ORDER BY date DESC
      `;

      const result = await query(sql, [userId, startDate, endDate]);
      return result.rows;
    } catch (error) {
      throw error;
    }
  }

  static async delete(id, userId) {
    try {
      const sql = `
        DELETE FROM symptom_logs
        WHERE id = $1 AND user_id = $2
        RETURNING id
      `;

      const result = await query(sql, [id, userId]);
      return result.rows[0];
    } catch (error) {
      throw error;
    }
  }

  static async getLatest(userId) {
    try {
      const sql = `
        SELECT id, user_id, date, symptoms, sleep_hours, stress_level, 
               notes, created_at, updated_at
        FROM symptom_logs
        WHERE user_id = $1
        ORDER BY date DESC
        LIMIT 1
      `;

      const result = await query(sql, [userId]);
      return result.rows[0];
    } catch (error) {
      throw error;
    }
  }

  // ============================================================================
  // FIX #3: Parameterized SQL interval to prevent SQL injection
  // ============================================================================
  // BEFORE: WHERE user_id = $1 AND date >= CURRENT_DATE - INTERVAL '${days} days'
  // AFTER:  WHERE user_id = $1 AND date >= CURRENT_DATE - ($2 || ' days')::INTERVAL
  // ============================================================================
  static async getStats(userId, days = 30) {
    try {
      // Validate days parameter to prevent abuse
      const validatedDays = Math.max(1, Math.min(365, parseInt(days) || 30));
      
      const sql = `
        SELECT 
          COUNT(*) as total_logs,
          AVG((symptoms->>'cramps')::NUMERIC) as avg_cramps,
          AVG((symptoms->>'mood')::NUMERIC) as avg_mood,
          AVG((symptoms->>'energy')::NUMERIC) as avg_energy,
          AVG((symptoms->>'headache')::NUMERIC) as avg_headache,
          AVG((symptoms->>'bloating')::NUMERIC) as avg_bloating,
          AVG(sleep_hours) as avg_sleep,
          AVG(stress_level) as avg_stress
        FROM symptom_logs
        WHERE user_id = $1 AND date >= CURRENT_DATE - ($2 || ' days')::INTERVAL
      `;

      const result = await query(sql, [userId, validatedDays]);
      return result.rows[0];
    } catch (error) {
      throw error;
    }
  }

  static async getForAnalysis(userId, limit = 90) {
    try {
      const sql = `
        SELECT date, symptoms, sleep_hours, stress_level
        FROM symptom_logs
        WHERE user_id = $1
        ORDER BY date DESC
        LIMIT $2
      `;

      const result = await query(sql, [userId, limit]);
      return result.rows;
    } catch (error) {
      throw error;
    }
  }
}

module.exports = SymptomLog;