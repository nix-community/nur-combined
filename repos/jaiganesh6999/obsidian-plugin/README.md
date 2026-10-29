# SEOWebChecker SEO Audit — Obsidian Plugin

[![Obsidian Plugin](https://img.shields.io/badge/Obsidian-Community%20Plugin-7C3AED.svg?logo=obsidian&logoColor=white)](https://obsidian.md/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-https%3A%2F%2Fseowebchecker.com%2F-brightgreen)](https://seowebchecker.com/)

An advanced on-page SEO and readability auditing plugin for **Obsidian**, powered by [SEOWebChecker](https://seowebchecker.com/).

Audit your Markdown notes, blog drafts, digital garden entries, documentation, and static site content (Hugo, Jekyll, Astro, Next.js) in real-time as you write.

---

## Key Features

- 🎯 **Real-Time SEO Health Score**:
  - Live 0–100 health score with academic grades (`A+` through `F`) updating seamlessly as you type.
  - Granular breakdown of Passes, Warnings, and Critical recommendations.

- 📝 **YAML Frontmatter Optimization**:
  - Validates `title` / `seo_title` length (30–65 characters).
  - Validates `description` / `meta_description` snippet length (120–165 characters).
  - Inspects `canonical` URL, `slug` kebab-case formatting, and keyword tags.

- 📐 **Heading Hierarchy & Document Structure**:
  - Ensures a single primary H1 heading (`#`).
  - Detects skipped heading tiers (e.g. H1 jumping to H3 without H2).
  - Displays full heading distribution counts across your article.

- 📖 **Readability & Content Metrics**:
  - Calculates Flesch Reading Ease score and equivalent grade levels.
  - Word count tracking against custom minimum and comprehensive targets.
  - Estimates reading time and speaking time.

- 🔑 **Focus Keyword Tracking**:
  - Specify your target term in frontmatter (`focus_keyword: "..."`).
  - Analyzes presence in SEO Title, H1, introduction paragraph, and subheadings.
  - Calculates keyword density percentage (recommends 1.0%–2.5%, warns if keyword stuffing > 3.0%).

- 🖼️ **Media & Link Diagnostics**:
  - Scans Markdown images (`![alt](url)`) and flags missing or empty alt text.
  - Distinguishes internal wiki-links (`[[note]]`) from external hyperlinks.
  - Detects generic, uninformative anchor text (e.g., "click here", "read more").

- 🌐 **Live Web Page Auditor**:
  - Direct integration to test published live URLs using Obsidian's secure `requestUrl` API.
  - Evaluates HTTP response status, title, meta description, mobile viewport configuration, canonical links, and server latency.

---

## Installation

### Method 1: Obsidian Community Plugins Directory
1. Open Obsidian **Settings** > **Community plugins**.
2. Turn off **Restricted mode**.
3. Click **Browse** and search for **SEOWebChecker SEO Audit**.
4. Click **Install**, then **Enable**.

### Method 2: Manual Installation
1. Download `manifest.json`, `main.js`, and `styles.css` from the latest release.
2. Inside your Obsidian vault, navigate to `.obsidian/plugins/`.
3. Create a new directory named `seowebchecker-seo-audit`.
4. Copy `manifest.json`, `main.js`, and `styles.css` into that directory.
5. In Obsidian, go to **Settings** > **Community plugins** and enable **SEOWebChecker SEO Audit**.

---

## Usage

### 1. Open the SEO Audit Sidebar
- Click the **Gauge** icon in the left ribbon, OR
- Open the Command Palette (`Ctrl+P` / `Cmd+P`) and run:
  `SEOWebChecker: Open SEO Audit Sidebar`

### 2. Insert SEO Frontmatter Template
- In any Markdown note, run:
  `SEOWebChecker: Insert SEO Frontmatter Template`
- This inserts a clean, SEO-optimized YAML frontmatter header:
  ```yaml
  ---
  title: "Your Comprehensive Article Title"
  description: "A compelling 120-165 character summary describing the core value of this article."
  canonical: "https://example.com/blog/article-slug"
  focus_keyword: "primary target term"
  slug: "article-slug"
  ---
  ```

### 3. Review Diagnostics
- Use the sidebar tabs (**Overview**, **Headings**, **Readability**, **Live URL**) to review actionable recommendations and resolve warnings before publishing your post.

---

## Official Links

- **Platform**: [https://seowebchecker.com/](https://seowebchecker.com/)
- **Repository**: [https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk](https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk)
- **Issue Tracker**: [https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk/issues](https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk/issues)

---

## License

MIT License. Copyright (c) 2026 SEOWebChecker.
