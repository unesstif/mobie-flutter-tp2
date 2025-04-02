const express = require('express');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { body, validationResult } = require('express-validator');
const db = require('../database');

const router = express.Router();
const JWT_SECRET = 'your-secret-key'; // In production, use environment variable

const validateLogin = [
  body('email').isEmail().withMessage('Please enter a valid email'),
  body('password').notEmpty().withMessage('Password is required')
];

// Login route
router.post('/login', validateLogin, async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { email, password } = req.body;

  // For demo purposes, we'll use a hardcoded user
  if (email === 'admin@example.com' && password === 'admin123') {
    const token = jwt.sign(
      { userId: 1, email: email },
      JWT_SECRET,
      { expiresIn: '24h' }
    );
    return res.json({ token });
  }

  return res.status(401).json({ error: 'Invalid email or password' });
});

// Logout route
router.post('/logout', (req, res) => {
  res.json({ message: 'Logged out successfully' });
});

module.exports = router; 