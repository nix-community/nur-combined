# SEOWebChecker — ChatGPT Custom GPT Manifest & Setup Guide

[![Platform](https://img.shields.io/badge/Platform-seowebchecker.com-brightgreen)](https://seowebchecker.com/)
[![OpenAI GPT Store](https://img.shields.io/badge/ChatGPT-Custom%20GPT-412991.svg)](https://chatgpt.com/gpts)
[![OpenAPI](https://img.shields.io/badge/OpenAPI-3.1.0-green.svg)](https://spec.openapis.org/oas/v3.1.0)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Official OpenAI Custom GPT configuration for **[SEOWebChecker](https://seowebchecker.com/)**. Allows any public user on ChatGPT (free or Plus) to perform live technical SEO audits, analyze on-page structure, and receive prioritized developer fixes directly inside their ChatGPT conversation.

---

## ⚡ 2-Minute Setup in OpenAI GPT Builder

### Step 1: Open ChatGPT GPT Editor
1. Log in to [ChatGPT](https://chatgpt.com/).
2. In the left sidebar, click **Explore GPTs** &rarr; click **+ Create** in the top-right (or visit [chatgpt.com/gpts/editor](https://chatgpt.com/gpts/editor)).
3. Click the **Configure** tab.

---

### Step 2: Configure Basic Details
- **Name**: `SEOWebChecker - Technical SEO Auditor`
- **Description**: `Instant technical SEO audits for any webpage. Get 0-100 health scores, on-page diagnostics, Core Web Vitals, and prioritized developer fixes.`
- **Instructions**:
  Copy and paste the full prompt from [`custom-gpt/instructions.md`](instructions.md).
- **Conversation Starters**:
  1. `Audit https://seowebchecker.com/ and report technical issues`
  2. `Analyze the technical SEO health of my website`
  3. `Inspect meta tags, headings, and mobile readiness for a URL`
  4. `Check Core Web Vitals and performance recommendations`
- **Capabilities**:
  - [x] Web Browsing
  - [x] Code Interpreter

---

### Step 3: Add Custom Action (OpenAPI Schema)
1. Scroll down to the bottom of the **Configure** tab and click **Create new action**.
2. In the **Schema** box, paste the complete JSON from [`custom-gpt/openapi.json`](openapi.json).
3. **Authentication**: Set to `None`.
4. **Privacy Policy**: Enter `https://seowebchecker.com/privacy-policy` (or `https://seowebchecker.com/`).
5. In the **Test** section on the right, click **Test** next to `runTechnicalSeoAudit` to confirm it returns real audit data from `https://seowebchecker.com/api/v1/audit`.

---

### Step 4: Publish to the Public GPT Store
1. In the top-right corner, click **Save** / **Update**.
2. Select **Everyone** (or **Anyone with a link**).
3. Choose the category **Productivity** or **Developer Tools**.
4. Click **Confirm**.

You will receive a public URL (e.g., `https://chatgpt.com/g/g-xxxxx-seowebchecker-technical-seo-auditor`) that **anyone in the world can click and use instantly** on ChatGPT web or mobile without installing anything!

---

## 📄 License

MIT License. Engineered by the [SEOWebChecker](https://seowebchecker.com/) team.
