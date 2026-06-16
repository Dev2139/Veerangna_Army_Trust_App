const express = require('express');
const router = express.Router();
const User = require('../models/User');
const Donation = require('../models/Donation');
const authMiddleware = require('../middleware/auth');

// Get current user profile
router.get('/profile', authMiddleware, async (req, res) => {
  try {
    const user = await User.findById(req.user.id).populate('savedCampaigns').populate('eventParticipation').lean();
    if (!user) return res.status(404).json({ error: 'User not found' });
    
    // Fetch donations
    const donations = await Donation.find({ user: req.user.id })
      .populate('campaign', 'title')
      .sort({ createdAt: -1 });
      
    const totalDonated = donations.reduce((sum, d) => sum + d.amount, 0);
    
    user.donationHistory = donations;
    user.totalDonated = totalDonated;
    
    res.json(user);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update profile
router.put('/profile', authMiddleware, async (req, res) => {
  try {
    const { name, phone, profilePhotoUrl } = req.body;
    const user = await User.findByIdAndUpdate(
      req.user.id,
      { name, phone, profilePhotoUrl },
      { new: true }
    );
    res.json(user);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get user donations
router.get('/donations', authMiddleware, async (req, res) => {
  try {
    const donations = await Donation.find({ user: req.user.id })
      .populate('campaign', 'title images')
      .sort({ createdAt: -1 });
    res.json(donations);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
