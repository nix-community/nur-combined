# SEOWebChecker MCP Server (Model Context Protocol)

[![Official Website](https://img.shields.io/badge/Official%20Site-seowebchecker.com-indigo)](https://seowebchecker.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Smithery](https://img.shields.io/badge/Smithery-seowebchecker-blue.svg)](https://smithery.ai)

Official Model Context Protocol (MCP) server for **[SEOWebChecker.com](https://seowebchecker.com/)**. Enables AI assistants such as **Claude Desktop**, **Cursor IDE**, **Windsurf**, and **Cline** to perform live on-page technical SEO audits, Core Web Vitals checks, and meta validations.

---

## 🚀 Features

* **`seowebchecker_audit`**: Run a comprehensive technical SEO audit on any URL (Title, Description, Canonical, Headings H1-H6, Images without alt, Links, HTTP status, Response time).
* **`seowebchecker_check_meta`**: Inspect and validate Title, Description, Robots, Canonical, OpenGraph, and Twitter cards.
* **`seowebchecker_core_web_vitals`**: Check performance indicators and Core Web Vitals (LCP, FID, CLS, INP, TTFB).
* **`seowebchecker_quick_score`**: Fast 0-100 technical SEO health score with passed checks and prioritized fixes.

---

## 🛠️ Quick Setup

### 1. Claude Desktop

Add this to your `claude_desktop_config.json`:

* **macOS:** `~/Library/Application Support/Claude/claude_desktop_config.json`
* **Windows:** `%APPDATA%\Claude\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "seowebchecker": {
      "command": "npx",
      "args": ["-y", "seowebchecker-mcp-server"]
    }
  }
}
```

### 2. Cursor IDE

In Cursor, go to **Settings** → **Features** → **MCP** → **Add New MCP Server**:
* **Name:** `seowebchecker`
* **Type:** `command`
* **Command:** `npx -y seowebchecker-mcp-server`

Or in `~/.cursor/mcp.json`:
```json
{
  "mcpServers": {
    "seowebchecker": {
      "command": "npx",
      "args": ["-y", "seowebchecker-mcp-server"]
    }
  }
}
```

### 3. Windsurf

In `~/.codeium/windsurf/mcp_config.json`:
```json
{
  "mcpServers": {
    "seowebchecker": {
      "command": "npx",
      "args": ["-y", "seowebchecker-mcp-server"]
    }
  }
}
```

### 4. Smithery (CLI)

```bash
npx -y @smithery/cli install seowebchecker --client claude
```

---

## 💡 Example AI Prompts

Once configured, you can ask your AI assistant:

* *"Audit the SEO on https://example.com and list top 3 improvements."*
* *"Compare the on-page SEO between https://site1.com and https://site2.com."*
* *"Check if my meta tags and OpenGraph image are properly configured on https://example.com."*

---

Official documentation and free online audit tool: **[https://seowebchecker.com/](https://seowebchecker.com/)**
