# astro-seowebchecker

[![Astro Integration](https://img.shields.io/badge/Astro-Integration-FF5D01.svg?logo=astro)](https://astro.build/integrations)
[![npm version](https://img.shields.io/npm/v/astro-seowebchecker.svg?color=red)](https://www.npmjs.com/package/astro-seowebchecker)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![SEOWebChecker](https://img.shields.io/badge/Platform-seowebchecker.com-indigo)](https://seowebchecker.com/)

Official [Astro](https://astro.build/) integration from **SEOWebChecker**. Automates build-time technical SEO audits, Core Web Vitals readiness checks, CI/CD regression gating, and provides an all-in-one `<SEO />` drop-in component.

Powered by the [SEOWebChecker](https://seowebchecker.com/) technical SEO analysis platform.

---

## ⚡ Features

- **Automated Build-Time SEO Auditing**: Crawls every static HTML page generated during `astro build`.
- **Pre-Deployment Regression Guard**: Automatically fail builds or CI pipelines (`failOnError: true` or `minScore: 85`) if critical SEO mistakes are introduced.
- **On-Page Health Checks**:
  - Title tag length verification (30–60 characters).
  - Meta description presence and length validation (70–160 characters).
  - Heading hierarchy diagnostics (missing `<h1>` or duplicate `<h1>` tags).
  - Image accessibility checks (missing `alt` attributes).
  - Canonical link tag validation.
  - External link security auditing (`rel="noopener noreferrer"` on `target="_blank"`).
  - Mobile viewport validation and zoom disabling prevention.
  - OpenGraph & Twitter preview card verification.
  - Schema.org JSON-LD structured data syntax validation.
- **Automated Diagnostic Reports**: Outputs `dist/seo-audit-report.md` and `dist/seo-audit-report.json` on every build.
- **Drop-In `<SEO />` Component**: Zero-boilerplate component handling canonicals, OpenGraph, Twitter cards, and Schema.org JSON-LD.

---

## 📦 Installation

Install `astro-seowebchecker` via the Astro CLI or npm:

```bash
# Using Astro CLI (recommended)
npx astro add astro-seowebchecker

# Or using npm
npm install astro-seowebchecker
```

---

## 🚀 Quick Setup

Add `seowebchecker` to your `astro.config.mjs`:

```javascript
import { defineConfig } from 'astro/config';
import seowebchecker from 'astro-seowebchecker';

export default defineConfig({
  site: 'https://example.com',
  integrations: [
    seowebchecker({
      minScore: 80,         // Optional: fail build if avg score drops below 80
      failOnError: false,   // Set to true in CI/CD to abort build on errors
      generateReport: true  // Creates dist/seo-audit-report.md & .json
    })
  ]
});
```

---

## 🧩 Using the `<SEO />` Component

Import and drop `<SEO />` into your Astro layouts or page templates:

```astro
---
import { SEO } from 'astro-seowebchecker/components';
---

<html lang="en">
  <head>
    <SEO
      title="High-Performance Astro Architectures | TechBlog"
      description="Learn how to optimize Astro static pages for maximum Google search visibility and sub-second Core Web Vitals."
      canonical="https://example.com/posts/astro-architectures"
      image="https://example.com/og-banner.jpg"
      openGraph={{
        type: 'article',
        siteName: 'TechBlog'
      }}
      twitter={{
        card: 'summary_large_image',
        site: '@techblog'
      }}
      schema={{
        "@context": "https://schema.org",
        "@type": "BlogPosting",
        "headline": "High-Performance Astro Architectures",
        "author": {
          "@type": "Person",
          "name": "Jane Doe"
        }
      }}
    />
  </head>
  <body>
    <h1>High-Performance Astro Architectures</h1>
    <p>Page content goes here...</p>
  </body>
</html>
```

---

## ⚙️ Configuration Options

| Option | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `minScore` | `number` | `0` | Minimum score (0–100) required to pass build. If average score is lower, build fails. |
| `failOnError` | `boolean` | `false` | If `true`, aborts the build when critical SEO errors (e.g. missing title/viewport) are detected. |
| `generateReport` | `boolean` | `true` | Writes summary report files to the output directory. |
| `reportFormat` | `'markdown' \| 'json' \| 'both'` | `'both'` | Report output format. |
| `reportFileName` | `string` | `'seo-audit-report'` | Base filename for generated report files. |
| `excludeRoutes` | `(string \| RegExp)[]` | `[]` | Routes to ignore (e.g. `['/404', /^\/admin/ ]`). |
| `minTitleLength` | `number` | `30` | Minimum recommended title character length. |
| `maxTitleLength` | `number` | `60` | Maximum recommended title character length. |
| `minDescriptionLength` | `number` | `70` | Minimum recommended meta description length. |
| `maxDescriptionLength` | `number` | `160` | Maximum recommended meta description length. |
| `checkImages` | `boolean` | `true` | Validate `alt` attributes on all images. |
| `checkHeadings` | `boolean` | `true` | Validate `<h1>` heading hierarchy. |
| `checkLinks` | `boolean` | `true` | Audit `target="_blank"` link security. |
| `checkOpenGraph` | `boolean` | `true` | Check for `og:title` and `og:image`. |
| `checkCanonical` | `boolean` | `true` | Check for canonical link tags. |
| `checkMobileViewport` | `boolean` | `true` | Validate mobile viewport settings. |
| `verbose` | `boolean` | `true` | Print detailed per-page CLI audit results to console. |

---

## 🖥️ Build Console Output Preview

During `astro build`, SEOWebChecker prints a clear CLI scorecard:

```text
═══════════════════════════════════════════════════════════════
 🔍 SEOWebChecker — Technical SEO Build Audit
═══════════════════════════════════════════════════════════════
 Pages Audited:    12
 Average Score:    94/100 (Grade: A)
 Errors:           0
 Warnings:         2
 Platform:         https://seowebchecker.com/
───────────────────────────────────────────────────────────────
  100/100 (A+)  /
   92/100 (A)   /about
    [WARN] SEO-DESC-02: Meta description is too short (42 characters). Target: 70–160.
   90/100 (A)   /blog/first-post
    [WARN] SEO-IMG-01: 1 of 3 image(s) are missing descriptive "alt" attributes.
═══════════════════════════════════════════════════════════════
```

---

## 🌐 Official Platform

For continuous crawling, automated site-wide audits, and Core Web Vitals monitoring:
👉 **[https://seowebchecker.com/](https://seowebchecker.com/)**

---

## 📄 License

MIT License © 2026 [SEOWebChecker](https://seowebchecker.com/).
