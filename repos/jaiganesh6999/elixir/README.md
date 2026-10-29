# SeoWebChecker

[![Hex.pm](https://img.shields.io/hexpm/v/seowebchecker.svg)](https://hex.pm/packages/seowebchecker)
[![Hex Docs](https://img.shields.io/badge/hex-docs-purple.svg)](https://hexdocs.pm/seowebchecker)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Official Site](https://img.shields.io/badge/Official%20Site-seowebchecker.com-indigo)](https://seowebchecker.com/)

A lightweight Elixir client SDK and technical SEO audit engine for on-page meta tag validations, heading structure inspections, image accessibility checks, and Core Web Vitals diagnostics.

Powered by **[SEOWebChecker.com](https://seowebchecker.com/)**.

---

## Installation

Add `seowebchecker` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:seowebchecker, "~> 1.0.0"}
  ]
end
```

Then run:

```bash
mix deps.get
```

---

## Usage

### 1. Audit Raw HTML String

```elixir
html = """
<!DOCTYPE html>
<html lang="en">
<head>
    <title>High Ranking On-Page SEO Checklist & Guide</title>
    <meta name="description" content="Master technical on-page SEO, heading structure, and Core Web Vitals optimization with our comprehensive developer checklist.">
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
"""

result = SeoWebChecker.audit_html(html, url: "https://example.com/guide")

IO.puts("Overall Score: #{result.score.overall}/100 (Grade #{result.score.grade})")
IO.puts("Passed: #{result.passed_checks}/#{result.total_checks}")
IO.puts("Warnings: #{result.warnings}, Errors: #{result.errors}")

Enum.each(result.issues, fn issue ->
  IO.puts("  [#{String.upcase(to_string(issue.severity))}] #{issue.title}: #{issue.message}")
end)
```

### 2. Audit a Live Remote Website URL

```elixir
{:ok, result} = SeoWebChecker.audit_url("https://example.com")
IO.puts("Audited URL: #{result.url}")
IO.puts("Score: #{result.score.overall}/100 (#{result.score.grade})")
```

---

## Features

- ⚡ **Zero Runtime Dependencies**: Uses standard Elixir & Erlang OTP modules (`:inets`, `:httpc`, `:ssl`).
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
