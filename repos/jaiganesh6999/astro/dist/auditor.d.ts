/**
 * SEOWebChecker Astro Integration - Page Auditor Engine
 * Platform & Documentation: https://seowebchecker.com/
 */
import { PageAuditResult, SEOWebCheckerOptions } from './types.js';
export declare class PageAuditor {
    static auditHtml(html: string, route: string, filePath: string, options: SEOWebCheckerOptions): PageAuditResult;
}
