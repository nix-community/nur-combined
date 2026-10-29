# @seowebchecker/audit

[![JSR](https://jsr.io/badges/@seowebchecker/audit)](https://jsr.io/@seowebchecker/audit)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Official Website](https://img.shields.io/badge/Website-seowebchecker.com-blue?style=flat-square)](https://seowebchecker.com/)

Lightweight, modern, zero-dependency SEO audit SDK for **TypeScript**, **Deno**, **Bun**, and **Node.js**. Built by the [SEOWebChecker](https://seowebchecker.com/) team to automate on-page technical SEO diagnostics, meta tag inspection, heading structure analysis, image accessibility verification, and Core Web Vitals checks.

Live web-based audits, interactive scoring, and comprehensive site health reports are available at **[https://seowebchecker.com/](https://seowebchecker.com/)**.

---

## ⚡ Features

- **Cross-Runtime**: Runs anywhere standard web APIs exist (`fetch`, `AbortController`) — Node.js 18+, Deno, Bun, Cloudflare Workers, and modern browsers.
- **Pure TypeScript**: First-class type definitions with zero slow types; native auto-generated API docs on JSR.
- **Zero Dependencies**: Lightweight and fast with no bloated external dependencies.
- **Comprehensive On-Page Audits**:
  - Title tag length and snippet optimization
  - Meta description validation (character limits & CTR impact)
  - Canonical link tag detection
  - Viewport & mobile responsiveness meta tags
  - Heading hierarchy checks (`<h1>` count & presence)
  - Image accessibility (`alt` attribute presence & modern format detection)
  - Protocol security (HTTPS verification)
  - OpenGraph & Schema.org JSON-LD structured data presence
- **Actionable Scoring Engine**: Computes weighted scores (0–100) and letter grades (A+ through F) alongside exact remediation recommendations.

---

## 📦 Installation

### Deno
```bash
deno add jsr:@seowebchecker/audit
```

### Node.js (via npx)
```bash
npx jsr add @seowebchecker/audit
```

### Bun
```bash
bunx jsr add @seowebchecker/audit
```

### pnpm
```bash
pnpm dlx jsr add @seowebchecker/audit
```

---

## 🚀 Quickstart

### 1. Audit an HTML String

```typescript
import { auditHtml } from "@seowebchecker/audit";

const html = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>SEOWebChecker: Free SEO Audit & Technical Analysis Tools</title>
  <meta name="description" content="Free open-source SEO audit tools for technical scorecards, meta tags, and Core Web Vitals.">
  <link rel="canonical" href="https://seowebchecker.com/">
  <meta property="og:title" content="SEOWebChecker SEO Tools">
</head>
<body>
  <h1>Optimize Your Search Engine Presence</h1>
  <p>Run instant diagnostic audits on your web pages.</p>
  <img src="banner.webp" alt="SEO Analysis Dashboard">
</body>
</html>
`;

const result = auditHtml(html, { url: "https://seowebchecker.com/" });

console.log(`Score: ${result.score.overall}/100 [Grade: ${result.score.grade}]`);
console.log(`Passed Checks: ${result.stats.passed} / ${result.stats.total}`);

for (const issue of result.issues) {
  console.log(`[${issue.severity.toUpperCase()}] ${issue.title}: ${issue.message}`);
}
```

### 2. Audit a Live Website URL

```typescript
import { auditUrl, formatConsole } from "@seowebchecker/audit";

const result = await auditUrl("https://seowebchecker.com/");

// Print formatted terminal report
console.log(formatConsole(result));
```

### 3. Generate Markdown Reports (e.g. for GitHub Actions / CI)

```typescript
import { auditHtml, formatMarkdown } from "@seowebchecker/audit";

const result = auditHtml(myProductionHtml, { url: "https://seowebchecker.com/" });
const markdownReport = formatMarkdown(result);

console.log(markdownReport);
```

---

## 🔗 Related Resources

- **Official Web Portal**: [https://seowebchecker.com/](https://seowebchecker.com/)
- **GitHub Repository**: [https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk](https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk)
- **npm Package**: [seowebchecker-seoaudit-sdk](https://www.npmjs.com/package/seowebchecker-seoaudit-sdk)
- **Vite Plugin**: [vite-plugin-seowebchecker](https://www.npmjs.com/package/vite-plugin-seowebchecker)

---

## 📄 License

This package is licensed under the [MIT License](https://opensource.org/licenses/MIT).
