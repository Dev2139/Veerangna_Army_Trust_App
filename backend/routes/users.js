const express = require('express');
const router = express.Router();
const User = require('../models/User');
const Donation = require('../models/Donation');
const authMiddleware = require('../middleware/auth');
const multer = require('multer');
const cloudinary = require('cloudinary').v2;

// Cloudinary config
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET
});

const storage = multer.memoryStorage();
const upload = multer({ storage });

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
    const { name, phone, profilePhotoUrl, billingInfo } = req.body;
    const updateFields = {};
    if (name !== undefined) updateFields.name = name;
    if (phone !== undefined) updateFields.phone = phone;
    if (profilePhotoUrl !== undefined) updateFields.profilePhotoUrl = profilePhotoUrl;
    if (billingInfo !== undefined) updateFields.billingInfo = billingInfo;

    const user = await User.findByIdAndUpdate(
      req.user.id,
      { $set: updateFields },
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

// Upload profile photo
router.post('/upload-photo', authMiddleware, upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'Image file is required' });
    }

    const uploadPromise = new Promise((resolve, reject) => {
      const stream = cloudinary.uploader.upload_stream(
        { folder: 'user_profiles' },
        (error, result) => {
          if (error) reject(error);
          else resolve(result);
        }
      );
      stream.end(req.file.buffer);
    });
    
    const result = await uploadPromise;

    const user = await User.findByIdAndUpdate(
      req.user.id,
      { profilePhotoUrl: result.secure_url },
      { new: true }
    );

    res.json(user);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
