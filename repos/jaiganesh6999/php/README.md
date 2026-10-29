# seowebchecker/seoaudit-sdk

[![Latest Stable Version](https://poser.pugx.org/seowebchecker/seoaudit-sdk/v/stable)](https://packagist.org/packages/seowebchecker/seoaudit-sdk)
[![Total Downloads](https://poser.pugx.org/seowebchecker/seoaudit-sdk/downloads)](https://packagist.org/packages/seowebchecker/seoaudit-sdk)
[![License](https://poser.pugx.org/seowebchecker/seoaudit-sdk/license)](https://packagist.org/packages/seowebchecker/seoaudit-sdk)
[![PHP Version](https://img.shields.io/badge/php-%3E%3D8.2-8892BF.svg)](https://php.net)
[![SEOWebChecker](https://img.shields.io/badge/Official%20Site-seowebchecker.com-indigo)](https://seowebchecker.com/)

A lightweight, zero-dependency PHP 8.2+ client SDK and CLI tool for full website SEO audits, technical checks, and on-page optimization.

Developed and maintained by [SEOWebChecker.com](https://seowebchecker.com/) — the premier free online SEO audit suite.

---

## ⚡ Highlights

- **Native PHP 8.2+**: Built with modern typed properties, match expressions, and readonly constructs.
- **Zero Heavy Dependencies**: Pure PHP standard library without external dependencies.
- **50+ SEO Checks**: Meta tags, Title, Description, Canonical URL, Headings (H1-H6), Image alt attributes, OpenGraph, Twitter Cards, Schema JSON-LD, HTTPS security, and latency diagnostics.
- **CI/CD Quality Gate**: Set `--min-score 85` in deployment pipelines to prevent SEO regressions.
- **Dual Engine**: Run local audits instantly or connect to [SEOWebChecker Cloud API](https://seowebchecker.com/).

---

## 📦 Installation

Install via Composer:

```bash
composer require seowebchecker/seoaudit-sdk
```

---

## 🚀 Quick Start

### 1. PHP Code

```php
use SeoWebChecker\SeoAudit\Auditor;

$auditor = new Auditor();

// Audit any public URL
$result = $auditor->audit('https://example.com');

echo "Score: {$result->score}/100 (Grade: {$result->grade})\n";
echo "Passed: {$result->stats['passed']}, Errors: {$result->stats['errors']}\n";

// Access issues
foreach ($result->errors as $err) {
    echo "[ERROR] {$err['title']}: {$err['recommendation']}\n";
}

// Export to JSON or Markdown
$json = $result->toJson();
$markdown = $result->toMarkdown();
```

### 2. Audit Rendered HTML Template / Blade / Twig

```php
use SeoWebChecker\SeoAudit\Auditor;

$auditor = new Auditor();
$result = $auditor->auditHtml($renderedHtml, 'https://seowebchecker.com/');
```

---

## 🖥️ Command-Line Interface (CLI)

```bash
# Pretty terminal output
php vendor/bin/seowebchecker https://example.com

# Save to Markdown
php vendor/bin/seowebchecker https://example.com --format markdown --output audit.md

# Save to JSON
php vendor/bin/seowebchecker https://example.com --format json --output audit.json

# CI/CD Quality Gate (fails with exit code 1 if score < 85)
php vendor/bin/seowebchecker https://example.com --min-score 85
```

---

## 🌐 Official Platform

Visit [SEOWebChecker.com](https://seowebchecker.com/) for in-depth web audits, backlink checkers, and SEO monitoring tools.

---

## 📄 License

MIT License © 2026 [SEOWebChecker](https://seowebchecker.com/).
