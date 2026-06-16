const express = require('express');
const router = express.Router();
const User = require('../models/User');
const Campaign = require('../models/Campaign');
const Donation = require('../models/Donation');

router.get('/stats', async (req, res) => {
  try {
    // Basic stats
    const totalUsers = await User.countDocuments({ role: 'user' });
    const activeCampaigns = await Campaign.countDocuments({ status: 'active' });
    
    // Calculate total donations amount (sum of all successful donations)
    const donations = await Donation.find({ status: 'success' });
    const totalDonations = donations.reduce((sum, d) => sum + d.amount, 0);

    // Get recent donations
    const recentDonations = await Donation.find()
      .sort({ createdAt: -1 })
      .limit(5)
      .populate('user', 'name')
      .populate('campaign', 'title');

    // Get campaign progress
    const campaignsProgress = await Campaign.find({ status: 'active' }).limit(5);

    res.json({
      stats: {
        totalDonations,
        activeCampaigns,
        totalBeneficiaries: 850, // Static for now as per design, or compute if logic exists
        totalUsers
      },
      recentDonations,
      campaignsProgress
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
