const mongoose = require('mongoose');

const campaignSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: { type: String, required: true },
  images: [{ type: String }],
  amountRequired: { type: Number, required: true },
  amountCollected: { type: Number, default: 0 },
  status: { type: String, enum: ['active', 'completed'], default: 'active' },
  documents: [{ type: String }] // proof/documents
}, { timestamps: true });

module.exports = mongoose.model('Campaign', campaignSchema);
