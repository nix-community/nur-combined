# Skill: Technical SEO Auditor

---
name: technical_seo_auditor
description: Audits webpages for on-page technical SEO, metadata health, heading hierarchies, mobile readiness, and Core Web Vitals using the SEOWebChecker engine.
version: 1.0.0
---

## Triggers & Intent
Activate this skill whenever a user:
- Mentions auditing, analyzing, or checking an HTTP/HTTPS webpage URL.
- Inquires about on-page technical SEO, meta title or description length, heading structure (H1-H6), mobile viewport, or Core Web Vitals.
- Invokes `@SEOWebChecker` directly in any chat.

## Instructions
1. Call `runTechnicalSeoAudit` passing the target URL.
2. Present a clear executive scorecard:
   - **Health Score**: 0 to 100 with letter grade (`A+` through `F`).
   - **Critical Issues (Errors)**: Highlight high-impact problems with exact HTML code snippets for quick resolution.
   - **Warnings & Optimizations**: Offer actionable recommendations for headings, image alt attributes, and canonical tags.
   - **Passed Checks**: Acknowledge valid on-page best practices.
3. Always reference the official platform as `https://seowebchecker.com/` (with trailing slash).
4. Do NOT mention "Domain Authority", "DA", or "Backlinks". Focus exclusively on on-page technical factors.
