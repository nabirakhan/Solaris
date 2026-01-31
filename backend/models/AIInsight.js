// File: backend/models/AIInsight.js
const { query } = require('../config/database');

class AIInsight {
  static async create({ userId, insightType, prediction, anomaly, cycleData, shouldDisplay = true, displayPriority = 0 }) {
    try {
      const sql = `
        INSERT INTO ai_insights (
          user_id, insight_type, prediction, anomaly, cycle_data, 
          should_display, display_priority
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING id, user_id, date, insight_type, prediction, anomaly, 
                  cycle_data, should_display, display_priority, viewed, 
                  viewed_at, created_at
      `;

      const values = [
        userId,
        insightType,
        prediction ? JSON.stringify(prediction) : null,
        anomaly ? JSON.stringify(anomaly) : null,
        cycleData ? JSON.stringify(cycleData) : null,
        shouldDisplay,
        displayPriority
      ];

      const result = await query(sql, values);
      return result.rows[0];
    } catch (error) {
      throw error;
    }
  }

  static async findByUserId(userId, limit = 30) {
    try {
      const sql = `
        SELECT id, user_id, date, insight_type, prediction, anomaly, 
               cycle_data, should_display, display_priority, viewed, 
               viewed_at, created_at
        FROM ai_insights
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

  static async getLatest(userId) {
    try {
      const sql = `
        SELECT id, user_id, date, insight_type, prediction, anomaly, 
               cycle_data, should_display, display_priority, viewed, 
               viewed_at, created_at
        FROM ai_insights
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

  static async getUnviewed(userId) {
    try {
      const sql = `
        SELECT id, user_id, date, insight_type, prediction, anomaly, 
               cycle_data, should_display, display_priority, viewed, 
               viewed_at, created_at
        FROM ai_insights
        WHERE user_id = $1 AND viewed = FALSE AND should_display = TRUE
        ORDER BY display_priority DESC, date DESC
      `;

      const result = await query(sql, [userId]);
      return result.rows;
    } catch (error) {
      throw error;
    }
  }

  static async markAsViewed(id, userId) {
    try {
      const sql = `
        UPDATE ai_insights
        SET viewed = TRUE, viewed_at = CURRENT_TIMESTAMP
        WHERE id = $1 AND user_id = $2
        RETURNING id, viewed, viewed_at
      `;

      const result = await query(sql, [id, userId]);
      return result.rows[0];
    } catch (error) {
      throw error;
    }
  }

  static async getByType(userId, insightType, limit = 10) {
    try {
      const sql = `
        SELECT id, user_id, date, insight_type, prediction, anomaly, 
               cycle_data, should_display, display_priority, viewed, 
               viewed_at, created_at
        FROM ai_insights
        WHERE user_id = $1 AND insight_type = $2
        ORDER BY date DESC
        LIMIT $3
      `;

      const result = await query(sql, [userId, insightType, limit]);
      return result.rows;
    } catch (error) {
      throw error;
    }
  }

  static async deleteOld(userId, daysToKeep = 90) {
    try {
      const sql = `
        DELETE FROM ai_insights
        WHERE user_id = $1 
        AND date < CURRENT_TIMESTAMP - INTERVAL '${daysToKeep} days'
        RETURNING id
      `;

      const result = await query(sql, [userId]);
      return result.rows.length;
    } catch (error) {
      throw error;
    }
  }

  static async getStats(userId) {
    try {
      const sql = `
        SELECT 
          COUNT(*) as total_insights,
          COUNT(*) FILTER (WHERE viewed = TRUE) as viewed_count,
          COUNT(*) FILTER (WHERE should_display = TRUE) as displayable_count,
          COUNT(*) FILTER (WHERE insight_type = 'prediction') as predictions_count,
          COUNT(*) FILTER (WHERE insight_type = 'anomaly') as anomalies_count
        FROM ai_insights
        WHERE user_id = $1
      `;

      const result = await query(sql, [userId]);
      return result.rows[0];
    } catch (error) {
      throw error;
    }
  }
}

module.exports = AIInsight;