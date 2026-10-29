const assert = require('assert');
const seoWebCheckerPlugin = require('../index');

console.log('Testing vite-plugin-seowebchecker...');

// 1. Instantiation test
const plugin = seoWebCheckerPlugin({ verbose: false });
assert.strictEqual(plugin.name, 'vite-plugin-seowebchecker');
assert.strictEqual(typeof plugin.transformIndexHtml.handler, 'function');

// 2. HTML transformation test
const sampleHtml = `
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Vite Site Title</title>
  <meta name="description" content="A test site for Vite build checks.">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="canonical" href="https://example.com/">
</head>
<body>
  <h1>Welcome</h1>
</body>
</html>
`;

const resultHtml = plugin.transformIndexHtml.handler(sampleHtml, { path: '/index.html' });
assert.strictEqual(resultHtml, sampleHtml);

// 3. Fails on error when failOnError is true
const failingPlugin = seoWebCheckerPlugin({ failOnError: true, verbose: false });
const defectiveHtml = '<html><body>No meta tags</body></html>';

assert.throws(() => {
  failingPlugin.transformIndexHtml.handler(defectiveHtml, { path: '/broken.html' });
}, /SEO audit failed/);

console.log('All vite-plugin-seowebchecker tests passed successfully!');
