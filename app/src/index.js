// app/src/index.js

const express = require('express');
const app = express();
const port = 80;

// Simple route to confirm the application is running
app.get('/', (req, res) => {
  res.send('Hello, Kubernetes DevOps Pipeline!');
});

app.listen(port, () => {
  console.log(`App listening at http://localhost:${port}`);
});
