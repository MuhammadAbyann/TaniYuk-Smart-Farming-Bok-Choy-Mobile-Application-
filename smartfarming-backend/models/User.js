const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
    unique: true
  },
  password: {
    type: String,
    required: true
  },
  lokasiLahan: {
    type: String,
    default: ''
  },
  jenisTanaman: {
    type: String,
    default: ''
  },
  luasLahan: {
    type: String,
    default: ''
  },
  lamaPanen: {
    type: String,
    default: ''
  }
});

module.exports = mongoose.model('User', userSchema);
