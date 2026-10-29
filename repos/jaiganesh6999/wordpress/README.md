# SEOWebChecker WordPress Plugin

[![Official Website](https://img.shields.io/badge/Website-seowebchecker.com-blue?style=flat-square)](https://seowebchecker.com/)
[![PHP: 8.2](https://img.shields.io/badge/PHP-8.2-777BB4.svg?logo=php&logoColor=white)](https://php.net/)
[![WordPress: 5.8+](https://img.shields.io/badge/WordPress-5.8+-21759B.svg?logo=wordpress&logoColor=white)](https://wordpress.org/)
[![License: GPLv2+](https://img.shields.io/badge/License-GPLv2+-green.svg)](https://www.gnu.org/licenses/gpl-2.0.html)

Official technical on-page SEO audit and analyzer plugin for WordPress. Engineered by the [SEOWebChecker](https://seowebchecker.com/) team to automate technical SEO audits, meta tag validations, heading structure inspections, image accessibility analysis, and Core Web Vitals readiness directly inside the WordPress dashboard.

Full web-based audits, historical report tracking, and advanced tools are available at **[https://seowebchecker.com/](https://seowebchecker.com/)**.

---

## ⚡ Features

- **Dashboard Audit Suite**: Audit any URL or your homepage with a single click.
- **On-Page SEO Scorecard**: Calculates overall score (0–100) and letter grades (A+ through F) alongside exact remediation recommendations.
- **Post & Page Editor Metabox**: Run live on-page SEO audits right in the editor sidebar before publishing.
- **Admin Bar Quick Audit**: Instant 1-click audit button in the top WordPress admin bar when viewing frontend pages.
- **Export Options**: Export full diagnostic reports to JSON or Markdown.
- **Zero Frontend Overhead**: 100% native PHP code running exclusively in the admin dashboard.

---

## 📦 How to Submit to WordPress.org Plugin Directory

1. Create a free account on [WordPress.org](https://login.wordpress.org/).
2. Submit your plugin for review at:
   👉 **[https://wordpress.org/plugins/add/](https://wordpress.org/plugins/add/)**
3. Create a zip archive of this `wordpress` directory:
   ```powershell
   Compress-Archive -Path wordpress\* -DestinationPath seowebchecker.zip
   ```
4. Upload `seowebchecker.zip` on the submission form.
5. Once approved by the WordPress Plugin Review Team, you will be granted access to the official SVN repository to publish updates!

---

## 🛠️ Manual Installation on Any WordPress Site

1. Download or zip the `wordpress` folder.
2. In your WordPress admin, go to **Plugins > Add New > Upload Plugin**.
3. Choose `seowebchecker.zip` and click **Install Now**.
4. Activate the plugin and navigate to **SEO Web Checker** in your admin menu.

---

## 📄 License

This plugin is licensed under the [GNU General Public License v2.0 or later](https://www.gnu.org/licenses/gpl-2.0.html).
