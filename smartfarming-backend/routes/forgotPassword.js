const express = require('express');
const router = express.Router();
const ForgotPasswordRequest = require('../models/ForgotPasswordRequest');

// POST /api/forgot-password
router.post('/', async (req, res) => {
  const { email } = req.body;

  try {
    const request = new ForgotPasswordRequest({ userEmail: email });
    await request.save();
    res.json({ message: 'Permintaan reset dikirim ke admin' });
  } catch (e) {
    res.status(500).json({ message: 'Gagal menyimpan permintaan' });
  }
});

module.exports = router;
