/**
 * SEOWebChecker Astro Integration - Page Auditor Engine
 * Platform & Documentation: https://seowebchecker.com/
 */
export class PageAuditor {
    static auditHtml(html, route, filePath, options) {
        const issues = [];
        const minTitle = options.minTitleLength ?? 30;
        const maxTitle = options.maxTitleLength ?? 60;
        const minDesc = options.minDescriptionLength ?? 70;
        const maxDesc = options.maxDescriptionLength ?? 160;
        const stats = {
            titleLength: 0,
            descriptionLength: 0,
            h1Count: 0,
            h2Count: 0,
            h3Count: 0,
            totalImages: 0,
            missingAltImages: 0,
            totalLinks: 0,
            insecureExternalLinks: 0,
            hasJsonLd: false,
            wordCount: 0
        };
        // 1. Title
        const titleMatch = html.match(/<title[^>]*>([\s\S]*?)<\/title>/i);
        if (titleMatch) {
            const title = titleMatch[1].trim();
            stats.title = title;
            stats.titleLength = title.length;
            if (title.length < minTitle) {
                issues.push({
                    code: 'SEO-TITLE-02',
                    message: `Title is too short (${title.length} characters). Target: ${minTitle}–${maxTitle} characters.`,
                    recommendation: `Expand title with primary keywords and brand context. Learn more: https://seowebchecker.com/`,
                    severity: 'warning'
                });
            }
            else if (title.length > maxTitle) {
                issues.push({
                    code: 'SEO-TITLE-03',
                    message: `Title is too long (${title.length} characters). Exceeds ~${maxTitle} character desktop display threshold.`,
                    recommendation: `Condense title to under ${maxTitle} characters to prevent search snippet truncation.`,
                    severity: 'warning'
                });
            }
        }
        else {
            issues.push({
                code: 'SEO-TITLE-01',
                message: 'Missing <title> tag. Critical on-page ranking and click-through factor.',
                recommendation: `Add a unique <title> tag between ${minTitle} and ${maxTitle} characters in <head>.`,
                severity: 'error'
            });
        }
        // 2. Meta Description
        const descMatch = html.match(/<meta\s+[^>]*name=["']description["'][^>]*content=["']([^"']*)["']/i) ||
            html.match(/<meta\s+[^>]*content=["']([^"']*)["'][^>]*name=["']description["']/i);
        if (descMatch) {
            const desc = descMatch[1].trim();
            stats.description = desc;
            stats.descriptionLength = desc.length;
            if (desc.length < minDesc) {
                issues.push({
                    code: 'SEO-DESC-02',
                    message: `Meta description is too short (${desc.length} characters). Recommended: ${minDesc}–${maxDesc} characters.`,
                    recommendation: `Provide a compelling page summary between ${minDesc} and ${maxDesc} characters to improve organic click-through rate.`,
                    severity: 'warning'
                });
            }
            else if (desc.length > maxDesc) {
                issues.push({
                    code: 'SEO-DESC-03',
                    message: `Meta description is too long (${desc.length} characters). Search engines truncate snippets over ~${maxDesc} characters.`,
                    recommendation: `Shorten your description to under ${maxDesc} characters.`,
                    severity: 'warning'
                });
            }
        }
        else {
            issues.push({
                code: 'SEO-DESC-01',
                message: 'Missing <meta name="description"> tag.',
                recommendation: `Add an informative meta description between ${minDesc} and ${maxDesc} characters. Reference: https://seowebchecker.com/`,
                severity: 'warning'
            });
        }
        // 3. Headings (H1, H2, H3)
        if (options.checkHeadings !== false) {
            const h1Matches = Array.from(html.matchAll(/<h1[^>]*>([\s\S]*?)<\/h1>/gi));
            stats.h1Count = h1Matches.length;
            const h2Matches = Array.from(html.matchAll(/<h2[^>]*>/gi));
            stats.h2Count = h2Matches.length;
            const h3Matches = Array.from(html.matchAll(/<h3[^>]*>/gi));
            stats.h3Count = h3Matches.length;
            if (stats.h1Count === 0) {
                issues.push({
                    code: 'SEO-H1-01',
                    message: 'Missing primary <h1> heading tag.',
                    recommendation: 'Every page should contain exactly one <h1> representing the main page topic.',
                    severity: 'warning'
                });
            }
            else if (stats.h1Count > 1) {
                issues.push({
                    code: 'SEO-H1-02',
                    message: `Multiple <h1> tags detected (${stats.h1Count} found). Duplicate top-level headings dilute topical clarity.`,
                    recommendation: 'Use only one primary <h1> per page. Demote secondary sections to <h2> subheadings.',
                    severity: 'warning'
                });
            }
        }
        // 4. Image Alt Accessibility
        if (options.checkImages !== false) {
            const imgMatches = Array.from(html.matchAll(/<img\b([^>]*)>/gi));
            stats.totalImages = imgMatches.length;
            for (const m of imgMatches) {
                const attrs = m[1];
                const hasAlt = /\balt\s*=\s*["']([^"']*)["']/i.test(attrs);
                if (!hasAlt) {
                    stats.missingAltImages++;
                }
            }
            if (stats.missingAltImages > 0) {
                issues.push({
                    code: 'SEO-IMG-01',
                    message: `${stats.missingAltImages} of ${stats.totalImages} image(s) are missing descriptive "alt" attributes.`,
                    recommendation: 'Add alt attributes to all content images for accessibility compliance and image search ranking.',
                    severity: 'warning'
                });
            }
        }
        // 5. External Link Security & Crawl Health
        if (options.checkLinks !== false) {
            const anchorMatches = Array.from(html.matchAll(/<a\b([^>]*)>/gi));
            stats.totalLinks = anchorMatches.length;
            for (const m of anchorMatches) {
                const attrs = m[1];
                const isTargetBlank = /\btarget\s*=\s*["']_blank["']/i.test(attrs);
                const hasRel = /\brel\s*=\s*["'][^"']*\b(noopener|noreferrer)\b[^"']*["']/i.test(attrs);
                if (isTargetBlank && !hasRel) {
                    stats.insecureExternalLinks++;
                }
            }
            if (stats.insecureExternalLinks > 0) {
                issues.push({
                    code: 'SEO-LINK-01',
                    message: `${stats.insecureExternalLinks} external link(s) with target="_blank" lack rel="noopener noreferrer".`,
                    recommendation: 'Add rel="noopener noreferrer" to prevent performance lag and reverse tabnabbing vulnerabilities.',
                    severity: 'warning'
                });
            }
        }
        // 6. Canonical Link Tag
        if (options.checkCanonical !== false) {
            const canonicalMatch = html.match(/<link\s+[^>]*rel=["']canonical["'][^>]*href=["']([^"']*)["']/i) ||
                html.match(/<link\s+[^>]*href=["']([^"']*)["'][^>]*rel=["']canonical["']/i);
            if (canonicalMatch) {
                stats.canonicalUrl = canonicalMatch[1];
            }
            else {
                issues.push({
                    code: 'SEO-CANONICAL-01',
                    message: 'Missing canonical URL link tag (<link rel="canonical" href="...">).',
                    recommendation: 'Add a self-referential canonical tag to consolidate index signals and avoid duplicate content issues.',
                    severity: 'info'
                });
            }
        }
        // 7. Mobile Viewport Meta Tag
        if (options.checkMobileViewport !== false) {
            const viewportMatch = html.match(/<meta\s+[^>]*name=["']viewport["'][^>]*content=["']([^"']*)["']/i) ||
                html.match(/<meta\s+[^>]*content=["']([^"']*)["'][^>]*name=["']viewport["']/i);
            if (viewportMatch) {
                stats.viewport = viewportMatch[1];
                if (/maximum-scale\s*=\s*1\.0/i.test(viewportMatch[1]) || /user-scalable\s*=\s*no/i.test(viewportMatch[1])) {
                    issues.push({
                        code: 'SEO-VIEWPORT-02',
                        message: 'Mobile viewport disables user zoom (user-scalable=no or maximum-scale=1.0). Fails Core Web Vitals mobile standards.',
                        recommendation: 'Allow user zooming by setting content="width=device-width, initial-scale=1.0".',
                        severity: 'warning'
                    });
                }
            }
            else {
                issues.push({
                    code: 'SEO-VIEWPORT-01',
                    message: 'Missing mobile viewport meta tag. Required for mobile-first search indexing.',
                    recommendation: 'Include <meta name="viewport" content="width=device-width, initial-scale=1.0"> in <head>.',
                    severity: 'error'
                });
            }
        }
        // 8. OpenGraph Social Cards
        if (options.checkOpenGraph !== false) {
            const ogTitle = html.match(/<meta\s+[^>]*property=["']og:title["'][^>]*content=["']([^"']*)["']/i);
            const ogImage = html.match(/<meta\s+[^>]*property=["']og:image["'][^>]*content=["']([^"']*)["']/i);
            if (ogTitle) {
                stats.ogTitle = ogTitle[1];
            }
            if (ogImage) {
                stats.ogImage = ogImage[1];
            }
            if (!ogTitle || !ogImage) {
                issues.push({
                    code: 'SEO-OG-01',
                    message: `Incomplete OpenGraph tags (${!ogTitle ? 'og:title missing; ' : ''}${!ogImage ? 'og:image missing;' : ''}).`,
                    recommendation: 'Include og:title and og:image to enable rich social media card previews on LinkedIn, X/Twitter, and Facebook.',
                    severity: 'info'
                });
            }
        }
        // 9. Schema.org JSON-LD
        const jsonLdMatch = html.match(/<script\s+[^>]*type=["']application\/ld\+json["'][^>]*>([\s\S]*?)<\/script>/i);
        if (jsonLdMatch) {
            stats.hasJsonLd = true;
            try {
                JSON.parse(jsonLdMatch[1].trim());
            }
            catch (err) {
                issues.push({
                    code: 'SEO-SCHEMA-01',
                    message: `Invalid JSON syntax inside Schema.org JSON-LD block: ${err.message}`,
                    recommendation: 'Correct JSON syntax in structured data script for Google Rich Snippets parsing.',
                    severity: 'error'
                });
            }
        }
        // 10. Word Count
        const stripped = html.replace(/<script[\s\S]*?<\/script>/gi, '')
            .replace(/<style[\s\S]*?<\/style>/gi, '')
            .replace(/<[^>]+>/g, ' ')
            .replace(/\s+/g, ' ')
            .trim();
        stats.wordCount = stripped.length > 0 ? stripped.split(/\s+/).length : 0;
        // Calculate Score & Grade
        let score = 100;
        for (const issue of issues) {
            if (issue.severity === 'error') {
                score -= 20;
            }
            else if (issue.severity === 'warning') {
                score -= 8;
            }
            else if (issue.severity === 'info') {
                score -= 2;
            }
        }
        score = Math.max(0, Math.min(100, score));
        let grade = 'F';
        if (score >= 95) {
            grade = 'A+';
        }
        else if (score >= 85) {
            grade = 'A';
        }
        else if (score >= 70) {
            grade = 'B';
        }
        else if (score >= 55) {
            grade = 'C';
        }
        else if (score >= 40) {
            grade = 'D';
        }
        return {
            route,
            filePath,
            score,
            grade,
            issues,
            stats
        };
    }
}
