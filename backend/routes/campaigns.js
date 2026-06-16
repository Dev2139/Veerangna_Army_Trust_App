const express = require('express');
const router = express.Router();
const Campaign = require('../models/Campaign');
const multer = require('multer');
const cloudinary = require('cloudinary').v2;

// Cloudinary config
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET
});

// Multer memory storage
const storage = multer.memoryStorage();
const upload = multer({ storage });

// Get all campaigns
router.get('/', async (req, res) => {
  try {
    const campaigns = await Campaign.find().sort({ createdAt: -1 });
    res.json(campaigns);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Create campaign (admin)
router.post('/', upload.single('image'), async (req, res) => {
  try {
    let images = [];
    
    if (req.file) {
      // Upload to Cloudinary using stream
      const uploadPromise = new Promise((resolve, reject) => {
        const stream = cloudinary.uploader.upload_stream(
          { folder: 'army_campaigns' },
          (error, result) => {
            if (error) reject(error);
            else resolve(result);
          }
        );
        stream.end(req.file.buffer);
      });
      
      const result = await uploadPromise;
      images.push(result.secure_url);
    } else if (req.body.imageUrl) {
      // Fallback if URL is provided directly instead of file
      images.push(req.body.imageUrl);
    }

    const campaignData = {
      title: req.body.title,
      description: req.body.description,
      amountRequired: req.body.amountRequired,
      images: images
    };

    const campaign = new Campaign(campaignData);
    await campaign.save();
    res.status(201).json(campaign);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Delete campaign (admin)
router.delete('/:id', async (req, res) => {
  try {
    await Campaign.findByIdAndDelete(req.params.id);
    res.json({ message: 'Campaign deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
