# SEOWebChecker Edge SEO Engine for Cloudflare Workers

[![Deploy to Cloudflare Workers](https://deploy.workers.cloudflare.com/button)](https://deploy.workers.cloudflare.com/?url=https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk/tree/main/cloudflare)
[![Cloudflare Workers](https://img.shields.io/badge/Cloudflare-Workers-F38020?logo=cloudflare&logoColor=white)](https://workers.cloudflare.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Official Website](https://img.shields.io/badge/Website-seowebchecker.com-blue?style=flat-square)](https://seowebchecker.com/)

High-performance, zero-latency **Edge SEO engine** and **global serverless audit service** running natively on [Cloudflare Workers](https://workers.cloudflare.com/) across 330+ edge locations worldwide. Powered by the [SEOWebChecker](https://seowebchecker.com/) technical SEO analysis platform.

Official web portal, interactive audits, and full reports are available at **[https://seowebchecker.com/](https://seowebchecker.com/)**.

---

## ⚡ 1-Click Instant Deployment

Click the button below to deploy your own private, globally distributed SEO audit service directly into your free Cloudflare account:

[![Deploy to Cloudflare Workers](https://deploy.workers.cloudflare.com/button)](https://deploy.workers.cloudflare.com/?url=https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk/tree/main/cloudflare)

---

## 🎯 The Two Main Cloudflare Use Cases

### 1. Global Serverless SEO Audit REST API

Run instant on-page technical SEO audits from the Cloudflare edge datacenter nearest to your target website, bypassing local network throttling.

#### A. Audit Any Live URL (GET)
```http
GET https://<your-worker>.workers.dev/audit?url=https://seowebchecker.com/
```

**JSON Response:**
```json
{
  "url": "https://seowebchecker.com/",
  "timestamp": "2026-09-30T11:24:00.000Z",
  "edge_location": "SJC",
  "score": {
    "overall": 95,
    "grade": "A+",
    "categories": {
      "meta": { "name": "meta", "score": 100, "passed": 4, "warnings": 0, "errors": 0 },
      "content": { "name": "content", "score": 95, "passed": 3, "warnings": 0, "errors": 0 },
      "images": { "name": "images", "score": 100, "passed": 1, "warnings": 0, "errors": 0 }
    }
  },
  "stats": {
    "total": 8,
    "passed": 8,
    "warnings": 0,
    "errors": 0
  },
  "meta": {
    "title": "SEOWebChecker: Free SEO Audit & Technical Analysis Tools",
    "title_length": 55,
    "description": "Free open-source SEO audit tools for technical scorecards, meta tags, and Core Web Vitals.",
    "description_length": 90,
    "canonical": "https://seowebchecker.com/",
    "viewport": "width=device-width, initial-scale=1.0"
  },
  "issues": []
}
```

#### B. Audit Raw HTML Payloads (POST)
Perfect for CI/CD pipelines, pre-commit hooks, or staging environments before deploying to production:

```bash
curl -X POST https://<your-worker>.workers.dev/audit \
  -H "Content-Type: application/json" \
  -d '{"html": "<html><head><title>Test Page</title></head><body><h1>Heading</h1></body></html>", "url": "https://example.com"}'
```

---

### 2. Edge SEO Middleware (`HTMLRewriter` Meta Remediation)

When managing legacy CMS platforms (Shopify, Magento, WordPress) or large enterprise web applications, fixing missing meta tags often takes weeks of engineering backlog.

This worker acts as an **Edge SEO reverse proxy**: as HTML streams from the origin server through the Cloudflare edge, Cloudflare's streaming `HTMLRewriter` detects missing canonical or mobile viewport tags and injects them on the fly before delivering to search bots:

```http
GET https://<your-worker>.workers.dev/edge-proxy?url=https://example.com
```

* **Zero Origin Load**: Streaming transformation adds less than 1 millisecond of edge latency.
* **Auto Canonical Remediation**: Injects `<link rel="canonical" href="...">` if the origin HTML omitted it.
* **Auto Mobile Viewport**: Injects `<meta name="viewport" content="width=device-width, initial-scale=1.0">` to guarantee mobile friendliness for Googlebot.
* **Diagnostic Response Headers**:
  ```http
  X-Edge-SEO-Processed: SEOWebChecker (https://seowebchecker.com/)
  X-Edge-SEO-Remediation: active
  ```

---

## 🛠️ Local Development & CLI Deployment

### Prerequisites
- Node.js 18+
- Cloudflare account

### 1. Run Locally with Wrangler
```bash
cd cloudflare
npx wrangler dev
```
Open [http://localhost:8787](http://localhost:8787) in your browser to inspect the edge dashboard and test endpoints.

### 2. Deploy to Production
```bash
npx wrangler deploy
```
Your worker will be live globally on `https://seowebchecker-edge-worker.<your-subdomain>.workers.dev`.

---

## 🔗 Related Resources

- **Official Web Portal**: [https://seowebchecker.com/](https://seowebchecker.com/)
- **GitHub Repository**: [https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk](https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk)
- **JSR TypeScript SDK**: [@seowebchecker/audit](https://jsr.io/@seowebchecker/audit)
- **NPM Package**: [seowebchecker-seoaudit-sdk](https://www.npmjs.com/package/seowebchecker-seoaudit-sdk)

---

## 📄 License

This package is licensed under the [MIT License](https://opensource.org/licenses/MIT).
