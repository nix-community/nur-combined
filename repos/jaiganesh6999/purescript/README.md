# SEOWebChecker PureScript Client SDK

[![Official Website](https://img.shields.io/badge/Website-seowebchecker.com-blue?style=flat-square)](https://seowebchecker.com/)
[![PureScript](https://img.shields.io/badge/PureScript-0.15+-white?logo=purescript&logoColor=black&style=flat-square)](https://www.purescript.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://opensource.org/licenses/MIT)

Official **PureScript Client SDK** for technical on-page SEO diagnostics and health auditing. Developed by the [SEOWebChecker](https://seowebchecker.com/) team to provide strongly-typed, purely functional SEO audits, meta tag validations, heading structure inspections, image accessibility checks, and Core Web Vitals readiness for PureScript and JavaScript front-end / back-end web applications.

Full web-based audits, historical tracking, and developer APIs are available at **[https://seowebchecker.com/](https://seowebchecker.com/)**.

---

## ⚡ Features

* **Pure & Strongly Typed**: Idiomatic PureScript types (`Report`, `Score`, `Stats`, `Issue`, `Severity`) with `Eq`, `Ord`, and `Show` instances.
* **On-Page Technical SEO Checks**:
  * **Title Tag**: Length and optimization (30–60 characters).
  * **Meta Description**: Length and organic search click-through rate optimization (70–160 characters).
  * **Mobile Viewport**: Multi-device viewport responsive tag validation.
  * **Canonical Link Tag**: Detection to prevent duplicate content indexing issues.
  * **Heading Hierarchy**: Primary `<h1>` validation and duplicate detection.
  * **Content Depth**: Word count estimation to warn against thin content.
  * **Image Accessibility**: Missing `alt` attributes count across content images.
  * **OpenGraph Social Cards**: OpenGraph tags (`og:title`, `og:image`) verification.
  * **Structured Data**: Schema.org JSON-LD structured data verification.
* **Weighted Scorecard**: 0–100 score and letter grades (`A+` through `F`).
* **Markdown Generator**: Built-in `generateMarkdown` formatter for reporting and CLI outputs.
* **PureScript 0.15+ Ready**: Emits clean ES module FFI compatible with modern Spago.

---

## 📦 Installation

### Using Spago (Recommended)

Add `seowebchecker` to your `spago.yaml`:

```yaml
package:
  dependencies:
    - seowebchecker
```

Or install via CLI:

```bash
spago install seowebchecker
```

---

## 🚀 Usage

```purescript
module Main where

import Prelude
import Effect (Effect)
import Effect.Console (log)
import SEOWebChecker (auditHtml, generateMarkdown)

main :: Effect Unit
main = do
  let html = "<html><head><title>My Web Page</title><meta name=\"description\" content=\"A high-performing web application built with PureScript.\"></head><body><h1>Welcome</h1><p>Content...</p></body></html>"
  let report = auditHtml html "https://seowebchecker.com/"

  log $ "Overall Score: " <> show report.score.overall <> "/100 (" <> report.score.grade <> ")"
  log $ "Passed Checks: " <> show report.stats.passed
  log $ "Warnings: " <> show report.stats.warnings
  log $ "Errors: " <> show report.stats.errors

  -- Generate Markdown
  log $ generateMarkdown report
```

---

## 📚 Types & API

### Types

```purescript
data Severity = Pass | Warning | Error

type Issue =
  { id :: String
  , category :: String
  , severity :: String
  , title :: String
  , message :: String
  , recommendation :: String
  }

type Score =
  { overall :: Int
  , grade :: String
  }

type Stats =
  { total :: Int
  , passed :: Int
  , warnings :: Int
  , errors :: Int
  }

type Report =
  { success :: Boolean
  , url :: String
  , timestamp :: String
  , score :: Score
  , stats :: Stats
  , issues :: Array Issue
  }
```

### Functions

```purescript
-- | Audit raw HTML string against technical on-page SEO standards
auditHtml :: String -> String -> Report

-- | Format severity constructor as an uppercase string
formatSeverity :: Severity -> String

-- | Format audit scorecard report as a Markdown document
generateMarkdown :: Report -> String
```

---

## 🌐 Pursuit & Registry Submission

To publish and index documentation on **Pursuit** (`https://pursuit.purescript.org/`):

1. **PureScript Registry**:
   The package is registered through the official [purescript/registry](https://github.com/purescript/registry).
   Publish using Spago:
   ```bash
   spago publish
   ```
2. **Pursuit Documentation**:
   Once registered, Pursuit automatically indexes packages and generates searchable type signature documentation at:
   `https://pursuit.purescript.org/packages/purescript-seowebchecker`

---

## 📄 License

MIT &copy; [SEOWebChecker](https://seowebchecker.com/).
