const express = require("express");
const path = require("path");
const app = express()

const PORT = 3001;

const flutterWebAppPath = path.join(__dirname, '..', "edublocks_flutter", "build", "web");
const v2WebAppPath = path.join(__dirname, "V2");
const v1WebAppPath = path.join(__dirname, "V1");

app.use('/v2', express.static(v2WebAppPath));
app.use('/v1', express.static(v1WebAppPath));
app.use('/live', express.static(flutterWebAppPath));

app.get("/", (req, res) => {
  res.redirect('/v2');
})

app.get("/v1", (req, res) => {
  res.sendFile(path.join(v1WebAppPath, "index.html"));
})

app.get("/v2", (req, res) => {
  res.sendFile(path.join(v2WebAppPath, "index.html"));
})

app.get("/live", (req, res) => {
  res.sendFile(path.join(flutterWebAppPath, "index.html"));
})

app.listen(PORT, () => {
  console.log(`Listening on port ${PORT}\nhttp://localhost:${PORT}`);
});