/**
 * Verification test for PureScript FFI bridge
 * Run with: node purescript/test_runner.js
 */

import { auditHtmlImpl, generateMarkdownImpl } from './src/SEOWebChecker.js';

console.log("=========================================================");
console.log("  SEOWebChecker: PureScript FFI Bridge Verification Test ");
console.log("=========================================================\n");

const html = `
<!DOCTYPE html>
<html>
<head>
  <title>SEOWebChecker PureScript Client Integration</title>
  <meta name="description" content="PureScript client library for validating on-page technical SEO, meta tags, and Core Web Vitals.">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="canonical" href="https://seowebchecker.com/">
  <meta property="og:title" content="SEOWebChecker">
  <script type="application/ld+json">{"@context":"https://schema.org","@type":"WebSite"}</script>
</head>
<body>
  <h1>Primary Technical SEO Diagnostic</h1>
  <p>${"Comprehensive SEO checking and validation for functional programming languages and web applications. ".repeat(20)}</p>
  <img src="banner.png" alt="PureScript Architecture Diagram">
</body>
</html>
`;

// PureScript curried call: auditHtmlImpl(html)(url)
const report = auditHtmlImpl(html)("https://seowebchecker.com/");

console.log("Report URL:", report.url);
console.log("Score:", report.score.overall, `(${report.score.grade})`);
console.log("Stats: Passed:", report.stats.passed, "| Warnings:", report.stats.warnings, "| Errors:", report.stats.errors);

const md = generateMarkdownImpl(report);
console.log("Markdown preview length:", md.length, "bytes");

if (report.score.overall >= 90 && report.stats.passed >= 7 && md.includes("SEO Audit Report")) {
  console.log("\n>>> ALL PURESCRIPT FFI TESTS PASSED SUCCESSFULLY!");
  process.exit(0);
} else {
  console.error("Test failed!");
  process.exit(1);
}
