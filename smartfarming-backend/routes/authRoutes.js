const express = require('express');
const router = express.Router();
const { body } = require('express-validator'); // Import express-validator
const authController = require('../controllers/authController');

// Registrasi dengan validasi
router.post(
  '/register',
  [
    body('email', 'Email tidak valid').isEmail(),
    body('password', 'Password harus memiliki minimal 6 karakter').isLength({ min: 6 }),
  ],
  authController.register
);

// Login dengan validasi
router.post(
  '/login',
  [
    body('email', 'Email tidak valid').isEmail(),
    body('password', 'Password tidak boleh kosong').notEmpty(),
  ],
  authController.login
);

module.exports = router;
