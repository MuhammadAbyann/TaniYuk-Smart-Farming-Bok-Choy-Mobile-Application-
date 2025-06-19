const express = require('express');
const router = express.Router();
const ForgotPasswordRequest = require('../models/ForgotPasswordRequest');

// POST /api/forgot-password
router.post('/', async (req, res) => {
  const { email } = req.body;

  if (!email) {
    return res.status(400).json({ message: 'Email tidak boleh kosong' });
  }

  try {
    const request = new ForgotPasswordRequest({ userEmail: email });
    await request.save(); // Menyimpan permintaan ke database
    res.json({ message: 'Permintaan reset dikirim ke admin' });
  } catch (e) {
    res.status(500).json({ message: 'Gagal menyimpan permintaan' });
  }
});

module.exports = router;
