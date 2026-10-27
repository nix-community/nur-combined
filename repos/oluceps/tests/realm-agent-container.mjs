// Run in an isolated copy of the locally available Misskey image. The helper
// performs the readiness handshake before this script starts.
import assert from 'node:assert/strict';
import dns from 'node:dns/promises';
import https from 'node:https';
import fs from 'node:fs';
import CacheableLookup from '/misskey/packages/backend/node_modules/cacheable-lookup/source/index.js';

for (const name of Object.keys(process.env)) {
  if (name.toLowerCase().endsWith('proxy')) delete process.env[name];
}
assert.deepEqual(await dns.resolve4('s3.nyaw.xyz'), ['203.0.113.8']);
const cache = new CacheableLookup({ lookup: false });
const answer = await cache.lookupAsync('s3.nyaw.xyz');
assert.equal(answer.address, '203.0.113.8');
// eihort's host resolver uses sing-box fake-IP. Application DNS must instead
// return the DoH answer obtained through its authenticated Internet egress.
const publicDNS = await Promise.all([dns.resolve4('example.com'), dns.resolve6('example.com')]);
assert(publicDNS.flat().length > 0);
assert(publicDNS[0].every(address => !address.startsWith('30.40.')));
assert(publicDNS[1].every(address => !address.startsWith('3072:a866:35c6:b73:26e5:d2e3:3fb2:')));

async function request(url, lookup) {
  return new Promise((resolve, reject) => {
    const req = https.get(url, { lookup, timeout: 15000 }, response => {
      let bytes = 0;
      response.on('data', chunk => { bytes += chunk.length; });
      response.on('end', () => resolve({ status: response.statusCode, type: response.headers['content-type'], bytes }));
    });
    req.on('error', reject);
    req.on('timeout', () => req.destroy(new Error('timeout')));
  });
}

const avatar = await request(
  'https://s3.nyaw.xyz/misskey/c638199d-2478-4904-a36b-d5f3e595e7b5.webp', cache.lookup,
);
assert.equal(avatar.status, 200);
assert.equal(avatar.type, 'image/webp');
assert(avatar.bytes > 0);
const internet = await request('https://example.com/', cache.lookup);
assert.equal(internet.status, 200);
const interfaces = fs.readFileSync('/proc/net/dev', 'utf8').split('\n').filter(line => line.includes(':'));
const allowed = new Set(['lo', 'realm0', 'ip6tnl0', 'gre0', 'gretap0', 'erspan0']);
assert(interfaces.every(line => allowed.has(line.split(':')[0].trim())));
assert(interfaces.some(line => /lo:/.test(line)));
assert(interfaces.some(line => /realm0:/.test(line)));
console.log(JSON.stringify({ cacheableLookup: answer.address, publicDNS, avatar, internet, network: 'loopback and dummy, no external link' }));
