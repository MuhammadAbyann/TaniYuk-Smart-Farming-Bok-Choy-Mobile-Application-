const express = require('express');
const router = express.Router();
const User = require('../models/User');
const authMiddleware = require('../middlewares/authMiddleware');
const adminOnly = require('../middlewares/adminOnly');
const bcrypt = require('bcryptjs');
const ForgotPasswordRequest = require('../models/ForgotPasswordRequest');

// GET semua user
router.get('/users', authMiddleware, adminOnly, async (req, res) => {
  const users = await User.find().select('-password');
  res.json(users);
});

// GET semua request lupa password (untuk ditampilkan ke admin)
router.get('/forgot-password-requests', authMiddleware, adminOnly, async (req, res) => {
  const requests = await ForgotPasswordRequest.find().sort({ createdAt: -1 });
  res.json(requests);
});

// POST request lupa password (dipanggil saat user klik "Lupa Password")
router.post('/forgot-password-request', async (req, res) => {
  const { email } = req.body;
  await ForgotPasswordRequest.create({ userEmail: email });
  res.json({ message: 'Permintaan lupa password dikirim' });
});

// PUT tandai request lupa password sebagai 'handled'
router.put('/forgot-password-requests/:id/handle', authMiddleware, adminOnly, async (req, res) => {
  await ForgotPasswordRequest.findByIdAndUpdate(req.params.id, { status: 'handled' });
  res.json({ message: 'Permintaan ditandai selesai' });
});

// DELETE user
router.delete('/users/:id', authMiddleware, adminOnly, async (req, res) => {
  await User.findByIdAndDelete(req.params.id);
  res.json({ message: 'User berhasil dihapus' });
});

module.exports = router;
