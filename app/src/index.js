// app/src/index.js

const express = require('express');
const app = express();
const port = 3000;

// Simple route to confirm the application is running
app.get('/', (req, res) => {
  res.send('Hello, Kubernetes DevOps Pipeline!');
});

// Bind to 0.0.0.0 to allow external access
app.listen(port, '0.0.0.0', () => {
  console.log(`App listening at http://0.0.0.0:${port}`);
});
