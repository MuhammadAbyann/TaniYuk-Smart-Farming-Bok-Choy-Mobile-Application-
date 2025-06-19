const express = require('express');
const router = express.Router();
const User = require('../models/User');
const authMiddleware = require('../middlewares/authMiddleware');
const adminOnly = require('../middlewares/adminOnly');
const ForgotLog = require('../models/ForgotLog');
const bcrypt = require('bcryptjs');
const ForgotPasswordRequest = require('../models/ForgotPasswordRequest');

// GET semua user
router.get('/users', authMiddleware, adminOnly, async (req, res) => {
  const users = await User.find().select('-password');
  res.json(users);
});

router.get('/forgot-password-requests', authMiddleware, adminOnly, async (req, res) => {
  const requests = await ForgotPasswordRequest.find().sort({ createdAt: -1 });
  res.json(requests);
});

// PUT reset password
router.put('/users/:id/reset-password', authMiddleware, adminOnly, async (req, res) => {
  const { newPassword } = req.body;
  const hashed = await bcrypt.hash(newPassword, 10);

  await User.findByIdAndUpdate(req.params.id, { password: hashed });
  res.json({ message: 'Password berhasil direset' });
});

// DELETE user
router.delete('/users/:id', authMiddleware, adminOnly, async (req, res) => {
  await User.findByIdAndDelete(req.params.id);
  res.json({ message: 'User berhasil dihapus' });
});


router.post('/notifications', authMiddleware, adminOnly, async (req, res) => {
  const { email, time } = req.body;
  await ForgotLog.create({ email, time });
  res.json({ message: 'Notifikasi disimpan' });
});

router.get('/notifications', authMiddleware, adminOnly, async (req, res) => {
  const logs = await ForgotLog.find().sort({ time: -1 });
  res.json(logs);
});


module.exports = router;
