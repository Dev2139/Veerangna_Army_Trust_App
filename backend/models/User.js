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
  billingInfo: {
    firstName: { type: String, default: '' },
    lastName: { type: String, default: '' },
    street1: { type: String, default: '' },
    street2: { type: String, default: '' },
    street3: { type: String, default: '' },
    city: { type: String, default: '' },
    state: { type: String, default: '' },
    zipCode: { type: String, default: '' },
    country: { type: String, default: '' },
    panCard: { type: String, default: '' },
    howHeard: { type: String, default: '' },
    keepUpdated: { type: Boolean, default: true },
    donateAnonymously: { type: Boolean, default: false }
  }
}, { timestamps: true });

module.exports = mongoose.model('User', userSchema);
