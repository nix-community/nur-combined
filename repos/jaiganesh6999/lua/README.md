# seowebchecker (Lua)

[![LuaRocks](https://img.shields.io/luarocks/v/seowebchecker/seowebchecker.svg)](https://luarocks.org/modules/seowebchecker/seowebchecker)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Official Site](https://img.shields.io/badge/Official%20Site-seowebchecker.com-indigo)](https://seowebchecker.com/)

A lightweight Lua client SDK and automated on-page technical SEO diagnostic engine for meta tag validations, heading structure inspections, image accessibility checks, and Core Web Vitals diagnostics.

Powered by **[SEOWebChecker.com](https://seowebchecker.com/)**.

---

## Installation

Using [LuaRocks](https://luarocks.org):

```bash
luarocks install seowebchecker
```

Or manually copy `lua/seowebchecker.lua` directly into your Lua module path.

---

## Quick Start

```lua
local seowebchecker = require("seowebchecker")

local html = [[
<!DOCTYPE html>
<html lang="en">
<head>
    <title>High Ranking On-Page SEO Checklist & Guide</title>
    <meta name="description" content="Master technical on-page SEO, heading structure, and Core Web Vitals optimization.">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="canonical" href="https://example.com/guide">
    <meta property="og:title" content="High Ranking On-Page SEO Checklist">
    <meta property="og:image" content="https://example.com/og.jpg">
</head>
<body>
    <h1>On-Page Technical SEO Essentials</h1>
    <p>Optimize your website performance and search rankings.</p>
    <img src="chart.png" alt="SEO Traffic Growth Chart">
</body>
</html>
]]

local result = seowebchecker.audit_html(html, "https://example.com/guide")

print(string.format("Overall Score: %d/100 (Grade %s)", result.score.overall, result.score.grade))
print(string.format("Checks Passed: %d/%d", result.passed_checks, result.total_checks))
print(string.format("Warnings: %d, Errors: %d", result.warnings, result.errors))

for _, issue in ipairs(result.issues) do
    print(string.format("  [%s] %s: %s", string.upper(issue.severity), issue.title, issue.message))
end
```

---

## Features

- ⚡ **Zero External Dependencies**: Compatible with Lua 5.1, 5.2, 5.3, 5.4, and LuaJIT.
- 🔍 **Core SEO Audits**:
  - Title tag presence & optimal character count (30-60 chars)
  - Meta description presence & length validation (50-160 chars)
  - Mobile viewport responsiveness configuration
  - Canonical link tag detection
  - Single primary `<h1>` heading validation
  - Image accessibility (`alt` attribute coverage)
  - OpenGraph social sharing meta tags (`og:title`, `og:image`)
- 📊 **Scoring**: Calculates standard weighted 0-100 numerical scores and letter grades (A-F).

---

## Online Tools

- **Official Website**: [https://seowebchecker.com/](https://seowebchecker.com/)
- **Live Interactive SEO Auditing**: Test live web pages at [https://seowebchecker.com/](https://seowebchecker.com/)

---

## License

MIT © 2026 [SEOWebChecker.com](https://seowebchecker.com/).
