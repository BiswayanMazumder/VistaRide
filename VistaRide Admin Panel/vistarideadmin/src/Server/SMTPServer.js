const express = require('express');
const cors = require('cors');
const nodemailer = require('nodemailer');
const app = express();

// Allow all origins (you can specify the frontend URL if needed)
app.use(cors());
app.use(express.json()); // To parse incoming JSON requests

// Define the email sending logic
app.post('/send-email', (req, res) => {
  const { email, body } = req.body;  // Get email and body from the request body

  if (!email || !body) {
    return res.status(400).json({ error: 'Email and body are required' });
  }

  // Set up the nodemailer transporter
  const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: "biswayanmazumder77@gmail.com",
      pass: "password"
    },
  });

  const mailOptions = {
    from: "support@vistaride.com",  // Sender's email address
    to: email,                      // Receiver's email address
    subject: 'Your VistaRide Booking Details – Everything You Need to Know',          // Subject line (can be customized)
    text: body,                     // The body of the email
  };

  transporter.sendMail(mailOptions, (err, info) => {
    if (err) {
      return res.status(500).json({ error: 'Failed to send email' });
    }
    res.status(200).json({ message: 'Email sent successfully' });
  });
});

// Start the server
app.listen(8080, () => {
  console.log('Server is running on http://localhost:8080');
});
