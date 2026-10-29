# SEOWebChecker - Zapier Platform Integration

[![Platform](https://img.shields.io/badge/Platform-seowebchecker.com-brightgreen)](https://seowebchecker.com/)
[![Zapier Platform Core](https://img.shields.io/badge/Zapier-19.1.0-orange.svg)](https://platform.zapier.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Official [Zapier](https://zapier.com/) integration for **SEOWebChecker**. Enables automated technical SEO auditing, on-page diagnostics, Core Web Vitals checks, and instant regression alerts across 6,000+ business applications (Slack, Google Sheets, HubSpot, Notion, Airtable, Discord, Jira, and Email).

Powered by the [SEOWebChecker](https://seowebchecker.com/) platform.

---

## ⚡ Integration Features

### Actions (Creates)
- **`Run Technical SEO Audit` (`runAudit`)**:
  - Audits any target webpage URL on-demand.
  - Returns overall score (0–100), letter grade (A+ through F), pass/alert status, title tag analysis, meta description optimization, heading hierarchy (H1 check), mobile viewport validation, canonical links, image alt attributes, and OpenGraph social tags.
  - Supports configurable alert score thresholds (e.g., flag alert when score < 85).

### Triggers
- **`New Audit Completed` (`auditCompleted`)**:
  - Triggers a Zap whenever an audit is recorded or refreshed.

---

## 🚀 How to Build & Publish to Zapier

### Step 1: Install & Verify Locally
The integration is already built and validated with zero errors:
```powershell
cd C:\Users\rinki\.gemini\antigravity\scratch\seowebchecker-seoaudit-sdk\zapier

# Run automated tests
npm test

# Run Zapier CLI validation
npx zapier-platform-cli validate
```

---

### Step 2: Log In to Your Zapier Account
1. Create or log in to your account at [developer.zapier.com](https://developer.zapier.com/).
2. Run the login command in your terminal:
```powershell
npx zapier-platform-cli login
```
*(This opens a browser window to authenticate and generate your Deploy Key).*

---

### Step 3: Register the Integration on Zapier
Register SEOWebChecker as a new integration under your Zapier account:
```powershell
npx zapier-platform-cli register "SEOWebChecker"
```

---

### Step 4: Push the First Version (v1.0.0)
Deploy the code to Zapier's cloud infrastructure:
```powershell
npx zapier-platform-cli push
```

Once pushed, your integration is live in your personal Zapier account! You can immediately create Zaps with it in the Zapier editor.

---

### Step 5: Invite Users & Publish to Zapier App Directory

1. **Private Sharing / Client Invites**:
   - In your [Zapier Developer Dashboard](https://developer.zapier.com/), open **SEOWebChecker** -> **Sharing**.
   - Copy the invite link to let team members or clients use SEOWebChecker in their Zaps immediately.
2. **Public Directory Listing**:
   - Go to the **Publish** tab in your Zapier Developer Dashboard.
   - Fill in app branding (logo, category: *SEO & Marketing*, canonical website: `https://seowebchecker.com/`).
   - Click **Submit for Review** to have SEOWebChecker published in the public [Zapier App Directory](https://zapier.com/apps).

---

## 📄 License

MIT License. Engineered by the [SEOWebChecker](https://seowebchecker.com/) team.
