# seowebchecker-seoaudit-sdk

[![npm version](https://img.shields.io/npm/v/seowebchecker-seoaudit-sdk.svg?color=red)](https://www.npmjs.com/package/seowebchecker-seoaudit-sdk)
[![npm downloads](https://img.shields.io/npm/dt/seowebchecker-seoaudit-sdk.svg)](https://www.npmjs.com/package/seowebchecker-seoaudit-sdk)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![SEOWebChecker](https://img.shields.io/badge/Official%20Site-seowebchecker.com-indigo)](https://seowebchecker.com/)

A lightweight, zero-dependency Node.js client SDK and CLI tool for instant website SEO audits, on-page analysis, and technical diagnostics.

Developed and maintained by [SEOWebChecker.com](https://seowebchecker.com/) — the premier free online SEO audit suite.

---

## ⚡ Highlights

- **Zero External Dependencies**: Fast, lightweight, pure Node.js implementation.
- **50+ SEO Checks**: Meta tags, Title, Description, Canonical, Headings hierarchy (H1-H6), Image alt tags, OpenGraph, Twitter Cards, Schema JSON-LD, HTTPS, and response latency.
- **CI/CD Quality Gate**: Enforce `--min-score 85` in GitHub Actions or GitLab CI to fail builds on SEO regressions.
- **Dual Mode**: Standalone local audits or connect to [SEOWebChecker Cloud API](https://seowebchecker.com/).
- **TypeScript Support**: Ships with full `.d.ts` definitions.

---

## 📦 Installation

```bash
# Global CLI installation
npm install -g seowebchecker-seoaudit-sdk

# Or install in your project
npm install seowebchecker-seoaudit-sdk
```

---

## 🚀 Quick Start

### 1. Programmatic Usage (Node.js / TypeScript)

```javascript
const { SEOAuditor } = require('seowebchecker-seoaudit-sdk');

const auditor = new SEOAuditor();

// Audit any URL
async function runAudit() {
  const result = await auditor.audit('https://example.com');

  console.log(`SEO Score: ${result.score.overall}/100 (Grade: ${result.score.grade})`);
  console.log(`Passed: ${result.stats.passed}, Warnings: ${result.stats.warnings}, Errors: ${result.stats.errors}`);

  for (const err of result.errors) {
    console.error(`[ERROR] ${err.title}: ${err.recommendation}`);
  }
}

runAudit();
```

### 2. Audit Raw HTML (e.g. Next.js, Nuxt, Astro SSR, Static Site Generators)

```javascript
const { SEOAuditor } = require('seowebchecker-seoaudit-sdk');

const auditor = new SEOAuditor();
const result = auditor.auditHtml(renderedHtmlString, 'https://seowebchecker.com/');
console.log('Score:', result.score.overall);
```

---

## 🖥️ Command-Line Interface (CLI)

Run immediately via `npx` without installing:

```bash
# Terminal output with ANSI colors
npx seowebchecker-seoaudit-sdk https://example.com

# Save to Markdown report
npx seowebchecker-seoaudit-sdk https://example.com --format markdown --output audit.md

# Save as JSON
npx seowebchecker-seoaudit-sdk https://example.com --format json --output audit.json

# CI/CD Quality Gate (Exits with code 1 if score < 85)
npx seowebchecker-seoaudit-sdk https://example.com --min-score 85
```

---

## 🌐 Official Platform

Explore the full web audit suite at [SEOWebChecker.com](https://seowebchecker.com/):
- [Website SEO Audit Tool](https://seowebchecker.com/)
- [Broken Link Checker](https://seowebchecker.com/)
- [Schema Markup Validator](https://seowebchecker.com/)

---

## 📄 License

MIT License © 2026 [SEOWebChecker](https://seowebchecker.com/).
