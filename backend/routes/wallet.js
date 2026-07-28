const express = require('express');
const router = express.Router();
const Razorpay = require('razorpay');
const crypto = require('crypto');
const authMiddleware = require('../middleware/auth');
const Wallet = require('../models/Wallet');
const Campaign = require('../models/Campaign');
const Donation = require('../models/Donation');

const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID,
  key_secret: process.env.RAZORPAY_KEY_SECRET,
});

// Helper: get or create wallet for a user
async function getOrCreateWallet(userId) {
  let wallet = await Wallet.findOne({ user: userId });
  if (!wallet) {
    wallet = new Wallet({ user: userId, balance: 0, transactions: [] });
    await wallet.save();
  }
  return wallet;
}

// GET /api/wallet — get current user's wallet (balance + transactions)
router.get('/', authMiddleware, async (req, res) => {
  try {
    const wallet = await getOrCreateWallet(req.user.id);
    // Populate campaign names in transactions
    await wallet.populate('transactions.campaign', 'title');
    res.json(wallet);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST /api/wallet/add-money/create-order — create Razorpay order to top-up wallet
router.post('/add-money/create-order', authMiddleware, async (req, res) => {
  try {
    const { amount } = req.body;
    if (!amount || amount <= 0) {
      return res.status(400).json({ error: 'Valid amount is required' });
    }

    const options = {
      amount: Math.round(amount * 100), // Razorpay works in paise
      currency: 'INR',
      receipt: `wallet_topup_${Date.now()}`,
      notes: {
        purpose: 'wallet_topup',
        userId: req.user.id,
      },
    };

    const order = await razorpay.orders.create(options);
    res.json(order);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST /api/wallet/add-money/verify — verify Razorpay payment and credit wallet
router.post('/add-money/verify', authMiddleware, async (req, res) => {
  try {
    const { razorpay_order_id, razorpay_payment_id, razorpay_signature, amount } = req.body;

    if (!razorpay_order_id || !razorpay_payment_id || !razorpay_signature || !amount) {
      return res.status(400).json({ error: 'All payment fields are required' });
    }

    // Verify signature
    const sign = `${razorpay_order_id}|${razorpay_payment_id}`;
    const expectedSign = crypto
      .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
      .update(sign)
      .digest('hex');

    if (razorpay_signature !== expectedSign) {
      return res.status(400).json({ success: false, message: 'Invalid payment signature' });
    }

    // Credit the wallet
    const wallet = await getOrCreateWallet(req.user.id);
    wallet.balance += Number(amount);
    wallet.transactions.push({
      type: 'credit',
      amount: Number(amount),
      description: 'Added via Razorpay',
      razorpay_order_id,
      razorpay_payment_id,
    });
    await wallet.save();

    res.json({
      success: true,
      message: `₹${amount} added to your wallet successfully`,
      newBalance: wallet.balance,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST /api/wallet/donate — donate from wallet balance to a campaign
router.post('/donate', authMiddleware, async (req, res) => {
  try {
    const { campaignId, amount } = req.body;

    if (!campaignId || !amount || amount <= 0) {
      return res.status(400).json({ error: 'Campaign ID and valid amount are required' });
    }

    const wallet = await getOrCreateWallet(req.user.id);

    if (wallet.balance < amount) {
      return res.status(400).json({
        error: 'Insufficient wallet balance',
        currentBalance: wallet.balance,
      });
    }

    const campaign = await Campaign.findById(campaignId);
    if (!campaign) {
      return res.status(404).json({ error: 'Campaign not found' });
    }

    // Deduct from wallet
    wallet.balance -= Number(amount);
    wallet.transactions.push({
      type: 'debit',
      amount: Number(amount),
      description: `Donated to ${campaign.title}`,
      campaign: campaignId,
    });
    await wallet.save();

    // Update campaign collected amount
    await Campaign.findByIdAndUpdate(campaignId, {
      $inc: { amountCollected: amount },
    });

    // Create a Donation record (same as Razorpay donation, for unified history)
    const donation = new Donation({
      user: req.user.id,
      campaign: campaignId,
      amount: Number(amount),
      razorpay_order_id: `wallet_${Date.now()}`,
      razorpay_payment_id: `wallet_txn_${Date.now()}`,
      status: 'success',
    });
    await donation.save();

    res.json({
      success: true,
      message: `₹${amount} donated to ${campaign.title} successfully`,
      newBalance: wallet.balance,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
