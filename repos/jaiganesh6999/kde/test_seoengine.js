/**
 * Test Suite for SEOWebChecker KDE Plasmoid Engine
 * Run with: node kde/test_seoengine.js
 */

const fs = require('fs');
const path = require('path');

console.log("=========================================================");
console.log("  SEOWebChecker: KDE Plasmoid Engine Verification Test   ");
console.log("=========================================================\n");

// Read and evaluate seoengine.js (strip .pragma library for Node.js)
const engineCode = fs.readFileSync(path.join(__dirname, 'contents/code/seoengine.js'), 'utf8')
    .replace('.pragma library', '');

// Evaluate in local context
const ctx = {};
const fn = new Function('exports', engineCode + '\nexports.auditHtml = auditHtml;\nexports.createOfflineReport = createOfflineReport;');
fn(ctx);

let passed = 0;
let total = 0;

function test(name, assertion) {
    total++;
    process.stdout.write(`[TEST ${total}] ${name}... `);
    try {
        if (assertion()) {
            console.log("PASSED [OK]");
            passed++;
        } else {
            console.log("FAILED");
        }
    } catch (e) {
        console.log("EXCEPTION: " + e.message);
    }
}

// TEST 1: Full Valid HTML
test("Audit complete well-optimized HTML document", () => {
    const html = `
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <title>SEOWebChecker - Technical On-Page SEO Analyzer</title>
        <meta name="description" content="Instant technical SEO diagnostics, meta tag validations, heading structure inspections, and Core Web Vitals checks.">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="canonical" href="https://seowebchecker.com/">
        <meta property="og:title" content="SEOWebChecker">
        <script type="application/ld+json">{"@context":"https://schema.org","@type":"WebSite"}</script>
    </head>
    <body>
        <h1>SEOWebChecker Technical SEO Audit Platform</h1>
        <p>${"Comprehensive technical SEO tools for modern web applications and sites. ".repeat(25)}</p>
        <img src="banner.png" alt="Platform Overview Diagram">
    </body>
    </html>
    `;

    const report = ctx.auditHtml(html, "https://seowebchecker.com/");
    if (!report.success) return false;
    if (report.score.overall < 90) return false;
    if (report.stats.errors !== 0) return false;
    if (report.stats.passed < 7) return false;

    console.log(`\n    -> Score: ${report.score.overall}/100 (${report.score.grade}), Total Checks: ${report.stats.total} (Passed: ${report.stats.passed}, Warnings: ${report.stats.warnings})`);
    return true;
});

// TEST 2: Deficient / Problematic HTML
test("Audit deficient HTML with missing tags & thin content", () => {
    const html = `
    <html>
    <head></head>
    <body>
        <p>Short note.</p>
        <img src="test.jpg">
    </body>
    </html>
    `;

    const report = ctx.auditHtml(html, "https://example.com/");
    if (!report.success) return false;
    if (report.score.overall > 50) return false;
    if (report.stats.errors < 3) return false; // Missing title, description, viewport, H1

    console.log(`\n    -> Score: ${report.score.overall}/100 (${report.score.grade}), Errors: ${report.stats.errors}, Warnings: ${report.stats.warnings}`);
    return true;
});

// TEST 3: Metadata JSON verification
test("Verify KDE metadata.json format and requirements", () => {
    const meta = JSON.parse(fs.readFileSync(path.join(__dirname, 'metadata.json'), 'utf8'));
    if (!meta.KPlugin) return false;
    if (meta.KPlugin.Id !== 'org.kde.plasma.seowebchecker') return false;
    if (meta.KPlugin.Website !== 'https://seowebchecker.com/') return false;
    if (!meta.KPackageStructure) return false;
    return true;
});

// TEST 4: Config file validation
test("Verify KConfigXT main.xml exists and has targetUrl", () => {
    const xml = fs.readFileSync(path.join(__dirname, 'contents/config/main.xml'), 'utf8');
    return xml.includes('name="targetUrl"') && xml.includes('https://seowebchecker.com/');
});

console.log("\n---------------------------------------------------------");
console.log(`  SUMMARY: ${passed} of ${total} tests passed successfully.`);
console.log("---------------------------------------------------------");

if (passed === total) {
    console.log(">>> ALL TESTS PASSED! KDE Plasma Widget logic is verified.");
    process.exit(0);
} else {
    process.exit(1);
}
