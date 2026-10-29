// | Foreign JavaScript implementation for SEOWebChecker PureScript SDK
// | Official Website: https://seowebchecker.com/

export const auditHtmlImpl = function (html) {
  return function (url) {
    if (!html || typeof html !== 'string') {
      html = '';
    }
    url = url || 'https://seowebchecker.com/';

    var issues = [];

    // 1. Title Tag
    var title = null;
    var titleMatch = html.match(/<title[^>]*>([\s\S]*?)<\/title>/i);
    if (titleMatch) {
      title = titleMatch[1].replace(/<[^>]+>/g, '').replace(/\s+/g, ' ').trim();
    }
    var titleLen = title ? title.length : 0;

    if (!title) {
      issues.push({
        id: 'meta-title-missing',
        category: 'meta',
        severity: 'error',
        title: 'Missing <title> Tag',
        message: 'No title tag was found in the document head.',
        recommendation: 'Add a descriptive <title> tag between 30 and 60 characters.'
      });
    } else if (titleLen < 30) {
      issues.push({
        id: 'meta-title-short',
        category: 'meta',
        severity: 'warning',
        title: 'Page Title Too Short',
        message: 'Title contains only ' + titleLen + ' characters. Optimal length is 30–60 characters.',
        recommendation: 'Expand title with relevant keywords and brand distinction.'
      });
    } else if (titleLen > 65) {
      issues.push({
        id: 'meta-title-long',
        category: 'meta',
        severity: 'warning',
        title: 'Page Title Too Long',
        message: 'Title contains ' + titleLen + ' characters and risks truncation in search snippets.',
        recommendation: 'Shorten title to under 60 characters for optimal search snippet display.'
      });
    } else {
      issues.push({
        id: 'meta-title-pass',
        category: 'meta',
        severity: 'pass',
        title: 'Optimal Page Title Length',
        message: 'Title length is well balanced (' + titleLen + ' characters): "' + title + '"',
        recommendation: 'Maintain concise and topic-focused title copy.'
      });
    }

    // 2. Meta Description
    var description = null;
    var descMatch = html.match(/<meta\s+[^>]*name=["']description["'][^>]*content=["']([^"']*)["']/i) ||
                    html.match(/<meta\s+[^>]*content=["']([^"']*)["'][^>]*name=["']description["']/i);
    if (descMatch) {
      description = descMatch[1].trim();
    }
    var descLen = description ? description.length : 0;

    if (!description) {
      issues.push({
        id: 'meta-desc-missing',
        category: 'meta',
        severity: 'error',
        title: 'Missing Meta Description',
        message: 'No <meta name="description"> tag detected.',
        recommendation: 'Add an engaging summary description to boost organic click-through rates.'
      });
    } else if (descLen < 70) {
      issues.push({
        id: 'meta-desc-short',
        category: 'meta',
        severity: 'warning',
        title: 'Meta Description Too Short',
        message: 'Description contains only ' + descLen + ' characters. Search snippets prefer 70–160 characters.',
        recommendation: 'Expand description to clearly communicate page value and intent.'
      });
    } else if (descLen > 165) {
      issues.push({
        id: 'meta-desc-long',
        category: 'meta',
        severity: 'warning',
        title: 'Meta Description Too Long',
        message: 'Description has ' + descLen + ' characters and may be truncated on mobile viewports.',
        recommendation: 'Shorten description to under 160 characters.'
      });
    } else {
      issues.push({
        id: 'meta-desc-pass',
        category: 'meta',
        severity: 'pass',
        title: 'Optimal Meta Description Length',
        message: 'Meta description length is balanced (' + descLen + ' characters).',
        recommendation: 'Keep description copy compelling and actionable.'
      });
    }

    // 3. Mobile Viewport Tag
    var hasViewport = /<meta\s+[^>]*name=["']viewport["']/i.test(html);
    if (!hasViewport) {
      issues.push({
        id: 'meta-viewport-missing',
        category: 'mobile',
        severity: 'error',
        title: 'Missing Viewport Meta Tag',
        message: 'No mobile viewport meta tag configured.',
        recommendation: 'Add <meta name="viewport" content="width=device-width, initial-scale=1.0"> for responsive display.'
      });
    } else {
      issues.push({
        id: 'meta-viewport-pass',
        category: 'mobile',
        severity: 'pass',
        title: 'Mobile Viewport Configured',
        message: 'Mobile viewport tag is properly defined for multi-device rendering.',
        recommendation: 'Ensure responsive CSS breakpoints accommodate small screens.'
      });
    }

    // 4. Canonical Link Tag
    var canonical = null;
    var canMatch = html.match(/<link\s+[^>]*rel=["']canonical["'][^>]*href=["']([^"']*)["']/i);
    if (canMatch) {
      canonical = canMatch[1].trim();
    }

    if (!canonical) {
      issues.push({
        id: 'canonical-missing',
        category: 'indexing',
        severity: 'warning',
        title: 'Missing Canonical Link Tag',
        message: 'No <link rel="canonical"> tag detected.',
        recommendation: 'Add a self-referencing canonical tag to prevent duplicate content indexing issues.'
      });
    } else {
      issues.push({
        id: 'canonical-pass',
        category: 'indexing',
        severity: 'pass',
        title: 'Canonical Tag Present',
        message: 'Canonical URL specified: ' + canonical,
        recommendation: 'Verify canonical URL strictly matches the primary indexed version.'
      });
    }

    // 5. Heading Structure (H1)
    var h1Matches = html.match(/<h1[^>]*>([\s\S]*?)<\/h1>/gi) || [];
    var h1Count = h1Matches.length;

    if (h1Count === 0) {
      issues.push({
        id: 'h1-missing',
        category: 'content',
        severity: 'error',
        title: 'Missing <h1> Heading',
        message: 'No primary <h1> tag detected in document body.',
        recommendation: 'Add a single descriptive <h1> heading communicating the page topic.'
      });
    } else if (h1Count === 1) {
      var h1Clean = h1Matches[0].replace(/<[^>]+>/g, '').replace(/\s+/g, ' ').trim();
      issues.push({
        id: 'h1-pass',
        category: 'content',
        severity: 'pass',
        title: 'Single <h1> Heading Configured',
        message: 'Primary <h1> detected: "' + h1Clean + '"',
        recommendation: 'Maintain a clear hierarchical heading structure (h1 -> h2 -> h3).'
      });
    } else {
      issues.push({
        id: 'h1-multiple',
        category: 'content',
        severity: 'warning',
        title: 'Multiple <h1> Headings (' + h1Count + ')',
        message: 'Found ' + h1Count + ' <h1> tags. Best practice is to use one primary <h1> per document.',
        recommendation: 'Consolidate secondary headings into <h2> subsections.'
      });
    }

    // 6. Content Word Count
    var cleanText = html
      .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, ' ')
      .replace(/<style\b[^<]*(?:(?!<\/style>)<[^<]*)*<\/style>/gi, ' ')
      .replace(/<[^>]+>/g, ' ')
      .replace(/\s+/g, ' ')
      .trim();
    var words = cleanText.length > 0 ? cleanText.split(/\s+/) : [];
    var wordCount = words.length;

    if (wordCount < 150) {
      issues.push({
        id: 'content-thin',
        category: 'content',
        severity: 'warning',
        title: 'Thin Content Detected',
        message: 'Document contains only approximately ' + wordCount + ' words.',
        recommendation: 'Expand text content with comprehensive, original analysis.'
      });
    } else {
      issues.push({
        id: 'content-words-pass',
        category: 'content',
        severity: 'pass',
        title: 'Substantive Word Count',
        message: 'Document contains approximately ' + wordCount + ' words.',
        recommendation: 'Maintain high-quality, comprehensive subject coverage.'
      });
    }

    // 7. Image Accessibility (Alt tags)
    var imgMatches = html.match(/<img\s+[^>]*?>/gi) || [];
    var totalImages = imgMatches.length;
    var missingAlt = 0;

    for (var i = 0; i < totalImages; i++) {
      if (!/alt=["']/i.test(imgMatches[i])) {
        missingAlt++;
      }
    }

    if (totalImages > 0) {
      if (missingAlt > 0) {
        issues.push({
          id: 'img-alt-missing',
          category: 'images',
          severity: 'warning',
          title: missingAlt + ' of ' + totalImages + ' Images Lack Alt Text',
          message: missingAlt + ' content images are missing descriptive alternative text.',
          recommendation: 'Add concise alt attributes to all content images for accessibility and image search.'
        });
      } else {
        issues.push({
          id: 'img-alt-pass',
          category: 'images',
          severity: 'pass',
          title: 'All Images Have Alt Attributes',
          message: 'All ' + totalImages + ' images configure alternative text.',
          recommendation: 'Keep alt attributes descriptive and accurate.'
        });
      }
    }

    // 8. OpenGraph Social Tags
    var hasOg = /<meta\s+[^>]*property=["']og:title["']/i.test(html);
    if (!hasOg) {
      issues.push({
        id: 'social-og-missing',
        category: 'social',
        severity: 'warning',
        title: 'Missing OpenGraph Tags',
        message: 'No og:title meta tag found.',
        recommendation: 'Add OpenGraph tags (og:title, og:image, og:description) for rich social sharing cards.'
      });
    } else {
      issues.push({
        id: 'social-og-pass',
        category: 'social',
        severity: 'pass',
        title: 'OpenGraph Social Tags Present',
        message: 'OpenGraph tags detected for social preview cards.',
        recommendation: 'Verify preview cards render properly on social networks.'
      });
    }

    // 9. Structured Data (Schema.org)
    var hasSchema = /<script\s+[^>]*type=["']application\/ld\+json["']/i.test(html);
    if (!hasSchema) {
      issues.push({
        id: 'schema-missing',
        category: 'technical',
        severity: 'warning',
        title: 'Missing JSON-LD Structured Data',
        message: 'No Schema.org JSON-LD structured data detected in HTML.',
        recommendation: 'Add structured data to unlock Google rich snippet features.'
      });
    } else {
      issues.push({
        id: 'schema-pass',
        category: 'technical',
        severity: 'pass',
        title: 'Structured Data Detected',
        message: 'Schema.org JSON-LD structured data is present.',
        recommendation: 'Validate markup using Google Rich Results Test.'
      });
    }

    // Calculate standard weighted scorecard
    var passedCount = 0;
    var warningCount = 0;
    var errorCount = 0;

    for (var j = 0; j < issues.length; j++) {
      if (issues[j].severity === 'pass') passedCount++;
      else if (issues[j].severity === 'warning') warningCount++;
      else if (issues[j].severity === 'error') errorCount++;
    }

    var totalChecks = issues.length;
    var maxPoints = Math.max(1, totalChecks * 10);
    var earnedPoints = (passedCount * 10) + (warningCount * 5);
    var overallScore = Math.max(0, Math.min(100, Math.round((earnedPoints / maxPoints) * 100)));

    var grade = 'F';
    if (overallScore >= 95) grade = 'A+';
    else if (overallScore >= 90) grade = 'A';
    else if (overallScore >= 80) grade = 'B';
    else if (overallScore >= 70) grade = 'C';
    else if (overallScore >= 60) grade = 'D';

    return {
      success: true,
      url: url,
      timestamp: new Date().toISOString(),
      score: {
        overall: overallScore,
        grade: grade
      },
      stats: {
        total: totalChecks,
        passed: passedCount,
        warnings: warningCount,
        errors: errorCount
      },
      issues: issues
    };
  };
};

export const generateMarkdownImpl = function (report) {
  if (!report) return '';
  var md = '# SEO Audit Report: ' + (report.url || 'Webpage') + '\n';
  md += '**Score**: ' + (report.score ? report.score.overall : '--') + '/100 (Grade: ' + (report.score ? report.score.grade : '-') + ')\n';
  if (report.stats) {
    md += '**Passed**: ' + report.stats.passed + ' | **Warnings**: ' + report.stats.warnings + ' | **Errors**: ' + report.stats.errors + '\n\n';
  }
  md += '## Diagnostic Findings\n\n';
  if (report.issues) {
    for (var i = 0; i < report.issues.length; i++) {
      var item = report.issues[i];
      md += '- [' + item.severity.toUpperCase() + '] **' + item.title + '**: ' + item.message + '\n';
      if (item.recommendation) {
        md += '  *Recommendation*: ' + item.recommendation + '\n';
      }
    }
  }
  md += '\n---\n*Report generated via SEOWebChecker (https://seowebchecker.com/)*\n';
  return md;
};
