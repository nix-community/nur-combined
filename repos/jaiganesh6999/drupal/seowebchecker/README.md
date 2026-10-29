# SEOWebChecker - Technical SEO & On-Page Analyzer for Drupal 10 & 11

[![Drupal Compatibility](https://img.shields.io/badge/Drupal-10%20%7C%2011-0678BE.svg?logo=drupal&logoColor=white)](https://www.drupal.org/)
[![PHP: 8.2](https://img.shields.io/badge/PHP-8.2%2B-777BB4.svg?logo=php&logoColor=white)](https://php.net/)
[![License: GPLv2+](https://img.shields.io/badge/License-GPLv2%2B-green.svg)](https://www.gnu.org/licenses/gpl-2.0.html)
[![Official Platform](https://img.shields.io/badge/Platform-seowebchecker.com-indigo)](https://seowebchecker.com/)

Automated technical on-page SEO audits, heading structure inspections, image accessibility analysis, and Core Web Vitals checks engineered natively for **Drupal 10 and Drupal 11**.

Powered by the [SEOWebChecker](https://seowebchecker.com/) technical SEO analysis platform.

---

## ⚡ Key Features

- **Administrative Audit Dashboard**: Audit any internal route or external URL directly from **Configuration > Search and metadata > SEO Web Checker** (`/admin/config/search/seowebchecker`).
- **Comprehensive 0–100 Scorecard**: Calculates overall score alongside letter grades (A+ through F).
- **Node Pre-Publish Sidebar Widget**: Integrated into Drupal content creation/edit forms (`hook_form_node_form_alter`) so editors can audit articles before publishing.
- **Deep Technical Diagnostics**:
  - Title tag presence, character length (30–60 characters), and search snippet readiness.
  - Meta description presence and length validation (70–160 characters).
  - Heading hierarchy diagnostics (missing `<h1>` or duplicate `<h1>` tags).
  - Image accessibility analysis (detects missing `alt` attributes across all content images).
  - Canonical link tag validation.
  - Mobile viewport configuration and zoom compliance.
  - OpenGraph & Twitter social card preview validation.
  - Schema.org JSON-LD syntax validation.
- **Report Exports**: Instant 1-click export of diagnostic audit reports to Markdown and JSON.
- **PHP 8.2+ Architecture**: Clean, typed, object-oriented service architecture using Drupal Dependency Injection (`@seowebchecker.auditor`).

---

## 📦 Installation

### Method 1: Composer (Recommended)

```bash
composer require seowebchecker/seowebchecker
drush pm:install seowebchecker
```

### Method 2: Manual Installation

1. Copy the `seowebchecker` directory to your Drupal installation's `web/modules/custom/` or `web/modules/contrib/` directory.
2. Navigate to **Extend** (`/admin/modules`) in your Drupal admin panel.
3. Search for **SEOWebChecker** and check the box to install.
4. Click **Install**.

---

## 🚀 Usage

1. In your Drupal administrative menu, go to **Configuration > Search and metadata > SEO Web Checker**.
2. Enter your homepage or any published URL and click **Run Technical SEO Audit**.
3. View real-time scorecards, Google SERP snippet previews, and actionable remediation steps.

---

## 🌐 Official Platform

For site-wide automated crawls, historic audit logging, and Core Web Vitals monitoring:
👉 **[https://seowebchecker.com/](https://seowebchecker.com/)**

---

## 📄 License

GPL v2.0 or later. Developed by the [SEOWebChecker](https://seowebchecker.com/) team.
