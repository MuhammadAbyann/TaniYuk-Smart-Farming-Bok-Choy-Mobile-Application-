module.exports = function (req, res, next) {
  console.log('[AUTH] Middleware aktif');

  console.log('HEADER:', req.headers.authorization);

  console.log('[AUTH] Header Authorization:', authHeader);


  const authHeader = req.header('Authorization');
  if (!authHeader) {
    console.log('❌ Tidak ada Authorization header');
    return res.status(401).json({ message: 'Tidak ada token. Akses ditolak.' });
  }

  const parts = authHeader.split(' ');
  if (parts.length !== 2 || parts[0] !== 'Bearer') {
    console.log('❌ Format Authorization salah:', authHeader);
    return res.status(401).json({ message: 'Format token tidak valid. Harus Bearer <token>' });
  }

  const token = parts[1];
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    console.log('✅ Token valid:', decoded);

    req.user = {
      id: decoded.userId,
      role: decoded.role || null,
    };
    next();
  } catch (err) {
    console.log('❌ Token tidak valid:', err.message);
    return res.status(401).json({ message: 'Token tidak valid' });
  }
};
