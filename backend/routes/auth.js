// File: backend/routes/auth.js

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

// Configure multer for profile picture uploads
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
    console.log('📸 MULTER: File upload attempt');
    console.log('📸 File details:', {
      originalname: file.originalname,
      mimetype: file.mimetype,
      fieldname: file.fieldname
    });

    // Accept files that are images OR have image extensions
    const isImageMimeType = file.mimetype && file.mimetype.startsWith('image/');
    const hasImageExtension = /\.(jpe?g|png|gif|webp)$/i.test(file.originalname);
    
    console.log('📸 isImageMimeType:', isImageMimeType);
    console.log('📸 hasImageExtension:', hasImageExtension);

    if (isImageMimeType || hasImageExtension) {
      console.log('✅ Accepting file');
      return cb(null, true);
    } else {
      console.log('❌ Rejecting file');
      cb(new Error('Only image files are allowed!'));
    }
  }
});

// Add this after the imports, before other routes
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

passport.use(new GoogleStrategy({
  clientID: process.env.GOOGLE_CLIENT_ID,
  clientSecret: process.env.GOOGLE_CLIENT_SECRET,
  callbackURL: process.env.GOOGLE_CALLBACK_URL
},
  async (accessToken, refreshToken, profile, done) => {
    try {
      // Check if user already exists with Google ID
      let user = await User.findByGoogleId(profile.id);

      if (user) {
        await User.updateLastLogin(user.id);
        return done(null, user);
      }

      // Check if user exists with same email
      user = await User.findByEmail(profile.emails[0].value);

      if (user) {
        // Link Google account to existing user
        user = await User.linkGoogleAccount(
          user.id,
          profile.id,
          profile.photos[0]?.value
        );
        await User.updateLastLogin(user.id);
        return done(null, user);
      }

      // Create new user
      user = await User.create({
        googleId: profile.id,
        email: profile.emails[0].value,
        name: profile.displayName,
        profilePicture: profile.photos[0]?.value,
        accountType: 'google'
      });

      done(null, user);

    } catch (error) {
      done(error, null);
    }
  }
));

const generateToken = (userId) => {
  return jwt.sign(
    { userId },
    process.env.JWT_SECRET,
    { expiresIn: '30d' }
  );
};

const formatUserResponse = (user) => {
  return {
    id: user.id,
    email: user.email,
    name: user.name,
    photoUrl: user.profile_picture, // ✅ Changed from profilePicture to photoUrl for consistency with frontend
    profilePicture: user.profile_picture,
    accountType: user.account_type,
    dateOfBirth: user.date_of_birth,
    preferences: user.preferences
  };
};

router.post('/signup', async (req, res) => {
  try {
    const { email, password, name, dateOfBirth } = req.body;

    if (!email || !password || !name) {
      return res.status(400).json({ error: 'Please provide all required fields' });
    }

    if (password.length < 6) {
      return res.status(400).json({ error: 'Password must be at least 6 characters' });
    }

    const existingUser = await User.findByEmail(email);
    if (existingUser) {
      return res.status(400).json({ error: 'Email already registered' });
    }

    const user = await User.create({
      email,
      password,
      name,
      dateOfBirth,
      accountType: 'email'
    });

    const token = generateToken(user.id);

    res.status(201).json({
      message: 'User created successfully',
      token,
      user: formatUserResponse(user)
    });
  } catch (error) {
    console.error('Signup error:', error);
    res.status(500).json({ error: error.message });
  }
});

router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validation
    if (!email || !password) {
      return res.status(400).json({ error: 'Please provide email and password' });
    }

    const user = await User.findByEmail(email);
    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Check if user signed up with Google
    if (user.account_type === 'google' && !user.password) {
      return res.status(401).json({
        error: 'This account uses Google Sign-In. Please login with Google.'
      });
    }

    const isMatch = await User.comparePassword(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    await User.updateLastLogin(user.id);

    const token = generateToken(user.id);

    res.json({
      message: 'Login successful',
      token,
      user: formatUserResponse(user)
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: error.message });
  }
});

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
      // Generate JWT token
      const token = generateToken(req.user.id);

      // Redirect to frontend with token
      res.redirect(`${process.env.FRONTEND_URL}/auth-success?token=${token}`);
    } catch (error) {
      console.error('Google callback error:', error);
      res.redirect(`${process.env.FRONTEND_URL}/login?error=token_generation_failed`);
    }
  }
);

router.post('/google/mobile', async (req, res) => {
  try {
    const { email, name, photoUrl, googleId } = req.body;

    if (!email || !name) {
      return res.status(400).json({ error: 'Invalid Google authentication data' });
    }

    // Check if user exists with Google ID
    let user = await User.findByGoogleId(googleId);

    if (!user) {
      // Check if user exists with email
      user = await User.findByEmail(email);

      if (user) {
        // Link Google account
        user = await User.linkGoogleAccount(user.id, googleId, photoUrl);
      } else {
        // Create new user
        user = await User.create({
          email,
          name,
          googleId,
          profilePicture: photoUrl,
          accountType: 'google'
        });
      }
    }

    await User.updateLastLogin(user.id);

    const token = generateToken(user.id);

    res.json({
      message: 'Google authentication successful',
      token,
      user: formatUserResponse(user)
    });

  } catch (error) {
    console.error('Mobile Google auth error:', error);
    res.status(500).json({ error: error.message });
  }
});

router.get('/me', auth, async (req, res) => {
  try {
    const user = await User.findById(req.userId);

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({ user: formatUserResponse(user) });
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({ error: error.message });
  }
});

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
      user: formatUserResponse(user)
    });
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({ error: error.message });
  }
});

// ✅ NEW: Profile picture upload endpoint
router.post('/profile/picture', auth, upload.single('picture'), async (req, res) => {
  try {
    console.log('📸 Profile picture upload request received');
    console.log('📸 User ID:', req.userId);
    console.log('📸 File:', req.file);

    if (!req.file) {
      return res.status(400).json({ error: 'No image file provided' });
    }

    // Get the relative URL for the uploaded file
    const imageUrl = `/uploads/profiles/${req.file.filename}`;
    
    console.log('📸 Image URL:', imageUrl);

    // Update user's profile picture in database
    const user = await User.update(req.userId, {
      profile_picture: imageUrl
    });

    if (!user) {
      // Clean up uploaded file if user not found
      await fs.unlink(req.file.path).catch(console.error);
      return res.status(404).json({ error: 'User not found' });
    }

    console.log('✅ Profile picture updated successfully');

    res.status(200).json({
      message: 'Profile picture uploaded successfully',
      photoUrl: imageUrl,
      user: formatUserResponse(user)
    });

  } catch (error) {
    console.error('❌ Profile picture upload error:', error);
    
    // Clean up uploaded file on error
    if (req.file) {
      await fs.unlink(req.file.path).catch(console.error);
    }

    res.status(500).json({ error: error.message });
  }
});

router.get('/stats', auth, async (req, res) => {
  try {
    const stats = await User.getStats(req.userId);
    res.json({ stats });
  } catch (error) {
    console.error('Get stats error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Logout (JWT is stateless, but included for completeness)
router.post('/logout', auth, async (req, res) => {
  try {
    res.json({ message: 'Logged out successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;