# SEOWebChecker - Technical SEO Audit & On-Page Analyzer Actor

[![Apify Store](https://img.shields.io/badge/Apify-Actor-orange.svg)](https://apify.com/store)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Official Website](https://img.shields.io/badge/Website-seowebchecker.com-blue)](https://seowebchecker.com/)

An official [Apify Actor](https://apify.com/) designed to crawl and audit websites for on-page technical SEO, meta tag validation, heading hierarchy verification, canonical link tags, image accessibility, and performance readiness.

---

## What Does This Actor Do?

- **Document Title Audit**: Checks `<title>` presence and character boundary (30–60 chars).
- **Meta Description**: Detects search snippet length (120–160 chars) and CTR optimization.
- **Canonical Hygiene**: Ensures valid canonical tags exist and follow self-referencing trailing slash hygiene.
- **Heading Hierarchy**: Enforces single primary `<h1>` topic structure.
- **Image Accessibility**: Flags missing `alt` attributes across all indexed images.
- **Mobile Viewport**: Validates mobile responsiveness meta tags.
- **Performance Metrics**: Records server response time (TTFB) and page payload size.

---

## Input Configuration

| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `startUrls` | `Array` | `["https://seowebchecker.com/"]` | List of URLs to audit |
| `timeoutSecs` | `Integer` | `15` | Request timeout per URL |
| `userAgent` | `String` | `SEOWebChecker-ApifyBot/1.0 (+https://seowebchecker.com/)` | Custom User-Agent header |

---

## Output Dataset Example

```json
{
  "url": "https://seowebchecker.com/",
  "score": 100,
  "grade": "A+",
  "meta": {
    "title": "SEOWebChecker: Free Technical SEO Audit Tool & On-Page Analyzer",
    "titleLength": 63,
    "description": "Comprehensive website SEO audit tool for analyzing on-page SEO factors...",
    "descriptionLength": 145,
    "canonical": "https://seowebchecker.com/"
  },
  "performance": {
    "responseTimeMs": 142,
    "pageSizeKb": 38.4
  },
  "images": {
    "total": 12,
    "missingAlt": 0
  },
  "passedChecks": 6,
  "failedChecks": 0,
  "scannedAt": "2026-10-07T12:00:00.000Z",
  "source": "https://seowebchecker.com/"
}
```

---

## Publishing to Apify Store

1. Install the Apify CLI:
   ```bash
   npm install -g apify-cli
   ```
2. Log in with your Apify account:
   ```bash
   apify login
   ```
3. Deploy the Actor from this directory:
   ```bash
   cd apify
   apify push
   ```
4. In the [Apify Console](https://console.apify.com/actors), navigate to your Actor and click **Publish to Apify Store**.
