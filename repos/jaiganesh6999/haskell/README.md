# seowebchecker (Haskell)

[![Official Website](https://img.shields.io/badge/Website-seowebchecker.com-blue?style=flat-square)](https://seowebchecker.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Hackage](https://img.shields.io/hackage/v/seowebchecker.svg?color=purple)](https://hackage.haskell.org/package/seowebchecker)

Lightweight, pure Haskell client library and utility suite for automated website technical SEO audits, meta tag validations, heading structure inspections, image accessibility analysis, and Core Web Vitals checks. Developed by the [SEOWebChecker](https://seowebchecker.com/) engineering team.

Online audits, live visual scoring, and comprehensive downloadable reports are available at **[https://seowebchecker.com/](https://seowebchecker.com/)**.

---

## ⚡ Features

- **Zero Heavy Dependencies**: Implemented in pure Haskell using only `base`.
- **Comprehensive On-Page Audits**:
  - Title tag presence and length optimization (30–60 characters).
  - Meta description inspection (50–160 characters).
  - Mobile viewport tag verification.
  - Canonical link tag detection.
  - Primary single `<h1>` tag integrity.
  - Missing image `alt` attributes.
  - OpenGraph social sharing preview tags (`og:title`).
- **Standardized Scoring**: Produces an actionable 0–100 score and letter grade (A through F).

---

## 📦 Installation

Add `seowebchecker` to your `.cabal` file:

```cabal
build-depends:
    base >= 4.12 && < 5,
    seowebchecker ^>= 1.0.0
```

Or install directly with `cabal`:

```bash
cabal install seowebchecker
```

---

## 🚀 Quickstart

```haskell
module Main where

import Network.SEO.WebChecker

sampleHtml :: String
sampleHtml =
    "<!DOCTYPE html><html><head>" ++
    "<title>SEOWebChecker: Free SEO Audit & Analysis Tools</title>" ++
    "<meta name='description' content='Audit your website for comprehensive SEO scoring.'>" ++
    "<meta name='viewport' content='width=device-width, initial-scale=1.0'>" ++
    "<link rel='canonical' href='https://seowebchecker.com/'>" ++
    "<meta property='og:title' content='SEOWebChecker SEO Audit'>" ++
    "</head><body>" ++
    "<h1>Comprehensive SEO Audit Tools</h1>" ++
    "<img src='banner.jpg' alt='Dashboard preview'>" ++
    "</body></html>"

main :: IO ()
main = do
    let result = auditHtml "https://seowebchecker.com/" sampleHtml
    putStrLn $ "URL: " ++ resultUrl result
    putStrLn $ "Score: " ++ show (scoreOverall (resultScore result)) ++ " / 100"
    putStrLn $ "Grade: " ++ scoreGrade (resultScore result)
    putStrLn $ "Passed Checks: " ++ show (resultPassedChecks result) ++ " / " ++ show (resultTotalChecks result)
    mapM_ printIssue (resultIssues result)
  where
    printIssue issue =
        putStrLn $ "[" ++ show (issueSeverity issue) ++ "] " ++ issueTitle issue ++ ": " ++ issueMessage issue
```

---

## 🔗 Related Resources

- **Official Web Portal**: [https://seowebchecker.com/](https://seowebchecker.com/)
- **GitHub Repository**: [https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk](https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk)
- **Hackage Package**: [https://hackage.haskell.org/package/seowebchecker](https://hackage.haskell.org/package/seowebchecker)

---

## 📄 License

MIT License © 2026 [SEOWebChecker](https://seowebchecker.com/).
