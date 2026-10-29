# SEO::WebChecker — Technical SEO Audit & Analyzer for Raku

[![Raku.land](https://img.shields.io/badge/Raku.land-SEO%3A%3AWebChecker-blue.svg)](https://raku.land/zef:jaiganesh6999/SEO::WebChecker)
[![License: Artistic-2.0](https://img.shields.io/badge/License-Artistic%202.0-0298c3.svg)](https://opensource.org/licenses/Artistic-2.0)
[![Official Website](https://img.shields.io/badge/Platform-seowebchecker.com-brightgreen)](https://seowebchecker.com/)

A lightweight, high-performance Raku module and CLI tool for on-page **technical SEO auditing**, metadata validation, heading hierarchy verification, mobile readiness checks, and regression alerting.

Powered by the [SEOWebChecker](https://seowebchecker.com/) platform.

---

## ⚡ Features

- **On-Page Metadata Diagnostics**: Inspects title tags, meta descriptions, and canonical link tags.
- **Heading Hierarchy**: Detects missing `<h1>` tags, verifies single primary `<h1>` best practices, and warns against multiple conflicting `<h1>` headings.
- **Mobile & Accessibility**: Validates responsive mobile `<meta name="viewport">` configuration.
- **Transport Security**: Audits SSL/TLS encryption and flags insecure HTTP links.
- **Thin Content Detection**: Analyzes word counts and estimated reading times.
- **Scorecard & Grading**: Generates a 0–100 health score with letter grades (`A+` through `F`) and configurable alert thresholds (`PASS` / `ALERT`).
- **Flexible Formats**: Export audit reports as raw Raku Hash structures, structured JSON, or human-readable Markdown.
- **Command-Line Interface**: Instant `seowebchecker` binary for CI/CD pipelines and terminal testing.

---

## 📦 Installation

Install `SEO::WebChecker` using **`zef`** (the standard Raku module manager):

```bash
zef install SEO::WebChecker
```

---

## 🚀 Quick Usage

### 1. In Your Raku Code

```raku
use SEO::WebChecker;

my $auditor = SEO::WebChecker.new(:alert-threshold(85));

# Audit a live URL
my $result = $auditor.audit('https://seowebchecker.com/');

say "Health Score: {$result.score} / 100 ({$result.grade})";
say "Status      : {$result.status}";
say "Title Tag   : {$result.title}";
say "Passed      : {$result.passes.elems} checks";
say "Issues      : {$result.issues.elems} items";

# Export as JSON or Markdown
say $result.to-json;
say $result.to-markdown;
```

### 2. Auditing Raw HTML Strings Directly

```raku
my $html = q:to/HTML/;
<!DOCTYPE html>
<html>
<head>
  <title>My Website Title</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="canonical" href="https://example.com/">
</head>
<body>
  <h1>Primary Topic</h1>
  <p>Long helpful paragraph text...</p>
</body>
</html>
HTML

my $result = $auditor.audit-html($html, :url<https://example.com/>);
say "Score: " ~ $result.score;
```

---

## 💻 Command-Line Interface (`bin/seowebchecker`)

After installing with `zef`, the `seowebchecker` executable is globally available:

```bash
# Run a full terminal audit
seowebchecker audit https://seowebchecker.com/

# Export structured JSON
seowebchecker audit https://seowebchecker.com/ --json

# Export clean Markdown
seowebchecker audit https://seowebchecker.com/ --md

# Fast score check (exits 0 on PASS, 1 on ALERT for CI/CD)
seowebchecker score https://seowebchecker.com/
```

---

## 🧪 Running Tests

To run the automated test suite locally:

```bash
zef test .
```

---

## 🌐 Publishing to Raku.land via Fez

Raku distributions are published to the global ecosystem (which indexes directly to **[raku.land](https://raku.land/)**) using **`fez`**:

### Step 1: Install `fez`
```bash
zef install fez
```

### Step 2: Register Your Account (One-Time)
```bash
fez register
```

### Step 3: Validate the Distribution Build
```bash
cd raku
fez checkbuild
```

### Step 4: Upload to Raku.land
```bash
fez upload
```

Within minutes, your package will be indexed and viewable at:
`https://raku.land/zef:jaiganesh6999/SEO::WebChecker`

---

## 📄 License

Artistic License 2.0. Engineered by the [SEOWebChecker](https://seowebchecker.com/) team.
