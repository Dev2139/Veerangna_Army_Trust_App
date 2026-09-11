const mongoose = require('mongoose');

const donationSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  campaign: { type: mongoose.Schema.Types.ObjectId, ref: 'Campaign', required: true },
  amount: { type: Number, required: true },
  cashfree_order_id: { type: String },
  cashfree_payment_id: { type: String },
  razorpay_order_id: { type: String },
  razorpay_payment_id: { type: String },
  status: { type: String, enum: ['success', 'failed', 'pending'], default: 'success' },
}, { timestamps: true });

module.exports = mongoose.model('Donation', donationSchema);
