# seowebchecker-seoaudit-sdk

[![PyPI version](https://img.shields.io/pypi/v/seowebchecker-seoaudit-sdk.svg?color=blue)](https://pypi.org/project/seowebchecker-seoaudit-sdk/)
[![Python Versions](https://img.shields.io/pypi/pyversions/seowebchecker-seoaudit-sdk.svg)](https://pypi.org/project/seowebchecker-seoaudit-sdk/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![SEOWebChecker](https://img.shields.io/badge/Official%20Site-seowebchecker.com-indigo)](https://seowebchecker.com/)

A lightweight, high-performance, open-source Python client SDK and CLI tool for instant website SEO audits, on-page analysis, Core Web Vitals checks, and technical SEO diagnostics.

Developed and maintained by [SEOWebChecker.com](https://seowebchecker.com/) — the free website audit and SEO diagnostic suite.

---

## ⚡ Highlights

- **Zero-Config Standalone Auditing**: Audit live URLs or raw HTML strings instantly without requiring external API keys.
- **50+ SEO Checks Across 7 Categories**:
  - **Meta & Header Tags**: `<title>`, `<meta description>`, `<link rel="canonical">`, `<meta robots>`, `<meta viewport>`, charset, and lang.
  - **Content & Structure**: Single `<h1>` enforcement, `<h2>`/`<h3>` hierarchy, word count, reading time estimation, and keyword density.
  - **Hyperlink Quality**: Internal vs external link distribution, empty anchor detection, generic anchor warnings ("click here"), and secure `target="_blank"` validation.
  - **Image SEO & Accessibility**: Missing `alt` tags, empty `alt` attributes, format breakdowns, and next-gen image format adoption (WebP, AVIF, SVG).
  - **Social Graph & Cards**: OpenGraph tags (`og:title`, `og:image`, `og:description`, `og:url`) and Twitter Cards.
  - **Technical & Security**: HTTPS verification, HSTS enforcement, MIME-sniffing protection (`X-Content-Type-Options`), clickjacking defenses, `robots.txt`, and `sitemap.xml` detection.
  - **Performance Signals**: Response time / TTFB, HTML payload weight, and server-side text compression (Gzip/Brotli).
  - **Structured Data**: JSON-LD schema parsing and Microdata type detection.
- **CI/CD Quality Gate**: Set `--min-score 85` to fail deployment builds if regressions occur.
- **Multiple Output Formats**: Terminal ANSI colors, clean Markdown tables, JSON output, or standalone HTML dashboard report.
- **Optional Cloud API Mode**: Connect seamlessly with the [SEOWebChecker Cloud API](https://seowebchecker.com/).

---

## 📦 Installation

Install via `pip`:

```bash
pip install seowebchecker-seoaudit-sdk
```

---

## 🚀 Quick Start

### 1. Python API

```python
from seowebchecker_seoaudit import SEOAuditor

# Initialize auditor
auditor = SEOAuditor()

# Audit any website
result = auditor.audit("https://example.com")

# View overall score and letter grade (A+, A, B, C, D, F)
print(f"SEO Score: {result.score.overall}/100 (Grade: {result.score.grade})")

# Access category breakdown
for cat_name, cat in result.score.categories.items():
    print(f"{cat_name.title()}: {cat.score}/100 ({cat.passed_count} passed, {cat.warning_count} warnings)")

# List critical issues
for error in result.errors:
    print(f"[ERROR] {error.title}: {error.recommendation}")

# Export to formats
print(result.to_json())
markdown_report = result.to_dict()
```

### 2. Audit Raw HTML Directly (Unit Tests & Static Site Generators)

```python
from seowebchecker_seoaudit import SEOAuditor

auditor = SEOAuditor()
html_content = """
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Best Free SEO Audit Tool - SEOWebChecker</title>
  <meta name="description" content="Audit your website SEO with 50+ real-time checks covering technical SEO, performance, mobile responsiveness, and meta tags.">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="canonical" href="https://seowebchecker.com/">
</head>
<body>
  <h1>Free SEO Audit & Analyzer</h1>
  <p>Run comprehensive on-page audits with instant recommendations.</p>
</body>
</html>
"""

result = auditor.audit_html(html_content, url="https://seowebchecker.com/")
print(f"Score: {result.score.overall}/100")
```

---

## 🖥️ Command-Line Interface (CLI)

The SDK installs a command-line tool `seowebchecker-audit`:

```bash
# Pretty terminal output
seowebchecker-audit https://example.com

# Generate a standalone responsive HTML dashboard
seowebchecker-audit https://example.com --format html --output report.html

# Export JSON for programmatic ingestion
seowebchecker-audit https://example.com --format json --output audit.json

# Export GitHub-compatible Markdown summary
seowebchecker-audit https://example.com --format markdown --output audit.md

# CI/CD Quality Gate (Exits with code 1 if score < 85)
seowebchecker-audit https://example.com --min-score 85
```

---

## ⚙️ CI/CD Pipeline Integration (GitHub Actions)

Add continuous SEO testing to your repository by adding `.github/workflows/seo-audit.yml`:

```yaml
name: Continuous SEO Audit

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  seo-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.11"

      - name: Install SDK
        run: pip install seowebchecker-seoaudit-sdk

      - name: Run SEO Audit Gate
        run: |
          seowebchecker-audit https://seowebchecker.com/ --min-score 85 --format markdown --output seo-report.md

      - name: Archive SEO Report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: seo-audit-report
          path: seo-report.md
```

---

## 🌐 Official Web Platform

Need an in-depth web-based audit or visual reports? Visit [SEOWebChecker.com](https://seowebchecker.com/):
- [Website SEO Audit Tool](https://seowebchecker.com/)
- [Broken Link Checker](https://seowebchecker.com/)
- [Schema Markup Validator](https://seowebchecker.com/)
- [Meta Tag Generator & Analyzer](https://seowebchecker.com/)

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
