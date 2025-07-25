const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const admin = require('./firebase-admin');
const redisService = require('./redis-service');

const app = express();
const PORT = process.env.PORT || 8000;

// Middleware
app.use(helmet());
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:3000',
  credentials: true
}));
app.use(express.json());

// Firebase Admin is initialized in firebase-admin.js
console.log('Firebase Admin SDK initialized');

// Middleware to verify Firebase token
const authenticateToken = async (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    req.user = decodedToken;
    next();
  } catch (error) {
    console.error('Error verifying token:', error);
    return res.status(403).json({ error: 'Invalid token' });
  }
};

// Health check endpoint with Redis status
app.get('/health', async (req, res) => {
  const redisHealth = await redisService.healthCheck();
  
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    service: 'backend-api',
    redis: redisHealth
  });
});

// Public endpoint
app.get('/', (req, res) => {
  res.json({ 
    message: 'Backend API is running!',
    timestamp: new Date().toISOString()
  });
});

// Protected endpoint that requires authentication with Redis caching
app.get('/api/data', authenticateToken, async (req, res) => {
  const cacheKey = `user_data:${req.user.uid}`;
  
  try {
    // Try to get data from cache first
    const cachedData = await redisService.get(cacheKey);
    if (cachedData) {
      console.log('📦 Serving from cache');
      return res.json({
        ...cachedData,
        cached: true
      });
    }

    // If not in cache, generate data
    const data = {
      message: 'Hello from the backend!',
      timestamp: new Date().toISOString(),
      userId: req.user.uid,
      userEmail: req.user.email,
      authenticated: true
    };

    // Cache the data for 5 minutes
    await redisService.set(cacheKey, data, 300);
    console.log('💾 Data cached');

    res.json({
      ...data,
      cached: false
    });
  } catch (error) {
    console.error('Error in /api/data:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// User profile endpoint with Redis caching
app.get('/api/profile', authenticateToken, async (req, res) => {
  const cacheKey = `user_profile:${req.user.uid}`;
  
  try {
    // Try to get profile from cache first
    const cachedProfile = await redisService.get(cacheKey);
    if (cachedProfile) {
      console.log('📦 Serving profile from cache');
      return res.json({
        ...cachedProfile,
        cached: true
      });
    }

    // If not in cache, generate profile
    const profile = {
      uid: req.user.uid,
      email: req.user.email,
      emailVerified: req.user.email_verified,
      name: req.user.name || 'Not provided',
      picture: req.user.picture || null
    };

    // Cache the profile for 1 hour
    await redisService.set(cacheKey, profile, 3600);
    console.log('💾 Profile cached');

    res.json({
      ...profile,
      cached: false
    });
  } catch (error) {
    console.error('Error in /api/profile:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Cache management endpoints (admin only)
app.post('/api/cache/flush', authenticateToken, async (req, res) => {
  try {
    const { pattern } = req.body;
    const success = await redisService.flush(pattern || '*');
    
    if (success) {
      res.json({ 
        message: `Cache flushed successfully${pattern ? ` for pattern: ${pattern}` : ''}`,
        pattern: pattern || '*'
      });
    } else {
      res.status(500).json({ error: 'Failed to flush cache' });
    }
  } catch (error) {
    console.error('Error flushing cache:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.delete('/api/cache/user/:userId', authenticateToken, async (req, res) => {
  try {
    const { userId } = req.params;
    const userDataKey = `user_data:${userId}`;
    const userProfileKey = `user_profile:${userId}`;
    
    await redisService.del(userDataKey);
    await redisService.del(userProfileKey);
    
    res.json({ 
      message: `Cache cleared for user: ${userId}`,
      clearedKeys: [userDataKey, userProfileKey]
    });
  } catch (error) {
    console.error('Error clearing user cache:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ error: 'Endpoint not found' });
});

// Initialize Redis connection
async function initializeServices() {
  try {
    await redisService.connect();
  } catch (error) {
    console.log('⚠️ Redis connection failed, continuing without cache');
  }
}

// Start server
app.listen(PORT, async () => {
  console.log(`🚀 Backend server running on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
  await initializeServices();
}); 