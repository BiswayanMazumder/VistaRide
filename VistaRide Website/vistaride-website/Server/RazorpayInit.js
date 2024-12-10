const express = require("express");
const Razorpay = require("razorpay");
const cors = require("cors");
const bodyParser = require("body-parser");

const app = express();

// Middleware
app.use(cors()); // To allow cross-origin requests
app.use(bodyParser.json()); // To parse JSON request bodies

// Initialize Razorpay
const razorpay = new Razorpay({
  key_id: "rzp_test_gG0pN5dKl2Axrp", // Replace with your Razorpay Key ID
  key_secret: "CnBN8sDEpfRobYiMhV5iSSnJ", // Replace with your Razorpay Key Secret
});

// Route to create a Razorpay order
app.post("/create-order", async (req, res) => {
  const { amount } = req.body;

  const options = {
    amount: amount * 100, // Convert to the smallest currency unit (e.g., paisa for INR)
    currency: "INR",
    receipt: `receipt_${Date.now()}`, // Unique receipt ID
  };

  try {
    const order = await razorpay.orders.create(options); // Create order
    res.status(200).json(order); // Send order details as JSON
  } catch (error) {
    console.error("Error creating order:", error);
    res.status(500).json({ message: "Something went wrong", error });
  }
});

// Default route for unhandled paths
app.get("/", (req, res) => {
  res.send("Welcome to Razorpay Backend!");
});

// Start the server
const PORT = 5000;
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
