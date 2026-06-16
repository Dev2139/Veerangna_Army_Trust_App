const mongoose = require('mongoose');

const foodGallerySchema = new mongoose.Schema({
  imageUrl: { type: String, required: true },
  caption: { type: String }
}, { timestamps: true });

module.exports = mongoose.model('FoodGallery', foodGallerySchema);
