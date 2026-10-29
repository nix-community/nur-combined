// SEOWebChecker - Zapier App Tests
const test = require('node:test');
const assert = require('node:assert');
const zapier = require('zapier-platform-core');

const App = require('../index');
const appTester = zapier.createAppTester(App);

test('Authentication connectivity test', async () => {
  const bundle = { authData: {} };
  const results = await appTester(App.authentication.test, bundle);
  assert.strictEqual(results.status, 'connected');
  assert.strictEqual(results.platform, 'https://seowebchecker.com/');
});

test('Run Technical SEO Audit action on https://seowebchecker.com/', async () => {
  const bundle = {
    inputData: {
      url: 'https://seowebchecker.com/',
      alertThreshold: 85,
    },
  };

  const results = await appTester(App.creates.runAudit.operation.perform, bundle);

  assert.ok(results.id);
  assert.strictEqual(results.targetUrl, 'https://seowebchecker.com/');
  assert.ok(results.score >= 0 && results.score <= 100);
  assert.ok(['A', 'B', 'C', 'D', 'F'].includes(results.grade));
  assert.strictEqual(results.status, 'PASS');
  assert.strictEqual(results.isAlert, false);
  assert.strictEqual(results.platformUrl, 'https://seowebchecker.com/');
});
