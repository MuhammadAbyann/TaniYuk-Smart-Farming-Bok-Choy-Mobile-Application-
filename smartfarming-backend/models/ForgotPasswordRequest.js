const mongoose = require('mongoose');
const mongoose = require('mongoose');

const forgotPasswordRequestSchema = new mongoose.Schema({
  userEmail: String,
  createdAt: { type: Date, default: Date.now },
  status: { type: String, enum: ['pending', 'handled'], default: 'pending' }
});

module.exports = mongoose.model('ForgotPasswordRequest', forgotPasswordRequestSchema);
