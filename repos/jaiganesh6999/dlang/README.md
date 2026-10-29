# SEOWebChecker for Dlang (DUB)

[![DUB Package](https://img.shields.io/dub/v/seowebchecker.svg)](https://code.dlang.org/packages/seowebchecker)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-https%3A%2F%2Fseowebchecker.com%2F-brightgreen)](https://seowebchecker.com/)

A high-performance technical SEO audit library and CLI binary for the **D programming language (Dlang)**, powered by [SEOWebChecker](https://seowebchecker.com/).

Evaluates on-page search engine optimization, meta tags, mobile viewport readiness, canonical URL integrity, heading hierarchies, indexable content volume, and HTTPS security.

---

## Features

- ⚡ **Zero Third-Party Dependencies**: Pure D Phobos standard library implementation (`std.net.curl`, `std.json`, `std.regex`).
- 🎯 **Algorithmic Health Scoring**: 0–100 health score with academic grade evaluation (`A+` to `F`).
- 🛠️ **Dual Mode**: Library API (`import seowebchecker;`) or standalone executable CLI (`seowebchecker`).
- 📊 **Multi-Format Export**: Terminal dashboard, JSON for automated pipelines, and GitHub-flavored Markdown.
- 🚦 **CI/CD Quality Gates**: Built-in score threshold verification with automated exit codes.

---

## Installation via DUB

Add `seowebchecker` to your project using DUB:

```bash
dub add seowebchecker
```

Or add to your `dub.json`:

```json
{
  "dependencies": {
    "seowebchecker": "~>1.0.0"
  }
}
```

---

## CLI Usage

### 1. Run directly with DUB
```bash
dub run seowebchecker -- https://seowebchecker.com/
```

### 2. Export as JSON
```bash
dub run seowebchecker -- https://seowebchecker.com/ --json
```

### 3. Export as Markdown
```bash
dub run seowebchecker -- https://seowebchecker.com/ --md
```

### 4. CI/CD Threshold Quality Gate
```bash
# Returns exit code 0 if score >= 90, otherwise exit code 1
dub run seowebchecker -- https://seowebchecker.com/ --score --threshold=90
```

---

## Library Usage

```d
import std.stdio;
import seowebchecker;

void main() {
    // 1. Initialize auditor
    auto auditor = new SeoAuditor(alertThreshold: 85);

    // 2. Audit live website
    auto result = auditor.audit("https://seowebchecker.com/");

    writeln("Health Score : ", result.score, " / 100 (", result.grade, ")");
    writeln("Status       : ", result.status);
    writeln("Title        : ", result.title, " (", result.titleLength, " chars)");
    writeln("Passed       : ", result.passes.length, " checks");
    writeln("Issues       : ", result.issues.length, " items");

    // 3. Export to JSON or Markdown
    string jsonReport = result.toJSON();
    string mdReport   = result.toMarkdown();

    // 4. Audit raw HTML string directly
    string rawHtml = "<html><head><title>My Title</title></head><body><h1>Hello</h1></body></html>";
    auto htmlResult = auditor.auditHtml(rawHtml, "https://example.com/");
}
```

---

## Audit Evaluation Criteria

| Category | Check | Criteria |
|:---|:---|:---|
| **Meta** | Title Tag | 30–65 characters, descriptive |
| **Meta** | Meta Description | 70–160 characters, engaging summary |
| **Technical** | Mobile Viewport | Responsive `<meta name="viewport">` declared |
| **Technical** | Canonical URL | Valid self-referencing canonical tag |
| **Technical** | HTTPS Security | Secure encrypted protocol active |
| **Content** | Heading Hierarchy | Exactly 1 primary `<h1>` heading |
| **Content** | Word Count | ≥ 100 words of indexable copy |

---

## Official Platform

For deep website crawling, multi-page indexing audits, and API documentation:
- **Official Site**: [https://seowebchecker.com/](https://seowebchecker.com/)

---

## License

MIT License. See [LICENSE](LICENSE) for details.
