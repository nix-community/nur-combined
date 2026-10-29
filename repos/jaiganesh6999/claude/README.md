# SEOWebChecker — Claude Integration & Plugin Guide

[![Platform](https://img.shields.io/badge/Platform-seowebchecker.com-brightgreen)](https://seowebchecker.com/)
[![Anthropic Claude](https://img.shields.io/badge/Claude-Compatible-purple.svg)](https://claude.ai)
[![Model Context Protocol](https://img.shields.io/badge/MCP-Standard-blue.svg)](https://modelcontextprotocol.io/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Official Claude plugin and tool integration for **[SEOWebChecker](https://seowebchecker.com/)**. Connects live technical SEO audits, Core Web Vitals diagnostics, and metadata checks directly to Anthropic's Claude ecosystem:
- **Claude Desktop** (Native Model Context Protocol - MCP)
- **Claude Code CLI** (Anthropic CLI Agent)
- **Claude.ai Projects & Custom Instructions**
- **Anthropic API (Python & TypeScript SDKs)**

---

## ⚡ Available Tools for Claude

| Tool Name | Description | Key Parameters |
|---|---|---|
| `seowebchecker_audit` | Full technical SEO audit (Title, Description, Canonical, Headings H1-H6, Image alt tags, HTTPS, Score 0-100, prioritized recommendations) | `url` (string, required) |
| `seowebchecker_check_meta` | Deep metadata validation (Title, Meta Description, Robots, Canonical, OpenGraph, Twitter Cards) | `url` (string, required) |
| `seowebchecker_core_web_vitals` | Core Web Vitals & page speed indicators (LCP, CLS, INP, TTFB, modern image formats) | `url` (string, required) |
| `seowebchecker_quick_score` | Fast 0-100 health score with issue counts and letter grade (A+ to F) | `url` (string, required) |

---

## 🖥️ 1. Claude Desktop Setup (Official MCP Plugin)

Claude uses the **Model Context Protocol (MCP)** as its official plugin standard.

### Configuration File Locations:
- **Windows:** `%APPDATA%\Claude\claude_desktop_config.json`
- **macOS:** `~/Library/Application Support/Claude/claude_desktop_config.json`

### Add to `claude_desktop_config.json`:

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

*Or run directly from your local repository:*
```json
{
  "mcpServers": {
    "seowebchecker": {
      "command": "node",
      "args": ["C:/Users/rinki/.gemini/antigravity/scratch/seowebchecker-seoaudit-sdk/mcp/index.js"]
    }
  }
}
```

### Restart Claude Desktop:
Once restarted, Claude will display the hammer/tool icon in the chat interface. You can immediately ask:
> *"Audit https://seowebchecker.com/ and give me top 3 technical fixes."*
> *"Check Core Web Vitals for https://example.com/."*

---

## 💻 2. Claude Code CLI Setup

If you use Anthropic's terminal agent **Claude Code**:

```bash
# Add the SEOWebChecker MCP server
claude mcp add seowebchecker -- npx -y seowebchecker-mcp-server
```

Now inside `claude` CLI, Claude can inspect websites and audit technical SEO directly from your terminal!

---

## 🌐 3. Claude.ai Projects Setup (Web & Mobile)

To create a dedicated **Technical SEO Assistant** on [Claude.ai](https://claude.ai):

1. Go to **Projects** on Claude.ai &rarr; Click **Create Project**.
2. **Project Name**: `SEOWebChecker - Technical SEO Specialist`
3. **Custom Instructions**:
   - Copy and paste the contents of [`claude/system_prompt.md`](system_prompt.md).
4. **Interactive Artifacts**:
   - Claude will render visual report cards using [`claude/artifact_template.html`](artifact_template.html).

---

## 🐍 4. Anthropic Python SDK Integration

To equip Claude with SEOWebChecker tools in your Python applications:

```python
import anthropic
import json

client = anthropic.Anthropic()

# Load the tool definitions
with open("claude/tools.json", "r") as f:
    tools = json.load(f)

response = client.messages.create(
    model="claude-3-5-sonnet-20241022",
    max_tokens=1024,
    tools=tools,
    messages=[
        {"role": "user", "content": "Please audit https://seowebchecker.com/ and report on technical SEO health."}
    ]
)

print(response)
```

---

## 📄 License

MIT License. Engineered by the [SEOWebChecker](https://seowebchecker.com/) team.
