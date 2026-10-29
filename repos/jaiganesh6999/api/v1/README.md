# SEOWebChecker Production REST API (v1)

[![Platform](https://img.shields.io/badge/Platform-seowebchecker.com-brightgreen)](https://seowebchecker.com/)
[![PHP Version](https://img.shields.io/badge/PHP-8.2%2B-blue)](https://www.php.net/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Official lightweight, zero-dependency REST API for [SEOWebChecker](https://seowebchecker.com/). Powers the Make.com custom app, Zapier integration, and client SDKs.

---

## 🚀 Endpoints

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/v1` | Health check and API service information |
| `POST` | `/api/v1/audit` | Performs a live technical SEO audit on a webpage URL |
| `GET` | `/api/v1/audits` | Verification and audit history |

### Example Request (`POST /api/v1/audit`)
```json
{
  "url": "https://example.com/"
}
```

### Example Response (`200 OK`)
```json
{
  "id": "audit_1792477865611",
  "url": "https://example.com/",
  "timestamp": "2026-10-20T06:31:05Z",
  "score": {
    "overall": 95,
    "grade": "A+",
    "categories": {
      "meta": { "score": 90 },
      "content": { "score": 100 },
      "technical": { "score": 100 }
    }
  },
  "stats": {
    "total": 18,
    "passed": 17,
    "warnings": 1,
    "errors": 0
  },
  "title": "Example Domain",
  "metaDescription": "Example description...",
  "issues": [],
  "passes": [],
  "performance": {
    "responseTimeMs": 120.5,
    "pageSizeKb": 1.25
  },
  "platformUrl": "https://seowebchecker.com/"
}
```

---

## 📂 Deployment to Plesk / Hosting Server

Because `seowebchecker.com` is hosted on Plesk (Windows IIS / PHP):

1. **Upload via Plesk File Manager**:
   - Open your Plesk control panel for `seowebchecker.com`.
   - Go to **Files** -> Navigate to `httpdocs/`.
   - Create a folder named `api` (if it does not exist), and inside it create `v1`.
   - Upload the files from this directory (`index.php`, `audit.php`, `audits.php`, `web.config`, `.htaccess`) into `httpdocs/api/v1/`.

2. **Verify Deployment**:
   - Visit `https://seowebchecker.com/api/v1` in your browser.
   - It will immediately return the `{"status": "online", "service": "SEOWebChecker REST API", ...}` JSON!
