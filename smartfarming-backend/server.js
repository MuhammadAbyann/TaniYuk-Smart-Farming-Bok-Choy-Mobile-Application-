const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const connectDB = require('./config/mongodb');

dotenv.config(); // Load environment variables

// Connect ke MongoDB
connectDB();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Routes
const authRoutes = require('./routes/authRoutes');
// Optional: sensorRoutes hanya jika sudah dibuat
try {
  const sensorRoutes = require('./routes/sensorRoutes');
  app.use('/api/sensor', sensorRoutes);
} catch (err) {
  console.warn('⚠️  routes/sensorRoutes.js not found, skipping...');
}

app.use('/api/auth', authRoutes);

// Root test endpoint
app.get('/', (req, res) => {
  res.send('🌱 Smart Farming API is running...');
});

// Start server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});
