# SeoWebCheckerAudit.jl Documentation

Welcome to the documentation for **SeoWebCheckerAudit.jl**, a lightweight, fast, and dependency-free open-source SEO audit SDK for the Julia programming language, developed by the [SEOWebChecker](https://seowebchecker.com/) team.

Official website and web-based audits: [https://seowebchecker.com/](https://seowebchecker.com/)

## Features

- **Metadata Verification**: Analyzes `<title>` length, `<meta name="description">` length, viewport tags, and `<link rel="canonical">`.
- **Heading Structure**: Checks for existence and count of primary `<h1>` tags.
- **Image Accessibility**: Checks for missing `alt` attributes on images.
- **OpenGraph & Social Tags**: Validates `og:title` and `og:image` tags.
- **Scoring Engine**: Computes overall SEO score (0-100) and letter grades (A through F) with remediation advice.

## Installation

```julia
using Pkg
Pkg.add("SeoWebCheckerAudit")
```

## Quick Start

```julia
using SeoWebCheckerAudit

html = """
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
</body>
</html>
"""

result = audit_html(html; url = "https://seowebchecker.com/")
println("Score: ", result.score.overall, " (Grade: ", result.score.grade, ")")
```
