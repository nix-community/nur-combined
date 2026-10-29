/**
 * Self-contained Client-Side SEO Audit Engine for StackBlitz & WebContainers
 * Powered by SEOWebChecker (https://seowebchecker.com/)
 */

export class BrowserSEOAuditor {
  auditHtml(html, url = 'https://seowebchecker.com/') {
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
      issues.push({ id: 'meta-title-missing', category: 'meta', severity: 'error', title: 'Missing Page Title', message: 'No <title> tag found in HTML head.', recommendation: 'Add a descriptive <title> tag between 30 and 60 characters.' });
    } else if (titleLength < 30) {
      issues.push({ id: 'meta-title-short', category: 'meta', severity: 'warning', title: 'Page Title Too Short', message: `Title is only ${titleLength} characters: "${title}".`, recommendation: 'Expand title to at least 30-60 characters.' });
    } else if (titleLength > 65) {
      issues.push({ id: 'meta-title-long', category: 'meta', severity: 'warning', title: 'Page Title Too Long', message: `Title is ${titleLength} characters. May be truncated in SERPs.`, recommendation: 'Shorten title to under 60 characters.' });
    } else {
      issues.push({ id: 'meta-title-pass', category: 'meta', severity: 'pass', title: 'Optimal Page Title Length', message: `Title length is optimal (${titleLength} characters): "${title}".`, recommendation: 'Maintain concise and descriptive title.' });
    }

    // Checks - Description
    if (!description) {
      issues.push({ id: 'meta-desc-missing', category: 'meta', severity: 'error', title: 'Missing Meta Description', message: 'No meta description found.', recommendation: 'Add a meta description between 120 and 160 characters.' });
    } else if (descriptionLength < 50) {
      issues.push({ id: 'meta-desc-short', category: 'meta', severity: 'warning', title: 'Meta Description Too Short', message: `Description is ${descriptionLength} characters.`, recommendation: 'Expand description to summarize page value.' });
    } else if (descriptionLength > 165) {
      issues.push({ id: 'meta-desc-long', category: 'meta', severity: 'warning', title: 'Meta Description Too Long', message: `Description is ${descriptionLength} characters. Risk of truncation.`, recommendation: 'Keep meta descriptions under 160 characters.' });
    } else {
      issues.push({ id: 'meta-desc-pass', category: 'meta', severity: 'pass', title: 'Optimal Meta Description', message: `Meta description is well balanced (${descriptionLength} characters).`, recommendation: 'Maintain keyword-relevant description.' });
    }

    // Checks - Viewport
    if (!viewport) {
      issues.push({ id: 'meta-viewport-missing', category: 'meta', severity: 'error', title: 'Missing Viewport Meta Tag', message: 'Mobile viewport tag is absent.', recommendation: 'Add <meta name="viewport" content="width=device-width, initial-scale=1.0">.' });
    } else {
      issues.push({ id: 'meta-viewport-pass', category: 'meta', severity: 'pass', title: 'Mobile Viewport Present', message: `Viewport configured: "${viewport}".`, recommendation: 'Maintain responsive layout.' });
    }

    // Checks - Canonical
    if (!canonical) {
      issues.push({ id: 'meta-canonical-missing', category: 'meta', severity: 'warning', title: 'Missing Canonical Tag', message: 'No canonical link found.', recommendation: 'Add <link rel="canonical" href="..."> to prevent duplicate content.' });
    } else {
      issues.push({ id: 'meta-canonical-pass', category: 'meta', severity: 'pass', title: 'Canonical Tag Specified', message: `Canonical URL defined: "${canonical}".`, recommendation: 'Ensure canonical matches indexed domain.' });
    }

    // 2. Headings & Content
    const h1Matches = (html.match(/<h1[^>]*>([\s\S]*?)<\/h1>/gi) || []).map(h => h.replace(/<[^>]+>/g, '').trim());
    if (h1Matches.length === 0) {
      issues.push({ id: 'content-h1-missing', category: 'content', severity: 'error', title: 'Missing <h1> Tag', message: 'No primary <h1> heading found.', recommendation: 'Add a single descriptive <h1> heading.' });
    } else if (h1Matches.length > 1) {
      issues.push({ id: 'content-h1-multiple', category: 'content', severity: 'warning', title: 'Multiple <h1> Tags Found', message: `Found ${h1Matches.length} <h1> tags. Best practice is exactly one <h1>.`, recommendation: 'Consolidate multiple <h1> tags into <h2> subheadings.' });
    } else {
      issues.push({ id: 'content-h1-pass', category: 'content', severity: 'pass', title: 'Single Primary <h1> Present', message: `Heading: "${h1Matches[0]}".`, recommendation: 'Ensure H1 matches target search intent.' });
    }

    // 3. Images & Alt Text
    const imgMatches = html.match(/<img\b[^>]*>/gi) || [];
    let missingAlt = 0;
    imgMatches.forEach(img => {
      if (!/alt=["'][^"']*["']/i.test(img)) missingAlt++;
    });
    if (imgMatches.length > 0 && missingAlt > 0) {
      issues.push({ id: 'images-alt-missing', category: 'images', severity: 'warning', title: 'Images Missing Alt Text', message: `${missingAlt} of ${imgMatches.length} images lack alt attributes.`, recommendation: 'Add alt attributes to all content images for accessibility and indexing.' });
    } else if (imgMatches.length > 0) {
      issues.push({ id: 'images-alt-pass', category: 'images', severity: 'pass', title: 'All Images Have Alt Attributes', message: `All ${imgMatches.length} images have alt attributes.`, recommendation: 'Maintain descriptive alt text.' });
    }

    // Calculate score
    let score = 100;
    let passed = 0;
    let warnings = 0;
    let errors = 0;

    issues.forEach(iss => {
      if (iss.severity === 'error') {
        score -= 15;
        errors++;
      } else if (iss.severity === 'warning') {
        score -= 5;
        warnings++;
      } else if (iss.severity === 'pass') {
        passed++;
      }
    });

    score = Math.max(0, Math.min(100, score));
    const grade = score >= 90 ? 'A' : score >= 80 ? 'B' : score >= 70 ? 'C' : score >= 60 ? 'D' : 'F';

    return {
      url,
      timestamp: new Date().toISOString(),
      score: { overall: score, grade },
      stats: { total: issues.length, passed, warnings, errors },
      issues
    };
  }
}
