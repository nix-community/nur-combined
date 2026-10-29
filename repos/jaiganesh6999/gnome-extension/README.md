# SEOWebChecker - GNOME Shell Extension

[![GNOME Extensions](https://img.shields.io/badge/GNOME-extensions.gnome.org-4a86cf.svg)](https://extensions.gnome.org/)
[![GNOME Shell](https://img.shields.io/badge/Shell%20Versions-45%20%7C%2046%20%7C%2047%20%7C%2048-blue.svg)](https://seowebchecker.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Real-time technical SEO health score, Core Web Vitals status, meta tag checker, and website monitoring indicator right inside the GNOME Shell top panel.

---

## Features

- **Live Top Bar Score Indicator**: Displays real-time on-page SEO health and site availability score in the GNOME top bar.
- **Quick Diagnostic Dropdown**: Inspect document title length, meta descriptions, heading structure (`<h1>`), canonical headers, and Core Web Vitals readiness.
- **One-Click Re-Audit**: Run fresh on-demand technical audits directly from your desktop panel.
- **GNOME 45–48 ESM Architecture**: Built on modern ECMAScript modules with strict lifecycle cleanup (`enable()` and `disable()`).

---

## Installation & Testing

### Sideload Locally on Linux (GNOME Desktop):

1. Clone or copy the `gnome-extension` directory to your local GNOME extensions directory:
   ```bash
   mkdir -p ~/.local/share/gnome-shell/extensions/seo-audit@seowebchecker.com
   cp -r gnome-extension/* ~/.local/share/gnome-shell/extensions/seo-audit@seowebchecker.com/
   ```
2. Enable the extension:
   ```bash
   gnome-extensions enable seo-audit@seowebchecker.com
   ```
3. Restart GNOME Shell (under X11 press `Alt+F2`, type `r`, and hit Enter; under Wayland log out and log back in).

---

## Submission to extensions.gnome.org

1. Package the extension archive using the pre-built `seo-audit@seowebchecker.com.zip` file:
   ```bash
   cd gnome-extension
   zip -r ../seo-audit@seowebchecker.com.zip metadata.json extension.js stylesheet.css
   ```
2. Log into [extensions.gnome.org/upload/](https://extensions.gnome.org/upload/).
3. Upload `seo-audit@seowebchecker.com.zip`.
