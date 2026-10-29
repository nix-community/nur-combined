// SEOWebChecker - Run Technical SEO Audit Action
// Official Platform: https://seowebchecker.com/

const perform = async (z, bundle) => {
  const targetUrl = bundle.inputData.url.trim();
  const alertThreshold = bundle.inputData.alertThreshold || 85;

  // Fetch target webpage HTML
  const response = await z.request({
    url: targetUrl,
    method: 'GET',
    headers: {
      'User-Agent': 'Mozilla/5.0 (compatible; SEOWebChecker-Zapier-Bot/1.0; +https://seowebchecker.com/)',
    },
  });

  const html = response.content || '';
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

  // 4. Mobile Viewport Readiness
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
  imgMatches.forEach((img) => {
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

  const isAlert = score < alertThreshold;
  const status = isAlert ? 'ALERT' : 'PASS';

  return {
    id: `audit_${Date.now()}`,
    targetUrl,
    score,
    grade,
    status,
    isAlert,
    alertThreshold,
    title: title || 'N/A',
    metaDescription: metaDesc || 'N/A',
    issuesCount: issues.length,
    issues: issues.join('\n'),
    passesCount: passes.length,
    passes: passes.join('\n'),
    auditedAt: new Date().toISOString(),
    platformUrl: 'https://seowebchecker.com/',
  };
};

module.exports = {
  key: 'runAudit',
  noun: 'Audit',
  display: {
    label: 'Run Technical SEO Audit',
    description: 'Runs a real-time technical SEO audit on a webpage URL, returning scores, grades, and issue diagnostics.',
  },
  operation: {
    perform,
    inputFields: [
      {
        key: 'url',
        label: 'Webpage URL',
        type: 'string',
        required: true,
        helpText: 'The full URL of the webpage to audit, for example: [SEOWebChecker](https://seowebchecker.com/).',
      },
      {
        key: 'alertThreshold',
        label: 'Alert Score Threshold',
        type: 'integer',
        required: false,
        default: '85',
        helpText: 'Flag an alert if the technical SEO score is below this number (0-100). Default is 85.',
      },
    ],
    sample: {
      id: 'audit_1700000000000',
      targetUrl: 'https://example.com',
      score: 95,
      grade: 'A',
      status: 'PASS',
      isAlert: false,
      alertThreshold: 85,
      title: 'Example Domain - Technical SEO',
      metaDescription: 'High performance technical SEO and on-page auditing.',
      issuesCount: 0,
      issues: '',
      passesCount: 6,
      passes: 'Title tag optimal\nMeta description optimal\nExactly one <h1> heading present',
      auditedAt: '2026-10-05T00:00:00.000Z',
      platformUrl: 'https://seowebchecker.com/',
    },
    outputFields: [
      { key: 'id', label: 'Audit ID' },
      { key: 'targetUrl', label: 'Audited URL' },
      { key: 'score', label: 'SEO Score (0-100)', type: 'integer' },
      { key: 'grade', label: 'SEO Letter Grade' },
      { key: 'status', label: 'Audit Status (PASS / ALERT)' },
      { key: 'isAlert', label: 'Is Score Below Threshold?', type: 'boolean' },
      { key: 'title', label: 'Page Title' },
      { key: 'metaDescription', label: 'Meta Description' },
      { key: 'issuesCount', label: 'Total Issues Detected', type: 'integer' },
      { key: 'issues', label: 'Issues Summary' },
      { key: 'passes', label: 'Passed Checks Summary' },
      { key: 'auditedAt', label: 'Audit Timestamp', type: 'datetime' },
      { key: 'platformUrl', label: 'SEOWebChecker Platform URL' },
    ],
  },
};
