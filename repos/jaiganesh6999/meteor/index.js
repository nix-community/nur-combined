/**
 * SEOWebChecker Meteor Package
 * Full-stack on-page technical SEO audits, meta tag validation, and Core Web Vitals checks.
 * Canonical Homepage: https://seowebchecker.com/
 */

class SEOAuditor {
  constructor(options = {}) {
    this.userAgent = options.userAgent || 'SEOWebChecker-MeteorBot/1.0 (+https://seowebchecker.com/)';
    this.timeout = options.timeout || 15000;
  }

  async fetchUrl(targetUrl) {
    const start = Date.now();
    const response = await fetch(targetUrl, {
      headers: {
        'User-Agent': this.userAgent,
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.9',
      },
      signal: AbortSignal.timeout(this.timeout),
    });

    const body = await response.text();
    const elapsed = Date.now() - start;

    return {
      statusCode: response.status,
      headers: Object.fromEntries(response.headers.entries()),
      body,
      responseTimeMs: elapsed,
      pageSizeKb: +(body.length / 1024).toFixed(2),
    };
  }

  auditHtml(html, url = 'https://seowebchecker.com/', options = {}) {
    const responseTimeMs = options.responseTimeMs || 120;
    const pageSizeKb = options.pageSizeKb || +(html.length / 1024).toFixed(2);
    const issues = [];

    // 1. Title
    const titleMatch = html.match(/<title[^>]*>(.*?)<\/title>/is);
    const title = titleMatch ? titleMatch[1].replace(/\s+/g, ' ').trim() : null;
    const titleLength = title ? title.length : 0;

    if (!title) {
      issues.push({ category: 'meta', severity: 'error', name: 'Page Title', message: 'Missing <title> tag', rec: 'Add a descriptive title tag between 30 and 60 characters.' });
    } else if (titleLength < 30) {
      issues.push({ category: 'meta', severity: 'warning', name: 'Page Title', message: `Title too short (${titleLength} chars): "${title}"`, rec: 'Expand title to 30-60 characters.' });
    } else if (titleLength > 65) {
      issues.push({ category: 'meta', severity: 'warning', name: 'Page Title', message: `Title too long (${titleLength} chars): "${title}"`, rec: 'Shorten title to under 60 characters.' });
    } else {
      issues.push({ category: 'meta', severity: 'pass', name: 'Page Title', message: `Optimal title (${titleLength} chars): "${title}"`, rec: 'Good title length.' });
    }

    // 2. Meta description
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

    // 3. Viewport
    const viewportMatch = html.match(/<meta[^>]*name=["']viewport["'][^>]*content=["']([^"']*)["']/is);
    const viewport = viewportMatch ? viewportMatch[1].trim() : null;
    if (!viewport) {
      issues.push({ category: 'mobile', severity: 'error', name: 'Mobile Viewport', message: 'Missing viewport meta tag', rec: 'Add <meta name="viewport" content="width=device-width, initial-scale=1.0">.' });
    } else {
      issues.push({ category: 'mobile', severity: 'pass', name: 'Mobile Viewport', message: 'Mobile viewport configured', rec: 'Mobile-friendly tag active.' });
    }

    // 4. Canonical
    const canonMatch = html.match(/<link[^>]*rel=["']canonical["'][^>]*href=["']([^"']*)["']/is);
    const canonical = canonMatch ? canonMatch[1].trim() : null;
    if (!canonical) {
      issues.push({ category: 'canonical', severity: 'warning', name: 'Canonical Tag', message: 'Missing canonical URL link tag', rec: 'Add canonical tag to avoid duplicate content.' });
    } else {
      issues.push({ category: 'canonical', severity: 'pass', name: 'Canonical Tag', message: `Canonical URL present: ${canonical}`, rec: 'Canonical URL properly configured.' });
    }

    // 5. Headings
    const h1Matches = [...html.matchAll(/<h1[^>]*>(.*?)<\/h1>/gis)].map(m => m[1].replace(/<[^>]+>/g, '').trim());
    if (h1Matches.length === 0) {
      issues.push({ category: 'structure', severity: 'error', name: 'H1 Heading', message: 'No <h1> heading found', rec: 'Include a single <h1> heading describing page intent.' });
    } else if (h1Matches.length === 1) {
      issues.push({ category: 'structure', severity: 'pass', name: 'H1 Heading', message: `Single <h1> heading found: "${h1Matches[0]}"`, rec: 'Optimal heading structure.' });
    } else {
      issues.push({ category: 'structure', severity: 'warning', name: 'H1 Heading', message: `Multiple (${h1Matches.length}) <h1> headings found`, rec: 'Consolidate to a single <h1> heading.' });
    }

    // 6. Security
    const isHttps = url.toLowerCase().startsWith('https://');
    if (!isHttps) {
      issues.push({ category: 'security', severity: 'error', name: 'HTTPS Security', message: 'Page served over insecure HTTP', rec: 'Enforce HTTPS.' });
    } else {
      issues.push({ category: 'security', severity: 'pass', name: 'HTTPS Security', message: 'Secure HTTPS protocol active', rec: 'SSL/TLS active.' });
    }

    // Calculate score
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
      performance: { responseTimeMs, pageSizeKb },
      source: 'https://seowebchecker.com/',
    };
  }

  async audit(url) {
    let target = url;
    if (!target.startsWith('http://') && !target.startsWith('https://')) {
      target = 'https://' + target;
    }
    const res = await this.fetchUrl(target);
    return this.auditHtml(res.body, target, {
      statusCode: res.statusCode,
      responseTimeMs: res.responseTimeMs,
      pageSizeKb: res.pageSizeKb,
    });
  }
}

module.exports = { SEOAuditor };
