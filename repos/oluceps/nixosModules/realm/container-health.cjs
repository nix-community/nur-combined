const http = require('node:http');
const request = http.get((process.env.REALM_HEALTH_PORT
  ? { host: '127.0.0.1', port: Number(process.env.REALM_HEALTH_PORT), path: '/health' }
  : { socketPath: '/realm/backend/http.sock', path: '/' }), (response) => {
  response.resume();
  process.exit(response.statusCode < 500 ? 0 : 1);
});
request.setTimeout(5000, () => { request.destroy(); process.exit(1); });
request.on('error', () => process.exit(1));
