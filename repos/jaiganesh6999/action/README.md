# SEOWebChecker GitHub Action 🚀

[![GitHub Marketplace](https://img.shields.io/badge/Marketplace-SEOWebChecker-blue.svg?colorA=24292e&colorB=0366d6&style=flat&logo=github)](https://github.com/marketplace/actions/seowebchecker-seo-audit)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Powered by SEOWebChecker](https://img.shields.io/badge/Audits%20by-SEOWebChecker.com-4CAF50.svg)](https://seowebchecker.com/)

Automate on-page technical SEO audits, meta tag validation, Open Graph verification, and Core Web Vitals checks directly inside your **GitHub Actions CI/CD workflows**.

Catch SEO regressions, missing meta titles, broken canonicals, and performance drops **before** code reaches production.

---

## ⚡ Quick Start

Add this step to your GitHub Actions workflow (e.g., `.github/workflows/seo-audit.yml`):

```yaml
name: Continuous SEO Audit

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - name: Audit Website SEO
        uses: jaiganesh6999/seowebchecker-action@v1
        with:
          url: 'https://seowebchecker.com/'
          min-score: 80
          fail-on-error: true
```

---

## 📋 Features

- 🎯 **Automated On-Page SEO Scoring:** Returns a comprehensive 0–100 score and grade (A+, A, B, C, D, F).
- 🏷️ **Meta Tag & Heading Checks:** Validates `<title>`, `<meta name="description">`, `<meta name="viewport">`, `<link rel="canonical">`, and `<h1>` single-heading structure.
- 📱 **Mobile & Social Previews:** Verifies responsive viewport meta tags and OpenGraph tags (`og:title`).
- 🔒 **Security & Protocol:** Enforces HTTPS protocol.
- 📊 **Rich GitHub Step Summary:** Automatically generates a detailed visual audit breakdown table inside your GitHub Actions run dashboard!
- ⚡ **Zero External Dependencies:** Built with pure Node.js 20 runtime for maximum speed and security.

---

## ⚙️ Inputs & Outputs

### Inputs

| Input | Description | Required | Default |
| :--- | :--- | :---: | :--- |
| `url` | The target URL to audit (e.g., production URL or staging preview). | **Yes** | — |
| `min-score` | Minimum SEO score (0–100) required for the step to pass. | No | `70` |
| `fail-on-error` | Fail the workflow step if the calculated score is below `min-score`. | No | `true` |
| `output-format` | Format for workflow log outputs (`markdown`, `json`). | No | `markdown` |

### Outputs

| Output | Description |
| :--- | :--- |
| `score` | Overall calculated SEO score (0–100). |
| `status` | Audit status (`passed` or `failed`). |
| `title` | Extracted page title. |
| `description` | Extracted meta description. |
| `canonical` | Extracted canonical URL. |
| `audit-json` | Complete audit results payload in JSON. |

---

## 💡 Advanced Examples

### PR Preview Deployment Check (e.g. Vercel, Netlify)

```yaml
name: PR Preview SEO Check

on:
  deployment_status:

jobs:
  seo:
    if: github.event.deployment_status.state == 'success'
    runs-on: ubuntu-latest
    steps:
      - name: Audit PR Preview URL
        uses: jaiganesh6999/seowebchecker-action@v1
        with:
          url: ${{ github.event.deployment_status.target_url }}
          min-score: 85
          fail-on-error: false
```

### Accessing Audit Outputs in Subsequent Steps

```yaml
- name: Run SEO Audit
  id: seo
  uses: jaiganesh6999/seowebchecker-action@v1
  with:
    url: 'https://seowebchecker.com/'

- name: Post Results to Slack or PR
  run: |
    echo "SEO Score was ${{ steps.seo.outputs.score }}/100"
    echo "Title: ${{ steps.seo.outputs.title }}"
```

---

## 🌐 Official Links

- **Official Web Audit Suite:** [https://seowebchecker.com/](https://seowebchecker.com/)
- **Documentation:** [https://seo-ai-tools.readthedocs.io/en/latest/](https://seo-ai-tools.readthedocs.io/en/latest/)
- **SDK Repository:** [jaiganesh6999/seowebchecker-seoaudit-sdk](https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk)

## 📄 License

MIT License. See [LICENSE](./LICENSE) for details.
