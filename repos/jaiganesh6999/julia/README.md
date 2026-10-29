# SeoWebCheckerAudit.jl

[![Official Website](https://img.shields.io/badge/Website-seowebchecker.com-blue?style=flat-square)](https://seowebchecker.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Julia: 1.10+](https://img.shields.io/badge/Julia-1.10+-purple.svg)](https://julialang.org)

Lightweight, fast, and dependency-free open-source SEO audit SDK for the Julia programming language. Engineered by the [SEOWebChecker](https://seowebchecker.com/) team to empower developers, data scientists, and webmasters to automate on-page technical SEO audits, meta tag validations, heading structure inspections, image accessibility analysis, and Core Web Vitals readiness checks directly in Julia.

Online web-based audits, full scoring, and report exports are available at **[https://seowebchecker.com/](https://seowebchecker.com/)**.

---

## ⚡ Features

- **Metadata Verification**: In-depth inspection of `<title>` length, `<meta name="description">` length, viewport tags, and `<link rel="canonical">`.
- **Heading Hierarchy**: Evaluates primary `<h1>` presence and warns against multiple conflicting `<h1>` tags.
- **Image Accessibility**: Detects missing `alt` attributes across all content images.
- **Social Graph Optimization**: Validates OpenGraph preview tags (`og:title`, `og:image`).
- **Scoring Engine**: Generates an actionable score (0-100) and letter grade (A through F) with explicit remediation recommendations.
- **Zero Heavy Dependencies**: Built solely upon Julia's standard library.

---

## 📦 Installation

Install `SeoWebCheckerAudit` via the Julia package manager (type `]` in the Julia REPL):

```julia
pkg> add SeoWebCheckerAudit
```

Or programmatically:

```julia
using Pkg
Pkg.add("SeoWebCheckerAudit")
```

---

## 🚀 Quickstart

### Audit an HTML String

```julia
using SeoWebCheckerAudit

html_content = """
<!DOCTYPE html>
<html lang="en">
<head>
    <title>SEOWebChecker: Fast On-Page SEO Analyzer</title>
    <meta name="description" content="Free open-source website audit tools for SEO metrics, meta tag inspection, and Core Web Vitals.">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="canonical" href="https://seowebchecker.com/">
</head>
<body>
    <h1>Elevate Your Search Engine Rankings</h1>
    <p>Discover actionable SEO recommendations with SEOWebChecker.</p>
    <img src="dashboard.png" alt="SEO Analysis Scoreboard">
</body>
</html>
"""

result = audit_html(html_content; url = "https://seowebchecker.com/")

println("Score: ", result.score.overall, "/100 (Grade: ", result.score.grade, ")")
println("Passed Checks: ", result.passed_checks, " / ", result.total_checks)

for issue in result.issues
    println("[", uppercase(issue.severity), "] ", issue.title, ": ", issue.message)
end
```

### Audit a Live Website URL

```julia
using SeoWebCheckerAudit

result = audit_url("https://seowebchecker.com/")

println("URL: ", result.url)
println("Overall SEO Score: ", result.score.overall, "% (Grade: ", result.score.grade, ")")
println("Identified Warnings: ", result.warnings)
println("Identified Errors: ", result.errors)
```

---

## 🔗 Related Resources & Tools

- **Official Web Portal**: [https://seowebchecker.com/](https://seowebchecker.com/)
- **GitHub Repository**: [https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk](https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk)
- **Rust Crate**: [crates.io/crates/seowebchecker-seoaudit-sdk](https://crates.io/crates/seowebchecker-seoaudit-sdk)
- **Docker Image**: [hub.docker.com/r/seoaitools/seoaudit-sdk](https://hub.docker.com/r/seoaitools/seoaudit-sdk)
- **Maven Central**: [central.sonatype.com/artifact/com.seowebchecker/seowebchecker-seoaudit-sdk](https://central.sonatype.com/artifact/com.seowebchecker/seowebchecker-seoaudit-sdk)

---

## 📄 License

This package is licensed under the [MIT License](LICENSE).
