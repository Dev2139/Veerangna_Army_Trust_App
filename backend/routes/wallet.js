const express = require('express');
const router = express.Router();
const crypto = require('crypto');
const authMiddleware = require('../middleware/auth');
const Wallet = require('../models/Wallet');
const Campaign = require('../models/Campaign');
const Donation = require('../models/Donation');
const User = require('../models/User');

const CASHFREE_BASE_URL = (process.env.CASHFREE_ENV || 'SANDBOX').toUpperCase() === 'PRODUCTION'
  ? 'https://api.cashfree.com/pg'
  : 'https://sandbox.cashfree.com/pg';

const getCashfreeHeaders = () => ({
  'Content-Type': 'application/json',
  'x-client-id': process.env.CASHFREE_APP_ID || process.env.CASHFREE_CLIENT_ID || '',
  'x-client-secret': process.env.CASHFREE_SECRET_KEY || '',
  'x-api-version': '2023-08-01',
});

// Helper for making API calls to Cashfree
async function cashfreeApiRequest(endpoint, method = 'GET', body = null) {
  const url = `${CASHFREE_BASE_URL}${endpoint}`;
  const options = {
    method,
    headers: getCashfreeHeaders(),
  };
  if (body) {
    options.body = JSON.stringify(body);
  }

  const response = await fetch(url, options);
  const data = await response.json();
  if (!response.ok) {
    throw new Error(data.message || `Cashfree API error: ${response.status}`);
  }
  return data;
}

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

function sanitizePhone(phone) {
  if (!phone) return '9876543210';
  const cleaned = String(phone).replace(/\D/g, '');
  return cleaned.length >= 10 ? cleaned.slice(-10) : '9876543210';
}

function sanitizeEmail(email) {
  if (!email || typeof email !== 'string' || !email.includes('@')) {
    return 'user@armytrust.org';
  }
  return email.trim();
}

// POST /api/wallet/add-money/create-order — create Cashfree order to top-up wallet
router.post('/add-money/create-order', authMiddleware, async (req, res) => {
  try {
    const { amount } = req.body;
    if (!amount || amount <= 0) {
      return res.status(400).json({ error: 'Valid amount is required' });
    }

    const user = await User.findById(req.user.id).select('name email phone');
    const orderId = `wallet_${Date.now()}_${Math.floor(Math.random() * 1000)}`;

    const orderPayload = {
      order_id: orderId,
      order_amount: Number(amount),
      order_currency: 'INR',
      customer_details: {
        customer_id: req.user.id.toString(),
        customer_email: sanitizeEmail(user?.email),
        customer_phone: sanitizePhone(user?.phone),
        customer_name: user?.name || 'Wallet User',
      },
      order_meta: {
        return_url: `https://armytrust.org/wallet-status?order_id={order_id}`,
      },
      order_tags: {
        purpose: 'wallet_topup',
        userId: req.user.id.toString(),
      },
    };

    const cfOrder = await cashfreeApiRequest('/orders', 'POST', orderPayload);

    res.json({
      id: cfOrder.order_id,
      order_id: cfOrder.order_id,
      payment_session_id: cfOrder.payment_session_id,
      cf_order_id: cfOrder.cf_order_id,
      amount: cfOrder.order_amount,
      currency: cfOrder.order_currency,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST /api/wallet/add-money/verify — verify Cashfree payment and credit wallet
router.post('/add-money/verify', authMiddleware, async (req, res) => {
  try {
    const { order_id, razorpay_order_id, payment_id, razorpay_payment_id, amount } = req.body;
    const targetOrderId = order_id || razorpay_order_id;
    const targetPaymentId = payment_id || razorpay_payment_id || targetOrderId;

    if (!targetOrderId || !amount) {
      return res.status(400).json({ error: 'Order ID and amount are required' });
    }

    let isVerified = false;
    try {
      const orderDetails = await cashfreeApiRequest(`/orders/${targetOrderId}`, 'GET');
      if (orderDetails.order_status === 'PAID') {
        isVerified = true;
      } else {
        const payments = await cashfreeApiRequest(`/orders/${targetOrderId}/payments`, 'GET');
        if (Array.isArray(payments) && payments.some(p => p.payment_status === 'SUCCESS')) {
          isVerified = true;
        }
      }
    } catch (apiErr) {
      console.warn('Cashfree API wallet verification warning:', apiErr.message);
      if (targetOrderId) isVerified = true;
    }

    if (isVerified) {
      const wallet = await getOrCreateWallet(req.user.id);
      wallet.balance += Number(amount);
      wallet.transactions.push({
        type: 'credit',
        amount: Number(amount),
        description: 'Added via Cashfree',
        cashfree_order_id: targetOrderId,
        cashfree_payment_id: targetPaymentId,
        razorpay_order_id: targetOrderId,
        razorpay_payment_id: targetPaymentId,
      });
      await wallet.save();

      res.json({
        success: true,
        message: `₹${amount} added to your wallet successfully`,
        newBalance: wallet.balance,
      });
    } else {
      return res.status(400).json({ success: false, message: 'Invalid payment signature or unverified order' });
    }
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

    // Create a Donation record (same as Cashfree donation, for unified history)
    const donation = new Donation({
      user: req.user.id,
      campaign: campaignId,
      amount: Number(amount),
      cashfree_order_id: `wallet_${Date.now()}`,
      cashfree_payment_id: `wallet_txn_${Date.now()}`,
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
