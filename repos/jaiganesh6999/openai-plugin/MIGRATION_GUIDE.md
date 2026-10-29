# OpenAI Custom GPT to Plugin & Skill Migration Guide

[![Platform](https://img.shields.io/badge/Platform-seowebchecker.com-brightgreen)](https://seowebchecker.com/)
[![OpenAI Plugin](https://img.shields.io/badge/OpenAI-Plugin%20%26%20Skills-412991.svg)](https://chatgpt.com/)
[![Deadline](https://img.shields.io/badge/Deadline-December%2011%2C%202026-red.svg)](https://openai.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

OpenAI has announced that **Custom GPTs are being retired on December 11, 2026**, replaced by a unified **Plugins & Skills** architecture.

This guide outlines everything you need to know and do before the deadline to ensure your **SEOWebChecker** integration transitions smoothly.

---

## 📅 Critical Deadlines

| Date | Milestone | Impact |
|---|---|---|
| **October 26, 2026** | **New GPT Creation Closes** | No new Custom GPTs can be created. Existing GPTs remain editable and functional. |
| **December 11, 2026** | **Official Retirement Date** | Standalone Custom GPT pages and URLs become completely inaccessible. All workflows must run via Plugins & Skills. |
| **February 11, 2027** | **Enterprise Deferral Cutoff** | Final shutdown for enterprise accounts with approved extension waivers. |

---

## 🔄 What Changes in the New Architecture?

| Feature | Legacy Custom GPTs | Modern Plugins & Skills |
|---|---|---|
| **Location** | Isolated separate chat tab | Universal in any chat via `@SEOWebChecker` |
| **Instructions** | Global prompt for whole chat | Reusable dynamic **Skill** (`technical_seo_auditor.md`) |
| **APIs / Actions** | GPT Actions tab | Plugin OpenAPI toolset (`openapi.json`) |
| **Default Sharing** | Kept previous access | **Resets to Private** upon migration (must re-share!) |

---

## 🛠️ Step-by-Step Migration Instructions

### Step 1: Ensure Your GPT is Published
1. Open [chatgpt.com/gpts/mine](https://chatgpt.com/gpts/mine).
2. Open your `SEOWebChecker` GPT in the editor.
3. Make sure all changes are published (drafts do not carry over).

### Step 2: Click "Migrate to Plugin"
1. In **My GPTs**, find `SEOWebChecker - Technical SEO Auditor`.
2. Click the `•••` options menu and select **Migrate to plugin**.
3. OpenAI will automatically convert your instructions into a **Skill** and link your reference files.

### Step 3: Re-link Your Custom Action (OpenAPI)
*Note: OpenAI's migration wizard does not auto-transfer custom action endpoints.*
1. In the sidebar, navigate to **Plugins** &rarr; **Personal** &rarr; **Installed** &rarr; `SEOWebChecker`.
2. Under **Actions / APIs**, click **Add API**.
3. Paste the contents of [`openai-plugin/openapi.json`](openapi.json) pointing to `https://seowebchecker.com/api/v1`.
4. Set Authentication to `None` and verify the test call succeeds.

### Step 4: Re-Configure Sharing Permissions
1. Migrated plugins default to **Private**.
2. Open the plugin settings and set sharing to **Public** or **Anyone with link**.

---

## 💬 How Users Call SEOWebChecker in the New System

Users no longer need to switch into a dedicated GPT tab. In any active ChatGPT conversation, they can simply type:
> *"@SEOWebChecker audit https://seowebchecker.com/ and check for missing meta tags."*
> *"@SEOWebChecker what are the Core Web Vitals for https://example.com/?"*

---

## 📂 Pre-Configured Files in This Repository

- **[`ai-plugin.json`](ai-plugin.json)**: Standard OpenAI plugin manifest.
- **[`openapi.json`](openapi.json)**: Production OpenAPI 3.1.0 action schema.
- **[`skills/technical_seo_auditor.md`](skills/technical_seo_auditor.md)**: Converted Skill instruction file.

---

## 📄 License

MIT License. Engineered by the [SEOWebChecker](https://seowebchecker.com/) team.
