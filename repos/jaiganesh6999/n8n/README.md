# SEOWebChecker - Automated Technical SEO Audit Workflow for n8n

[![Platform](https://img.shields.io/badge/Platform-seowebchecker.com-brightgreen)](https://seowebchecker.com/)
[![n8n Workflow](https://img.shields.io/badge/n8n-Workflow%20Template-orange.svg)](https://n8n.io/workflows)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

An automated technical SEO auditing workflow template for [n8n](https://n8n.io/). Continuously inspects websites for on-page SEO health, verifies title tags, meta descriptions, H1 headings, image accessibility alt attributes, mobile viewports, and OpenGraph social cards, and sends automated regression alerts to Slack, Discord, Microsoft Teams, or Email.

Powered by the [SEOWebChecker](https://seowebchecker.com/) platform.

---

## ⚡ Workflow Highlights

1. **Scheduled or Triggered Execution**:
   - Runs automatically on a weekly or daily cron schedule, or on-demand via webhook/manual trigger.
2. **Comprehensive Technical SEO Auditing**:
   - **Title Tag**: Checks presence, detects missing tags, and flags truncation risks (< 30 or > 60 characters).
   - **Meta Description**: Detects missing snippets, too short (< 70 chars), or overly long (> 160 chars).
   - **Heading Structure**: Ensures exactly one `<h1>` tag exists and flags duplicate H1 headings.
   - **Mobile Readiness**: Validates `<meta name="viewport">` presence.
   - **Canonical Tag**: Ensures `<link rel="canonical">` is specified.
   - **Image Accessibility**: Audits all `<img>` elements for missing `alt` attributes.
   - **Social Sharing**: Checks presence of OpenGraph (`og:title`, `og:image`) tags.
3. **Automated Scoring & Regression Alerts**:
   - Computes an SEO health score (0–100) and letter grade (A through F).
   - Automatically routes notifications based on your custom threshold (e.g., alert if score < 85).

---

## 🚀 How to Import into Your n8n Instance

### Method 1: 1-Click Copy & Paste
1. Open [seowebchecker-technical-seo-audit.json](file:///C:/Users/rinki/.gemini/antigravity/scratch/seowebchecker-seoaudit-sdk/n8n/seowebchecker-technical-seo-audit.json) and copy the entire JSON.
2. In your n8n workspace (Cloud or Self-hosted), create a new workflow.
3. Press `Ctrl+V` (or `Cmd+V`) on the canvas to paste the nodes directly.

### Method 2: Import from File
1. In n8n, click the **three dots menu (⋮)** in the top right of the canvas.
2. Select **Import from File**.
3. Choose `seowebchecker-technical-seo-audit.json`.

---

## 🌐 How to Publish to the Official n8n Workflow Gallery (n8n.io/workflows)

n8n distributes official community templates through the **n8n Creator Program**.

### Step 1: Join the n8n Creator Program
1. Visit **[https://n8n.io/creators](https://n8n.io/creators)**.
2. Sign in or register for the free n8n Creator Portal.

### Step 2: Share Your Template
1. In the Creator Portal dashboard, click **"Share new template"**.
2. Provide the template details:
   - **Workflow Name**: `SEOWebChecker - Automated Technical SEO Audit & Alert System`
   - **Category**: Marketing / Operations / DevOps
   - **Description**: Technical SEO auditing workflow that validates title tags, meta descriptions, heading structure, duplicate H1s, image alt tags, mobile viewports, and OpenGraph tags, sending automated regression alerts.
   - **Workflow JSON**: Upload or paste `seowebchecker-technical-seo-audit.json`.
   - **Official Platform Link**: `https://seowebchecker.com/`

### Step 3: Review & Listing
Once submitted, the n8n community team reviews the template and publishes it to the official gallery at `https://n8n.io/workflows/`.

---

## 📄 License

MIT License. Engineered by the [SEOWebChecker](https://seowebchecker.com/) team.
