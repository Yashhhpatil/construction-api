// server.js
// This is the main entry point of the application
// It sets up Express, connects to DB, registers routes, and starts the server

const express = require('express');
const cors = require('cors');
require('dotenv').config(); // Load environment variables from .env file

const sequelize = require('./config/database');
require('./models/index'); // Import all models (registers associations)

// Import routes
const authRoutes = require('./routes/authRoutes');
const projectRoutes = require('./routes/projectRoutes');
const dprRoutes = require('./routes/dprRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

// ─── MIDDLEWARE SETUP ────────────────────────────────────────────────────────
// Middleware runs on every request before it reaches any route

app.use(cors()); // Allow cross-origin requests (needed for frontend to call this API)
app.use(express.json()); // Parse JSON request bodies (req.body will be populated)
app.use(express.urlencoded({ extended: true })); // Parse URL-encoded form data

// ─── ROUTES ─────────────────────────────────────────────────────────────────
// Mount routers at specific URL prefixes
app.use('/auth', authRoutes);
app.use('/projects', projectRoutes);
// Nested routes: /projects/:id/dpr goes to dprRoutes
// mergeParams in dprRoutes allows access to :id from parent route
app.use('/projects/:id/dpr', dprRoutes);

// ─── HEALTH CHECK ────────────────────────────────────────────────────────────
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'Construction Management API is running!',
    version: '1.0.0',
    endpoints: {
      auth: [
        'POST /auth/register',
        'POST /auth/login',
        'GET  /auth/me'
      ],
      projects: [
        'POST   /projects',
        'GET    /projects',
        'GET    /projects/:id',
        'PUT    /projects/:id',
        'DELETE /projects/:id'
      ],
      dpr: [
        'POST /projects/:id/dpr',
        'GET  /projects/:id/dpr'
      ]
    }
  });
});

// ─── 404 HANDLER ─────────────────────────────────────────────────────────────
// Catches any request to a route that doesn't exist
app.use((req, res) => {
  res.status(404).json({ success: false, message: `Route ${req.method} ${req.url} not found` });
});

// ─── GLOBAL ERROR HANDLER ────────────────────────────────────────────────────
// Catches any unhandled errors thrown in route handlers
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ success: false, message: 'Internal server error' });
});

// ─── DATABASE SYNC & SERVER START ────────────────────────────────────────────
const startServer = async () => {
  try {
    // Test database connection
    await sequelize.authenticate();
    console.log('✅ Database connected successfully');

    // sync({ alter: true }) updates table structure if models changed
    // sync({ force: true }) DROPS and recreates all tables (use only in development)
    await sequelize.sync({ alter: true });
    console.log('✅ Database tables synced');

    app.listen(PORT, () => {
      console.log(`🚀 Server running on http://localhost:${PORT}`);
      console.log(`📋 Environment: ${process.env.NODE_ENV || 'development'}`);
    });

  } catch (error) {
    console.error('❌ Failed to start server:', error.message);
    process.exit(1); // Exit with error code
  }
};

startServer();
