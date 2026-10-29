# SEOWebChecker - Technical SEO & On-Page Analyzer for Joomla 5

[![Joomla Compatibility](https://img.shields.io/badge/Joomla-5.x-185A9D.svg?logo=joomla&logoColor=white)](https://extensions.joomla.org/)
[![PHP: 8.2](https://img.shields.io/badge/PHP-8.2%2B-777BB4.svg?logo=php&logoColor=white)](https://php.net/)
[![License: GPLv2+](https://img.shields.io/badge/License-GPLv2%2B-green.svg)](https://www.gnu.org/licenses/gpl-2.0.html)
[![Official Platform](https://img.shields.io/badge/Platform-seowebchecker.com-indigo)](https://seowebchecker.com/)

Automated technical on-page SEO diagnostics, heading hierarchy inspections, image accessibility analysis, and Core Web Vitals checks engineered natively as a **Joomla 5 System Plugin**.

Powered by the [SEOWebChecker](https://seowebchecker.com/) technical SEO analysis platform.

---

## 🔗 Extension Links

- **Interactive Demo**: [https://jaiganesh6999.github.io/seowebchecker-seoaudit-sdk/joomla/](https://jaiganesh6999.github.io/seowebchecker-seoaudit-sdk/joomla/)
- **Documentation**: [https://seo-ai-tools.readthedocs.io/en/latest/joomla/](https://seo-ai-tools.readthedocs.io/en/latest/joomla/)
- **Support & Issues**: [https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk/issues/new?title=%5BJoomla%5D+](https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk/issues/new?title=%5BJoomla%5D+)
- **Download Latest Package (.zip)**: [plg_system_seowebchecker.zip](https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk/raw/main/joomla/plg_system_seowebchecker.zip)

---

## ⚡ Key Features

- **Joomla 5 Native Architecture**: Uses Joomla 5 modern dependency injection (`services/provider.php`) and event subscribers.
- **On-Demand AJAX Audit Endpoint**: Compatible with Joomla's `com_ajax` framework:
  ```text
  index.php?option=com_ajax&plugin=seowebchecker&group=system&format=json
  ```
- **Automated Update Server**: Fully compliant with Joomla Update Manager (`update.xml`) for one-click in-dashboard updates.
- **Comprehensive On-Page Scoring (0–100)**:
  - Title tag presence, length (30–60 characters), and search snippet readiness.
  - Meta description presence and length validation (70–160 characters).
  - Heading hierarchy diagnostics (detects missing or multiple `<h1>` headings).
  - Image accessibility analysis (detects missing `alt` attributes across content images).
  - Canonical link tag validation.
  - Mobile viewport configuration and responsive display checks.
  - OpenGraph & Twitter social card preview validation.
  - Schema.org JSON-LD syntax validation.
- **Zero Frontend Overhead**: Runs strictly in administrator workflows and AJAX requests.

---

## 📦 Installation & Configuration

1. In your Joomla Administrator dashboard, navigate to **System > Install > Extensions**.
2. Upload the `plg_system_seowebchecker.zip` file.
3. Go to **System > Plugins**, search for **System - SEOWebChecker**, and click to **Enable** it.
4. (Optional) Configure audit thresholds in the plugin settings:
   - **Minimum SEO Score**: Threshold for warning administrators (default: 80).
   - **Check Image Alt Attributes**: Enable or disable image accessibility validation.
   - **Check Heading Hierarchy**: Enable or disable single `<h1>` hierarchy checks.

---

## 📄 License

GPL v2.0 or later. Developed by the [SEOWebChecker](https://seowebchecker.com/) team.
