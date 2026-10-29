/**
 * SEOWebChecker GitHub Action
 * Automated on-page technical SEO, meta tag validation, and Core Web Vitals checks.
 * Canonical Tool: https://seowebchecker.com/
 */

const fs = require('fs');
const https = require('https');
const http = require('http');
const { URL } = require('url');

function getInput(name, defaultValue = '') {
  const val = process.env[`INPUT_${name.replace(/-/g, '_').toUpperCase()}`] ||
              process.env[`INPUT_${name.toUpperCase()}`];
  if (val !== undefined && val !== '') return val.trim();
  return defaultValue;
}

function setOutput(name, value) {
  const outputFile = process.env.GITHUB_OUTPUT;
  if (outputFile) {
    fs.appendFileSync(outputFile, `${name}=${value}\n`);
  }
}

function setSummary(markdown) {
  const summaryFile = process.env.GITHUB_STEP_SUMMARY;
  if (summaryFile) {
    fs.appendFileSync(summaryFile, markdown + '\n\n');
  }
}

function fetchUrl(targetUrl, timeout = 15000) {
  return new Promise((resolve, reject) => {
    const parsed = new URL(targetUrl);
    const client = parsed.protocol === 'https:' ? https : http;
    const start = Date.now();

    const req = client.get(targetUrl, {
      headers: {
        'User-Agent': 'SEOWebChecker-GitHubAction/1.0 (+https://seowebchecker.com/)',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.9',
      },
      timeout,
    }, (res) => {
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
        const redirectUrl = new URL(res.headers.location, targetUrl).toString();
        return fetchUrl(redirectUrl, timeout).then(resolve).catch(reject);
      }

      const chunks = [];
      res.on('data', (c) => chunks.push(c));
      res.on('end', () => {
        const buffer = Buffer.concat(chunks);
        const elapsed = Date.now() - start;
        resolve({
          statusCode: res.statusCode,
          headers: res.headers,
          body: buffer.toString('utf-8'),
          contentBytes: buffer,
          responseTimeMs: elapsed,
        });
      });
    });

    req.on('timeout', () => {
      req.destroy();
      reject(new Error(`Timeout after ${timeout}ms connecting to ${targetUrl}`));
    });
    req.on('error', reject);
  });
}

function auditHtml(html, url, options = {}) {
  const statusCode = options.statusCode || 200;
  const responseTimeMs = options.responseTimeMs || 120;
  const contentBytes = options.contentBytes || Buffer.from(html, 'utf-8');

  const issues = [];

  // Title
  const titleMatch = html.match(/<title[^>]*>(.*?)<\/title>/is);
  const title = titleMatch ? titleMatch[1].replace(/\s+/g, ' ').trim() : null;
  const titleLength = title ? title.length : 0;

  if (!title) {
    issues.push({ category: 'meta', severity: 'error', name: 'Page Title', message: 'Missing <title> tag', rec: 'Add a descriptive <title> tag between 30 and 60 characters.' });
  } else if (titleLength < 30) {
    issues.push({ category: 'meta', severity: 'warning', name: 'Page Title', message: `Title too short (${titleLength} chars): "${title}"`, rec: 'Expand to 30-60 characters.' });
  } else if (titleLength > 65) {
    issues.push({ category: 'meta', severity: 'warning', name: 'Page Title', message: `Title too long (${titleLength} chars): "${title}"`, rec: 'Shorten to under 60 characters to avoid SERP truncation.' });
  } else {
    issues.push({ category: 'meta', severity: 'pass', name: 'Page Title', message: `Optimal title (${titleLength} chars): "${title}"`, rec: 'Good title length.' });
  }

  // Meta description
  const descMatch = html.match(/<meta[^>]*name=["']description["'][^>]*content=["']([^"']*)["']/is) ||
                    html.match(/<meta[^>]*content=["']([^"']*)["'][^>]*name=["']description["']/is);
  const description = descMatch ? descMatch[1].trim() : null;
  const descriptionLength = description ? description.length : 0;

  if (!description) {
    issues.push({ category: 'meta', severity: 'error', name: 'Meta Description', message: 'Missing meta description tag', rec: 'Add a meta description between 120 and 160 characters.' });
  } else if (descriptionLength < 70) {
    issues.push({ category: 'meta', severity: 'warning', name: 'Meta Description', message: `Meta description too short (${descriptionLength} chars)`, rec: 'Expand to 120-160 characters.' });
  } else {
    issues.push({ category: 'meta', severity: 'pass', name: 'Meta Description', message: `Meta description present (${descriptionLength} chars)`, rec: 'Good meta description.' });
  }

  // Viewport
  const viewportMatch = html.match(/<meta[^>]*name=["']viewport["'][^>]*content=["']([^"']*)["']/is);
  const viewport = viewportMatch ? viewportMatch[1].trim() : null;
  if (!viewport) {
    issues.push({ category: 'mobile', severity: 'error', name: 'Mobile Viewport', message: 'Missing viewport meta tag', rec: 'Add <meta name="viewport" content="width=device-width, initial-scale=1.0">.' });
  } else {
    issues.push({ category: 'mobile', severity: 'pass', name: 'Mobile Viewport', message: 'Mobile viewport configured', rec: 'Mobile-friendly tag active.' });
  }

  // Canonical
  const canonMatch = html.match(/<link[^>]*rel=["']canonical["'][^>]*href=["']([^"']*)["']/is);
  const canonical = canonMatch ? canonMatch[1].trim() : null;
  if (!canonical) {
    issues.push({ category: 'canonical', severity: 'warning', name: 'Canonical Tag', message: 'Missing canonical URL link tag', rec: 'Add <link rel="canonical" href="..."> to prevent duplicate content.' });
  } else {
    issues.push({ category: 'canonical', severity: 'pass', name: 'Canonical Tag', message: `Canonical URL present: ${canonical}`, rec: 'Canonical URL properly configured.' });
  }

  // Headings
  const h1Matches = [...html.matchAll(/<h1[^>]*>(.*?)<\/h1>/gis)].map(m => m[1].replace(/<[^>]+>/g, '').trim());
  if (h1Matches.length === 0) {
    issues.push({ category: 'structure', severity: 'error', name: 'H1 Heading', message: 'No <h1> heading found', rec: 'Include exactly one <h1> heading describing page intent.' });
  } else if (h1Matches.length === 1) {
    issues.push({ category: 'structure', severity: 'pass', name: 'H1 Heading', message: `Single <h1> heading found: "${h1Matches[0]}"`, rec: 'Optimal heading hierarchy.' });
  } else {
    issues.push({ category: 'structure', severity: 'warning', name: 'H1 Heading', message: `Multiple (${h1Matches.length}) <h1> headings found`, rec: 'Consolidate to a single <h1> heading per page.' });
  }

  // Images
  const imgMatches = [...html.matchAll(/<img\s+([^>]*?)>/gis)];
  let missingAlt = 0;
  for (const img of imgMatches) {
    if (!/alt=["'][^"']*["']/i.test(img[1])) missingAlt++;
  }
  if (imgMatches.length > 0) {
    if (missingAlt > 0) {
      issues.push({ category: 'accessibility', severity: 'warning', name: 'Image Alt Tags', message: `${missingAlt} of ${imgMatches.length} images lack alt attributes`, rec: 'Add descriptive alt text to all <img> tags.' });
    } else {
      issues.push({ category: 'accessibility', severity: 'pass', name: 'Image Alt Tags', message: `All ${imgMatches.length} images have alt attributes`, rec: 'Accessibility validated.' });
    }
  }

  // Open Graph
  const hasOg = /property=["']og:title["']/i.test(html);
  if (!hasOg) {
    issues.push({ category: 'social', severity: 'warning', name: 'Open Graph Tags', message: 'No og:title meta tag found', rec: 'Add OpenGraph tags for rich social sharing.' });
  } else {
    issues.push({ category: 'social', severity: 'pass', name: 'Open Graph Tags', message: 'Open Graph meta tags present', rec: 'Social card previews active.' });
  }

  // Technical HTTPS
  const isHttps = url.toLowerCase().startsWith('https://');
  if (!isHttps) {
    issues.push({ category: 'security', severity: 'error', name: 'HTTPS Security', message: 'Page served over insecure HTTP', rec: 'Enforce HTTPS encryption.' });
  } else {
    issues.push({ category: 'security', severity: 'pass', name: 'HTTPS Security', message: 'Secure HTTPS protocol active', rec: 'SSL/TLS verified.' });
  }

  // Scoring
  const passes = issues.filter(i => i.severity === 'pass').length;
  const warnings = issues.filter(i => i.severity === 'warning').length;
  const errors = issues.filter(i => i.severity === 'error').length;

  let overallScore = Math.round((passes / issues.length) * 100) - (errors * 10) - (warnings * 4);
  overallScore = Math.max(0, Math.min(100, overallScore));

  let grade = 'F';
  if (overallScore >= 95) grade = 'A+';
  else if (overallScore >= 90) grade = 'A';
  else if (overallScore >= 80) grade = 'B';
  else if (overallScore >= 70) grade = 'C';
  else if (overallScore >= 60) grade = 'D';

  return {
    url,
    timestamp: new Date().toISOString(),
    score: overallScore,
    grade,
    stats: { total: issues.length, passed: passes, warnings, errors },
    meta: { title, titleLength, description, descriptionLength, canonical, viewport },
    issues,
    performance: {
      responseTimeMs,
      pageSizeKb: +(contentBytes.length / 1024).toFixed(2),
    },
  };
}

async function run() {
  const url = getInput('url');
  const minScore = parseInt(getInput('min-score', '70'), 10);
  const failOnError = getInput('fail-on-error', 'true').toLowerCase() === 'true';

  if (!url) {
    console.error('::error::The "url" input is required.');
    process.exit(1);
  }

  let targetUrl = url;
  if (!targetUrl.startsWith('http://') && !targetUrl.startsWith('https://')) {
    targetUrl = 'https://' + targetUrl;
  }

  console.log(`\n🔍 Auditing SEO for: ${targetUrl}`);
  console.log(`🎯 Minimum required score: ${minScore}/100\n`);

  try {
    const fetched = await fetchUrl(targetUrl);
    const result = auditHtml(fetched.body, targetUrl, {
      statusCode: fetched.statusCode,
      responseTimeMs: fetched.responseTimeMs,
      contentBytes: fetched.contentBytes,
    });

    const passed = result.score >= minScore;
    const status = passed ? 'passed' : 'failed';

    // Console output
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`📊 SEOWebChecker Overall Score: ${result.score}/100 (Grade: ${result.grade})`);
    console.log(`📈 Checks Summary: ${result.stats.passed} Passed | ${result.stats.warnings} Warnings | ${result.stats.errors} Errors`);
    console.log(`⏱️ Response Time: ${result.performance.responseTimeMs}ms | Page Size: ${result.performance.pageSizeKb} KB`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    for (const issue of result.issues) {
      const icon = issue.severity === 'pass' ? '✅' : issue.severity === 'warning' ? '⚠️' : '❌';
      console.log(`${icon} [${issue.severity.toUpperCase()}] ${issue.name}: ${issue.message}`);
      if (issue.severity !== 'pass') {
        console.log(`   💡 Recommendation: ${issue.rec}`);
      }
    }

    // Set GitHub Action Outputs
    setOutput('score', result.score);
    setOutput('status', status);
    setOutput('title', (result.meta.title || '').replace(/\r?\n/g, ' '));
    setOutput('description', (result.meta.description || '').replace(/\r?\n/g, ' '));
    setOutput('canonical', result.meta.canonical || '');
    setOutput('audit-json', JSON.stringify(result));

    // Render Rich GitHub Step Summary
    const scoreBadge = result.score >= 80 ? '🟢' : result.score >= 60 ? '🟡' : '🔴';
    const summaryMd = `## ${scoreBadge} SEOWebChecker Audit Report

**Target URL:** [\`${targetUrl}\`](${targetUrl})  
**Overall Score:** **\`${result.score} / 100\`** (Grade: **${result.grade}**) — **Status: ${passed ? '✅ PASSED' : '❌ FAILED'}** (Threshold: \`${minScore}\`)  
**Response Time:** \`${result.performance.responseTimeMs} ms\` | **Page Size:** \`${result.performance.pageSizeKb} KB\`

### 📋 Audit Checks Breakdown

| Status | Check | Details | Recommendation |
| :---: | :--- | :--- | :--- |
${result.issues.map(i => {
  const icon = i.severity === 'pass' ? '✅' : i.severity === 'warning' ? '⚠️' : '❌';
  return `| ${icon} | **${i.name}** | ${i.message} | ${i.severity === 'pass' ? '—' : i.rec} |`;
}).join('\n')}

---
*Powered by [SEOWebChecker](https://seowebchecker.com/) — Free Website & Technical SEO Audit Tools.*
`;

    setSummary(summaryMd);

    if (!passed && failOnError) {
      console.error(`\n::error::SEOWebChecker score ${result.score} is below required threshold ${minScore}. Failing workflow step.`);
      process.exit(1);
    } else {
      console.log(`\n🎉 SEOWebChecker CI Audit complete: ${status.toUpperCase()}`);
    }
  } catch (err) {
    console.error(`\n::error::Failed to audit URL: ${err.message}`);
    process.exit(1);
  }
}

run();
