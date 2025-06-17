module.exports = function (req, res, next) {
  const authHeader = req.header('Authorization'); // ✔️ inisialisasi dulu
  const token = authHeader && authHeader.split(' ')[1]; // ✔️ baru dipakai

  if (!token) {
    return res.status(401).json({ message: 'No token, authorization denied' });
  }

  try {
    const decoded = require('jsonwebtoken').verify(token, process.env.JWT_SECRET);
    req.user = { id: decoded.userId, role: decoded.role };
    next();
  } catch (e) {
    res.status(401).json({ message: 'Token is not valid' });
  }
};
