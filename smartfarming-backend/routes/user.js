const express = require('express');
const router = express.Router();
const User = require('../models/User');
const authMiddleware = require('../middlewares/authMiddleware');

// GET /api/user/profile
router.get('/profile', authMiddleware, async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-password');
    if (!user) return res.status(404).json({ message: 'User not found' });

    res.json({
      email: user.email || '',
      lokasiLahan: user.lokasiLahan || 'Belum diatur',
      jenisTanaman: user.jenisTanaman || 'Belum diatur',
      luasLahan: user.luasLahan || 'Belum diatur',
      lamaPanen: user.lamaPanen || 'Belum diatur',
      role: user.role || 'user',
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// PUT /api/user/profile
router.put('/profile', authMiddleware, async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) return res.status(404).json({ message: 'User not found' });

    // Update hanya field yang boleh
    if (req.body.lokasiLahan !== undefined) user.lokasiLahan = req.body.lokasiLahan;
    if (req.body.jenisTanaman !== undefined) user.jenisTanaman = req.body.jenisTanaman;
    if (req.body.luasLahan !== undefined) user.luasLahan = req.body.luasLahan;
    if (req.body.lamaPanen !== undefined) user.lamaPanen = req.body.lamaPanen;

    await user.save();
    res.json({ message: 'Profile updated successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
