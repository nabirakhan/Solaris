// File: backend/models/User.js
const { pool } = require('../config/database');
const bcrypt = require('bcryptjs');

class User {
  static async create({ email, password, name, dateOfBirth, googleId, profilePicture, accountType = 'email' }) {
    try {
      let hashedPassword = null;

      // Only hash password if it's provided (not for Google sign-in)
      if (password) {
        const salt = await bcrypt.genSalt(10);
        hashedPassword = await bcrypt.hash(password, salt);
      }

      const query = `
        INSERT INTO users (
          email, 
          password, 
          name, 
          date_of_birth, 
          google_id, 
          profile_picture, 
          account_type,
          email_verified
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
        RETURNING 
          id, 
          email, 
          name, 
          date_of_birth, 
          profile_picture, 
          account_type, 
          preferences,
          created_at
      `;

      const values = [
        email,
        hashedPassword,
        name,
        dateOfBirth || null,
        googleId || null,
        profilePicture || null,
        accountType,
        accountType === 'google' // Auto-verify Google accounts
      ];

      const result = await pool.query(query, values);
      return result.rows[0];
    } catch (error) {
      console.error('Error creating user:', error);
      throw error;
    }
  }

  static async findByEmail(email) {
    try {
      const query = `
        SELECT 
          id, 
          email, 
          password, 
          name, 
          date_of_birth, 
          google_id,
          profile_picture, 
          account_type, 
          preferences,
          email_verified,
          created_at,
          last_login
        FROM users 
        WHERE email = $1
      `;

      const result = await pool.query(query, [email]);
      return result.rows[0] || null;
    } catch (error) {
      console.error('Error finding user by email:', error);
      throw error;
    }
  }

  static async findById(id) {
    try {
      const query = `
        SELECT 
          id, 
          email, 
          name, 
          date_of_birth, 
          google_id,
          profile_picture, 
          account_type, 
          preferences,
          email_verified,
          created_at,
          last_login
        FROM users 
        WHERE id = $1
      `;

      const result = await pool.query(query, [id]);
      return result.rows[0] || null;
    } catch (error) {
      console.error('Error finding user by ID:', error);
      throw error;
    }
  }

  static async findByGoogleId(googleId) {
    try {
      const query = `
        SELECT 
          id, 
          email, 
          name, 
          date_of_birth, 
          google_id,
          profile_picture, 
          account_type, 
          preferences,
          email_verified,
          created_at,
          last_login
        FROM users 
        WHERE google_id = $1
      `;

      const result = await pool.query(query, [googleId]);
      return result.rows[0] || null;
    } catch (error) {
      console.error('Error finding user by Google ID:', error);
      throw error;
    }
  }

  static async comparePassword(candidatePassword, hashedPassword) {
    try {
      return await bcrypt.compare(candidatePassword, hashedPassword);
    } catch (error) {
      console.error('Error comparing password:', error);
      throw error;
    }
  }

  static async update(id, updates) {
    try {
      const fields = [];
      const values = [];
      let paramCount = 1;

      // Build dynamic update query
      Object.keys(updates).forEach(key => {
        fields.push(`${key} = $${paramCount}`);
        values.push(updates[key]);
        paramCount++;
      });

      if (fields.length === 0) {
        throw new Error('No fields to update');
      }

      values.push(id); // Add ID as last parameter

      const query = `
        UPDATE users 
        SET ${fields.join(', ')}, updated_at = CURRENT_TIMESTAMP
        WHERE id = $${paramCount}
        RETURNING 
          id, 
          email, 
          name, 
          date_of_birth, 
          profile_picture, 
          account_type, 
          preferences,
          created_at,
          updated_at
      `;

      const result = await pool.query(query, values);
      return result.rows[0] || null;
    } catch (error) {
      console.error('Error updating user:', error);
      throw error;
    }
  }

  // Link Google account to existing user
  static async linkGoogleAccount(userId, googleId, profilePicture) {
    try {
      const query = `
        UPDATE users 
        SET 
          google_id = $1, 
          profile_picture = COALESCE(profile_picture, $2),
          updated_at = CURRENT_TIMESTAMP
        WHERE id = $3
        RETURNING 
          id, 
          email, 
          name, 
          date_of_birth, 
          google_id,
          profile_picture, 
          account_type, 
          preferences,
          created_at
      `;

      const result = await pool.query(query, [googleId, profilePicture, userId]);
      return result.rows[0];
    } catch (error) {
      console.error('Error linking Google account:', error);
      throw error;
    }
  }

  static async updateLastLogin(userId) {
    try {
      const query = `
        UPDATE users 
        SET last_login = CURRENT_TIMESTAMP
        WHERE id = $1
      `;

      await pool.query(query, [userId]);
    } catch (error) {
      console.error('Error updating last login:', error);
      // Don't throw - this is not critical
    }
  }

  static async getStats(userId) {
    try {
      const cyclesQuery = `
        SELECT COUNT(*) as total_cycles
        FROM cycles
        WHERE user_id = $1
      `;

      const symptomsQuery = `
        SELECT COUNT(*) as total_symptom_logs
        FROM symptom_logs
        WHERE user_id = $1
      `;

      const cyclesResult = await pool.query(cyclesQuery, [userId]);
      const symptomsResult = await pool.query(symptomsQuery, [userId]);

      return {
        totalCycles: parseInt(cyclesResult.rows[0].total_cycles) || 0,
        totalSymptomLogs: parseInt(symptomsResult.rows[0].total_symptom_logs) || 0
      };
    } catch (error) {
      console.error('Error getting user stats:', error);
      return {
        totalCycles: 0,
        totalSymptomLogs: 0
      };
    }
  }

  // Delete user (soft delete - mark as deleted)
  static async softDelete(userId) {
    try {
      const query = `
        UPDATE users 
        SET 
          deleted_at = CURRENT_TIMESTAMP,
          email = CONCAT('deleted_', id, '_', email)
        WHERE id = $1
      `;

      await pool.query(query, [userId]);
    } catch (error) {
      console.error('Error soft deleting user:', error);
      throw error;
    }
  }
}

module.exports = User;