const express = require('express');
const router = express.Router();
const Donation = require('../models/Donation');
const authMiddleware = require('../middleware/auth');

// Get all donations (Admin)
router.get('/', async (req, res) => {
  try {
    const donations = await Donation.find()
      .populate('user', 'name email phone')
      .populate('campaign', 'title')
      .sort({ createdAt: -1 });
      
    res.json(donations);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
