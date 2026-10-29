# SEOWebChecker - Technical SEO & On-Page Analyzer for Joomla 5

[![Joomla Compatibility](https://img.shields.io/badge/Joomla-5.x-185A9D.svg?logo=joomla&logoColor=white)](https://extensions.joomla.org/)
[![PHP: 8.2](https://img.shields.io/badge/PHP-8.2%2B-777BB4.svg?logo=php&logoColor=white)](https://php.net/)
[![License: GPLv2+](https://img.shields.io/badge/License-GPLv2%2B-green.svg)](https://www.gnu.org/licenses/gpl-2.0.html)
[![Official Platform](https://img.shields.io/badge/Platform-seowebchecker.com-indigo)](https://seowebchecker.com/)

Automated technical on-page SEO audits, heading structure inspections, image accessibility analysis, and Core Web Vitals checks engineered natively as a **Joomla 5 System Plugin**.

Powered by the [SEOWebChecker](https://seowebchecker.com/) technical SEO analysis platform.

---

## ⚡ Key Features

- **Joomla 5 Native Architecture**: Uses Joomla 5 modern dependency injection (`services/provider.php`) and event subscribers.
- **On-Demand AJAX Audit Endpoint**: Compatible with Joomla's `com_ajax` framework (`index.php?option=com_ajax&plugin=seowebchecker&group=system&format=json`).
- **Comprehensive On-Page Scoring (0–100)**:
  - Title tag presence, character length (30–60 characters), and search snippet readiness.
  - Meta description presence and length validation (70–160 characters).
  - Heading hierarchy diagnostics (missing `<h1>` or duplicate `<h1>` tags).
  - Image accessibility analysis (detects missing `alt` attributes across content images).
  - Canonical link tag validation.
  - Mobile viewport configuration and zoom compliance.
  - OpenGraph & Twitter social card preview validation.
  - Schema.org JSON-LD syntax validation.
- **Zero Frontend Overhead**: Runs exclusively in administrator workflows and AJAX requests.

---

## 📦 Installation

1. In your Joomla Administrator dashboard, navigate to **System > Install > Extensions**.
2. Upload the `plg_system_seowebchecker.zip` file.
3. Go to **System > Plugins**, search for **System - SEOWebChecker**, and click to **Enable** it.

---

## 🌐 Official Platform

For continuous site-wide automated crawls, historic audit logging, and Core Web Vitals monitoring:
👉 **[https://seowebchecker.com/](https://seowebchecker.com/)**

---

## 📄 License

GPL v2.0 or later. Developed by the [SEOWebChecker](https://seowebchecker.com/) team.
