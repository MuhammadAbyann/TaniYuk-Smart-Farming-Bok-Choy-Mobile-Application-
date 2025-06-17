require('dotenv').config();
const { InfluxDB } = require('@influxdata/influxdb-client');

const url = process.env.INFLUXDB_URL;
const token = process.env.INFLUXDB_TOKEN;
const org = process.env.INFLUXDB_ORG;
const bucket = process.env.INFLUXDB_BUCKET;

const influxDB = new InfluxDB({ url, token });

const writeApi = influxDB.getWriteApi(org, bucket, 'ns');
writeApi.useDefaultTags({ source: 'pakcoy_device' });

const queryApi = influxDB.getQueryApi(org);


module.exports = { writeApi, queryApi, bucket, org };
