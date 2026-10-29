# SEOWebChecker - Technical SEO Audit & Analyzer for VS Code

[![Visual Studio Marketplace](https://img.shields.io/badge/VS%20Code%20Marketplace-SEOWebChecker-blue.svg?logo=visualstudiocode)](https://marketplace.visualstudio.com/)
[![Platform](https://img.shields.io/badge/Platform-seowebchecker.com-brightgreen)](https://seowebchecker.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**SEOWebChecker for VS Code** brings real-time on-page technical SEO diagnostics, heading structure validation, image accessibility auditing, and Core Web Vitals readiness directly into your code editor.

Catch SEO regressions before code commits and deployments across HTML, JSX, TSX (React/Next.js), Astro, Vue, Svelte, PHP, and Markdown.

Powered by the [SEOWebChecker](https://seowebchecker.com/) technical SEO analysis platform.

---

## ⚡ Key Features

### 1. 🔍 Real-Time Diagnostics & Problem Highlighting
- **Title Tag Inspector**:
  - Missing `<title>` tags in HTML or frontmatter.
  - Length optimization warning (< 30 characters or > 60 characters).
- **Meta Description Linter**:
  - Missing `<meta name="description">` or frontmatter description.
  - Snippet length warning (< 70 characters or > 160 characters).
- **Heading Hierarchy & Duplicate H1 Detection**:
  - Detects missing `<h1>` tags.
  - Highlights duplicate/multiple `<h1>` tags on a single page with automated warnings.
  - Tracks H1, H2, and H3 document structure.
- **Image Accessibility & Alt Text**:
  - Highlights `<img>` and `<Image />` elements missing `alt` attributes.
  - Detects redundant phrasing like `alt="image of..."` or `alt="picture of..."`.
  - Supports Markdown images `![alt](url)`.
- **Link Security & Crawler Optimization**:
  - Detects external links with `target="_blank"` missing `rel="noopener noreferrer"`.
  - Flags empty anchor tags.
- **Mobile Viewport & Core Web Vitals**:
  - Detects missing `<meta name="viewport">`.
  - Warns if pinch-to-zoom is disabled (`user-scalable=no` or `maximum-scale=1.0`).
- **Canonical URL Tag Validation**:
  - Validates presence of self-referential `<link rel="canonical" href="...">`.
- **OpenGraph & Social Sharing Cards**:
  - Verifies `og:title` and `og:image` tags for rich preview snippets on social networks.
- **Schema.org Structured Data**:
  - Validates JSON syntax in `<script type="application/ld+json">`.

### 2. 📊 Dynamic Status Bar Score & Grade
- View your file's live SEO score and letter grade (A+ through F) right in the VS Code Status Bar:
  - `$(check) SEO: 96/100 (A+)` (Green)
  - `$(warning) SEO: 68/100 (C)` (Yellow)
  - `$(error) SEO: 40/100 (F)` (Red)
- Click the status bar anytime to reveal the **Quick Actions Menu**.

### 3. 🎨 Visual Audit Webview Dashboard
- Interactive side-by-side dashboard inside VS Code:
  - **Live Circular Score Gauge**: Real-time 0–100 score and letter grade.
  - **Google SERP Snippet Preview**: Live desktop/mobile simulation of your title, URL, and meta description.
  - **Category Breakdown**: High-level statistics on title, description, headings, images, and word count.
  - **One-Click Markdown Export**: Copy a clean Markdown diagnostic report to your clipboard.

### 4. 💡 Quick Fixes & Code Actions
- Automatic 1-click Quick Fixes via `Ctrl+.` or `Cmd+.`:
  - *Add `alt=""` attribute to `<img>`*
  - *Add `rel="noopener noreferrer"` to external link*
  - *View documentation on SEOWebChecker*

### 5. 🏷️ Rich Hover Tooltips
- Hover over `<title>`, `<img>`, `<h1>`, or `<meta name="description">` to see real-time character counters, SEO thresholds, and remediation guides.

---

## 🚀 Supported File Types & Frameworks

| Framework / Language | File Extensions |
| :--- | :--- |
| **HTML** | `.html`, `.htm` |
| **React / Next.js** | `.jsx`, `.tsx` |
| **Astro** | `.astro` |
| **Vue.js** | `.vue` |
| **Svelte** | `.svelte` |
| **PHP / WordPress** | `.php` |
| **Markdown / MDX** | `.md`, `.mdx` |

---

## ⌨️ Commands

Open the Command Palette (`Ctrl+Shift+P` / `Cmd+Shift+P`) and type:
- `SEOWebChecker: Run Technical SEO Audit on Current File`
- `SEOWebChecker: Open Visual SEO Audit Panel`
- `SEOWebChecker: Export SEO Report as Markdown`
- `SEOWebChecker: Export SEO Report as JSON`

---

## ⚙️ Configuration Settings

Customize auditing thresholds in your VS Code `settings.json`:

```json
{
  "seowebchecker.minTitleLength": 30,
  "seowebchecker.maxTitleLength": 60,
  "seowebchecker.minDescriptionLength": 70,
  "seowebchecker.maxDescriptionLength": 160,
  "seowebchecker.checkHeadings": true,
  "seowebchecker.checkImages": true,
  "seowebchecker.checkLinks": true,
  "seowebchecker.checkOpenGraph": true,
  "seowebchecker.checkCanonical": true,
  "seowebchecker.checkMobileViewport": true,
  "seowebchecker.checkThinContent": true,
  "seowebchecker.minWordCount": 300,
  "seowebchecker.enableStatusBar": true,
  "seowebchecker.enableHover": true
}
```

---

## 🌐 Official Platform

For deep domain crawls, multi-page site audits, historic audit tracking, and automated Core Web Vitals monitoring:
👉 **[https://seowebchecker.com/](https://seowebchecker.com/)**

---

## 📄 License

MIT License. Engineered by the [SEOWebChecker](https://seowebchecker.com/) team.
