// File: backend/routes/auth.js
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
      stats: { method: 'GET', path: '/api/auth/stats', description: 'Get user statistics', auth: true },
      logout: { method: 'POST', path: '/api/auth/logout', description: 'Logout user', auth: true }
    }
  });
});

const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const passport = require('passport');
const GoogleStrategy = require('passport-google-oauth20').Strategy;
const User = require('../models/User');
const auth = require('../middleware/auth');

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