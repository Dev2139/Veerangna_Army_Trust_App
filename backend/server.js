const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
const authRoutes = require('./routes/auth');
const campaignsRoutes = require('./routes/campaigns');
const donationsRoutes = require('./routes/donations');
const usersRoutes = require('./routes/users');
const newsRoutes = require('./routes/news');
const eventsRoutes = require('./routes/events');
const paymentRoutes = require('./routes/payments');
const adminRoutes = require('./routes/admin');
const galleryRoutes = require('./routes/gallery');
const bannersRoutes = require('./routes/banners');
const foodGalleryRoutes = require('./routes/food-gallery');
const walletRoutes = require('./routes/wallet');

app.use('/api/auth', authRoutes);
app.use('/api/campaigns', campaignsRoutes);
app.use('/api/donations', donationsRoutes);
app.use('/api/users', usersRoutes);
app.use('/api/news', newsRoutes);
app.use('/api/events', eventsRoutes);
app.use('/api/donations', require('./routes/donations'));
app.use('/api/payments', paymentRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/gallery', galleryRoutes);
app.use('/api/banners', bannersRoutes);
app.use('/api/food-gallery', foodGalleryRoutes);
app.use('/api/wallet', walletRoutes);

// Basic Route
app.get('/', (req, res) => {
  res.send('Army Donation API is running');
});

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI)
  .then(() => console.log('Connected to MongoDB'))
  .catch((err) => console.error('MongoDB connection error:', err));

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
