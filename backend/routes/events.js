const express = require('express');
const router = express.Router();
const Event = require('../models/Event');
const authMiddleware = require('../middleware/auth');
const User = require('../models/User');
const multer = require('multer');
const cloudinary = require('cloudinary').v2;

const storage = multer.memoryStorage();
const upload = multer({ storage });

// Get all events
router.get('/', async (req, res) => {
  try {
    const events = await Event.find().sort({ date: 1 });
    res.json(events);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Create event (admin)
router.post('/', upload.single('image'), async (req, res) => {
  try {
    let banners = [];
    
    if (req.file) {
      const uploadPromise = new Promise((resolve, reject) => {
        const stream = cloudinary.uploader.upload_stream(
          { folder: 'army_events' },
          (error, result) => {
            if (error) reject(error);
            else resolve(result);
          }
        );
        stream.end(req.file.buffer);
      });
      const result = await uploadPromise;
      banners.push(result.secure_url);
    }

    const eventData = {
      title: req.body.title,
      description: req.body.description,
      date: req.body.date,
      location: req.body.location,
      banners: banners
    };

    const event = new Event(eventData);
    await event.save();
    res.status(201).json(event);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Register for event
router.post('/:id/register', authMiddleware, async (req, res) => {
  try {
    const eventId = req.params.id;
    const userId = req.user.id;
    const { name, phone, attendees } = req.body;

    // Create registration object
    const registrationData = {
      user: userId,
      name: name || 'Unknown',
      phone: phone || '',
      attendees: attendees || 1
    };

    // Add registration to event
    await Event.findByIdAndUpdate(eventId, { 
      $push: { registrations: registrationData } 
    });
    
    // Add event to user
    await User.findByIdAndUpdate(userId, { $addToSet: { eventParticipation: eventId } });

    res.json({ success: true, message: 'Successfully registered for the event' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
