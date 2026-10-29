# SEOWebChecker for Nim

[![Nimble Directory](https://img.shields.io/badge/nimble-seowebchecker-orange.svg)](https://nimble.directory/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-https%3A%2F%2Fseowebchecker.com%2F-brightgreen)](https://seowebchecker.com/)

A high-performance technical SEO audit library and CLI binary for the **Nim** programming language, powered by [SEOWebChecker](https://seowebchecker.com/).

Evaluates on-page search engine optimization, meta tags, mobile viewport configuration, canonical URL consistency, heading hierarchies, content volume, and HTTPS security with zero external runtime dependencies.

---

## Features

- ⚡ **Zero External Dependencies**: Built entirely with Nim's native standard library (`httpclient`, `json`, `strutils`, `times`, `parseopt`).
- 🎯 **Algorithmic Health Scoring**: 0–100 health score with academic grade evaluation (`A+` to `F`).
- 🛠️ **Dual Mode**: Use programmatically as a library (`import seowebchecker`) or as a standalone CLI tool (`seowebchecker`).
- 📊 **Multi-Format Export**: Generates console tables, raw JSON for CI/CD pipelines, and GitHub-flavored Markdown for pull request comments.
- 🚦 **CI/CD Quality Gates**: Enforce SEO health score minimum thresholds in deployment pipelines with automated exit codes.

---

## Installation

Install using **Nimble**:

```bash
nimble install seowebchecker
```

Or install directly from GitHub:

```bash
nimble install https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk
```

---

## CLI Usage

### 1. Visual Terminal Report
```bash
seowebchecker https://seowebchecker.com/
```

### 2. JSON Output for Automated Pipelines
```bash
seowebchecker https://seowebchecker.com/ --json
```

### 3. Markdown Report for Documentation & PRs
```bash
seowebchecker https://seowebchecker.com/ --md
```

### 4. CI/CD Threshold Score Gate
```bash
# Returns exit code 0 if score >= 90, otherwise exit code 1
seowebchecker --score https://seowebchecker.com/ --threshold=90
```

---

## Programmatic Library Usage

```nim
import seowebchecker

# 1. Initialize auditor
let auditor = newSeoAuditor(alertThreshold = 85)

# 2. Audit a live website
let result = auditor.audit("https://seowebchecker.com/")

echo "SEO Health Score : ", result.score, " / 100 (", result.grade, ")"
echo "Audit Status     : ", result.status
echo "Title            : ", result.title, " (", result.titleLength, " chars)"
echo "Mobile Viewport  : ", result.hasViewport
echo "Passed Checks    : ", result.passes.len
echo "Issues Found     : ", result.issues.len

# 3. Export to JSON or Markdown
let jsonReport = result.toJson()
let mdReport = result.toMarkdown()

# 4. Audit raw HTML string directly
let rawHtml = "<html><head><title>My Title</title></head><body><h1>Heading</h1><p>...</p></body></html>"
let stringAudit = auditor.auditHtml(rawHtml, "https://example.com/")
```

---

## Audit Criteria

| Category | Audit Metric | Optimal Range / Recommendation |
|:---|:---|:---|
| **Meta** | Title Tag Length | 30–65 characters, descriptive |
| **Meta** | Meta Description Length | 70–160 characters, engaging summary |
| **Technical** | Mobile Viewport | `<meta name="viewport" content="...">` declared |
| **Technical** | Canonical URL | `<link rel="canonical" href="...">` declared |
| **Technical** | HTTPS Security | Secure encrypted protocol active |
| **Content** | Heading Hierarchy | Exactly 1 primary `<h1>` heading |
| **Content** | Word Count | ≥ 100 words of relevant on-page copy |

---

## Official Platform

For web-based auditing, API keys, and enterprise crawling, visit:
- **Official Site**: [https://seowebchecker.com/](https://seowebchecker.com/)

---

## License

MIT License. See [LICENSE](LICENSE) for details.
