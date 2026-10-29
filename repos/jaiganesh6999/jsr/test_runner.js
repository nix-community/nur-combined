import assert from 'node:assert/strict';
import { auditHtml, formatConsole, formatMarkdown } from './mod.ts';

console.log('Testing @seowebchecker/audit JSR package...');

const sampleHtml = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>SEOWebChecker: Free SEO Audit & Technical Analysis Tools</title>
  <meta name="description" content="Free open-source SEO audit tools for technical scorecards, meta tags, and Core Web Vitals.">
  <link rel="canonical" href="https://seowebchecker.com/">
  <meta property="og:title" content="SEOWebChecker SEO Tools">
</head>
<body>
  <h1>Optimize Your Search Engine Presence</h1>
  <p>Run instant diagnostic audits on your web pages. Discover comprehensive technical insights and recommendations.</p>
  <img src="banner.webp" alt="SEO Analysis Dashboard">
</body>
</html>
`;

const result = auditHtml(sampleHtml, { url: 'https://seowebchecker.com/' });

console.log(`Report generated for: ${result.url}`);
console.log(`Overall Score: ${result.score.overall} (Grade: ${result.score.grade})`);
console.log(`Passed checks: ${result.stats.passed}, Warnings: ${result.stats.warnings}, Errors: ${result.stats.errors}`);

assert.equal(result.url, 'https://seowebchecker.com/');
assert.ok(result.score.overall >= 80, `Expected score >= 80, got ${result.score.overall}`);
assert.equal(result.meta.title, 'SEOWebChecker: Free SEO Audit & Technical Analysis Tools');
assert.equal(result.content.h1_tags[0], 'Optimize Your Search Engine Presence');
assert.equal(result.images.missing_alt, 0);

// Test empty HTML error reporting
const emptyResult = auditHtml('<html><body></body></html>', { url: 'https://example.com' });
assert.ok(emptyResult.stats.errors > 0, 'Expected errors on empty HTML');

// Test formatters
const consoleOutput = formatConsole(result);
assert.ok(consoleOutput.includes('SEOWebChecker Audit Report'));

const mdOutput = formatMarkdown(result);
assert.ok(mdOutput.includes('# SEO Audit Report: https://seowebchecker.com/'));

console.log('✅ All @seowebchecker/audit tests passed successfully!');
