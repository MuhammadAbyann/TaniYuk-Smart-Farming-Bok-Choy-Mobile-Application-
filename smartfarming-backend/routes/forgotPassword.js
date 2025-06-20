// POST /api/forgot-password
router.post('/', async (req, res) => {
  const { email } = req.body;

  if (!email) {
    return res.status(400).json({ message: 'Email tidak boleh kosong' });
  }

  try {
    // Simpan permintaan ke database
    const request = new ForgotPasswordRequest({ userEmail: email });
    await request.save(); // Simpan permintaan ke MongoDB

    // Kirim respons sukses
    res.json({ message: 'Permintaan reset dikirim ke admin' });
  } catch (e) {
    res.status(500).json({ message: 'Gagal menyimpan permintaan' });
    console.error(e);  // Tambahkan log jika terjadi kesalahan
  }
});
