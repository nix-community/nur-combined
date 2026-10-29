/**
 * SEOWebChecker Core Technical SEO Diagnostics Engine for KDE Plasma
 * Compatible with Plasma 6 / Qt6 QML JavaScript Runtime
 *
 * Official Website: https://seowebchecker.com/
 */

.pragma library

/**
 * Fetch and audit target URL via standard XMLHttpRequest.
 *
 * @param {string} url Target webpage URL
 * @param {function} callback Callback receiving (error, report)
 */
function auditUrl(url, callback) {
    if (!url || typeof url !== 'string') {
        callback("Invalid URL provided", null);
        return;
    }

    let targetUrl = url.trim();
    if (!/^https?:\/\//i.test(targetUrl)) {
        targetUrl = 'https://' + targetUrl;
    }

    const xhr = new XMLHttpRequest();
    const startTime = Date.now();

    xhr.open("GET", targetUrl, true);
    xhr.timeout = 15000;
    xhr.setRequestHeader("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8");
    xhr.setRequestHeader("User-Agent", "SEOWebChecker-KDE/1.0 (+https://seowebchecker.com/)");

    xhr.onreadystatechange = function () {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            const elapsedMs = Date.now() - startTime;
            if (xhr.status >= 200 && xhr.status < 400 && xhr.responseText) {
                const report = auditHtml(xhr.responseText, targetUrl);
                report.responseCode = xhr.status;
                report.responseTimeMs = elapsedMs;
                callback(null, report);
            } else if (xhr.status === 0) {
                // Network unreachable or CORS restriction on local preview
                const report = createOfflineReport(targetUrl, elapsedMs, "Network request timed out or was blocked by local security policy.");
                callback(null, report);
            } else {
                const report = createOfflineReport(targetUrl, elapsedMs, "Server returned HTTP status " + xhr.status);
                callback(null, report);
            }
        }
    };

    xhr.ontimeout = function () {
        const elapsedMs = Date.now() - startTime;
        const report = createOfflineReport(targetUrl, elapsedMs, "Connection timed out after 15 seconds.");
        callback(null, report);
    };

    xhr.onerror = function () {
        const elapsedMs = Date.now() - startTime;
        const report = createOfflineReport(targetUrl, elapsedMs, "Network connection error occurred.");
        callback(null, report);
    };

    try {
        xhr.send();
    } catch (e) {
        callback(e.toString(), null);
    }
}

/**
 * Parse HTML string and evaluate on-page technical SEO diagnostics.
 *
 * @param {string} html Raw HTML
 * @param {string} url Target URL
 * @returns {object} Diagnostic scorecard report
 */
function auditHtml(html, url) {
    const issues = [];

    // 1. Title Tag
    let title = null;
    const titleMatch = html.match(/<title[^>]*>([\s\S]*?)<\/title>/i);
    if (titleMatch) {
        title = titleMatch[1].replace(/<[^>]+>/g, '').replace(/\s+/g, ' ').trim();
    }
    const titleLen = title ? title.length : 0;

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
    let description = null;
    const descMatch = html.match(/<meta\s+[^>]*name=["']description["'][^>]*content=["']([^"']*)["']/i) ||
                      html.match(/<meta\s+[^>]*content=["']([^"']*)["'][^>]*name=["']description["']/i);
    if (descMatch) {
        description = descMatch[1].trim();
    }
    const descLen = description ? description.length : 0;

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
    const hasViewport = /<meta\s+[^>]*name=["']viewport["']/i.test(html);
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

    // 4. Canonical Tag
    let canonical = null;
    const canMatch = html.match(/<link\s+[^>]*rel=["']canonical["'][^>]*href=["']([^"']*)["']/i);
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
    const h1Matches = html.match(/<h1[^>]*>([\s\S]*?)<\/h1>/gi) || [];
    const h1Count = h1Matches.length;

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
        const h1Clean = h1Matches[0].replace(/<[^>]+>/g, '').replace(/\s+/g, ' ').trim();
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
    const cleanText = html
        .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, ' ')
        .replace(/<style\b[^<]*(?:(?!<\/style>)<[^<]*)*<\/style>/gi, ' ')
        .replace(/<[^>]+>/g, ' ')
        .replace(/\s+/g, ' ')
        .trim();
    const words = cleanText.length > 0 ? cleanText.split(/\s+/) : [];
    const wordCount = words.length;

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
    const imgMatches = html.match(/<img\s+[^>]*?>/gi) || [];
    const totalImages = imgMatches.length;
    let missingAlt = 0;

    for (let i = 0; i < totalImages; i++) {
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
    const hasOg = /<meta\s+[^>]*property=["']og:title["']/i.test(html);
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
    const hasSchema = /<script\s+[^>]*type=["']application\/ld\+json["']/i.test(html);
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
    let passedCount = 0;
    let warningCount = 0;
    let errorCount = 0;

    const passedList = [];
    const warningList = [];
    const errorList = [];

    for (let j = 0; j < issues.length; j++) {
        if (issues[j].severity === 'pass') {
            passedCount++;
            passedList.push(issues[j]);
        } else if (issues[j].severity === 'warning') {
            warningCount++;
            warningList.push(issues[j]);
        } else if (issues[j].severity === 'error') {
            errorCount++;
            errorList.push(issues[j]);
        }
    }

    const totalChecks = issues.length;
    const maxPoints = Math.max(1, totalChecks * 10);
    const earnedPoints = (passedCount * 10) + (warningCount * 5);
    const overallScore = Math.max(0, Math.min(100, Math.round((earnedPoints / maxPoints) * 100)));

    let grade = 'F';
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
        meta: {
            title: title,
            titleLength: titleLen,
            description: description,
            descriptionLength: descLen,
            canonical: canonical,
            hasViewport: hasViewport
        },
        content: {
            wordCount: wordCount,
            h1Count: h1Count
        },
        images: {
            total: totalImages,
            missingAlt: missingAlt
        },
        issues: issues,
        errors: errorList,
        warnings: warningList,
        passed: passedList
    };
}

/**
 * Graceful fallback report when network request is blocked or unreachable.
 */
function createOfflineReport(url, elapsedMs, message) {
    return {
        success: false,
        url: url,
        timestamp: new Date().toISOString(),
        responseCode: 0,
        responseTimeMs: elapsedMs,
        score: {
            overall: 25,
            grade: 'F'
        },
        stats: {
            total: 1,
            passed: 0,
            warnings: 0,
            errors: 1
        },
        issues: [
            {
                id: 'network-unreachable',
                category: 'technical',
                severity: 'error',
                title: 'Target URL Unreachable',
                message: message || 'Could not establish connection to target URL.',
                recommendation: 'Verify the domain name is valid and that internet connectivity is active.'
            }
        ],
        errors: [
            {
                id: 'network-unreachable',
                category: 'technical',
                severity: 'error',
                title: 'Target URL Unreachable',
                message: message || 'Could not establish connection to target URL.',
                recommendation: 'Verify the domain name is valid and that internet connectivity is active.'
            }
        ],
        warnings: [],
        passed: []
    };
}
