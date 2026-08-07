const express = require('express');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 8081;

// Serve static files from pure_web directory
app.use(express.static(path.join(__dirname, 'pure_web')));

app.listen(PORT, () => {
    console.log(`⚡ Pure Web Admin Dashboard listening on http://localhost:${PORT}`);
});
