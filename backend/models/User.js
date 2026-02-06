const { pool } = require('../config/database');
const bcrypt = require('bcryptjs');

class User {
  static async create({ 
    email, 
    password, 
    name, 
    dateOfBirth, 
    googleId, 
    profilePicture, 
    accountType = 'email',
    verificationToken = null,
    verificationTokenExpires = null
  }) {
    try {
      let hashedPassword = null;

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
          email_verified,
          verification_token,
          verification_token_expires
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
        RETURNING 
          id, 
          email, 
          name, 
          date_of_birth, 
          profile_picture, 
          account_type, 
          preferences,
          email_verified,
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
        accountType === 'google', // Auto-verify Google accounts
        verificationToken,
        verificationTokenExpires
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
          verification_token,
          verification_token_expires,
          reset_token,
          reset_token_expires,
          otp_code,
          otp_expires_at,
          otp_attempts,
          otp_last_sent_at,
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
          verification_token,
          verification_token_expires,
          reset_token,
          reset_token_expires,
          otp_code,
          otp_expires_at,
          otp_attempts,
          otp_last_sent_at,
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

      Object.keys(updates).forEach(key => {
        const dbKey = key.replace(/[A-Z]/g, letter => `_${letter.toLowerCase()}`);
        fields.push(`${dbKey} = $${paramCount}`);
        values.push(updates[key]);
        paramCount++;
      });

      if (fields.length === 0) {
        throw new Error('No fields to update');
      }

      values.push(id);

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
          email_verified,
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

  /**
   * Update user's OTP code and expiry
   * @param {string} userId - User ID
   * @param {string} hashedOTP - Hashed OTP code
   * @param {Date} expiresAt - Expiry timestamp
   */
  static async updateOTP(userId, hashedOTP, expiresAt) {
    try {
      const query = `
        UPDATE users 
        SET 
          otp_code = $1,
          otp_expires_at = $2,
          otp_attempts = COALESCE(otp_attempts, 0) + 1,
          otp_last_sent_at = CURRENT_TIMESTAMP,
          updated_at = CURRENT_TIMESTAMP
        WHERE id = $3
        RETURNING id, email, otp_attempts, otp_last_sent_at
      `;

      const result = await pool.query(query, [hashedOTP, expiresAt, userId]);
      return result.rows[0];
    } catch (error) {
      console.error('Error updating OTP:', error);
      throw error;
    }
  }

  /**
   * Verify user's email (clear OTP and mark as verified)
   * @param {string} userId - User ID
   */
  static async verifyEmail(userId) {
    try {
      const query = `
        UPDATE users 
        SET 
          email_verified = true,
          otp_code = NULL,
          otp_expires_at = NULL,
          otp_attempts = 0,
          otp_last_sent_at = NULL,
          verification_token = NULL,
          verification_token_expires = NULL,
          updated_at = CURRENT_TIMESTAMP
        WHERE id = $1
        RETURNING 
          id, 
          email, 
          name, 
          email_verified,
          created_at
      `;

      const result = await pool.query(query, [userId]);
      return result.rows[0];
    } catch (error) {
      console.error('Error verifying email:', error);
      throw error;
    }
  }

  /**
   * Update verification token (for backward compatibility)
   * @param {string} userId - User ID
   * @param {string} verificationToken - Verification token
   * @param {Date} verificationTokenExpires - Token expiry
   */
  static async updateVerificationToken(userId, verificationToken, verificationTokenExpires) {
    try {
      const query = `
        UPDATE users 
        SET 
          verification_token = $1,
          verification_token_expires = $2,
          updated_at = CURRENT_TIMESTAMP
        WHERE id = $3
        RETURNING 
          id, 
          email, 
          name,
          email_verified
      `;

      const result = await pool.query(query, [
        verificationToken, 
        verificationTokenExpires, 
        userId
      ]);
      return result.rows[0];
    } catch (error) {
      console.error('Error updating verification token:', error);
      throw error;
    }
  }

  static async linkGoogleAccount(userId, googleId, profilePicture) {
    try {
      const query = `
        UPDATE users 
        SET 
          google_id = $1, 
          profile_picture = COALESCE(profile_picture, $2),
          email_verified = true,
          verification_token = NULL,
          verification_token_expires = NULL,
          otp_code = NULL,
          otp_expires_at = NULL,
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

  /**
   * Reset OTP attempts
   * @param {string} userId - User ID
   */
  static async resetOTPAttempts(userId) {
    try {
      const query = `
        UPDATE users 
        SET 
          otp_attempts = 0,
          updated_at = CURRENT_TIMESTAMP
        WHERE id = $1
      `;

      await pool.query(query, [userId]);
    } catch (error) {
      console.error('Error resetting OTP attempts:', error);
    }
  }

  /**
   * Delete expired unverified users
   */
  static async deleteExpiredUnverifiedUsers() {
    try {
      const query = `
        DELETE FROM users 
        WHERE 
          email_verified = false 
          AND (
            (otp_expires_at IS NOT NULL AND otp_expires_at < CURRENT_TIMESTAMP)
            OR (verification_token_expires IS NOT NULL AND verification_token_expires < CURRENT_TIMESTAMP)
          )
          AND created_at < CURRENT_TIMESTAMP - INTERVAL '24 hours'
        RETURNING email
      `;
      
      const result = await pool.query(query);
      
      if (result.rows.length > 0) {
        console.log(`🧹 Deleted ${result.rows.length} expired unverified users`);
      }
      
      return result.rows.length;
    } catch (error) {
      console.error('Error deleting expired unverified users:', error);
      return 0;
    }
  }

  /**
   * Get user's OTP status
   * @param {string} userId - User ID
   */
  static async getOTPStatus(userId) {
    try {
      const query = `
        SELECT 
          email_verified,
          otp_code IS NOT NULL as has_otp,
          otp_expires_at,
          otp_attempts,
          otp_last_sent_at,
          CASE 
            WHEN otp_expires_at IS NULL THEN NULL
            WHEN otp_expires_at < CURRENT_TIMESTAMP THEN true
            ELSE false
          END as otp_expired
        FROM users 
        WHERE id = $1
      `;

      const result = await pool.query(query, [userId]);
      return result.rows[0] || null;
    } catch (error) {
      console.error('Error getting OTP status:', error);
      return null;
    }
  }

  /**
   * Get user by email with all OTP fields (for auth routes)
   * @param {string} email - User email
   */
  static async findByEmailWithOTP(email) {
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
          verification_token,
          verification_token_expires,
          reset_token,
          reset_token_expires,
          otp_code,
          otp_expires_at,
          otp_attempts,
          otp_last_sent_at,
          created_at,
          last_login
        FROM users 
        WHERE LOWER(email) = LOWER($1)
      `;

      const result = await pool.query(query, [email]);
      return result.rows[0] || null;
    } catch (error) {
      console.error('Error finding user by email with OTP:', error);
      throw error;
    }
  }
}

module.exports = User;