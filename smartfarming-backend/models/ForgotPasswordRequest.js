const mongoose = require('mongoose');
const mongoose = require('mongoose');

const forgotPasswordRequestSchema = new mongoose.Schema({
  userEmail: String,
  createdAt: { type: Date, default: Date.now },
  status: { type: String, enum: ['pending', 'handled'], default: 'pending' }
});

module.exports = mongoose.model('ForgotPasswordRequest', forgotPasswordRequestSchema);

const forgotLogSchema = new mongoose.Schema({
  email: String,
  time: { type: Date, default: Date.now },
});

module.exports = mongoose.model('ForgotLog', forgotLogSchema);
