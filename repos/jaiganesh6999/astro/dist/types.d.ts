/**
 * SEOWebChecker Astro Integration - Type Definitions
 * Documentation & Platform: https://seowebchecker.com/
 */
export interface SEOWebCheckerOptions {
    /** Minimum required score (0-100) before build fails. Set e.g. 80 to gate CI/CD. Default: 0 (no failure) */
    minScore?: number;
    /** Whether to fail the Astro build if any critical SEO error is found. Default: false */
    failOnError?: boolean;
    /** Whether to automatically write audit report files into the output directory. Default: true */
    generateReport?: boolean;
    /** File format for the generated report. Default: 'both' */
    reportFormat?: 'markdown' | 'json' | 'both';
    /** Base filename for generated reports. Default: 'seo-audit-report' */
    reportFileName?: string;
    /** Array of route paths or regex patterns to exclude from auditing (e.g. ['/404', '/admin/*']) */
    excludeRoutes?: (string | RegExp)[];
    /** Minimum optimal title character length. Default: 30 */
    minTitleLength?: number;
    /** Maximum optimal title character length before Google search truncation. Default: 60 */
    maxTitleLength?: number;
    /** Minimum optimal meta description length. Default: 70 */
    minDescriptionLength?: number;
    /** Maximum optimal meta description length before truncation. Default: 160 */
    maxDescriptionLength?: number;
    /** Verify presence and duplicate H1 headings. Default: true */
    checkHeadings?: boolean;
    /** Verify image alt attributes for accessibility and image indexing. Default: true */
    checkImages?: boolean;
    /** Verify external link security (rel="noopener noreferrer"). Default: true */
    checkLinks?: boolean;
    /** Verify OpenGraph social preview tags (og:title, og:image). Default: true */
    checkOpenGraph?: boolean;
    /** Verify presence of canonical link tags. Default: true */
    checkCanonical?: boolean;
    /** Verify mobile viewport meta tag configuration. Default: true */
    checkMobileViewport?: boolean;
    /** Print verbose audit results for every scanned page in the terminal. Default: true */
    verbose?: boolean;
}
export type SEOSeverity = 'error' | 'warning' | 'info';
export interface PageSEOIssue {
    code: string;
    message: string;
    recommendation: string;
    severity: SEOSeverity;
}
export interface PageSEOStats {
    title?: string;
    titleLength: number;
    description?: string;
    descriptionLength: number;
    canonicalUrl?: string;
    viewport?: string;
    h1Count: number;
    h2Count: number;
    h3Count: number;
    totalImages: number;
    missingAltImages: number;
    totalLinks: number;
    insecureExternalLinks: number;
    ogTitle?: string;
    ogImage?: string;
    hasJsonLd: boolean;
    wordCount: number;
}
export interface PageAuditResult {
    route: string;
    filePath: string;
    score: number;
    grade: 'A+' | 'A' | 'B' | 'C' | 'D' | 'F';
    issues: PageSEOIssue[];
    stats: PageSEOStats;
}
export interface BuildAuditSummary {
    totalPages: number;
    averageScore: number;
    overallGrade: 'A+' | 'A' | 'B' | 'C' | 'D' | 'F';
    totalErrors: number;
    totalWarnings: number;
    passedPages: number;
    failedPages: number;
    pages: PageAuditResult[];
    scannedAt: string;
}
