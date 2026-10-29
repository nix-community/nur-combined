// SEOWebChecker - n8n Workflow Logic Unit Test
// Tests the exact JavaScript evaluation logic embedded inside seowebchecker-technical-seo-audit.json

const https = require('https');
const http = require('http');

const targetUrl = process.argv[2] || 'https://seowebchecker.com/';
const threshold = 85;

console.log('======================================================');
console.log('  SEOWebChecker: n8n Workflow Verification Test');
console.log('======================================================');
console.log(`Auditing target URL: ${targetUrl}`);
console.log(`Alert Threshold:    ${threshold} / 100\n`);

function fetchHtml(url) {
  return new Promise((resolve, reject) => {
    const client = url.startsWith('https') ? https : http;
    client.get(url, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (compatible; SEOWebChecker-Bot/1.0; +https://seowebchecker.com/)'
      }
    }, (res) => {
      let data = '';
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
        return resolve(fetchHtml(res.headers.location));
      }
      res.on('data', chunk => data += chunk);
      res.on('end', () => resolve(data));
    }).on('error', reject);
  });
}

async function run() {
  try {
    const html = await fetchHtml(targetUrl);
    console.log(`Successfully fetched ${html.length} bytes of HTML.\n`);

    // --- EXACT N8N CODE NODE LOGIC START ---
    const issues = [];
    const passes = [];
    let score = 100;

    // 1. Title Tag Check
    const titleMatch = html.match(/<title[^>]*>([^<]*)<\/title>/i);
    const title = titleMatch ? titleMatch[1].trim() : null;
    if (!title) {
      issues.push('Missing <title> tag (-20 pts)');
      score -= 20;
    } else if (title.length < 30) {
      issues.push(`Title tag too short (${title.length} chars, recommended 30-60) (-5 pts)`);
      score -= 5;
    } else if (title.length > 60) {
      issues.push(`Title tag may truncate in search (${title.length} chars, recommended 30-60) (-5 pts)`);
      score -= 5;
    } else {
      passes.push(`Title tag optimal (${title.length} chars)`);
    }

    // 2. Meta Description Check
    const metaDescMatch = html.match(/<meta[^>]*name=["']description["'][^>]*content=["']([^"']*)["'][^>]*>/i)
      || html.match(/<meta[^>]*content=["']([^"']*)["'][^>]*name=["']description["'][^>]*>/i);
    const metaDesc = metaDescMatch ? metaDescMatch[1].trim() : null;
    if (!metaDesc) {
      issues.push('Missing meta description tag (-15 pts)');
      score -= 15;
    } else if (metaDesc.length < 70) {
      issues.push(`Meta description too short (${metaDesc.length} chars, recommended 70-160) (-5 pts)`);
      score -= 5;
    } else if (metaDesc.length > 160) {
      issues.push(`Meta description exceeds recommended length (${metaDesc.length} chars) (-5 pts)`);
      score -= 5;
    } else {
      passes.push(`Meta description optimal (${metaDesc.length} chars)`);
    }

    // 3. Heading Hierarchy (H1 validation)
    const h1Matches = html.match(/<h1[^>]*>/gi) || [];
    if (h1Matches.length === 0) {
      issues.push('Missing <h1> tag (-15 pts)');
      score -= 15;
    } else if (h1Matches.length > 1) {
      issues.push(`Multiple <h1> tags detected (${h1Matches.length} found) (-10 pts)`);
      score -= 10;
    } else {
      passes.push('Exactly one <h1> heading present');
    }

    // 4. Viewport Mobile Readiness
    const viewportMatch = html.match(/<meta[^>]*name=["']viewport["'][^>]*>/i);
    if (!viewportMatch) {
      issues.push('Missing mobile viewport meta tag (-15 pts)');
      score -= 15;
    } else {
      passes.push('Mobile viewport meta tag configured');
    }

    // 5. Canonical Link Tag
    const canonicalMatch = html.match(/<link[^>]*rel=["']canonical["'][^>]*>/i);
    if (!canonicalMatch) {
      issues.push('Missing canonical link tag (-10 pts)');
      score -= 10;
    } else {
      passes.push('Canonical link tag present');
    }

    // 6. Image Accessibility (Alt text check)
    const imgMatches = html.match(/<img[^>]*>/gi) || [];
    let missingAltCount = 0;
    imgMatches.forEach(img => {
      if (!img.match(/alt=["'][^"']*["']/i)) {
        missingAltCount++;
      }
    });
    if (missingAltCount > 0) {
      issues.push(`${missingAltCount} image(s) missing alt attribute (-10 pts)`);
      score -= 10;
    } else if (imgMatches.length > 0) {
      passes.push(`All ${imgMatches.length} images include alt attributes`);
    }

    // 7. OpenGraph Social Sharing Card Check
    const ogTitle = html.match(/<meta[^>]*property=["']og:title["'][^>]*>/i);
    const ogImage = html.match(/<meta[^>]*property=["']og:image["'][^>]*>/i);
    if (!ogTitle || !ogImage) {
      issues.push('Incomplete OpenGraph tags (og:title / og:image missing) (-5 pts)');
      score -= 5;
    } else {
      passes.push('OpenGraph social tags present');
    }

    score = Math.max(0, score);
    let grade = 'F';
    if (score >= 90) grade = 'A';
    else if (score >= 80) grade = 'B';
    else if (score >= 70) grade = 'C';
    else if (score >= 60) grade = 'D';

    const status = score >= threshold ? 'PASS' : 'ALERT';
    // --- EXACT N8N CODE NODE LOGIC END ---

    console.log('--- AUDIT RESULTS ---');
    console.log(`Title:       ${title || 'N/A'}`);
    console.log(`Description: ${metaDesc || 'N/A'}`);
    console.log(`Score:       ${score} / 100 (Grade: ${grade})`);
    console.log(`Status:      ${status}`);
    console.log(`\nChecks Passed (${passes.length}):`);
    passes.forEach(p => console.log(`  ✓ ${p}`));

    if (issues.length > 0) {
      console.log(`\nIssues Detected (${issues.length}):`);
      issues.forEach(i => console.log(`  ⚠ ${i}`));
    } else {
      console.log('\nNo technical SEO issues found!');
    }

    console.log('\n======================================================');
    console.log('Verdict: Workflow logic executed successfully!');
    console.log('======================================================');
  } catch (err) {
    console.error('Test execution failed:', err.message);
    process.exit(1);
  }
}

run();
