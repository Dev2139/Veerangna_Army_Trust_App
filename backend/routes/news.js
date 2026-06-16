const express = require('express');
const router = express.Router();
const News = require('../models/News');
const multer = require('multer');
const cloudinary = require('cloudinary').v2;

const storage = multer.memoryStorage();
const upload = multer({ storage });

// Get all news (public)
router.get('/', async (req, res) => {
  try {
    const news = await News.find().sort({ createdAt: -1 });
    res.json(news);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Create news (admin only)
router.post('/', upload.single('image'), async (req, res) => {
  try {
    let mediaUrl = req.body.mediaUrl;
    
    if (req.file) {
      const uploadPromise = new Promise((resolve, reject) => {
        const stream = cloudinary.uploader.upload_stream(
          { folder: 'army_news' },
          (error, result) => {
            if (error) reject(error);
            else resolve(result);
          }
        );
        stream.end(req.file.buffer);
      });
      const result = await uploadPromise;
      mediaUrl = result.secure_url;
    }

    const newsData = {
      title: req.body.title,
      content: req.body.content,
      type: req.body.type,
      mediaUrl: mediaUrl
    };

    const news = new News(newsData);
    await news.save();
    res.status(201).json(news);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Like a post
router.post('/:id/like', async (req, res) => {
  try {
    const news = await News.findByIdAndUpdate(req.params.id, { $inc: { likesCount: 1 } }, { new: true });
    res.json(news);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
