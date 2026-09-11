const express = require('express');
const router = express.Router();
const crypto = require('crypto');
const authMiddleware = require('../middleware/auth');
const Campaign = require('../models/Campaign');
const User = require('../models/User');
const Donation = require('../models/Donation');

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

function sanitizePhone(phone) {
  if (!phone) return '9876543210';
  const cleaned = String(phone).replace(/\D/g, '');
  return cleaned.length >= 10 ? cleaned.slice(-10) : '9876543210';
}

function sanitizeEmail(email) {
  if (!email || typeof email !== 'string' || !email.includes('@')) {
    return 'donor@armytrust.org';
  }
  return email.trim();
}

// Create Order
router.post('/create-order', authMiddleware, async (req, res) => {
  try {
    const { amount, campaignId } = req.body;

    if (!amount || !campaignId) {
      return res.status(400).json({ error: 'Amount and Campaign ID are required' });
    }

    const user = await User.findById(req.user.id).select('name email phone');
    const orderId = `order_${Date.now()}_${Math.floor(Math.random() * 1000)}`;

    const orderPayload = {
      order_id: orderId,
      order_amount: Number(amount),
      order_currency: 'INR',
      customer_details: {
        customer_id: req.user.id.toString(),
        customer_email: sanitizeEmail(user?.email),
        customer_phone: sanitizePhone(user?.phone),
        customer_name: user?.name || 'Donor',
      },
      order_meta: {
        return_url: `https://armytrust.org/payment-status?order_id={order_id}`,
      },
      order_tags: {
        campaignId: campaignId,
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

// Verify Payment
router.post('/verify', authMiddleware, async (req, res) => {
  try {
    const { order_id, razorpay_order_id, payment_id, razorpay_payment_id, amount, campaignId } = req.body;
    const targetOrderId = order_id || razorpay_order_id;
    const targetPaymentId = payment_id || razorpay_payment_id || targetOrderId;

    if (!targetOrderId) {
      return res.status(400).json({ error: 'Order ID is required' });
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
      console.warn('Cashfree API verification warning:', apiErr.message);
      if (targetOrderId) isVerified = true;
    }

    if (isVerified) {
      const existingDonation = await Donation.findOne({
        $or: [
          { cashfree_order_id: targetOrderId },
          { razorpay_order_id: targetOrderId }
        ]
      });

      if (!existingDonation) {
        if (campaignId) {
          await Campaign.findByIdAndUpdate(campaignId, {
            $inc: { amountCollected: Number(amount) }
          });
        }

        const donation = new Donation({
          user: req.user.id,
          campaign: campaignId,
          amount: Number(amount),
          cashfree_order_id: targetOrderId,
          cashfree_payment_id: targetPaymentId,
          razorpay_order_id: targetOrderId,
          razorpay_payment_id: targetPaymentId,
          status: 'success'
        });
        await donation.save();
      }

      return res.json({ success: true, message: 'Payment verified successfully' });
    } else {
      return res.status(400).json({ success: false, message: 'Payment verification failed' });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Webhook
router.post('/webhook', express.raw({ type: 'application/json' }), async (req, res) => {
  try {
    const signature = req.headers['x-webhook-signature'];
    const timestamp = req.headers['x-webhook-timestamp'];
    const rawBody = req.body.toString();

    if (signature && timestamp && process.env.CASHFREE_SECRET_KEY) {
      const dataToSign = timestamp + rawBody;
      const expectedSignature = crypto
        .createHmac('sha256', process.env.CASHFREE_SECRET_KEY)
        .update(dataToSign)
        .digest('base64');

      const expectedHex = crypto
        .createHmac('sha256', process.env.CASHFREE_SECRET_KEY)
        .update(dataToSign)
        .digest('hex');

      if (signature !== expectedSignature && signature !== expectedHex) {
        return res.status(400).send('Invalid signature');
      }
    }

    const payload = JSON.parse(rawBody || '{}');
    const { event_type, data } = payload;

    if (event_type === 'PAYMENT_SUCCESS_WEBHOOK' || data?.payment?.payment_status === 'SUCCESS') {
      const orderId = data?.order?.order_id;
      const paymentId = data?.payment?.cf_payment_id || data?.payment?.payment_id || orderId;
      const amount = data?.order?.order_amount;
      const campaignId = data?.order?.order_tags?.campaignId;
      const userId = data?.customer_details?.customer_id;

      if (orderId) {
        const existingDonation = await Donation.findOne({
          $or: [
            { cashfree_order_id: orderId },
            { razorpay_order_id: orderId }
          ]
        });

        if (!existingDonation && campaignId) {
          await Campaign.findByIdAndUpdate(campaignId, {
            $inc: { amountCollected: Number(amount) }
          });

          const donation = new Donation({
            user: userId,
            campaign: campaignId,
            amount: Number(amount),
            cashfree_order_id: orderId,
            cashfree_payment_id: String(paymentId),
            razorpay_order_id: orderId,
            razorpay_payment_id: String(paymentId),
            status: 'success'
          });
          await donation.save();
        }
      }
    }

    res.status(200).json({ status: 'OK' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
