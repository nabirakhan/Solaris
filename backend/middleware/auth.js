const jwt = require("jsonwebtoken");

module.exports = function (req, res, next) {
  // Get token from header
  const authHeader = req.header("Authorization");

  // Check if no token
  if (!authHeader) {
    return res.status(401).json({ 
      error: 'Access denied',
      message: "No authentication token provided" 
    });
  }

  try {
    // Extract token (format: "Bearer TOKEN")
    const token = authHeader.replace("Bearer ", "");
    
    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Add user ID to request
    req.userId = decoded.userId;
    
    next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({ 
        error: 'Token expired',
        message: "Your session has expired. Please login again." 
      });
    }
    
    res.status(401).json({ 
      error: 'Invalid token',
      message: "Authentication token is not valid" 
    });
  }
};