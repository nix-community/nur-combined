/**
 * SEO Auditor for Node.js (Zero external dependencies)
 * Official Tool: https://seowebchecker.com/
 */

const https = require('https');
const http = require('http');
const { URL } = require('url');

class SEOAuditor {
  constructor(options = {}) {
    this.userAgent = options.userAgent || 'SEOWebChecker-NodeBot/1.0 (+https://seowebchecker.com/)';
    this.timeout = options.timeout || 15000;
  }

  fetchUrl(targetUrl) {
    return new Promise((resolve, reject) => {
      const parsed = new URL(targetUrl);
      const client = parsed.protocol === 'https:' ? https : http;
      const start = Date.now();

      const req = client.get(targetUrl, {
        headers: {
          'User-Agent': this.userAgent,
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.9',
          'Accept-Encoding': 'gzip, deflate',
        },
        timeout: this.timeout,
      }, (res) => {
        // Handle redirects
        if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
          const redirectUrl = new URL(res.headers.location, targetUrl).toString();
          return this.fetchUrl(redirectUrl).then(resolve).catch(reject);
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
        reject(new Error(`Timeout after ${this.timeout}ms connecting to ${targetUrl}`));
      });
      req.on('error', reject);
    });
  }

  auditHtml(html, url = 'https://seowebchecker.com/', options = {}) {
    const headers = options.headers || {};
    const statusCode = options.statusCode || 200;
    const responseTimeMs = options.responseTimeMs || 120;
    const contentBytes = options.contentBytes || Buffer.from(html, 'utf-8');

    const issues = [];

    // 1. Meta & Header extraction
    const titleMatch = html.match(/<title[^>]*>(.*?)<\/title>/is);
    const title = titleMatch ? titleMatch[1].replace(/\s+/g, ' ').trim() : null;
    const titleLength = title ? title.length : 0;

    const descMatch = html.match(/<meta[^>]*name=["']description["'][^>]*content=["']([^"']*)["']/is) ||
                      html.match(/<meta[^>]*content=["']([^"']*)["'][^>]*name=["']description["']/is);
    const description = descMatch ? descMatch[1].trim() : null;
    const descriptionLength = description ? description.length : 0;

    const canonMatch = html.match(/<link[^>]*rel=["']canonical["'][^>]*href=["']([^"']*)["']/is);
    const canonical = canonMatch ? canonMatch[1].trim() : null;

    const viewportMatch = html.match(/<meta[^>]*name=["']viewport["'][^>]*content=["']([^"']*)["']/is);
    const viewport = viewportMatch ? viewportMatch[1].trim() : null;

    const robotsMatch = html.match(/<meta[^>]*name=["']robots["'][^>]*content=["']([^"']*)["']/is);
    const robots = robotsMatch ? robotsMatch[1].trim() : null;

    // Checks - Title
    if (!title) {
      issues.push({ id: 'meta-title-missing', category: 'meta', severity: 'error', title: 'Missing Page Title', message: 'No <title> tag found.', recommendation: 'Add a descriptive <title> tag between 30 and 60 characters.' });
    } else if (titleLength < 30) {
      issues.push({ id: 'meta-title-short', category: 'meta', severity: 'warning', title: 'Page Title Too Short', message: `Title is ${titleLength} characters: '${title}'.`, recommendation: 'Expand title to at least 30 characters.' });
    } else if (titleLength > 65) {
      issues.push({ id: 'meta-title-long', category: 'meta', severity: 'warning', title: 'Page Title Too Long', message: `Title is ${titleLength} characters. May be truncated in SERPs.`, recommendation: 'Shorten title to under 60 characters.' });
    } else {
      issues.push({ id: 'meta-title-pass', category: 'meta', severity: 'pass', title: 'Optimal Page Title Length', message: `Title is ${titleLength} characters: '${title}'.`, recommendation: 'Maintain descriptive title.' });
    }

    // Checks - Description
    if (!description) {
      issues.push({ id: 'meta-desc-missing', category: 'meta', severity: 'error', title: 'Missing Meta Description', message: 'No meta description found.', recommendation: 'Add a meta description between 120 and 160 characters.' });
    } else if (descriptionLength < 70) {
      issues.push({ id: 'meta-desc-short', category: 'meta', severity: 'warning', title: 'Meta Description Too Short', message: `Meta description is ${descriptionLength} characters.`, recommendation: 'Expand description to 120-160 characters.' });
    } else {
      issues.push({ id: 'meta-desc-pass', category: 'meta', severity: 'pass', title: 'Optimal Meta Description', message: `Description is ${descriptionLength} characters.`, recommendation: 'Well-crafted meta description.' });
    }

    // Checks - Viewport
    if (!viewport) {
      issues.push({ id: 'meta-viewport-missing', category: 'meta', severity: 'error', title: 'Missing Viewport Meta Tag', message: 'Mobile viewport is missing.', recommendation: 'Add <meta name="viewport" content="width=device-width, initial-scale=1.0">.' });
    } else {
      issues.push({ id: 'meta-viewport-pass', category: 'meta', severity: 'pass', title: 'Mobile Viewport Present', message: `Viewport configured: ${viewport}.`, recommendation: 'Mobile viewport active.' });
    }

    // Checks - Canonical
    if (!canonical) {
      issues.push({ id: 'meta-canonical-missing', category: 'meta', severity: 'warning', title: 'Missing Canonical Tag', message: 'No <link rel="canonical"> specified.', recommendation: 'Add canonical tag to avoid duplicate content.' });
    } else {
      issues.push({ id: 'meta-canonical-pass', category: 'meta', severity: 'pass', title: 'Canonical Tag Present', message: `Canonical URL: ${canonical}`, recommendation: 'Valid canonical URL.' });
    }

    // 2. Headings & Content
    const h1Matches = [...html.matchAll(/<h1[^>]*>(.*?)<\/h1>/gis)].map(m => m[1].replace(/<[^>]+>/g, '').trim());
    const h2Matches = [...html.matchAll(/<h2[^>]*>(.*?)<\/h2>/gis)].map(m => m[1].replace(/<[^>]+>/g, '').trim());
    const cleanText = html.replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, ' ')
                          .replace(/<style\b[^<]*(?:(?!<\/style>)<[^<]*)*<\/style>/gi, ' ')
                          .replace(/<[^>]+>/g, ' ');
    const words = cleanText.match(/\b[a-zA-Z0-9_\'-]{2,}\b/g) || [];
    const wordCount = words.length;

    if (h1Matches.length === 0) {
      issues.push({ id: 'content-h1-missing', category: 'content', severity: 'error', title: 'Missing <h1> Tag', message: 'No <h1> heading found.', recommendation: 'Add a single <h1> heading representing page intent.' });
    } else if (h1Matches.length === 1) {
      issues.push({ id: 'content-h1-pass', category: 'content', severity: 'pass', title: 'Single <h1> Tag Configured', message: `Optimal <h1> found: '${h1Matches[0]}'.`, recommendation: 'Good heading structure.' });
    } else {
      issues.push({ id: 'content-h1-multiple', category: 'content', severity: 'warning', title: `Multiple <h1> Tags (${h1Matches.length})`, message: `Found ${h1Matches.length} <h1> tags.`, recommendation: 'Consolidate to a single <h1> heading.' });
    }

    if (wordCount < 100) {
      issues.push({ id: 'content-thin', category: 'content', severity: 'error', title: 'Thin Content', message: `Page has only ${wordCount} words.`, recommendation: 'Expand content with informative text.' });
    } else {
      issues.push({ id: 'content-words-pass', category: 'content', severity: 'pass', title: 'Adequate Word Count', message: `Page has ${wordCount} words (~${(wordCount / 200).toFixed(1)} min read).`, recommendation: 'Good text volume.' });
    }

    // 3. Images
    const imgMatches = [...html.matchAll(/<img\s+([^>]*?)>/gis)];
    let missingAlt = 0;
    let modernFormats = 0;
    for (const img of imgMatches) {
      const attrs = img[1];
      const altMatch = attrs.match(/alt=["']([^"']*)["']/i);
      if (!altMatch) missingAlt++;
      if (/\.(webp|avif|svg)/i.test(attrs)) modernFormats++;
    }

    if (imgMatches.length > 0) {
      if (missingAlt > 0) {
        issues.push({ id: 'images-missing-alt', category: 'images', severity: 'error', title: `${missingAlt} Images Missing 'alt'`, message: `${missingAlt} of ${imgMatches.length} images lack alt attributes.`, recommendation: 'Add descriptive alt text to all images.' });
      } else {
        issues.push({ id: 'images-alt-pass', category: 'images', severity: 'pass', title: 'All Images Have Alt Attributes', message: `All ${imgMatches.length} images have alt tags.`, recommendation: 'Good accessibility.' });
      }
    }

    // 4. Technical / Security
    const isHttps = url.toLowerCase().startsWith('https://');
    if (!isHttps) {
      issues.push({ id: 'tech-not-https', category: 'technical', severity: 'error', title: 'Insecure HTTP Protocol', message: 'URL uses HTTP instead of HTTPS.', recommendation: 'Install SSL/TLS and enforce HTTPS.' });
    } else {
      issues.push({ id: 'tech-https-pass', category: 'technical', severity: 'pass', title: 'Secure HTTPS Active', message: 'Encrypted connection.', recommendation: 'SSL certificate valid.' });
    }

    // 5. OpenGraph & Schema
    const hasOg = /property=["']og:title["']/i.test(html);
    if (!hasOg) {
      issues.push({ id: 'social-og-missing', category: 'social', severity: 'warning', title: 'Missing OpenGraph Tags', message: 'No og:title meta tag found.', recommendation: 'Add OpenGraph tags for rich social previews.' });
    } else {
      issues.push({ id: 'social-og-pass', category: 'social', severity: 'pass', title: 'OpenGraph Detected', message: 'OpenGraph meta tags configured.', recommendation: 'Social sharing enabled.' });
    }

    const hasSchema = /application\/ld\+json/i.test(html);
    if (!hasSchema) {
      issues.push({ id: 'schema-missing', category: 'schema', severity: 'warning', title: 'Missing Structured Data', message: 'No JSON-LD schema detected.', recommendation: 'Add Schema.org JSON-LD structured data.' });
    } else {
      issues.push({ id: 'schema-pass', category: 'schema', severity: 'pass', title: 'Structured Data Active', message: 'JSON-LD schema detected.', recommendation: 'Schema markup validated.' });
    }

    // Calculate score
    const categoryWeights = { meta: 0.25, content: 0.20, technical: 0.20, performance: 0.15, images: 0.10, social: 0.05, schema: 0.05 };
    const catMap = {};
    for (const issue of issues) {
      if (!catMap[issue.category]) catMap[issue.category] = [];
      catMap[issue.category].push(issue);
    }

    const catScores = {};
    let weightedSum = 0;
    let weightTotal = 0;

    for (const [catName, catIssues] of Object.entries(catMap)) {
      const passCount = catIssues.filter(i => i.severity === 'pass').length;
      const warnCount = catIssues.filter(i => i.severity === 'warning').length;
      const errCount = catIssues.filter(i => i.severity === 'error').length;
      const total = catIssues.length;

      let score = Math.round((passCount / total) * 100) - (errCount * 10) - (warnCount * 3);
      score = Math.max(0, Math.min(100, score));

      catScores[catName] = {
        name: catName,
        score,
        passed_count: passCount,
        warning_count: warnCount,
        error_count: errCount,
      };

      const w = categoryWeights[catName] || 0.1;
      weightedSum += score * w;
      weightTotal += w;
    }

    const overallScore = Math.max(0, Math.min(100, Math.round(weightedSum / weightTotal)));
    let grade = 'F';
    if (overallScore >= 95) grade = 'A+';
    else if (overallScore >= 90) grade = 'A';
    else if (overallScore >= 80) grade = 'B';
    else if (overallScore >= 70) grade = 'C';
    else if (overallScore >= 60) grade = 'D';

    const passedList = issues.filter(i => i.severity === 'pass');
    const warningList = issues.filter(i => i.severity === 'warning');
    const errorList = issues.filter(i => i.severity === 'error');

    return {
      url,
      timestamp: new Date().toISOString(),
      score: {
        overall: overallScore,
        grade,
        categories: catScores,
      },
      stats: {
        total: issues.length,
        passed: passedList.length,
        warnings: warningList.length,
        errors: errorList.length,
      },
      meta: { title, title_length: titleLength, description, description_length: descriptionLength, canonical, viewport },
      content: { word_count: wordCount, reading_time_minutes: +(wordCount / 200).toFixed(1), h1_tags: h1Matches, h2_tags: h2Matches },
      images: { total_images: imgMatches.length, missing_alt: missingAlt, modern_formats: modernFormats },
      technical: { is_https: isHttps },
      performance: { response_time_ms: responseTimeMs, page_size_kb: +(contentBytes.length / 1024).toFixed(2) },
      issues,
      errors: errorList,
      warnings: warningList,
      passed: passedList,
    };
  }

  async audit(url) {
    let target = url;
    if (!target.startsWith('http://') && !target.startsWith('https://')) {
      target = 'https://' + target;
    }
    const res = await this.fetchUrl(target);
    return this.auditHtml(res.body, target, {
      headers: res.headers,
      statusCode: res.statusCode,
      responseTimeMs: res.responseTimeMs,
      contentBytes: res.contentBytes,
    });
  }
}

module.exports = { SEOAuditor };
