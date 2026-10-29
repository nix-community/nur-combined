=== SEOWebChecker ===
Contributors: jaiganesh6999, seowebchecker
Tags: seo, seo audit, technical seo, meta tags, core web vitals
Requires at least: 5.8
Tested up to: 7.1
Stable tag: 1.0.0
Requires PHP: 8.0
License: GPLv2 or later
License URI: https://www.gnu.org/licenses/gpl-2.0.html

Automated technical on-page SEO audits, meta tag validations, heading structure inspections, image accessibility, and Core Web Vitals checks.

== Description ==

**SEOWebChecker** is a lightweight, high-performance technical SEO audit plugin engineered to help WordPress site owners, digital publishers, and agency developers identify on-page SEO regressions, validate meta tags, and optimize Core Web Vitals directly from the WordPress dashboard.

Powered by the [SEOWebChecker](https://seowebchecker.com/) technical SEO analysis platform.

### ⚡ Key Features

* **Instant Dashboard Audit**: Audit any published webpage URL or your homepage with a single click.
* **On-Page SEO Scorecard**: Calculates a comprehensive 0–100 score and letter grade (A+ through F).
* **Metadata Verification**:
  * Title tag presence and length optimization (30–60 characters).
  * Meta description presence, length balance, and organic search click-through rate readiness.
  * Canonical link tag validation.
  * Mobile viewport configuration.
* **Heading Hierarchy Diagnostics**: Detects missing primary `<h1>` headings and warns against conflicting duplicate `<h1>` tags.
* **Image Accessibility Analysis**: Detects missing `alt` attributes across all content images.
* **Social Sharing Card Validation**: Verifies OpenGraph tags (`og:title`, `og:image`) for LinkedIn, Facebook, and Twitter/X.
* **Post Editor Live Scorecard**: Run real-time pre-publish SEO audits right inside the post editor sidebar.
* **Admin Bar Shortcut**: Instant 1-click audit button in the WordPress Admin Bar when viewing frontend pages.
* **Export Options**: Export full diagnostic audit reports to Markdown or JSON.
* **Zero External Bloat**: 100% native PHP code compatible with PHP 8.0 through PHP 8.2+.

== Installation ==

1. Upload the `seowebchecker` folder to the `/wp-content/plugins/` directory, or install directly through the WordPress Plugins dashboard (**Plugins > Add New**).
2. Activate the plugin through the **Plugins** menu in WordPress.
3. Go to **SEO Web Checker** in your WordPress admin menu to run your first technical audit.

== Frequently Asked Questions ==

= Does this plugin slow down my website frontend? =
No. SEOWebChecker runs exclusively in the WordPress admin dashboard and post editor. Zero external CSS or JavaScript is loaded on your public frontend pages.

= What PHP version is required? =
SEOWebChecker is compatible with PHP 8.0 through PHP 8.2 and later.

= Can I audit external URLs or staging sites? =
Yes. In the **SEO Web Checker** dashboard menu, you can input any public URL to run an instant on-page diagnostic audit.

= Where can I get deeper audits and performance metrics? =
Comprehensive site crawls, historic audit logging, and Core Web Vitals monitoring are available at [https://seowebchecker.com/](https://seowebchecker.com/).

== Screenshots ==

1. Admin Dashboard with instant SEO score, category stats, and issue recommendations.
2. Post editor sidebar metabox for pre-publishing on-page validation.
3. Top WordPress Admin Bar quick audit button.

== Changelog ==

= 1.0.0 =
* Initial public release.
* Added instant URL audit dashboard.
* Added post editor sidebar metabox.
* Added admin bar quick audit shortcut.
* Added JSON and Markdown report export.
