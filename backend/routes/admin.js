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

// GET /api/admin/users - Get all users with donation stats
router.get('/users', async (req, res) => {
  try {
    const users = await User.find().select('-password').sort({ createdAt: -1 }).lean();
    
    const userIds = users.map(u => u._id);
    const donations = await Donation.find({ user: { $in: userIds }, status: 'success' });
    
    const statsMap = {};
    donations.forEach(d => {
      if (!d.user) return;
      const uid = d.user.toString();
      if (!statsMap[uid]) {
        statsMap[uid] = { count: 0, total: 0 };
      }
      statsMap[uid].count += 1;
      statsMap[uid].total += d.amount;
    });

    const usersWithStats = users.map(user => ({
      ...user,
      donationCount: statsMap[user._id.toString()]?.count || 0,
      totalDonated: statsMap[user._id.toString()]?.total || 0,
    })).sort((a, b) => b.totalDonated - a.totalDonated || b.donationCount - a.donationCount);

    res.json(usersWithStats);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// DELETE /api/admin/users/:id - Delete user
router.delete('/users/:id', async (req, res) => {
  try {
    await User.findByIdAndDelete(req.params.id);
    res.json({ success: true, message: 'User deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
