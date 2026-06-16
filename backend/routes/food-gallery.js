const express = require('express');
const router = express.Router();
const FoodGallery = require('../models/FoodGallery');
const multer = require('multer');
const cloudinary = require('cloudinary').v2;

const storage = multer.memoryStorage();
const upload = multer({ storage });

// Get all food gallery images
router.get('/', async (req, res) => {
  try {
    const images = await FoodGallery.find().sort({ createdAt: -1 });
    res.json(images);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Upload new image to food gallery
router.post('/', upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'Image file is required' });
    }

    const uploadPromise = new Promise((resolve, reject) => {
      const stream = cloudinary.uploader.upload_stream(
        { folder: 'army_food_gallery' },
        (error, result) => {
          if (error) reject(error);
          else resolve(result);
        }
      );
      stream.end(req.file.buffer);
    });
    
    const result = await uploadPromise;

    const galleryItem = new FoodGallery({
      imageUrl: result.secure_url,
      caption: req.body.caption || ''
    });

    await galleryItem.save();
    res.status(201).json(galleryItem);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
