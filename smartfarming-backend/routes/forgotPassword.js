// Mengimpor express dan mendeklarasikan router
const express = require('express');
const router = express.Router();
const ForgotPasswordRequest = require('../models/ForgotPasswordRequest');

// POST /api/forgot-password
router.post('/', async (req, res) => {
  const { email } = req.body;

  if (!email) {
    return res.status(400).json({ message: 'Email tidak boleh kosong' });
  }

  console.log('Email diterima:', email);  // Log email yang diterima

  try {
    // Menyimpan permintaan ke database MongoDB
    const request = new ForgotPasswordRequest({ userEmail: email });
    await request.save(); // Menyimpan permintaan ke MongoDB

    res.json({ message: 'Permintaan reset dikirim ke admin' });
  } catch (e) {
    res.status(500).json({ message: 'Gagal menyimpan permintaan' });
    console.error('Error menyimpan permintaan:', e);  // Log error jika terjadi kesalahan
  }
});


// Mengekspor router agar dapat digunakan di server.js
module.exports = router;


