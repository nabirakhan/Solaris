// File: backend/services/otpService.js
const crypto = require('crypto');

class OTPService {
  /**
   * Generate a 6-digit OTP code
   * @returns {string} 6-digit OTP
   */
  static generateOTP() {
    // Generate a random 6-digit number
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    console.log('🔑 Generated OTP:', otp);
    return otp;
  }

  /**
   * Hash OTP for secure storage
   * Uses SHA-256 hashing
   * @param {string} otp - Plain OTP code
   * @returns {string} Hashed OTP
   */
  static hashOTP(otp) {
    return crypto
      .createHash('sha256')
      .update(otp)
      .digest('hex');
  }

  /**
   * Verify OTP against hashed version
   * @param {string} plainOTP - User-provided OTP
   * @param {string} hashedOTP - Stored hashed OTP
   * @returns {boolean} True if OTP matches
   */
  static verifyOTP(plainOTP, hashedOTP) {
    const hashedInput = this.hashOTP(plainOTP);
    return hashedInput === hashedOTP;
  }

  /**
   * Check if OTP has expired
   * @param {Date} expiresAt - Expiration timestamp
   * @returns {boolean} True if expired
   */
  static isOTPExpired(expiresAt) {
    if (!expiresAt) return true;
    return new Date() > new Date(expiresAt);
  }

  /**
   * Calculate OTP expiry time
   * @param {number} minutes - Minutes until expiry (default: 10)
   * @returns {Date} Expiry timestamp
   */
  static getOTPExpiry(minutes = 10) {
    const expiry = new Date();
    expiry.setMinutes(expiry.getMinutes() + minutes);
    return expiry;
  }

  /**
   * Check if user can request new OTP (rate limiting)
   * @param {Date} lastSentAt - Last OTP sent timestamp
   * @param {number} cooldownSeconds - Cooldown period in seconds (default: 60)
   * @returns {object} { canSend: boolean, remainingSeconds: number }
   */
  static canRequestNewOTP(lastSentAt, cooldownSeconds = 60) {
    if (!lastSentAt) {
      return { canSend: true, remainingSeconds: 0 };
    }

    const now = new Date();
    const lastSent = new Date(lastSentAt);
    const secondsSinceLastSend = Math.floor((now - lastSent) / 1000);
    const remainingSeconds = Math.max(0, cooldownSeconds - secondsSinceLastSend);

    return {
      canSend: secondsSinceLastSend >= cooldownSeconds,
      remainingSeconds
    };
  }

  /**
   * Format time remaining for user display
   * @param {Date} expiresAt - Expiration timestamp
   * @returns {string} Formatted time (e.g., "9 minutes 30 seconds")
   */
  static formatTimeRemaining(expiresAt) {
    if (!expiresAt) return '0 seconds';

    const now = new Date();
    const expiry = new Date(expiresAt);
    const diffMs = expiry - now;

    if (diffMs <= 0) return '0 seconds';

    const minutes = Math.floor(diffMs / 60000);
    const seconds = Math.floor((diffMs % 60000) / 1000);

    if (minutes > 0) {
      return `${minutes} minute${minutes > 1 ? 's' : ''} ${seconds} second${seconds !== 1 ? 's' : ''}`;
    }
    return `${seconds} second${seconds !== 1 ? 's' : ''}`;
  }

  /**
   * Validate OTP format
   * @param {string} otp - OTP to validate
   * @returns {object} { valid: boolean, error: string }
   */
  static validateOTPFormat(otp) {
    if (!otp) {
      return { valid: false, error: 'OTP is required' };
    }

    if (typeof otp !== 'string') {
      return { valid: false, error: 'OTP must be a string' };
    }

    if (otp.length !== 6) {
      return { valid: false, error: 'OTP must be 6 digits' };
    }

    if (!/^\d{6}$/.test(otp)) {
      return { valid: false, error: 'OTP must contain only numbers' };
    }

    return { valid: true };
  }

  /**
   * Clean expired OTPs from database
   * Call this periodically via cron job
   * @param {Function} dbQuery - Database query function
   */
  static async cleanExpiredOTPs(dbQuery) {
    try {
      const query = `
        UPDATE users 
        SET 
          otp_code = NULL,
          otp_expires_at = NULL,
          otp_attempts = 0
        WHERE 
          otp_expires_at IS NOT NULL 
          AND otp_expires_at < NOW()
      `;

      const result = await dbQuery(query);
      console.log(`🧹 Cleaned ${result.rowCount} expired OTPs`);
      return result.rowCount;
    } catch (error) {
      console.error('Error cleaning expired OTPs:', error);
      return 0;
    }
  }

  /**
   * Generate OTP with metadata
   * Returns everything needed to send and store OTP
   * @param {number} expiryMinutes - Minutes until expiry
   * @returns {object} { otp, hashedOTP, expiresAt }
   */
  static generateOTPWithMetadata(expiryMinutes = 10) {
    const otp = this.generateOTP();
    const hashedOTP = this.hashOTP(otp);
    const expiresAt = this.getOTPExpiry(expiryMinutes);

    return {
      otp, // Plain text (for email)
      hashedOTP, // For database storage
      expiresAt // Expiry timestamp
    };
  }

  /**
   * Sanitize email address
   * @param {string} email - Email to sanitize
   * @returns {string} Sanitized email
   */
  static sanitizeEmail(email) {
    if (!email) return '';
    return email.toLowerCase().trim();
  }

  /**
   * Mask email for display
   * Example: john.doe@example.com → j***e@e***e.com
   * @param {string} email - Email to mask
   * @returns {string} Masked email
   */
  static maskEmail(email) {
    if (!email || !email.includes('@')) return '***';

    const [localPart, domain] = email.split('@');
    const [domainName, tld] = domain.split('.');

    const maskString = (str) => {
      if (str.length <= 2) return '*'.repeat(str.length);
      return str[0] + '*'.repeat(str.length - 2) + str[str.length - 1];
    };

    return `${maskString(localPart)}@${maskString(domainName)}.${tld}`;
  }
}

module.exports = OTPService;