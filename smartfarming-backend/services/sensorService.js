// sensorService.js
const { Point } = require('@influxdata/influxdb-client');
const { writeApi, queryApi, bucket } = require('../config/influxdb');

// Validasi lengkap sesuai data sensor nyata
const validateSensorData = (data) => {
  const {
    ph_sensor, pH_nano,
    soil_moisture_1, soil_moisture_2,
    nano_moisture_1, nano_moisture_2, nano_moisture_3,
    humidity, temperature, lux, flow_rate
  } = data;

  // Contoh validasi, sesuaikan rentang dan tipe data
  if (
    (ph_sensor !== undefined && (typeof ph_sensor !== 'number' || ph_sensor < 0 || ph_sensor > 14)) ||
    (pH_nano !== undefined && (typeof pH_nano !== 'number' || pH_nano < 0 || pH_nano > 14)) ||
    (soil_moisture_1 !== undefined && (typeof soil_moisture_1 !== 'number' || soil_moisture_1 < 0 || soil_moisture_1 > 100)) ||
    (soil_moisture_2 !== undefined && (typeof soil_moisture_2 !== 'number' || soil_moisture_2 < 0 || soil_moisture_2 > 100)) ||
    (nano_moisture_1 !== undefined && (typeof nano_moisture_1 !== 'number' || nano_moisture_1 < 0 || nano_moisture_1 > 100)) ||
    (nano_moisture_2 !== undefined && (typeof nano_moisture_2 !== 'number' || nano_moisture_2 < 0 || nano_moisture_2 > 100)) ||
    (nano_moisture_3 !== undefined && (typeof nano_moisture_3 !== 'number' || nano_moisture_3 < 0 || nano_moisture_3 > 100)) ||
    (humidity !== undefined && (typeof humidity !== 'number' || humidity < 0 || humidity > 100)) ||
    (temperature !== undefined && (typeof temperature !== 'number' || temperature < -10 || temperature > 60)) ||
    (lux !== undefined && (typeof lux !== 'number' || lux < 0)) ||
    (flow_rate !== undefined && (typeof flow_rate !== 'number' || flow_rate < 0))
  ) {
    throw new Error('Nilai data sensor tidak valid atau tidak lengkap');
  }
};

const writeSensorData = (data) => {
  validateSensorData(data);

  const point = new Point('sensor_data')
    .tag('source', data.device || 'unknown_device');

  // Tambahkan field sesuai data yang ada
  if (data.ph_sensor !== undefined) point.floatField('ph_sensor', data.ph_sensor);
  if (data.pH_nano !== undefined) point.floatField('pH_nano', data.pH_nano);
  if (data.soil_moisture_1 !== undefined) point.floatField('soil_moisture_1', data.soil_moisture_1);
  if (data.soil_moisture_2 !== undefined) point.floatField('soil_moisture_2', data.soil_moisture_2);
  if (data.nano_moisture_1 !== undefined) point.floatField('nano_moisture_1', data.nano_moisture_1);
  if (data.nano_moisture_2 !== undefined) point.floatField('nano_moisture_2', data.nano_moisture_2);
  if (data.nano_moisture_3 !== undefined) point.floatField('nano_moisture_3', data.nano_moisture_3);
  if (data.humidity !== undefined) point.floatField('humidity', data.humidity);
  if (data.temperature !== undefined) point.floatField('temperature', data.temperature);
  if (data.lux !== undefined) point.floatField('lux', data.lux);
  if (data.flow_rate !== undefined) point.floatField('flow_rate', data.flow_rate);

  try {
    writeApi.writePoint(point);
    writeApi.flush();
  } catch (err) {
    console.error('Gagal menulis data sensor:', err);
    throw new Error('Gagal menulis data sensor');
  }
};

// Query umum dengan rentang waktu dan filter measurement sensor_data
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
      next: (row, tableMeta) => result.push(tableMeta.toObject(row)),
      error: reject,
      complete: () => resolve(result)
    });
  });
};

// Fungsi baru: ambil data sensor dari device tertentu
const querySensorDataByDevice = async (device, start = '-30d', stop = 'now()') => {
  const query = `
    from(bucket: "${bucket}")
      |> range(start: ${start}, stop: ${stop})
      |> filter(fn: (r) => r._measurement == "sensor_data")
      |> filter(fn: (r) => r.device == "${device}")
      |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
      |> sort(columns: ["_time"], desc: false)
  `;

  const result = [];
  return new Promise((resolve, reject) => {
    queryApi.queryRows(query, {
      next: (row, tableMeta) => result.push(tableMeta.toObject(row)),
      error: reject,
      complete: () => resolve(result)
    });
  });
};

const getSensorSummaryData = async () => {
  const query = `
    import "experimental/aggregate"

    from(bucket: "${bucket}")
      |> range(start: -30d)
      |> filter(fn: (r) => r._measurement == "sensor_data")
      |> filter(fn: (r) => r._field == "ph_sensor" or r._field == "pH_nano" or
                         r._field == "temperature" or r._field == "humidity" or
                         r._field == "lux" or
                         r._field == "flow_rate" or
                         r._field == "soil_moisture_1" or r._field == "soil_moisture_2" or
                         r._field == "nano_moisture_1" or r._field == "nano_moisture_2" or r._field == "nano_moisture_3")
      |> group(columns: ["_field"])
      |> reduce(
        identity: {min: 9999999.0, max: -9999999.0, sum: 0.0, count: 0},
        fn: (r, accumulator) => ({
          min: if r._value < accumulator.min then r._value else accumulator.min,
          max: if r._value > accumulator.max then r._value else accumulator.max,
          sum: accumulator.sum + r._value,
          count: accumulator.count + 1
        })
      )
  `;

  const results = {};

  return new Promise((resolve, reject) => {
    queryApi.queryRows(query, {
      next(row, tableMeta) {
        const obj = tableMeta.toObject(row);
        results[obj._field] = {
          min: obj.min,
          max: obj.max,
          avg: obj.sum / obj.count
        };
      },
      error(error) {
        reject(error);
      },
      complete() {
        resolve(results);
      }
    });
  });
};

module.exports = {
  writeSensorData,
  getLastHourSensorData: () => querySensorData('-1h', 'now()'),
  getDailySensorData: () => querySensorData('today()', 'now()'),
  getWeeklySensorData: () => querySensorData('-7d', 'now()'),
  getMonthlySensorData: () => querySensorData('-30d', 'now()'),
  getSensorSummaryData,
  getLatestSensorData: () => querySensorData('-1h', 'now()').then(data => data.length ? data[data.length - 1] : null),
  querySensorDataByDevice
};
