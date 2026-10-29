# seowebchecker (Conda / Anaconda.org)

[![Anaconda-Server Badge](https://anaconda.org/seoaitools/seowebchecker-seoaudit-sdk/badges/version.svg)](https://anaconda.org/seoaitools/seowebchecker-seoaudit-sdk)
[![Anaconda-Server Badge](https://anaconda.org/seoaitools/seowebchecker-seoaudit-sdk/badges/platforms.svg)](https://anaconda.org/seoaitools/seowebchecker-seoaudit-sdk)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Official Site](https://img.shields.io/badge/Official%20Site-seowebchecker.com-indigo)](https://seowebchecker.com/)

A lightweight Conda package and automated on-page technical SEO diagnostic engine for meta tag validations, heading structure inspections, image accessibility checks, and Core Web Vitals diagnostics.

Powered by **[SEOWebChecker.com](https://seowebchecker.com/)**.

---

## Installation via Conda

Once published to your channel on Anaconda.org:

```bash
conda install -c <YOUR_ANACONDA_CHANNEL> seowebchecker-seoaudit-sdk
```

Or using `mamba`:

```bash
mamba install -c <YOUR_ANACONDA_CHANNEL> seowebchecker-seoaudit-sdk
```

---

## Quick Start (Python)

```python
from seowebchecker_seoaudit import Auditor

html = """
<!DOCTYPE html>
<html>
<head>
    <title>Optimal Website Title Tag for High Search Ranking</title>
    <meta name="description" content="A comprehensive guide to modern on-page technical SEO and Core Web Vitals optimization.">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="canonical" href="https://example.com/guide">
</head>
<body>
    <h1>Mastering Technical SEO</h1>
</body>
</html>
"""

auditor = Auditor()
result = auditor.audit_html(html, target_url="https://example.com/guide")

print(f"Overall Score: {result.score.overall}/100 (Grade {result.score.grade})")
print(f"Passed Checks: {result.passed_checks}/{result.total_checks}")
```

---

## CLI Usage

```bash
seowebchecker audit https://example.com --format text
```

---

## Publishing to Anaconda.org

### Method 1: Web Upload (Drag & Drop - 30 Seconds)
1. Sign in to **[anaconda.org](https://anaconda.org)**.
2. Click **Upload** (top right) or navigate to `https://anaconda.org/<YOUR_USERNAME>/upload`.
3. Drag & drop the built package:
   `conda/dist/noarch/seowebchecker-seoaudit-sdk-1.0.0-py_0.tar.bz2`
4. Click **Upload Package**.

### Method 2: CLI via `anaconda-client`
```bash
pip install anaconda-client
anaconda login
anaconda upload conda/dist/noarch/seowebchecker-seoaudit-sdk-1.0.0-py_0.tar.bz2
```

### Method 3: Automated via GitHub Actions
Add secret `ANACONDA_API_TOKEN` in GitHub Repository Settings. The workflow `Conda Build & Anaconda.org Publish` will publish automatically on push to `main`!

---

## Official Website & Free Online Auditing

- **Live SEO Checkers & Audits**: [https://seowebchecker.com/](https://seowebchecker.com/)

---

## License

MIT © 2026 [SEOWebChecker.com](https://seowebchecker.com/).
