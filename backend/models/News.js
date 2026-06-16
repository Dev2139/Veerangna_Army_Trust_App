const mongoose = require('mongoose');

const newsSchema = new mongoose.Schema({
  type: { type: String, enum: ['news', 'motivational', 'video'], default: 'news' },
  title: { type: String, required: true },
  content: { type: String, required: true },
  mediaUrl: { type: String }, // image or video URL
  likesCount: { type: Number, default: 0 },
}, { timestamps: true });

module.exports = mongoose.model('News', newsSchema);
