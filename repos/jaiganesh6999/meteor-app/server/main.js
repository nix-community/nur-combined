import { Meteor } from 'meteor/meteor';
import { WebApp } from 'meteor/webapp';
import { URL } from 'url';

/**
 * SEOWebChecker SEO Auditor Engine for Meteor Server
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

    // Title
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

    // Meta description
    const descMatch = html.match(/<meta[^>]*name=["']description["'][^>]*content=["']([^"']*)["']/is) ||
                      html.match(/<meta[^>]*content=["']([^"']*)["'][^>]*name=["']description["']/is);
    const description = descMatch ? descMatch[1].trim() : null;
    const descriptionLength = description ? description.length : 0;

    if (!description) {
      issues.push({ category: 'meta', severity: 'error', name: 'Meta Description', message: 'Missing meta description', rec: 'Add a compelling meta description between 120 and 160 characters.' });
    } else if (descriptionLength < 100) {
      issues.push({ category: 'meta', severity: 'warning', name: 'Meta Description', message: `Meta description too short (${descriptionLength} chars)`, rec: 'Expand description to 120-160 characters.' });
    } else if (descriptionLength > 165) {
      issues.push({ category: 'meta', severity: 'warning', name: 'Meta Description', message: `Meta description too long (${descriptionLength} chars)`, rec: 'Shorten description to under 160 characters.' });
    } else {
      issues.push({ category: 'meta', severity: 'pass', name: 'Meta Description', message: `Optimal meta description (${descriptionLength} chars)`, rec: 'Good description length.' });
    }

    // Canonical
    const canonMatch = html.match(/<link[^>]*rel=["']canonical["'][^>]*href=["']([^"']*)["']/is) ||
                       html.match(/<link[^>]*href=["']([^"']*)["'][^>]*rel=["']canonical["']/is);
    const canonical = canonMatch ? canonMatch[1].trim() : null;
    if (!canonical) {
      issues.push({ category: 'meta', severity: 'warning', name: 'Canonical Tag', message: 'Missing canonical URL link', rec: 'Specify a self-referencing canonical tag.' });
    } else {
      issues.push({ category: 'meta', severity: 'pass', name: 'Canonical Tag', message: `Canonical URL defined: ${canonical}`, rec: 'Canonical tag is properly set.' });
    }

    // Robots
    const robotsMatch = html.match(/<meta[^>]*name=["']robots["'][^>]*content=["']([^"']*)["']/is);
    const robots = robotsMatch ? robotsMatch[1].trim() : null;

    // Viewport
    const viewportMatch = html.match(/<meta[^>]*name=["']viewport["'][^>]*content=["']([^"']*)["']/is);
    if (!viewportMatch) {
      issues.push({ category: 'mobile', severity: 'error', name: 'Mobile Viewport', message: 'Missing mobile viewport tag', rec: 'Add <meta name="viewport" content="width=device-width, initial-scale=1.0">.' });
    } else {
      issues.push({ category: 'mobile', severity: 'pass', name: 'Mobile Viewport', message: 'Mobile viewport tag found', rec: 'Mobile viewport is configured.' });
    }

    // Headings
    const h1Matches = html.match(/<h1[^>]*>(.*?)<\/h1>/gis) || [];
    const h1Count = h1Matches.length;
    if (h1Count === 0) {
      issues.push({ category: 'headings', severity: 'error', name: 'H1 Heading', message: 'No <h1> heading found', rec: 'Include exactly one <h1> heading summarizing the main topic.' });
    } else if (h1Count > 1) {
      issues.push({ category: 'headings', severity: 'warning', name: 'H1 Heading', message: `Multiple <h1> headings found (${h1Count})`, rec: 'Use a single primary <h1> per document.' });
    } else {
      issues.push({ category: 'headings', severity: 'pass', name: 'H1 Heading', message: 'Exactly one primary <h1> found', rec: 'Single H1 structure.' });
    }

    // Images
    const imgMatches = html.match(/<img\b[^>]*>/gi) || [];
    let totalImages = imgMatches.length;
    let missingAlt = 0;
    let modernFormats = 0;

    imgMatches.forEach(img => {
      if (!/alt=["'][^"']*["']/i.test(img)) {
        missingAlt++;
      }
      if (/src=["'][^"']*\.(webp|avif|svg)["']/i.test(img)) {
        modernFormats++;
      }
    });

    if (totalImages > 0 && missingAlt > 0) {
      issues.push({ category: 'images', severity: 'warning', name: 'Image Alt Tags', message: `${missingAlt} of ${totalImages} images missing alt text`, rec: 'Provide descriptive alt attributes for all images.' });
    } else {
      issues.push({ category: 'images', severity: 'pass', name: 'Image Alt Tags', message: 'All images have alt tags', rec: 'Image accessibility compliant.' });
    }

    // OpenGraph
    const ogTitleMatch = html.match(/<meta[^>]*property=["']og:title["'][^>]*content=["']([^"']*)["']/is);
    const ogDescMatch = html.match(/<meta[^>]*property=["']og:description["'][^>]*content=["']([^"']*)["']/is);
    const ogImgMatch = html.match(/<meta[^>]*property=["']og:image["'][^>]*content=["']([^"']*)["']/is);

    const openGraph = {
      og_title: ogTitleMatch ? ogTitleMatch[1].trim() : null,
      og_description: ogDescMatch ? ogDescMatch[1].trim() : null,
      og_image: ogImgMatch ? ogImgMatch[1].trim() : null,
    };

    // Calculate Scores
    let deductions = 0;
    issues.forEach(i => {
      if (i.severity === 'error') deductions += 15;
      if (i.severity === 'warning') deductions += 5;
    });

    const score = Math.max(0, Math.min(100, 100 - deductions));
    let grade = 'F';
    if (score >= 90) grade = 'A+';
    else if (score >= 80) grade = 'A';
    else if (score >= 70) grade = 'B';
    else if (score >= 60) grade = 'C';
    else if (score >= 50) grade = 'D';

    return {
      url,
      timestamp: new Date().toISOString(),
      score: {
        overall: score,
        grade,
        passed_checks: issues.filter(i => i.severity === 'pass').length,
        failed_checks: issues.filter(i => i.severity !== 'pass').length,
        total_checks: issues.length,
        categories: {
          meta: { score: Math.max(0, 100 - (issues.filter(i => i.category === 'meta' && i.severity !== 'pass').length * 15)), weight: 0.25 },
          headings: { score: Math.max(0, 100 - (issues.filter(i => i.category === 'headings' && i.severity !== 'pass').length * 20)), weight: 0.15 },
          images: { score: Math.max(0, 100 - (issues.filter(i => i.category === 'images' && i.severity !== 'pass').length * 20)), weight: 0.15 },
          performance: { score: responseTimeMs < 500 ? 95 : (responseTimeMs < 1500 ? 80 : 60), weight: 0.25 },
          mobile: { score: viewportMatch ? 100 : 40, weight: 0.20 },
        },
      },
      meta: {
        title,
        title_length: titleLength,
        description,
        description_length: descriptionLength,
        canonical,
        robots,
        open_graph: openGraph,
      },
      performance: {
        response_time_ms: responseTimeMs,
        page_size_kb: pageSizeKb,
        diagnostics: {
          ttfb: responseTimeMs < 600 ? 'Good' : 'Needs Improvement',
          status: 'Healthy',
        },
      },
      images: {
        total_images: totalImages,
        missing_alt: missingAlt,
        modern_formats: modernFormats,
      },
      issues,
      source: 'https://seowebchecker.com/',
    };
  }

  async audit(targetUrl) {
    const fetchRes = await this.fetchUrl(targetUrl);
    return this.auditHtml(fetchRes.body, targetUrl, {
      responseTimeMs: fetchRes.responseTimeMs,
      pageSizeKb: fetchRes.pageSizeKb,
    });
  }
}

const auditor = new SEOAuditor();

// Helper: Send JSON Response
function sendJson(res, statusCode, data) {
  res.writeHead(statusCode, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Accept, Authorization',
  });
  res.end(JSON.stringify(data, null, 2));
}

// REST API Middleware using WebApp connectHandlers
WebApp.connectHandlers.use(async (req, res, next) => {
  // CORS Preflight
  if (req.method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Accept, Authorization',
    });
    return res.end();
  }

  const parsedUrl = new URL(req.url, `http://${req.headers.host || 'localhost'}`);
  const pathname = parsedUrl.pathname;
  const targetUrl = parsedUrl.searchParams.get('url') || 'https://seowebchecker.com/';

  // Smithery Server Card: /.well-known/mcp/server-card.json
  if (pathname === '/.well-known/mcp/server-card.json' || pathname === '/server-card.json') {
    return sendJson(res, 200, {
      $schema: 'https://static.modelcontextprotocol.io/schemas/2025-10-17/server.schema.json',
      serverInfo: {
        name: 'seowebchecker',
        title: 'SEOWebChecker MCP Server',
        version: '1.0.2',
        description: 'On-page technical SEO audits, meta tag validation, heading hierarchy verification, and Core Web Vitals checks by SEOWebChecker.',
      },
      website: 'https://seowebchecker.com/',
      authentication: { required: false },
      tools: [
        {
          name: 'seowebchecker_audit',
          description: 'Run full technical SEO audit on any URL.',
          inputSchema: { type: 'object', properties: { url: { type: 'string' } }, required: ['url'] },
        },
        {
          name: 'seowebchecker_quick_score',
          description: 'Calculate instant 0-100 technical SEO score.',
          inputSchema: { type: 'object', properties: { url: { type: 'string' } }, required: ['url'] },
        },
      ],
      resources: [],
      prompts: [],
    });
  }

  // 1. Health Score: GET /api/score
  if (req.method === 'GET' && pathname === '/api/score') {
    try {
      const result = await auditor.audit(targetUrl);
      return sendJson(res, 200, {
        url: result.url,
        score: result.score.overall,
        grade: result.score.grade,
        categories: {
          meta: result.score.categories.meta.score,
          headings: result.score.categories.headings.score,
          images: result.score.categories.images.score,
          performance: result.score.categories.performance.score,
          mobile: result.score.categories.mobile.score,
        },
        source: 'https://seowebchecker.com/',
      });
    } catch (err) {
      return sendJson(res, 400, { error: err.message, source: 'https://seowebchecker.com/' });
    }
  }

  // 2. Meta Tags: GET /api/meta
  if (req.method === 'GET' && pathname === '/api/meta') {
    try {
      const result = await auditor.audit(targetUrl);
      return sendJson(res, 200, {
        url: result.url,
        title: result.meta.title,
        title_length: result.meta.title_length,
        description: result.meta.description,
        description_length: result.meta.description_length,
        canonical: result.meta.canonical,
        robots: result.meta.robots,
        open_graph: result.meta.open_graph,
        source: 'https://seowebchecker.com/',
      });
    } catch (err) {
      return sendJson(res, 400, { error: err.message, source: 'https://seowebchecker.com/' });
    }
  }

  // 3. Core Web Vitals: GET /api/vitals
  if (req.method === 'GET' && pathname === '/api/vitals') {
    try {
      const result = await auditor.audit(targetUrl);
      return sendJson(res, 200, {
        url: result.url,
        response_time_ms: result.performance.response_time_ms,
        page_size_kb: result.performance.page_size_kb,
        diagnostics: result.performance.diagnostics,
        source: 'https://seowebchecker.com/',
      });
    } catch (err) {
      return sendJson(res, 400, { error: err.message, source: 'https://seowebchecker.com/' });
    }
  }

  // 4. Image Audit: GET /api/images
  if (req.method === 'GET' && pathname === '/api/images') {
    try {
      const result = await auditor.audit(targetUrl);
      return sendJson(res, 200, {
        url: result.url,
        total_images: result.images.total_images,
        missing_alt: result.images.missing_alt,
        modern_formats: result.images.modern_formats,
        source: 'https://seowebchecker.com/',
      });
    } catch (err) {
      return sendJson(res, 400, { error: err.message, source: 'https://seowebchecker.com/' });
    }
  }

  // 5. Full Audit: POST /api/audit
  if (req.method === 'POST' && pathname === '/api/audit') {
    let body = '';
    req.on('data', chunk => { body += chunk; });
    req.on('end', async () => {
      try {
        const parsed = JSON.parse(body || '{}');
        const urlToAudit = parsed.url || 'https://seowebchecker.com/';
        const result = await auditor.audit(urlToAudit);
        return sendJson(res, 200, result);
      } catch (err) {
        return sendJson(res, 400, { error: err.message, source: 'https://seowebchecker.com/' });
      }
    });
    return;
  }

  return next();
});

// Meteor RPC Methods for Meteor client apps
Meteor.methods({
  async 'seoaudit.score'(url) {
    const res = await auditor.audit(url || 'https://seowebchecker.com/');
    return { score: res.score.overall, grade: res.score.grade, categories: res.score.categories };
  },
  async 'seoaudit.audit'(url) {
    return await auditor.audit(url || 'https://seowebchecker.com/');
  },
});

Meteor.startup(() => {
  console.log('✅ SEOWebChecker Meteor Service ready on Galaxy Cloud.');
  console.log('🔗 Official Website: https://seowebchecker.com/');
});
