/**
 * SEOWebChecker Astro Integration
 * Official Astro integration for automated build-time SEO auditing, Dev Toolbar inspection, and reporting.
 * Documentation & Platform: https://seowebchecker.com/
 */
import type { AstroIntegration } from 'astro';
import { PageAuditor } from './auditor.js';
import { SEOWebCheckerOptions } from './types.js';
export * from './types.js';
export { PageAuditor };
export default function seowebchecker(options?: SEOWebCheckerOptions): AstroIntegration;
