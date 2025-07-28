const express = require('express');
const router = express.Router();
const User = require('../models/User');
const authMiddleware = require('../middlewares/authMiddleware');
const adminOnly = require('../middlewares/adminOnly');
const ForgotPasswordRequest = require('../models/ForgotPasswordRequest');

// GET semua user
router.get('/users', authMiddleware, adminOnly, async (req, res) => {
  const users = await User.find().select('-password');
  res.json(users);
});

// GET notifikasi permintaan reset password untuk admin
router.get('/notifications', authMiddleware, adminOnly, async (req, res) => {
  try {
    // Ambil permintaan reset password dan urutkan berdasarkan waktu pembuatan (createdAt)
    const notifications = await ForgotPasswordRequest.find().sort({ createdAt: -1 });
    
    // Kirimkan data notifikasi ke frontend
    res.json(notifications);
  } catch (e) {
    res.status(500).json({ message: 'Gagal mengambil notifikasi' });
    console.error(e); // Log error untuk debugging
  }
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

  // Hapus user terkait permintaan lupa password
  const request = await ForgotPasswordRequest.findById(req.params.id);
  if (request) {
    const user = await User.findOne({ email: request.userEmail });
    if (user) {
      await User.findByIdAndDelete(user._id); // Hapus akun pengguna
      res.json({ message: 'Akun pengguna berhasil dihapus. Petani dapat mendaftar kembali.' });
    } else {
      res.status(404).json({ message: 'Pengguna tidak ditemukan' });
    }
  } else {
    res.status(404).json({ message: 'Permintaan tidak ditemukan' });
  }
});

// DELETE user by ID
router.delete('/users/:id', authMiddleware, adminOnly, async (req, res) => {
  try {
    const user = await User.findByIdAndDelete(req.params.id);
    if (!user) {
      return res.status(404).json({ message: 'User tidak ditemukan' });
    }
    res.json({ message: 'User berhasil dihapus' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Gagal menghapus user' });
  }
});

module.exports = router;
