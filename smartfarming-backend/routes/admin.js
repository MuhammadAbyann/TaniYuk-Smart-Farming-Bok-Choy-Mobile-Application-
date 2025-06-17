const express = require('express');
const router = express.Router();
const User = require('../models/User');
const authMiddleware = require('../middlewares/authMiddleware');
const adminOnly = require('../middlewares/adminOnly');
const bcrypt = require('bcryptjs');

// GET semua user
router.get('/users', authMiddleware, adminOnly, async (req, res) => {
  const users = await User.find().select('-password');
  res.json(users);
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

module.exports = router;
