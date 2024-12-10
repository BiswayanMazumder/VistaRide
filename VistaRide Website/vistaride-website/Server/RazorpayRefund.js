const express = require('express');
const Razorpay = require('razorpay');
const cors = require('cors');  // Import CORS
const app = express();
const bodyParser = require('body-parser');

// Use CORS middleware
app.use(cors());  // This will enable CORS for all routes

app.use(bodyParser.json());

const razorpay = new Razorpay({
  key_id: 'rzp_test_gG0pN5dKl2Axrp',
  key_secret: 'CnBN8sDEpfRobYiMhV5iSSnJ',
});

// Refund endpoint
app.post('/refund', async (req, res) => {
  const { paymentId, amount } = req.body;
  
  if (!paymentId || !amount) {
    return res.status(400).json({ error: 'Missing paymentId or amount' });
  }

  try {
    // Call Razorpay refund API
    const refund = await razorpay.payments.refund(paymentId, {
      amount, // Amount should be in paise (e.g., 100 = ₹1)
      speed: 'optimum',
    });

    // Respond with the refund details
    res.json(refund);
  } catch (error) {
    console.error('Error during refund:', error);
    res.status(500).json({ error: error.message });
  }
});

// Server listens on port 4000
app.listen(4000, () => console.log('Server running on port 4000'));
