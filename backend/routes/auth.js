// File: backend/routes/auth.js
const supabaseStorage = require('../services/supabaseStorage');
const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const passport = require('passport');
const GoogleStrategy = require('passport-google-oauth20').Strategy;
const multer = require('multer');
const path = require('path');
const fs = require('fs').promises;
const User = require('../models/User');
const auth = require('../middleware/auth');
const EmailService = require('../services/emailService');
const OTPService = require('../services/otpService');

// Configure multer for profile picture uploads (MUST BE DEFINED BEFORE ROUTES THAT USE IT)
const storage = multer.diskStorage({
  destination: async (req, file, cb) => {
    const uploadDir = path.join(__dirname, '../uploads/profiles');
    try {
      await fs.mkdir(uploadDir, { recursive: true });
      cb(null, uploadDir);
    } catch (error) {
      cb(error, null);
    }
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'profile-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024 // 5MB limit
  },
  fileFilter: (req, file, cb) => {
    // Accept files that are images OR have image extensions
    const isImageMimeType = file.mimetype && file.mimetype.startsWith('image/');
    const hasImageExtension = /\.(jpe?g|png|gif|webp)$/i.test(file.originalname);

    if (isImageMimeType || hasImageExtension) {
      return cb(null, true);
    } else {
      cb(new Error('Only image files are allowed!'));
    }
  }
});

// Helper function to format user response with correct profile picture URL
function formatUserResponse(user) {
  const baseUrl = 'https://solaris-vhc8.onrender.com';
  
  let profilePicture = user.profile_picture || user.profilePicture;
  
  // If profile picture exists and is a relative path, convert to full URL
  if (profilePicture) {
    if (profilePicture.startsWith('/uploads/')) {
      profilePicture = `${baseUrl}${profilePicture}`;
    } else if (!profilePicture.startsWith('http')) {
      // If it's neither a full URL nor starts with /uploads/, it might be a filename only
      profilePicture = `${baseUrl}/uploads/profiles/${profilePicture}`;
    }
  }
  
  return {
    id: user.id,
    email: user.email,
    name: user.name,
    dateOfBirth: user.date_of_birth,
    profilePicture: profilePicture,
    photoUrl: profilePicture, // Alternative field name for compatibility
    accountType: user.account_type,
    preferences: user.preferences,
    emailVerified: user.email_verified,
    createdAt: user.created_at,
    lastLogin: user.last_login
  };
}

// Generate JWT token helper function
const generateToken = (userId, email) => {
  return jwt.sign(
    { userId, email },
    process.env.JWT_SECRET,
    { expiresIn: '30d' }
  );
};

// UPDATED: Get current user endpoint with fixed profile picture URL
router.get('/me', auth, async (req, res) => {
  try {
    const user = await User.findById(req.userId);
    
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    const stats = await User.getStats(req.userId);
    
    res.json({
      user: formatUserResponse(user), // ✅ UPDATED: Using formatUserResponse
      stats
    });
  } catch (error) {
    console.error('Get current user error:', error);
    res.status(500).json({ error: error.message });
  }
});

// UPDATED: Login endpoint with fixed profile picture URL
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    const user = await User.findByEmail(email.toLowerCase());

    if (!user) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    if (!user.password) {
      return res.status(401).json({ 
        error: 'This account uses Google sign-in. Please use the Google sign-in button.' 
      });
    }

    const isValidPassword = await User.comparePassword(password, user.password);

    if (!isValidPassword) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    if (!user.email_verified) {
      return res.status(401).json({ 
        error: 'Please verify your email before logging in',
        emailVerified: false 
      });
    }

    await User.updateLastLogin(user.id);

    const token = generateToken(user.id, user.email);

    res.json({
      message: 'Login successful',
      token,
      user: formatUserResponse(user) // ✅ UPDATED: Using formatUserResponse
    });

  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: error.message });
  }
});

// UPDATED: Signup endpoint with OTP verification
router.post('/signup', async (req, res) => {
  try {
    const { email, password, name, dateOfBirth } = req.body;

    // Validation
    if (!email || !password || !name) {
      return res.status(400).json({ 
        error: 'Email, password, and name are required' 
      });
    }

    if (password.length < 6) {
      return res.status(400).json({ error: 'Password must be at least 6 characters' });
    }

    // Check if user already exists
    const existingUser = await User.findByEmail(email.toLowerCase());
    if (existingUser) {
      // If user exists but not verified, allow resending OTP
      if (!existingUser.email_verified) {
        return res.status(400).json({ 
          error: 'Email already registered but not verified. Please verify your email or request a new OTP.',
          emailVerified: false,
          userId: existingUser.id
        });
      }
      return res.status(400).json({ error: 'Email already registered and verified' });
    }

    // Create user (unverified)
    const user = await User.create({
      email: email.toLowerCase(),
      password,
      name,
      dateOfBirth,
      accountType: 'email',
      emailVerified: false // Important: don't auto-verify
    });

    // Generate OTP
    const { otp, hashedOTP, expiresAt } = OTPService.generateOTPWithMetadata(10);

    // Store OTP in database
    await User.updateOTP(user.id, hashedOTP, expiresAt);

    // Send OTP email
    try {
      await EmailService.sendOTPEmail(email, otp, name);
    } catch (emailError) {
      console.error('Failed to send OTP email:', emailError);
      // Don't fail the signup - user can request resend
    }

    res.status(201).json({
      message: 'Account created! Please check your email for verification code.',
      userId: user.id,
      email: OTPService.maskEmail(email),
      expiresAt: expiresAt.toISOString()
    });

  } catch (error) {
    console.error('Signup error:', error);
    res.status(500).json({ error: error.message });
  }
});

/**
 * SEND OTP - Send OTP to user's email
 * POST /api/auth/send-otp
 */
router.post('/send-otp', async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ error: 'Email is required' });
    }

    const sanitizedEmail = OTPService.sanitizeEmail(email);
    const user = await User.findByEmailWithOTP(sanitizedEmail);

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    if (user.email_verified) {
      return res.status(400).json({ error: 'Email is already verified' });
    }

    // Check rate limiting
    const { canSend, remainingSeconds } = OTPService.canRequestNewOTP(
      user.otp_last_sent_at,
      60 // 60-second cooldown
    );

    if (!canSend) {
      return res.status(429).json({ 
        error: `Please wait ${remainingSeconds} seconds before requesting a new code`,
        remainingSeconds
      });
    }

    // Check maximum attempts
    const maxAttempts = parseInt(process.env.OTP_MAX_RESEND_ATTEMPTS) || 3;
    if (user.otp_attempts >= maxAttempts) {
      return res.status(429).json({ 
        error: 'Maximum OTP requests exceeded. Please contact support.',
        maxAttemptsReached: true
      });
    }

    // Generate new OTP
    const { otp, hashedOTP, expiresAt } = OTPService.generateOTPWithMetadata(10);

    // Update user with new OTP
    await User.updateOTP(user.id, hashedOTP, expiresAt);

    // Send OTP email
    await EmailService.sendOTPEmail(sanitizedEmail, otp, user.name);

    res.json({
      message: 'Verification code sent to your email',
      email: OTPService.maskEmail(sanitizedEmail),
      expiresAt: expiresAt.toISOString(),
      attemptsRemaining: maxAttempts - (user.otp_attempts + 1)
    });

  } catch (error) {
    console.error('Send OTP error:', error);
    res.status(500).json({ error: 'Failed to send verification code' });
  }
});

/**
 * VERIFY OTP - Verify user's email with OTP
 * POST /api/auth/verify-otp
 */
router.post('/verify-otp', async (req, res) => {
  try {
    const { email, otp } = req.body;

    if (!email || !otp) {
      return res.status(400).json({ error: 'Email and OTP are required' });
    }

    // Validate OTP format
    const formatValidation = OTPService.validateOTPFormat(otp);
    if (!formatValidation.valid) {
      return res.status(400).json({ error: formatValidation.error });
    }

    const sanitizedEmail = OTPService.sanitizeEmail(email);
    const user = await User.findByEmail(sanitizedEmail);

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    if (user.email_verified) {
      return res.status(400).json({ 
        error: 'Email is already verified',
        emailVerified: true
      });
    }

    if (!user.otp_code) {
      return res.status(400).json({ 
        error: 'No verification code found. Please request a new one.' 
      });
    }

    // Check if OTP expired
    if (OTPService.isOTPExpired(user.otp_expires_at)) {
      return res.status(400).json({ 
        error: 'Verification code has expired. Please request a new one.',
        expired: true
      });
    }

    // Verify OTP
    const isValid = OTPService.verifyOTP(otp, user.otp_code);

    if (!isValid) {
      return res.status(400).json({ 
        error: 'Invalid verification code. Please try again.' 
      });
    }

    // Mark email as verified and clear OTP
    await User.verifyEmail(user.id);

    // Send welcome email (optional, non-blocking)
    EmailService.sendWelcomeEmail(sanitizedEmail, user.name).catch(err => {
      console.error('Failed to send welcome email:', err);
    });

    // Generate auth token
    const token = generateToken(user.id, user.email);

    // Get updated user data
    const verifiedUser = await User.findById(user.id);

    res.json({
      message: 'Email verified successfully!',
      token,
      user: formatUserResponse(verifiedUser)
    });

  } catch (error) {
    console.error('Verify OTP error:', error);
    res.status(500).json({ error: 'Failed to verify code' });
  }
});

/**
 * RESEND OTP - Resend verification code
 * POST /api/auth/resend-otp
 */
router.post('/resend-otp', async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ error: 'Email is required' });
    }

    const sanitizedEmail = OTPService.sanitizeEmail(email);
    const user = await User.findByEmail(sanitizedEmail);

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    if (user.email_verified) {
      return res.status(400).json({ error: 'Email is already verified' });
    }

    // Check rate limiting
    const { canSend, remainingSeconds } = OTPService.canRequestNewOTP(
      user.otp_last_sent_at,
      60
    );

    if (!canSend) {
      return res.status(429).json({ 
        error: `Please wait ${remainingSeconds} seconds before requesting a new code`,
        remainingSeconds
      });
    }

    // Check maximum attempts
    const maxAttempts = parseInt(process.env.OTP_MAX_RESEND_ATTEMPTS) || 3;
    if (user.otp_attempts >= maxAttempts) {
      return res.status(429).json({ 
        error: 'Maximum OTP requests exceeded. Please try again later or contact support.',
        maxAttemptsReached: true
      });
    }

    // Generate new OTP
    const { otp, hashedOTP, expiresAt } = OTPService.generateOTPWithMetadata(10);

    // Update user
    await User.updateOTP(user.id, hashedOTP, expiresAt);

    // Send email
    await EmailService.sendOTPEmail(sanitizedEmail, otp, user.name);

    res.json({
      message: 'New verification code sent to your email',
      email: OTPService.maskEmail(sanitizedEmail),
      expiresAt: expiresAt.toISOString(),
      attemptsRemaining: maxAttempts - (user.otp_attempts + 1)
    });

  } catch (error) {
    console.error('Resend OTP error:', error);
    res.status(500).json({ error: 'Failed to resend verification code' });
  }
});

/**
 * CHECK EMAIL VERIFICATION STATUS
 * GET /api/auth/verification-status/:email
 */
router.get('/verification-status/:email', async (req, res) => {
  try {
    const { email } = req.params;
    const sanitizedEmail = OTPService.sanitizeEmail(email);
    
    const user = await User.findByEmail(sanitizedEmail);

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    const response = {
      emailVerified: user.email_verified,
      email: OTPService.maskEmail(sanitizedEmail)
    };

    // If not verified, include OTP status
    if (!user.email_verified && user.otp_expires_at) {
      response.otpExpired = OTPService.isOTPExpired(user.otp_expires_at);
      response.timeRemaining = OTPService.formatTimeRemaining(user.otp_expires_at);
    }

    res.json(response);

  } catch (error) {
    console.error('Check verification status error:', error);
    res.status(500).json({ error: 'Failed to check verification status' });
  }
});

// UPDATED: Profile picture upload endpoint with better URL handling
router.post('/profile/picture', auth, upload.single('picture'), async (req, res) => {
  try {
    console.log('📸 Profile picture upload request received');
    console.log('📸 User ID:', req.userId);
    console.log('📸 File:', req.file);

    if (!req.file) {
      return res.status(400).json({ error: 'No image file provided' });
    }

    // Read file buffer from temporary upload
    const fileBuffer = await fs.readFile(req.file.path);
    
    console.log('📤 Uploading to Supabase Storage...');

    // Upload to Supabase Storage (permanent cloud storage)
    const publicUrl = await supabaseStorage.uploadProfilePicture(
      req.userId,
      fileBuffer,
      req.file.originalname,
      req.file.mimetype
    );

    // Delete temporary file from Render's ephemeral storage
    await fs.unlink(req.file.path).catch(err => {
      console.error('⚠️ Failed to delete temp file:', err);
    });

    console.log('💾 Updating database with Supabase URL...');

    // Update user's profile picture in database with Supabase URL
    const user = await User.update(req.userId, {
      profile_picture: publicUrl  // Store Supabase URL
    });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    console.log('✅ Profile picture updated successfully');
    console.log('✅ Supabase URL:', publicUrl);

    // Return response
    res.status(200).json({
      success: true,
      message: 'Profile picture uploaded successfully',
      photoUrl: publicUrl,  // Full Supabase URL
      user: formatUserResponse(user)
    });

  } catch (error) {
    console.error('❌ Error uploading profile picture:', error);
    
    // Clean up temporary file on error
    if (req.file && req.file.path) {
      await fs.unlink(req.file.path).catch(err => {
        console.error('⚠️ Failed to delete temp file on error:', err);
      });
    }

    res.status(500).json({ 
      error: 'Failed to upload profile picture',
      details: error.message 
    });
  }
});

// UPDATED: Google sign-in with proper profile picture handling
router.post('/google/mobile', async (req, res) => {
  try {
    const { email, name, photoUrl, googleId } = req.body;

    if (!email || !googleId) {
      return res.status(400).json({ error: 'Email and Google ID are required' });
    }

    let user = await User.findByGoogleId(googleId);

    if (user) {
      await User.updateLastLogin(user.id);
      
      // Update profile picture if it's a Google photo URL
      if (photoUrl && photoUrl.startsWith('http')) {
        await User.update(user.id, { profile_picture: photoUrl });
        user.profile_picture = photoUrl;
      }
    } else {
      user = await User.findByEmail(email.toLowerCase());

      if (user) {
        user = await User.linkGoogleAccount(user.id, googleId, photoUrl);
        await User.updateLastLogin(user.id);
      } else {
        user = await User.create({
          googleId,
          email: email.toLowerCase(),
          name,
          profile_picture: photoUrl,
          accountType: 'google'
        });
      }
    }

    const token = generateToken(user.id, user.email);

    res.json({
      message: 'Google sign-in successful',
      token,
      user: formatUserResponse(user) // ✅ UPDATED: Using formatUserResponse
    });

  } catch (error) {
    console.error('Google mobile sign-in error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Profile update endpoint
router.put('/profile', auth, async (req, res) => {
  try {
    const { name, dateOfBirth, preferences } = req.body;

    const updates = {};
    if (name) updates.name = name;
    if (dateOfBirth) updates.date_of_birth = dateOfBirth;
    if (preferences) updates.preferences = preferences;

    const user = await User.update(req.userId, updates);

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({
      message: 'Profile updated successfully',
      user: formatUserResponse(user) // ✅ UPDATED: Using formatUserResponse
    });
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Google OAuth Strategy
passport.use(new GoogleStrategy({
  clientID: process.env.GOOGLE_CLIENT_ID,
  clientSecret: process.env.GOOGLE_CLIENT_SECRET,
  callbackURL: process.env.GOOGLE_CALLBACK_URL
},
  async (accessToken, refreshToken, profile, done) => {
    try {
      let user = await User.findByGoogleId(profile.id);

      if (user) {
        await User.updateLastLogin(user.id);
        return done(null, user);
      }

      user = await User.findByEmail(profile.emails[0].value);

      if (user) {
        user = await User.linkGoogleAccount(
          user.id,
          profile.id,
          profile.photos[0]?.value
        );
        await User.updateLastLogin(user.id);
        return done(null, user);
      }

      user = await User.create({
        googleId: profile.id,
        email: profile.emails[0].value,
        name: profile.displayName,
        profile_picture: profile.photos[0]?.value,
        accountType: 'google'
      });

      done(null, user);

    } catch (error) {
      done(error, null);
    }
  }
));

// Google OAuth endpoints
router.get('/google',
  passport.authenticate('google', {
    scope: ['profile', 'email'],
    session: false
  })
);

router.get('/google/callback',
  passport.authenticate('google', {
    session: false,
    failureRedirect: `${process.env.FRONTEND_URL}/login?error=google_auth_failed`
  }),
  (req, res) => {
    try {
      const token = generateToken(req.user.id, req.user.email);
      res.redirect(`${process.env.FRONTEND_URL}/auth-success?token=${token}`);
    } catch (error) {
      console.error('Google callback error:', error);
      res.redirect(`${process.env.FRONTEND_URL}/login?error=token_generation_failed`);
    }
  }
);

// Stats endpoint
router.get('/stats', auth, async (req, res) => {
  try {
    const stats = await User.getStats(req.userId);
    res.json({ stats });
  } catch (error) {
    console.error('Get stats error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Logout endpoint
router.post('/logout', auth, async (req, res) => {
  try {
    res.json({ message: 'Logged out successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Endpoints documentation
router.get('/', (req, res) => {
  res.json({
    service: 'Authentication API',
    endpoints: {
      signup: { method: 'POST', path: '/api/auth/signup', description: 'Create new account with email/password' },
      login: { method: 'POST', path: '/api/auth/login', description: 'Login with email/password' },
      google: { method: 'GET', path: '/api/auth/google', description: 'Start Google OAuth flow' },
      google_callback: { method: 'GET', path: '/api/auth/google/callback', description: 'Google OAuth callback' },
      google_mobile: { method: 'POST', path: '/api/auth/google/mobile', description: 'Mobile Google authentication' },
      me: { method: 'GET', path: '/api/auth/me', description: 'Get current user profile', auth: true },
      profile: { method: 'PUT', path: '/api/auth/profile', description: 'Update user profile', auth: true },
      profile_picture: { method: 'POST', path: '/api/auth/profile/picture', description: 'Upload profile picture', auth: true },
      stats: { method: 'GET', path: '/api/auth/stats', description: 'Get user statistics', auth: true },
      logout: { method: 'POST', path: '/api/auth/logout', description: 'Logout user', auth: true }
    }
  });
});


module.exports = router;