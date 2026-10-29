# SEOWebChecker — KDE Plasma Desktop & Panel Widget

[![Official Website](https://img.shields.io/badge/Website-seowebchecker.com-blue?style=flat-square)](https://seowebchecker.com/)
[![Plasma](https://img.shields.io/badge/KDE_Plasma-6.0%20%7C%205.27+-31363b?logo=kde&logoColor=white&style=flat-square)](https://develop.kde.org/)
[![License: GPL-2.0-or-later](https://img.shields.io/badge/License-GPL--2.0--or--later-green.svg?style=flat-square)](https://www.gnu.org/licenses/gpl-2.0.html)

Official **KDE Plasma Widget (Plasmoid)** for technical on-page SEO diagnostics and website monitoring. Engineered by the [SEOWebChecker](https://seowebchecker.com/) team, this desktop applet brings instant SEO audits, meta tag validations, heading structure inspections, image accessibility checks, and Core Web Vitals readiness straight to your Linux desktop panel or desktop canvas.

Full web-based audits and platform features are available at **[https://seowebchecker.com/](https://seowebchecker.com/)**.

---

## ⚡ Key Features

* **Panel & Desktop Dual Representation**:
  * **Compact View**: Minimalist icon and dynamic letter grade badge (`A+`, `A`, `B`, `C`, `D`, `F`) designed for system trays and taskbar panels.
  * **Full View**: Expansive diagnostics dashboard with live URL audit input, circular score indicator, breakdown cards, and scrollable recommendation list.
* **On-Page SEO Diagnostics**:
  * **Title Tag**: Validates presence, length balance (30–60 characters), and snippet readiness.
  * **Meta Description**: Inspects length (70–160 characters) and organic search click-through rate optimization.
  * **Mobile Viewport**: Verifies responsive multi-device viewport configuration.
  * **Canonical Link**: Validates canonical URLs to prevent duplicate indexing issues.
  * **Heading Structure**: Checks for primary `<h1>` headings and flags conflicting duplicates.
  * **Content Depth**: Estimates text word count to alert against thin content.
  * **Image Accessibility**: Detects missing `alt` attributes across all content images.
  * **Social Preview Cards**: Verifies OpenGraph tags (`og:title`, `og:image`) for social sharing.
  * **Structured Data**: Checks for Schema.org JSON-LD structured data markup.
* **Background Monitoring**: Configurable auto-refresh timer to periodically re-audit production or staging URLs in the background.
* **Filterable Scorecard**: Quickly filter findings by *All*, *Errors Only*, *Warnings Only*, or *Passed Checks*.
* **One-Click Export**: Copy full diagnostic Markdown reports directly to your system clipboard.
* **Zero External Dependencies**: Pure QML and JavaScript. Works out-of-the-box on any KDE Plasma desktop.

---

## 📦 Package Contents

```text
kde/
├── metadata.json                          # Plasma 6 / 5.27+ widget manifest
├── package_plasmoid.ps1                   # Packaging script
├── test_seoengine.js                      # Automated test suite
├── org.kde.plasma.seowebchecker.plasmoid  # Ready-to-install Plasma package
└── contents/
    ├── config/
    │   ├── config.qml                     # Settings categories model
    │   └── main.xml                       # KConfigXT persistent user preferences
    ├── code/
    │   └── seoengine.js                   # JavaScript SEO auditing engine
    └── ui/
        ├── main.qml                       # Plasmoid root item
        ├── CompactRepresentation.qml      # Panel & system tray UI
        ├── FullRepresentation.qml         # Desktop & popup dashboard UI
        └── ConfigGeneral.qml              # Settings dialog UI
```

---

## 🚀 Installation

### Method 1: Using the KDE Plasma GUI (Easiest)

1. Right-click on your desktop or panel and choose **Add Widgets...**
2. In the widget explorer sidebar, click **Get New Widgets** &rarr; **Install from local file...**
3. Select `org.kde.plasma.seowebchecker.plasmoid`.
4. Drag **SEOWebChecker** onto your panel or desktop.

---

### Method 2: Command Line (CLI)

#### Plasma 6 (Modern KDE):
```bash
kpackagetool6 -t Plasma/Applet -i org.kde.plasma.seowebchecker.plasmoid
```

#### Plasma 5 (Legacy KDE):
```bash
kpackagetool5 -t Plasma/Applet -i org.kde.plasma.seowebchecker.plasmoid
```

#### To update an existing installation:
```bash
kpackagetool6 -t Plasma/Applet -u org.kde.plasma.seowebchecker.plasmoid
```

---

### Method 3: Manual Installation

Extract or copy the `kde` folder contents into your local Plasma applets directory:

```bash
mkdir -p ~/.local/share/plasma/plasmoids/org.kde.plasma.seowebchecker
cp -r metadata.json contents ~/.local/share/plasma/plasmoids/org.kde.plasma.seowebchecker/
```

Restart Plasma Shell to load new widgets:
```bash
# Plasma 6:
kquitapp6 plasmashell && kstart plasmashell

# Plasma 5:
kquitapp5 plasmashell && kstart5 plasmashell
```

---

## ⚙️ Configuration

Right-click the widget on your panel or desktop and select **Configure SEOWebChecker...**:

* **Default Target URL**: The primary website address you wish to audit (defaults to `https://seowebchecker.com/`).
* **Automatic Refresh**: Enable or disable scheduled re-audits in the background.
* **Refresh Interval**: Frequency in minutes (from 5 to 1440 minutes).
* **Panel Display**: Toggle display of the color-coded letter grade badge in the compact panel view.

---

## 📄 License

GPL-2.0-or-later &copy; [SEOWebChecker](https://seowebchecker.com/).
