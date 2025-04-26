const { Point } = require('@influxdata/influxdb-client');
const { writeApi, queryApi, bucket } = require('../config/influxdb');

// Fungsi untuk tulis data sensor ke InfluxDB
const writeSensorData = (data) => {
  if (!data.ph || !data.kelembaban_tanah || !data.kelembaban_udara || !data.suhu || !data.cahaya) {
    throw new Error('Data sensor tidak lengkap');
  }

  const point = new Point('sensor_data')
    .tag('source', 'pakcoy_device')
    .floatField('ph', data.ph)
    .floatField('kelembaban_tanah', data.kelembaban_tanah)
    .floatField('kelembaban_udara', data.kelembaban_udara)
    .floatField('suhu', data.suhu)
    .floatField('cahaya', data.cahaya);

  writeApi.writePoint(point);
  writeApi.flush();
};

// Helper untuk query fleksibel
const querySensorData = async (start, stop) => {
  const query = `
    from(bucket: "${bucket}")
    |> range(start: ${start}, stop: ${stop})
    |> filter(fn: (r) => r._measurement == "sensor_data")
    |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
    |> sort(columns: ["_time"], desc: false)
  `;

  const result = [];

  return new Promise((resolve, reject) => {
    queryApi.queryRows(query, {
      next(row, tableMeta) {
        const o = tableMeta.toObject(row);
        result.push(o);
      },
      error(error) {
        reject(error);
      },
      complete() {
        resolve(result);
      }
    });
  });
};

// 🚀 Fetch data fungsi-fungsi monitoring
const getLastHourSensorData = async () => {
  return await querySensorData('-1h', 'now()');
};

const getDailySensorData = async () => {
    const today = new Date();
    const startOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate());
    return await querySensorData(startOfDay.toISOString(), 'now()');
};  

const getWeeklySensorData = async () => {
  return await querySensorData('-7d', 'now()');
};

const getMonthlySensorData = async () => {
  return await querySensorData('-30d', 'now()');
};

module.exports = {
  writeSensorData,
  getLastHourSensorData,
  getDailySensorData,
  getWeeklySensorData,
  getMonthlySensorData
};
