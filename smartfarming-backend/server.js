// ===== server.js =====
const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const connectDB = require('./config/mongodb');
const morgan = require('morgan');


// Load env
dotenv.config();

// Connect to MongoDB
connectDB();

// Create app
const app = express();
app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

// Routes
const authRoutes = require('./routes/authRoutes');
const sensorRoutes = require('./routes/sensorRoutes');
const adminRoutes = require('./routes/admin');

app.use('/api/admin', adminRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/sensor', sensorRoutes);
app.use('/api/user', require('./routes/user'));



// Root
app.get('/', (req, res) => {
  res.send('🌱 Smart Farming API is running...');
});

// Start server
const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on http://0.0.0.0:${PORT}`);
});

