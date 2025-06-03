// sensorRoutes.js
const express = require('express');
const {
  writeSensorData,
  getLastHourSensorData,
  getDailySensorData,
  getWeeklySensorData,
  getMonthlySensorData,
  getSensorSummaryData,
  getLatestSensorData,
  querySensorDataByDevice
} = require('../services/sensorService');
const authMiddleware = require('../middlewares/authMiddleware');

const router = express.Router();

// POST untuk upload sensor data
router.post('/', authMiddleware, (req, res) => {
  try {
    writeSensorData(req.body);
    res.status(201).json({ message: 'Data sensor berhasil disimpan' });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// GET data 1 jam terakhir
router.get('/last-hour', authMiddleware, async (req, res) => {
  try {
    const data = await getLastHourSensorData();
    if (data.length === 0) {
      return res.status(404).json({ message: 'Data 1 jam terakhir tidak ditemukan' });
    }
    res.json(data);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// GET data harian
router.get('/daily', authMiddleware, async (req, res) => {
  try {
    const data = await getDailySensorData();
    res.json(data);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// GET data mingguan
router.get('/weekly', authMiddleware, async (req, res) => {
  try {
    const data = await getWeeklySensorData();
    if (data.length === 0) {
      return res.status(404).json({ message: 'Data mingguan tidak ditemukan' });
    }
    res.json(data);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// GET data bulanan
router.get('/monthly', authMiddleware, async (req, res) => {
  try {
    const data = await getMonthlySensorData();
    if (data.length === 0) {
      return res.status(404).json({ message: 'Data bulanan tidak ditemukan' });
    }
    res.json(data);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// GET ringkasan data sensor
router.get('/summary', authMiddleware, async (req, res) => {
  try {
    const summary = await getSensorSummaryData();
    res.json(summary);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// GET data sensor terakhir
router.get('/last', authMiddleware, async (req, res) => {
  try {
    const data = await getLatestSensorData();
    if (!data) return res.status(404).json({ message: 'Data sensor terakhir tidak ditemukan' });
    res.json(data);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// GET data sensor berdasarkan device
router.get('/device/:device', authMiddleware, async (req, res) => {
  try {
    const device = req.params.device;
    const data = await querySensorDataByDevice(device);
    if (data.length === 0) {
      return res.status(404).json({ message: `Data sensor device ${device} tidak ditemukan` });
    }
    res.json(data);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get('/total-volume', authMiddleware, async (req, res) => {
  try {
    const data = await getDailySensorData();
    let totalVolume = 0;

    for (const record of data) {
      const flow = record.flow_rate || 0;      
      const durasi = record.durasi || 0;        
      totalVolume += flow * durasi;
    }

    res.json({ totalVolume: totalVolume.toFixed(2) });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});


module.exports = router;
