const express = require("express");
const axios = require("axios");
const path = require("path");
const app = express()

const PORT = 3001;

const flutterWebAppPath = path.join(__dirname, '..', "edublocks_flutter", "build", "web");
app.use(express.static(flutterWebAppPath));

app.get("/v2", (req, res) => {
  res.sendFile(path.join(flutterWebAppPath, "index.html"));
})

app.get("/", (req, res) => {
  res.redirect('/v2');
})

app.get("/v1", (req, res) => {
  res.sendFile(path.join(flutterWebAppPath, "index.html"));
})

app.post('/log', async (req, res) => {
  const targetURL = 'https://marklochrie.co.uk/edublocks_logger/log';

  try {
    const response = await axios.post(targetURL, req.body, {
      headers: { 'Content-Type': 'application/json' }
    });

    res.status(200).json({ message: 'Data forwarded successfully' });
  } catch (error) {
    console.error('Error forwarding data:', error.message);
    res.status(500).json({ error: 'Failed to forward data' });
  }
});

app.listen(PORT, () => {
  console.log(`Listening on port ${PORT}\nhttp://localhost:${PORT}`);
});