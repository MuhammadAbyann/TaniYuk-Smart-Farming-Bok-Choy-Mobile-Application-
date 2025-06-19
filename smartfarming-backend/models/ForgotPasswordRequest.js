const mongoose = require('mongoose');

const forgotPasswordRequestSchema = new mongoose.Schema(
  {
    userEmail: {
      type: String,
      required: true,
    },
    status: {
      type: String,
      enum: ['pending', 'handled'],
      default: 'pending',
    },
  },
  { timestamps: true } // ✅ INI YANG PENTING
);

module.exports = mongoose.model('ForgotPasswordRequest', forgotPasswordRequestSchema);
