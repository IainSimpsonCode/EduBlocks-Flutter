const express = require("express");
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

app.listen(PORT, () => {
  console.log(`Listening on port ${PORT}\nhttp://localhost:${PORT}`);
});