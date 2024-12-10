const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send('Hello from Vercel!');
});

app.listen(5000, () => {
  console.log(`Server running at http://localhost:5000`);
});
