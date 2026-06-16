const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  phone: { type: String },
  role: { type: String, enum: ['user', 'admin'], default: 'user' },
  profilePhotoUrl: { type: String },
  savedCampaigns: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Campaign' }],
  eventParticipation: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Event' }],
}, { timestamps: true });

module.exports = mongoose.model('User', userSchema);
