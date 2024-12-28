// Import the nodemailer package
const nodemailer = require('nodemailer');

// Create a transporter object using SMTP transport (you can use your email service's SMTP details)
const transporter = nodemailer.createTransport({
  service: 'gmail', // You can change this based on your email provider
  auth: {
    user: 'teamc398@gmail.com', // Your email address
    pass: 'password'   // Your email password or app-specific password
  }
});

// Set up email data
const mailOptions = {
  from: 'teamc398@gmail.com',     // Sender address
  to: 'biswayanmazumder77@gmail.com', // List of recipients
  subject: 'Hello from Node.js',     // Subject line
  text: 'This is a test email sent from Node.js using nodemailer.', // Plain text body
  html: '<b>This is a test email sent from Node.js using nodemailer.</b>' // HTML body (optional)
};

// Send the email
transporter.sendMail(mailOptions, (error, info) => {
  if (error) {
    console.log('Error sending email:', error);
  } else {
    console.log('Email sent:', info.response);
  }
});
