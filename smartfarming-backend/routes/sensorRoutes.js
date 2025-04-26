const express = require('express');
const {
  writeSensorData,
  getLastHourSensorData,
  getDailySensorData,
  getWeeklySensorData,
  getMonthlySensorData
} = require('../services/sensorService');

const router = express.Router();

// POST untuk upload sensor data
router.post('/', (req, res) => {
  try {
    writeSensorData(req.body);
    res.status(201).json({ message: 'Data sensor berhasil disimpan' });
  } catch (error) {
    res.status(500).json({ message: 'Gagal menyimpan data', error: error.message });
  }
});

// GET data 1 jam terakhir
router.get('/last-hour', async (req, res) => {
  try {
    const data = await getLastHourSensorData();
    res.json(data);
  } catch (error) {
    res.status(500).json({ message: 'Gagal mengambil data 1 jam terakhir', error: error.message });
  }
});

// GET data harian
router.get('/daily', async (req, res) => {
  try {
    const data = await getDailySensorData();
    res.json(data);
  } catch (error) {
    res.status(500).json({ message: 'Gagal mengambil data harian', error: error.message });
  }
});

// GET data mingguan
router.get('/weekly', async (req, res) => {
  try {
    const data = await getWeeklySensorData();
    res.json(data);
  } catch (error) {
    res.status(500).json({ message: 'Gagal mengambil data mingguan', error: error.message });
  }
});

// GET data bulanan
router.get('/monthly', async (req, res) => {
  try {
    const data = await getMonthlySensorData();
    res.json(data);
  } catch (error) {
    res.status(500).json({ message: 'Gagal mengambil data bulanan', error: error.message });
  }
});

module.exports = router;
