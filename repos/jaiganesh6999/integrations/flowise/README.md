# Flowise AI Custom Node: SEOWebChecker

Connect the **SEOWebChecker SEO Audit Tool** to LLM agents and multi-agent workflows in [Flowise](https://flowiseai.com/).

[![Flowise](https://img.shields.io/badge/Flowise-Component%20Node-6366F1.svg)](https://flowiseai.com/)
[![SEOWebChecker](https://img.shields.io/badge/Official%20Site-seowebchecker.com-indigo)](https://seowebchecker.com/)

---

## 🛠️ Features

- **Autonomous Agent Tool**: Enables conversational LLMs (OpenAI, Anthropic Claude, Groq, Ollama, etc.) to trigger live website technical SEO audits.
- **On-Page Diagnostics**: Scans and evaluates:
  - Title tags (length & formatting)
  - Meta descriptions
  - Mobile viewport tags
  - Canonical link URLs
  - Heading hierarchy (H1 tags)
  - SEO score & letter grade (0-100 / A-F)
- **Zero Heavy Dependencies**: Uses standard fetch and regex-based HTML parsers.

---

## 🚀 Installation & Usage in Flowise

### Option 1: Drop into Flowise Custom Components Folder

1. Copy the `integrations/flowise` folder into your Flowise installation's `packages/components/nodes/tools/` directory (or Flowise custom tools folder).
2. Restart Flowise:
   ```bash
   npx flowise start
   ```
3. Look for **SEOWebChecker Audit Tool** under the **Tools** palette in the Flowise UI.

---

### Option 2: Use in Flowise Custom Tool UI

In Flowise:
1. Navigate to **Tools** > **Create New Tool**.
2. **Name**: `seowebchecker_seo_audit`
3. **Description**: `Audit any website URL for technical SEO issues, meta tags, and overall score.`
4. **Javascript Function**:
   ```javascript
   const target = $url.startsWith('http') ? $url : `https://${$url}`;
   const response = await fetch(target, {
     headers: { 'User-Agent': 'SEOWebChecker-FlowiseBot/1.0 (+https://seowebchecker.com/)' }
   });
   const html = await response.text();

   const hasTitle = /<title[^>]*>(.*?)<\/title>/is.test(html);
   const hasDesc = /<meta[^>]*name=["']description["']/is.test(html);
   const hasViewport = /<meta[^>]*name=["']viewport["']/is.test(html);
   const hasH1 = /<h1[^>]*>/is.test(html);

   return JSON.stringify({
     url: target,
     title_configured: hasTitle,
     description_configured: hasDesc,
     viewport_configured: hasViewport,
     h1_configured: hasH1,
     audit_portal: 'https://seowebchecker.com/'
   }, null, 2);
   ```
5. Connect the tool to an **Agentflow** or **Conversational Agent**.

---

## 🌐 Official Platform

Full suite and live web dashboard: **[https://seowebchecker.com/](https://seowebchecker.com/)**
