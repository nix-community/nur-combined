# SEOWebChecker - Advanced Technical SEO Audit for Thunderbird

[![Mozilla Add-ons](https://img.shields.io/badge/Thunderbird-MailExtension-blue.svg)](https://addons.thunderbird.net/)
[![Platform](https://img.shields.io/badge/Platform-Gecko%20%2F%20Thunderbird%20115+-blue)](https://seowebchecker.com/)
[![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](LICENSE)

An official MailExtension for Mozilla Thunderbird that enables technical SEO analysis, newsletter HTML formatting checks, heading structure validation, image accessibility audits, and link verifications directly inside your email client.

---

## Key Features

- **Email HTML Structure & SEO Analysis**: Inspect HTML newsletters, promotional emails, and transactional templates for broken heading hierarchies (`<h1>` - `<h6>`), viewport tags, and metadata.
- **Image Accessibility Auditing**: Flag missing `alt` attributes on images to ensure email client accessibility and spam filter compliance.
- **Canonical & Open Graph Inspection**: Check that embedded web links, canonical URLs, and Open Graph social tags conform to search engine specifications.
- **Standalone URL & Custom HTML Diagnostics**: Audit external URLs or paste raw HTML snippets directly into Thunderbird.

---

## Installation & Packaging

### Option 1: Install from Add-ons for Thunderbird (ATN)
Install directly from the Thunderbird Add-on Manager or [addons.thunderbird.net](https://addons.thunderbird.net).

### Option 2: Sideload in Development Mode
1. Open Thunderbird.
2. Go to **Tools &gt; Add-ons and Themes** (or press `Ctrl+Shift+A`).
3. Click the gear icon (⚙️) and select **Debug Add-ons**.
4. Click **Load Temporary Add-on...** and select `thunderbird/manifest.json`.

### Option 3: Package as `.xpi` for ATN Submission
```bash
# From the repository root
python -c "import zipfile, os; z = zipfile.ZipFile('thunderbird/seowebchecker-thunderbird.xpi', 'w', zipfile.ZIP_DEFLATED); [z.write(os.path.join(r, f), os.path.relpath(os.path.join(r, f), 'thunderbird')) for r, _, fs in os.walk('thunderbird') if not f.endswith('.xpi') for f in fs]"
```

---

## ATN Marketplace Submission Details

- **Add-on Name**: `SEOWebChecker: Advanced Technical SEO Audit`
- **Gecko ID**: `thunderbird-seoaudit@seowebchecker.com`
- **Minimum Thunderbird Version**: `115.0`
- **Homepage**: [https://seowebchecker.com/](https://seowebchecker.com/)
- **Documentation**: [https://seo-ai-tools.readthedocs.io/en/latest/](https://seo-ai-tools.readthedocs.io/en/latest/)
