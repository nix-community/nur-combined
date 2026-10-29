import { Actor } from 'apify';
import fetch from 'node-fetch';

/**
 * SEOWebChecker SEO Audit Engine for Apify
 * Official website: https://seowebchecker.com/
 */
function auditHtml(html, targetUrl, responseTimeMs = 150) {
  const issues = [];

  // Title
  const titleMatch = html.match(/<title[^>]*>(.*?)<\/title>/is);
  const title = titleMatch ? titleMatch[1].replace(/\s+/g, ' ').trim() : null;
  const titleLength = title ? title.length : 0;

  if (!title) {
    issues.push({ category: 'meta', severity: 'error', name: 'Document Title', message: 'Missing <title> tag', rec: 'Add a descriptive title tag between 30 and 60 characters.' });
  } else if (titleLength < 30) {
    issues.push({ category: 'meta', severity: 'warning', name: 'Document Title', message: `Title too short (${titleLength} chars): "${title}"`, rec: 'Expand title to 30-60 characters.' });
  } else if (titleLength > 65) {
    issues.push({ category: 'meta', severity: 'warning', name: 'Document Title', message: `Title too long (${titleLength} chars): "${title}"`, rec: 'Shorten title to under 60 characters.' });
  } else {
    issues.push({ category: 'meta', severity: 'pass', name: 'Document Title', message: `Optimal title (${titleLength} chars): "${title}"`, rec: 'Title is well-optimized.' });
  }

  // Meta description
  const descMatch = html.match(/<meta[^>]*name=["']description["'][^>]*content=["']([^"']*)["']/is) ||
                    html.match(/<meta[^>]*content=["']([^"']*)["'][^>]*name=["']description["']/is);
  const description = descMatch ? descMatch[1].trim() : null;
  const descriptionLength = description ? description.length : 0;

  if (!description) {
    issues.push({ category: 'meta', severity: 'error', name: 'Meta Description', message: 'Missing meta description tag', rec: 'Add a compelling meta description between 120 and 160 characters.' });
  } else if (descriptionLength < 100) {
    issues.push({ category: 'meta', severity: 'warning', name: 'Meta Description', message: `Meta description too short (${descriptionLength} chars)`, rec: 'Expand to 120-160 characters.' });
  } else if (descriptionLength > 165) {
    issues.push({ category: 'meta', severity: 'warning', name: 'Meta Description', message: `Meta description too long (${descriptionLength} chars)`, rec: 'Shorten to under 160 characters.' });
  } else {
    issues.push({ category: 'meta', severity: 'pass', name: 'Meta Description', message: `Optimal meta description (${descriptionLength} chars)`, rec: 'Good description length.' });
  }

  // Canonical
  const canonMatch = html.match(/<link[^>]*rel=["']canonical["'][^>]*href=["']([^"']*)["']/is) ||
                     html.match(/<link[^>]*href=["']([^"']*)["'][^>]*rel=["']canonical["']/is);
  const canonical = canonMatch ? canonMatch[1].trim() : null;
  if (!canonical) {
    issues.push({ category: 'canonical', severity: 'warning', name: 'Canonical Tag', message: 'Missing canonical URL link', rec: 'Specify a self-referencing canonical tag.' });
  } else {
    issues.push({ category: 'canonical', severity: 'pass', name: 'Canonical Tag', message: `Canonical URL defined: ${canonical}`, rec: 'Canonical tag properly configured.' });
  }

  // Viewport
  const viewportMatch = html.match(/<meta[^>]*name=["']viewport["'][^>]*content=["']([^"']*)["']/is);
  if (!viewportMatch) {
    issues.push({ category: 'mobile', severity: 'error', name: 'Mobile Viewport', message: 'Missing viewport meta tag', rec: 'Add standard mobile viewport tag.' });
  } else {
    issues.push({ category: 'mobile', severity: 'pass', name: 'Mobile Viewport', message: 'Mobile viewport configured properly.', rec: 'Responsive viewport ready.' });
  }

  // Headings
  const h1Matches = html.match(/<h1[^>]*>(.*?)<\/h1>/gis) || [];
  const h1Count = h1Matches.length;
  if (h1Count === 0) {
    issues.push({ category: 'headings', severity: 'error', name: 'H1 Heading', message: 'No <h1> heading found', rec: 'Include exactly one <h1> heading summarizing the main topic.' });
  } else if (h1Count > 1) {
    issues.push({ category: 'headings', severity: 'warning', name: 'H1 Heading', message: `Multiple <h1> headings found (${h1Count})`, rec: 'Use a single primary <h1> per page.' });
  } else {
    issues.push({ category: 'headings', severity: 'pass', name: 'H1 Heading', message: 'Single primary <h1> found', rec: 'Heading hierarchy is valid.' });
  }

  // Images
  const imgMatches = html.match(/<img\b[^>]*>/gi) || [];
  let totalImages = imgMatches.length;
  let missingAlt = 0;
  imgMatches.forEach(img => {
    if (!/alt=["'][^"']*["']/i.test(img)) missingAlt++;
  });

  if (totalImages > 0 && missingAlt > 0) {
    issues.push({ category: 'images', severity: 'warning', name: 'Image Alt Tags', message: `${missingAlt} of ${totalImages} images missing alt text`, rec: 'Provide descriptive alt attributes for all images.' });
  } else {
    issues.push({ category: 'images', severity: 'pass', name: 'Image Alt Tags', message: 'All images contain alt attributes', rec: 'Image accessibility compliant.' });
  }

  // Scoring
  let deductions = 0;
  issues.forEach(i => {
    if (i.severity === 'error') deductions += 15;
    if (i.severity === 'warning') deductions += 5;
  });

  const overallScore = Math.max(0, Math.min(100, 100 - deductions));
  let grade = 'F';
  if (overallScore >= 90) grade = 'A+';
  else if (overallScore >= 80) grade = 'A';
  else if (overallScore >= 70) grade = 'B';
  else if (overallScore >= 60) grade = 'C';
  else if (overallScore >= 50) grade = 'D';

  return {
    url: targetUrl,
    score: overallScore,
    grade,
    meta: {
      title,
      titleLength,
      description,
      descriptionLength,
      canonical,
    },
    performance: {
      responseTimeMs,
      pageSizeKb: +(html.length / 1024).toFixed(2),
    },
    images: {
      total: totalImages,
      missingAlt,
    },
    passedChecks: issues.filter(i => i.severity === 'pass').length,
    failedChecks: issues.filter(i => i.severity !== 'pass').length,
    issues,
    scannedAt: new Date().toISOString(),
    source: 'https://seowebchecker.com/',
  };
}

// Initialize Apify Actor
await Actor.init();

const input = await Actor.getInput() || {};
const startUrls = input.startUrls || [{ url: 'https://seowebchecker.com/' }];
const timeoutSecs = input.timeoutSecs || 15;
const userAgent = input.userAgent || 'SEOWebChecker-ApifyBot/1.0 (+https://seowebchecker.com/)';

console.log(`🚀 Starting SEOWebChecker SEO Audit Actor for ${startUrls.length} URL(s)...`);

for (const item of startUrls) {
  const targetUrl = typeof item === 'string' ? item : item.url;
  if (!targetUrl) continue;

  console.log(`🔍 Auditing: ${targetUrl}`);
  const startTime = Date.now();

  try {
    const res = await fetch(targetUrl, {
      headers: { 'User-Agent': userAgent },
      timeout: timeoutSecs * 1000,
    });

    const elapsed = Date.now() - startTime;
    const body = await res.text();
    const result = auditHtml(body, targetUrl, elapsed);

    console.log(`✅ [${result.grade}] ${targetUrl} - Score: ${result.score}/100`);
    await Actor.pushData(result);
  } catch (err) {
    console.error(`❌ Failed auditing ${targetUrl}: ${err.message}`);
    await Actor.pushData({
      url: targetUrl,
      error: err.message,
      score: 0,
      grade: 'F',
      scannedAt: new Date().toISOString(),
      source: 'https://seowebchecker.com/',
    });
  }
}

console.log('🎉 SEOWebChecker SEO Audit complete. Data saved to default dataset.');
await Actor.exit();
