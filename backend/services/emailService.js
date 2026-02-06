// File: backend/services/emailService.js
const sgMail = require('@sendgrid/mail');

// Initialize SendGrid with API key
sgMail.setApiKey(process.env.SENDGRID_API_KEY);

class EmailService {
  /**
   * Send OTP verification email
   * @param {string} email - Recipient email address
   * @param {string} otp - 6-digit OTP code
   * @param {string} name - User's name
   */
  static async sendOTPEmail(email, otp, name = 'there') {
    try {
      const msg = {
        to: email,
        from: {
          email: process.env.SENDGRID_FROM_EMAIL,
          name: process.env.SENDGRID_FROM_NAME || 'Solaris'
        },
        subject: 'Verify Your Email - Solaris',
        html: this.getOTPEmailTemplate(otp, name),
        text: this.getOTPEmailTextVersion(otp, name), // Fallback for non-HTML clients
      };

      const response = await sgMail.send(msg);
      console.log('✅ OTP email sent successfully to:', email);
      console.log('📧 SendGrid response:', response[0].statusCode);
      
      return {
        success: true,
        messageId: response[0].headers['x-message-id']
      };
    } catch (error) {
      console.error('❌ SendGrid email error:', error);
      
      if (error.response) {
        console.error('SendGrid error details:', error.response.body);
      }
      
      throw new Error(`Failed to send email: ${error.message}`);
    }
  }

  /**
   * Send welcome email after successful verification
   * @param {string} email - Recipient email address
   * @param {string} name - User's name
   */
  static async sendWelcomeEmail(email, name) {
    try {
      const msg = {
        to: email,
        from: {
          email: process.env.SENDGRID_FROM_EMAIL,
          name: process.env.SENDGRID_FROM_NAME || 'Solaris'
        },
        subject: 'Welcome to Solaris! 🌸',
        html: this.getWelcomeEmailTemplate(name),
        text: `Hi ${name},\n\nWelcome to Solaris! Your account has been successfully verified.\n\nYou can now log in and start tracking your menstrual cycle.\n\nBest regards,\nThe Solaris Team`
      };

      await sgMail.send(msg);
      console.log('✅ Welcome email sent to:', email);
    } catch (error) {
      console.error('❌ Failed to send welcome email:', error);
      // Don't throw - welcome email is not critical
    }
  }

  /**
   * Send password reset OTP
   * @param {string} email - Recipient email address
   * @param {string} otp - 6-digit OTP code
   */
  static async sendPasswordResetOTP(email, otp) {
    try {
      const msg = {
        to: email,
        from: {
          email: process.env.SENDGRID_FROM_EMAIL,
          name: process.env.SENDGRID_FROM_NAME || 'Solaris'
        },
        subject: 'Password Reset - Solaris',
        html: this.getPasswordResetTemplate(otp),
        text: `Your password reset code is: ${otp}\n\nThis code will expire in 10 minutes.\n\nIf you didn't request this, please ignore this email.`
      };

      await sgMail.send(msg);
      console.log('✅ Password reset email sent to:', email);
    } catch (error) {
      console.error('❌ Failed to send password reset email:', error);
      throw new Error(`Failed to send password reset email: ${error.message}`);
    }
  }

  /**
   * HTML Email Template for OTP Verification
   */
  static getOTPEmailTemplate(otp, name) {
    return `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Verify Your Email</title>
</head>
<body style="margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
  <table width="100%" cellpadding="0" cellspacing="0" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 40px 0;">
    <tr>
      <td align="center">
        <!-- Main Container -->
        <table width="600" cellpadding="0" cellspacing="0" style="background: white; border-radius: 16px; overflow: hidden; box-shadow: 0 20px 60px rgba(0,0,0,0.3);">
          
          <!-- Header with Gradient -->
          <tr>
            <td style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 40px 30px; text-align: center;">
              <h1 style="margin: 0; color: white; font-size: 32px; font-weight: 700; text-shadow: 0 2px 4px rgba(0,0,0,0.2);">
                ✨ Solaris
              </h1>
              <p style="margin: 10px 0 0 0; color: rgba(255,255,255,0.9); font-size: 16px;">
                Your Personal Cycle Companion
              </p>
            </td>
          </tr>
          
          <!-- Content -->
          <tr>
            <td style="padding: 40px 30px;">
              <h2 style="margin: 0 0 20px 0; color: #333; font-size: 24px; font-weight: 600;">
                Hi ${name}! 👋
              </h2>
              
              <p style="margin: 0 0 20px 0; color: #555; font-size: 16px; line-height: 1.6;">
                Thank you for signing up with Solaris! To complete your registration and start tracking your menstrual health, please verify your email address using the code below:
              </p>
              
              <!-- OTP Code Box -->
              <table width="100%" cellpadding="0" cellspacing="0" style="margin: 30px 0;">
                <tr>
                  <td align="center" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 12px; padding: 30px;">
                    <p style="margin: 0 0 10px 0; color: rgba(255,255,255,0.9); font-size: 14px; text-transform: uppercase; letter-spacing: 1px;">
                      Your Verification Code
                    </p>
                    <div style="background: white; border-radius: 8px; padding: 20px; display: inline-block;">
                      <span style="font-size: 36px; font-weight: 700; letter-spacing: 8px; color: #667eea; font-family: 'Courier New', monospace;">
                        ${otp}
                      </span>
                    </div>
                  </td>
                </tr>
              </table>
              
              <p style="margin: 20px 0; color: #555; font-size: 16px; line-height: 1.6;">
                This code will expire in <strong>10 minutes</strong>. If you didn't request this verification, you can safely ignore this email.
              </p>
              
              <!-- Info Box -->
              <table width="100%" cellpadding="0" cellspacing="0" style="margin: 30px 0; background: #f8f9fa; border-left: 4px solid #667eea; border-radius: 4px;">
                <tr>
                  <td style="padding: 20px;">
                    <p style="margin: 0; color: #555; font-size: 14px; line-height: 1.6;">
                      💡 <strong>Tip:</strong> For your security, never share this code with anyone. Solaris will never ask for your verification code via phone, text message, or email.
                    </p>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          
          <!-- Footer -->
          <tr>
            <td style="background: #f8f9fa; padding: 30px; text-align: center; border-top: 1px solid #e9ecef;">
              <p style="margin: 0 0 10px 0; color: #6c757d; font-size: 14px;">
                Need help? Contact us at <a href="mailto:support@solaris.com" style="color: #667eea; text-decoration: none;">support@solaris.com</a>
              </p>
              <p style="margin: 0; color: #adb5bd; font-size: 12px;">
                © ${new Date().getFullYear()} Solaris. All rights reserved.
              </p>
            </td>
          </tr>
          
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
    `;
  }

  /**
   * Plain text version of OTP email (fallback)
   */
  static getOTPEmailTextVersion(otp, name) {
    return `
Hi ${name}!

Thank you for signing up with Solaris!

Your verification code is: ${otp}

This code will expire in 10 minutes.

If you didn't request this verification, you can safely ignore this email.

Need help? Contact us at support@solaris.com

© ${new Date().getFullYear()} Solaris. All rights reserved.
    `.trim();
  }

  /**
   * Welcome email template
   */
  static getWelcomeEmailTemplate(name) {
    return `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f5f5f5;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background: #f5f5f5; padding: 40px 0;">
    <tr>
      <td align="center">
        <table width="600" cellpadding="0" cellspacing="0" style="background: white; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
          
          <tr>
            <td style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 40px 30px; text-align: center;">
              <h1 style="margin: 0; color: white; font-size: 32px;">🌸 Welcome to Solaris!</h1>
            </td>
          </tr>
          
          <tr>
            <td style="padding: 40px 30px;">
              <h2 style="margin: 0 0 20px 0; color: #333;">Hi ${name}!</h2>
              <p style="color: #555; font-size: 16px; line-height: 1.6;">
                Your account has been successfully verified. You're all set to start tracking your menstrual cycle and taking control of your health!
              </p>
              <p style="color: #555; font-size: 16px; line-height: 1.6;">
                Here's what you can do with Solaris:
              </p>
              <ul style="color: #555; font-size: 16px; line-height: 1.8;">
                <li>Track your period and predict future cycles</li>
                <li>Log symptoms and mood changes</li>
                <li>Get AI-powered insights</li>
                <li>Monitor your health metrics</li>
              </ul>
            </td>
          </tr>
          
          <tr>
            <td style="background: #f8f9fa; padding: 30px; text-align: center;">
              <p style="margin: 0; color: #6c757d; font-size: 14px;">
                © ${new Date().getFullYear()} Solaris. All rights reserved.
              </p>
            </td>
          </tr>
          
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
    `;
  }

  /**
   * Password reset email template
   */
  static getPasswordResetTemplate(otp) {
    return `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background: #f5f5f5; padding: 40px 0;">
    <tr>
      <td align="center">
        <table width="600" cellpadding="0" cellspacing="0" style="background: white; border-radius: 16px; overflow: hidden;">
          
          <tr>
            <td style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 40px 30px; text-align: center;">
              <h1 style="margin: 0; color: white; font-size: 28px;">🔒 Password Reset</h1>
            </td>
          </tr>
          
          <tr>
            <td style="padding: 40px 30px;">
              <p style="color: #555; font-size: 16px; line-height: 1.6;">
                You requested to reset your password. Use the code below to continue:
              </p>
              
              <table width="100%" cellpadding="0" cellspacing="0" style="margin: 30px 0;">
                <tr>
                  <td align="center" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 12px; padding: 30px;">
                    <div style="background: white; border-radius: 8px; padding: 20px; display: inline-block;">
                      <span style="font-size: 36px; font-weight: 700; letter-spacing: 8px; color: #667eea; font-family: 'Courier New', monospace;">
                        ${otp}
                      </span>
                    </div>
                  </td>
                </tr>
              </table>
              
              <p style="color: #555; font-size: 16px; line-height: 1.6;">
                This code will expire in <strong>10 minutes</strong>.
              </p>
              
              <p style="color: #d63031; font-size: 14px; line-height: 1.6; margin-top: 20px;">
                ⚠️ If you didn't request this password reset, please ignore this email and ensure your account is secure.
              </p>
            </td>
          </tr>
          
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
    `;
  }
}

module.exports = EmailService;