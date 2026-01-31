// File: backend/models/Cycle.js
const { query } = require('../config/database');

class Cycle {
  static async create({ userId, startDate, flow = 'medium', notes }) {
    try {
      const sql = `
        INSERT INTO cycles (user_id, start_date, flow, notes)
        VALUES ($1, $2, $3, $4)
        RETURNING id, user_id, start_date, end_date, flow, notes, 
                  cycle_length, created_at, updated_at
      `;

      const values = [userId, startDate, flow, notes || null];
      const result = await query(sql, values);
      return result.rows[0];
    } catch (error) {
      throw error;
    }
  }

  static async update(id, userId, updates) {
    try {
      const allowedFields = ['end_date', 'flow', 'notes'];
      const fields = [];
      const values = [];
      let paramCount = 1;

      Object.keys(updates).forEach(key => {
        if (allowedFields.includes(key) && updates[key] !== undefined) {
          fields.push(`${key} = $${paramCount}`);
          values.push(updates[key]);
          paramCount++;
        }
      });

      if (fields.length === 0) {
        throw new Error('No valid fields to update');
      }

      values.push(id, userId);
      const sql = `
        UPDATE cycles
        SET ${fields.join(', ')}, updated_at = CURRENT_TIMESTAMP
        WHERE id = $${paramCount} AND user_id = $${paramCount + 1}
        RETURNING id, user_id, start_date, end_date, flow, notes, 
                  cycle_length, created_at, updated_at
      `;

      const result = await query(sql, values);
      return result.rows[0];
    } catch (error) {
      throw error;
    }
  }

  static async findByUserId(userId, limit = 50) {
    try {
      const sql = `
        SELECT id, user_id, start_date, end_date, flow, notes, 
               cycle_length, created_at, updated_at
        FROM cycles
        WHERE user_id = $1
        ORDER BY start_date DESC
        LIMIT $2
      `;

      const result = await query(sql, [userId, limit]);
      return result.rows;
    } catch (error) {
      throw error;
    }
  }

  static async findById(id, userId) {
    try {
      const sql = `
        SELECT id, user_id, start_date, end_date, flow, notes, 
               cycle_length, created_at, updated_at
        FROM cycles
        WHERE id = $1 AND user_id = $2
      `;

      const result = await query(sql, [id, userId]);
      return result.rows[0];
    } catch (error) {
      throw error;
    }
  }

  static async delete(id, userId) {
    try {
      const sql = `
        DELETE FROM cycles
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
        SELECT id, user_id, start_date, end_date, flow, notes, 
               cycle_length, created_at, updated_at
        FROM cycles
        WHERE user_id = $1
        ORDER BY start_date DESC
        LIMIT 1
      `;

      const result = await query(sql, [userId]);
      return result.rows[0];
    } catch (error) {
      throw error;
    }
  }

  static async getForAnalysis(userId, limit = 12) {
    try {
      const sql = `
        SELECT id, start_date, end_date, cycle_length, flow
        FROM cycles
        WHERE user_id = $1 AND cycle_length IS NOT NULL
        ORDER BY start_date DESC
        LIMIT $2
      `;

      const result = await query(sql, [userId, limit]);
      return result.rows;
    } catch (error) {
      throw error;
    }
  }

  static async getAverageCycleLength(userId, limit = 6) {
    try {
      const sql = `
        SELECT 
          AVG(cycle_length)::NUMERIC(10,2) as avg_length,
          STDDEV(cycle_length)::NUMERIC(10,2) as std_dev,
          COUNT(*) as count
        FROM cycles
        WHERE user_id = $1 AND cycle_length IS NOT NULL AND cycle_length BETWEEN 14 AND 45
        ORDER BY start_date DESC
        LIMIT $2
      `;

      const result = await query(sql, [userId, limit]);
      return result.rows[0];
    } catch (error) {
      throw error;
    }
  }

  static async getByDateRange(userId, startDate, endDate) {
    try {
      const sql = `
        SELECT id, user_id, start_date, end_date, flow, notes, 
               cycle_length, created_at, updated_at
        FROM cycles
        WHERE user_id = $1 AND start_date BETWEEN $2 AND $3
        ORDER BY start_date DESC
      `;

      const result = await query(sql, [userId, startDate, endDate]);
      return result.rows;
    } catch (error) {
      throw error;
    }
  }
}

module.exports = Cycle;